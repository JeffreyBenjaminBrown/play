-- CREDIT|SETUP discussed here. Thank you Mr. Gold! http://lurk.org/groups/tidal/messages/topic/123JqmA0MsCFrOUb9zOfzc/

-- TO LEARN
  -- preplace

-- TO PROG
  -- ## infixl
  -- modes: flip argument order
  -- more instruments ? request|invite
  -- move tests to separate file
  -- just intonation

-- imports (remember, they must come first)
  -- general
    import Data.List
    import Data.Maybe
    import Control.Applicative
    import Data.String
    import Data.Ratio

  -- Tidal    
    import Sound.Tidal.Params
    import Sound.Tidal.Parse
    import Sound.Tidal.Pattern
    import Sound.Tidal.Strategies
    import Sound.Tidal.Stream
    import Sound.Tidal.Stream
    import Sound.Tidal.SuperCollider
    import Sound.Tidal.Tempo
    import Sound.Tidal.Time
    import Sound.Tidal.Transition
    import Sound.Tidal.Utils

-- minor dollars
  -- first, deprecated
    infixr 3 $. -- binds before |+|, after <$> and <*>
    ($.) :: (a -> b) -> a -> b
    f $. x = f x

    infixr 5 $.. -- binds even after <$> and <*>
    ($..) :: (a -> b) -> a -> b
    ($..) = ($)

  -- it is () and , at once
    infixr 5 #.
    (#.) :: (a -> b) -> a -> b
    (#.) = ($)

    infixl 3 ##
    (##) :: (a -> b) -> a -> b
    (##) = ($)

    infixr 0 ### -- = is ($) but stands out more
    (###) :: (a -> b) -> a -> b
    (###) = ($)

    -- group more spaces between ) and (, let each be a separate grammar within

-- synonyms and near-synonyms
    -- dur: broken, defining by hand (from init.tidal)
      -- Did this ever work from a .hs file?
      -- dur :: Double -> IO ()
      -- dur = cps . (\x -> 1 / x)

    fast = density
    cyc = slowspread

-- pitch
  -- hi, spd (speed)
    -- this is a 31et version of up
    hi = speed . ((step**) <$>) where step = 2**(1/31)
    hi_ob transp = speed . ((step**) . (+ transp) <$>) 
      where step = 2**(1/31) 
      --obsoleted by |*|, but used in early portion of music.tidal

    sp  = speed . return 
    sps = speed . stack . fmap return

  -- scale functions
    remPos num den = if x<0 then x+den else x where x = rem num den
      -- fmap (flip remPos 3) [-5..5] -- positive remainder, test

    -- scaleElt :: [Double] -> Int -> Double
    scaleElt scale n = fromIntegral .(scale !!) $ fromIntegral $ remPos n (fromIntegral $ length scale) 
    -- fmap (scaleElt [0,3,7]) [-5..5] -- test
    
    -- scaleOctave :: [Double] -> Int -> Double -- type sig breaks it
    scaleOctave scale n = (31 *) . fromIntegral . floor . ((fromIntegral n) /) $ fromIntegral $ length scale  
      -- fmap (scaleOctave s) [-1..1] --test
      -- fmap (scaleOctave s) [-5..5] --test
    scaleOctave12 scale n = (12 *) . fromIntegral . floor . ((fromIntegral n) /) $ fromIntegral $ length scale  

    sc s n = scaleOctave s n + scaleElt s n -- Tidal."scale" already = stretch
      -- scale s 1              -- test
      -- fmap (scale s) [-1..1] -- test
    sc12 s n = scaleOctave12 s n + scaleElt s n

  -- scale data
    -- 31et harmonics: 10 (5/4), 14 (11/8), 18 (3/2), 22 (13/8), 25 (7/4)
    sDia = [ 0, 5, 10, 13, 18, 23, 28] :: [Double]
    sMel = [ 0, 5, 10, 15, 20, 23, 28] :: [Double]
    sHar = [ 0, 5, 10, 13, 20, 23, 28] :: [Double]
    sAnt = [ 0, 5, 10, 13, 18, 21, 28] :: [Double]

  -- voices, inc. pitch corrections ("Corr") tuning (units of octave/31) to jvbass
    insBass = sound "bass" |*| hi "-2"
    -- IS NEW WAY. Other instruments are defined with more complexity.
    -- bassCorr = (-2) -- bass correction, to harmonize jvbass
      -- to prove that correction
      -- d1 $ sound "bass*4" |+| up "1.82"
      -- d2 $ (1/8) <~ sound "jvbass*4"

    insPsr = sound "psr" |*| hi ## psrCorr <$> "0"
    psrCorr = (+2.5) -- psr correction, to harmonize jvbass
      -- to prove that correction
      -- d1 $ sound "psr*4" |+| up "1.82"
      -- d2 $ (1/8) <~ sound "jvbass*4"

    insF = sound "f" |*| gain "0.75" |*| cutoff "0.15" |*| resonance "0.9" |*| hi ## fCorr <$> "-31"
    fCorr = (+ 7.0)
      -- fcorr = (+ 7)
      -- d1 $ sound "jvbass*3" |+| pit 0 "0"
      -- d2 $ sound "f" |+| gain "0.7" |+| pit (fcorr 0) "0"

    insSine = sound "sine" |*| hi ## sineCorr <$> "0" |*| gain "0.9"
    sineCorr = (+ 3.7)

  -- modes
    rotl :: Int -> [a] -> [a] -- rotate left
    rotl n xs = take (length xs) . drop n . cycle $ xs

    md tones rotn = toFirstOctaveIfJustUnder  -- maybe flip order 
      . (relToRotatedTones rotn tones) <$> shift
      where relToRotatedTones rotn tones x = x - (shift !! 0)
            toFirstOctaveIfJustUnder x = if x < 0 then x + 31 else x
            shift = rotl rotn tones

    md12 tones rotn = toFirstOctaveIfJustUnder  -- maybe flip order 
      . (relToRotatedTones rotn tones) <$> shift 
      where relToRotatedTones rotn tones x = x - (shift !! 0)
            toFirstOctaveIfJustUnder x = if x < 0 then x + 12 else x
            shift = rotl rotn tones

-- time (DUPLICATE; main at Tidal_7/Sound/Tidal/JBB.hs) 
    ceiling_ish :: Arc -> Time
      -- in a cycle-respecting Arc (a,b), b < floor a + 1
    ceiling_ish (a,b) = fromInteger $ floor a + 1
    
    splitArcAtIntegers :: Arc -> [Arc]
    splitArcAtIntegers (a,b) = let c = ceiling_ish (a,b)
      in if      b <= a then []    
         else if b <= c then [(a,b)]
         else (a,c) : splitArcAtIntegers (c,b)  
    
    arcOverlaps :: Arc -> Event a -> Bool
    arcOverlaps (s,e) ((a,b),_,evt) = a <= s && b > s ||  a < e && b >= e
    
    firstUnitIntersection :: [Event a] -> Arc -> [Event a] -- warning: expects
      -- (s,e) in the unit interval
    firstUnitIntersection evts (s,e) = filter (arcOverlaps (s,e)) evts
    
    anyUnitIntersection :: [Event a] -> Arc -> [Event a] -- warning: expects 
      -- e <= floor s + 1
    anyUnitIntersection evts (s,e) = let f = fromInteger $ floor s in
      map (\((a,b),(c,d),e) -> ((a+f,b+f),(c+f,d+f),e)) 
      $ firstUnitIntersection evts (s-f,e-f)
    
    evtListToPatt :: [Event a] -> Pattern a
    evtListToPatt evts = Pattern $ \(s,e) -> concat 
      $ map (\(s',e') -> anyUnitIntersection evts (s',e'))
      $ splitArcAtIntegers (s,e)
      -- it works!
        -- > let x = [((0,1),(0,1),"bd")] :: [Event String]
        -- > (arc $ evtListToPatt x) (1/2,3/2)
        -- [((0 % 1,1 % 1),(0 % 1,1 % 1),"bd"),
        --  ((1 % 1,2 % 1),(1 % 1,2 % 1),"bd")]
  
--

