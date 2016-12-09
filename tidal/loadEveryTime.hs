-- SETUP discussed here. Thank you Ben Gold! 
  -- http://lurk.org/groups/tidal/messages/topic/123JqmA0MsCFrOUb9zOfzc/
    {-# LANGUAGE FlexibleContexts #-}
    {-# LANGUAGE ViewPatterns #-}
    module Tidal_JBB where

-- imports (remember, they must come first)
  -- general
    import qualified Data.List as List
    import qualified Data.Map as M
    import Data.Maybe
    import Control.Applicative
    import Data.String
    import Data.Ratio

    import Test.HUnit
    import qualified Data.Graph.Inductive as L

    import Data.Random
    import Data.Random.Source.DevRandom

    import Data.Fixed (mod',div')

  -- Tidal    
    import Sound.Tidal.Params
    import Sound.Tidal.Parse
    import Sound.Tidal.Pattern
    import Sound.Tidal.Strategies
    import Sound.Tidal.Stream
    import Sound.Tidal.SuperCollider
    import Sound.Tidal.Tempo
    import Sound.Tidal.Time
    import Sound.Tidal.Transition
    import Sound.Tidal.Utils

-- promote here the old useful
    type PS = Pattern String
    type PD = Pattern Double
    type PI = Pattern Int

    duty phase duty wavelen = when (\n -> mod (n - phase) wavelen < duty)
    to1to2 x = x / 2**(fromIntegral $ floor $ log x / log 2) -- for normalizing a just scale with numbers outside of [1,2). For fixed real number r and any integer k, to1to2 $ r*2**k has the same value.

    -- abbrevs
    -- @init.hs: h hush, sa striate
    fl = floor
    (fi,fr,tr) = (fromIntegral,fromRational,toRational)
    si = silence
    rl = (<~)
    rr = (~>)
    pp = preplace (1,1)
    (fa,sl) = (fast,slow)
    (sp,sd,ga,co,ch,cr)=(speed,sound,gain,coarse,chop,crush)
    (d,dt,df) = (delay,delaytime,delayfeedback)
    rd = rand
    (st,ap,sr,ssr) = (stack,append,spread,slowspread)
    (ev,du) = (every,duty)
    lin min max x = x*(max - min) + min
    st' fracs = stack $ map pure fracs
    ca' fracs = cat $ map pure fracs

    zipNoTuple :: [a] -> [a] -> [a]
    zipNoTuple xs     []     = xs
    zipNoTuple []     ys     = ys
    zipNoTuple (x:xs) (y:ys) = x : y : zipNoTuple xs ys

  -- scales
    remUnif :: Integral a => a -> a -> a
    remUnif num den = -- positive remainder
      if x<0 then x+den else x where x = rem num den
      -- fmap (flip remUnif 3) [-5..5] -- test
      -- ifdo speed: could use one divide instead of many adds

    quotUnif :: Integral a => a -> a -> a
    quotUnif num den = if num < 0 then q - 1 else q
      where q = quot num den

    lk12 :: [Double] -> Int -> Double -- 12 tone scale lookup
    lk12 sc idx =
      let len = length sc
          idx' = floor $ fromIntegral $ remUnif idx len
          octaves = quotUnif idx len
      in (12 * fromIntegral octaves) + (sc !! idx')

    lkji :: [Double] -> Int -> Double -- (scale) lookup, just inton
    lkji sc idx =
      let len = length sc
          idx' = floor $ fromIntegral $ remUnif idx len
          octaves = quotUnif idx len
      in (2 ** fromIntegral octaves) * (sc !! idx')

    denSca denom = map (flip (/) denom) [denom..denom*2-1] -- **
      -- one-octave JI scale defined by a denominator

    runDegPat :: ([Double] -> Int -> Double) -- e.g. lk12, lkji
      -> (Int -> [Double]) -- probably a map lookup
      -> Pattern Int -- args for the (probably a)map lookup
      -> Pattern Int -- scale degrees, i.e. indices into a [Double]
      -> Pattern Double
    runDegPat temperedLookup scaleFromInt scalePat degreePat = unwrap
      $ fmap (fmap . temperedLookup . scaleFromInt) scalePat 
        <*> pure degreePat

  -- transition between two patterns
    -- based on playWhen, which transitions from silence to one pattern
    changeWhen :: (Time -> Bool) -> Pattern a -> Pattern a -> Pattern a
    changeWhen test (Pattern before) (Pattern after) =  
      stack [b,a] where
      b = Pattern $ (filter $ \e -> not $ test $ eventOnset e) . before
      a = Pattern $ (filter $ \e ->       test $ eventOnset e) . after

-- ==================
-- == Experimental ==
-- ==================
    reps n fracs = concat $ map (\a -> take n $ repeat a) fracs
      -- reps  3 [1,2] = [1,1,1,2,2,2]

  -- rhythm factory
    f              len      p1 n1 seps1   p2 n2 seps2 -- was "f"
      = cat $ take len $ _f p1 n1 seps1   p2 n2 seps2

    _f p1 n1 seps1   p2 n2 seps2 = 
       let sep = flip replicate si;
           g seps = concatMap (\e -> e:sep seps);
           s1 = g seps1 $ replicate n1 p1; 
           s2 = g seps2 $ replicate n2 p2;
       in concat $ repeat $ s1 ++ s2
       --  repeat $ concat $ s1 ++ s2

  -- Randomness (not \Tidal)
    x :: IO Float
    x = runRVar (uniform 1 5) DevRandom

    z :: IO ()
    z = do
      f <- (*10) <$> runRVar (uniform 1 2) DevRandom :: IO Double
      putStrLn $ show f
      return ()

-- ================== FGL ====================
    type When = Rational
    type Dur = Rational

    type Addr = L.Node
    type SdOrQualAddr = L.Node

    type G = L.Gr GN GE -- Graph, Node, Edge
    data SoundQual = Spl String | Spd Float | Amp Float
      deriving (Read, Show, Ord, Eq)
    data GE = Has | HasAt When | HasAtFor When Dur deriving (Read, Show, Ord, Eq)
    data GN = Q SoundQual | Sd | Seq --REM: add typenames if xtend
      deriving (Read, Show, Ord, Eq)

    -- fromSoundQuals :: G -> SdOrQualAddr -> ParamPattern

    trigList :: G -> Addr -> [(When,ParamPattern)]
    trigList g (L.lab g -> Nothing) = error "Node absent."
    trigList g a@(L.lab g -> Just Seq) =
      let contents = L.lsuc g a :: [(Addr,GE)] -- any kind?
      in map (\(a,HasAt t)->(t,hStar g a)) contents
    trigList g  _ = error "to do (finish hStar)"

    -- WARNING: inputs must all start at beat 0 and have no duration
      -- and all When values must be in [0,1] (or maybe only [0,1)]
    trigListToPatt' :: [(When, ParamPattern)] -> ParamPattern
    trigListToPatt' pairs = let f when patt = rl when patt
      in seqPLoop $ map (\(when,patt) -> (0,1,f when patt)) pairs

  -- seqPLoop. Thanks, Alex McLean!
    loopFirst p = splitQueries $ Pattern f where
      f a@(s,e) = mapSnds' plus $ mapFsts' plus $ arc p (minus a) where
        minus = mapArc (subtract (sam s))
        plus = mapArc (+ (sam s))
    outside n = inside (1/n)
    timeLoop n = outside n loopFirst

    seqPLoop :: [(Time, Time, Pattern a)] -> Pattern a
    -- WARNING: in a triple (a,b,p), speed of p is indep of a, b
    seqPLoop ps= timeLoop (maximum $ map (\(_,x,_) -> x) ps) $ seqP ps

  -- render to audio, text
    hStar :: G -> Addr -> ParamPattern
    hStar g (L.lab g -> Nothing) = error "Node absent."
    hStar g a@(L.lab g -> Just n) = let tp=trigListToPatt in case n of
      Q (Spl s) -> sound $ tp [(0,s)]
--      Seq -> let
--        contents = L.lsuc g a :: [(Addr,GE)]
--        triples =map (\(a,HasAt t)->(t,t+epsilon,hStar g a)) contents
--        in sd $ tp triples
      _ -> error "to do (finish hStar)"

    view :: G -> [Addr] -> IO ()
    view g as = let labs = catMaybes $ map (L.lab g) as
      in if length labs < length as
         then error "address not present in graph"
         else mapM_ (putStrLn . show) $ zip as labs

    addNodes :: [GN] -> G -> G
    addNodes ns g = g'
      where g' = L.insNodes (zip is ns) g
            is = L.newNodes (length ns) g

    addNodesRep :: [GN] -> G -> (G,[Addr]) -- also report addresses
    addNodesRep ns g = (g',is)
      where g' = L.insNodes (zip is ns) g
            is = L.newNodes (length ns) g

  -- stale
    isSplQual x = case x of Spl _ -> True; _ -> False
    isSpdQual x = case x of Spd _ -> True; _ -> False
    isAmpQual x = case x of Amp _ -> True; _ -> False

   -- fgl, data for tests
    g123 :: G
    g123 = L.mkGraph [ (1,Sd), (2,Seq), (3,Q $ Spl "ps")
                     , (4,Sd), (5,Seq), (6,Q $ Spl "cp"), (7,Q $ Spd 2)
                     ][
                       (1,3,Has) -- the Sound at 1 is the "ps" at 3
                     , (2,1,HasAt $ 1%2) -- the Event at 2 is the Sound at 1
                     , (4,6,Has), (4,7,Has) -- the Sound at 4 is the "sn" at 6,
                                            -- at double speed
                     , (5,4,HasAt 0), (5,1,HasAt $ 1%2) -- Event 5 has 2 sounds
                     ]


-- =============== old, little used ============

-- minor dollars
  -- first, deprecated
    infixr 3 $. -- binds before |+|, after <$> and <*>
    ($.) :: (a -> b) -> a -> b
    f $. x = f x

    infixr 5 $.. -- binds even before <$> and <*>
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
    fast = density
    cyc = slowspread

-- pitch
  -- hi, spd (speed)
    -- this is a 31et version of up

    -- to :: 31 tone pattern -> frequency pattern
    to :: (Floating b, Functor f) => f b -> f b
    to = ((oneMicrotone**) <$>) where oneMicrotone = 2**(1/31)

    hi = speed . ((step**) <$>) where step = 2**(1/31)
    hi_ob transp = speed . ((step**) . (+ transp) <$>) 
      where step = 2**(1/31) 
      --obsoleted by |*|, but used in early portion of music.tidal

    -- sp  = speed . return 
    -- sps = speed . stack . fmap return

  -- _. scale functions (obsolete, redundant ..
      -- but used in music/by_date.tidal)
    scaleElt :: (Num c, Integral a, Integral s) => [a] -> s -> c
    scaleElt scale n = fromIntegral .(scale !!) $ fromIntegral $ remUnif n (fromIntegral $ length scale) 
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

  -- voices, inc. pitch corrections ("Corr") tuning (units of octave/31) to jv
    pluckCorr = 7.87
    insPl = sound "pluck" |*| hi $. return pluckCorr

    offCorr = 13.4
    insOff = sound "off" |*| hi $. return offCorr  |*| gain "0.6"

    baCorr = -2
    insBa = sound "ba" |*| hi $. return baCorr
    -- IS NEW WAY. Other instruments are defined with more complexity.
    -- baCorr = (-2) -- ba correction, to harmonize jv
      -- to prove that correction
      -- d1 $ sound "ba*4" |+| up "1.82"
      -- d2 $ (1/8) <~ sound "jv*4"

    insPs = sound "ps" |*| hi ## psCorr <$> "0"
    psCorr = (+2.5) -- ps correction, to harmonize jv
      -- to prove that correction
      -- d1 $ sound "ps*4" |+| up "1.82"
      -- d2 $ (1/8) <~ sound "jv*4"

    insF = sound "f" |*| gain "0.75" |*| cutoff "0.15" |*| resonance "0.9" |*| hi ## fCorr <$> "-31"
    fCorr = (+ 7.0)
      -- fcorr = (+ 7)
      -- d1 $ sound "jv*3" |+| pit 0 "0"
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

-- time => trigListToPatt
    epsilon = 1/2^16 -- surely short enough to rarely cross cycles
      -- I have little reason to believe crossing cycles could cause bad things,
      -- but of even a 60-second cycle this would be only one thousandth.

    ceiling_ish :: Arc -> Time -- in a "cycle-respecting" Arc (a,b),
      -- b < floor a + 1 = ceiling_ish (a,b)
    ceiling_ish (a,b) = fromInteger $ floor a + 1

    splitArcAtIntegers :: Arc -> [Arc]
    splitArcAtIntegers (a,b) = let c = ceiling_ish (a,b) in
      if      b <= a then []    
      else if b <= c then [(a,b)]
      else (a,c) : splitArcAtIntegers (c,b)  

    arcOverlaps :: Arc -> Event a -> Bool
    arcOverlaps (s,e) ((a,b),_,evt) = a <= s && b > s ||  a < e && b >= e
      -- boundary conditions (< vs. <=) tricky

    firstUnitIntersection :: [Event a] -> Arc -> [Event a] -- warning: expects
      -- (s,e) in the unit interval
    firstUnitIntersection evts (s,e) = List.filter (arcOverlaps (s,e)) evts

    anyUnitIntersection :: [Event a] -> Arc -> [Event a] -- warning: expects 
      -- e <= floor s + 1
    anyUnitIntersection evts (s,e) = let f = fromInteger $ floor s in
      List.map (\((a,b),(c,d),e) -> ((a+f,b+f),(c+f,d+f),e)) 
      $ firstUnitIntersection evts (s-f,e-f)

    evtListToPatt :: [Event a] -> Pattern a
    evtListToPatt evts = Pattern $ \(s,e) -> concat 
      $ List.map (\(s',e') -> anyUnitIntersection evts (s',e'))
      $ splitArcAtIntegers (s,e)
      -- seems to work:
        -- > let x = [((0,1%2),(0,1%2),"bd"),((1%2,1),(1%2,1),"sn")] :: [Event String]
        -- > (arc $ evtListToPatt x) (1/2,3/2)
        -- [((1 % 2,1 % 1),(1 % 2,1 % 1),"sn"),((1 % 1,3 % 2),(1 % 1,3 % 2),"bd")]

    trigListToPatt :: [(When, a)] -> Pattern a
    trigListToPatt trigList = 
      let f time = (time, time + epsilon)
          evts = map (\(r,a) -> (f r,f r,a)) trigList
      in evtListToPatt evts
      -- demo: d1 $ sound $ trigListToPatt [(0,"bd"),(1/2,"sn")]
      -- trick: makes arcs miniscule (epsilon), ignore all but first time coordinate
