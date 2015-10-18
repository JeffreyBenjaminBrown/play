--  Setup discussed here. Thank you Mr. Gold! http://lurk.org/groups/tidal/messages/topic/123JqmA0MsCFrOUb9zOfzc/

-- TODO: move tests to separate file

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

-- functions, not Tidal-specific
    rotl :: Int -> [a] -> [a] -- rotate left
    rotl n xs = take (length xs) . drop n . cycle $ xs

    infixr 3 $. -- binds before |+|, after <$> and <*>
    ($.) :: (a -> b) -> a -> b
    f $. x = f x

-- synonyms and near-synonyms
    -- dur :: Double -> IO () -- broken; define by had from init.tidal
    -- dur = cps . (\x -> 1 / x)

    fast = density
    cyc = slowspread

-- pitch
  -- 31et version of up
    hi = speed . ((step**) <$>) where step = 2**(1/31)
    hi_ob transp = speed . ((step**) . (+ transp) <$>) 
      where step = 2**(1/31) 
      --obsoleted by |*|, but used in early portion of music.tidal

  -- scale functions
    remPos num den = if x<0 then x+den else x where x = rem num den
      -- fmap (flip remPos 3) [-5..5] -- positive remainder (works)

    -- scaleElt :: [Double] -> Int -> Double
    scaleElt scale n = fromIntegral .(scale !!) $ fromIntegral $ remPos n (fromIntegral $ length scale) 
    -- fmap (scaleElt [0,3,7]) [-5..5] --test
    
    -- scaleOctave :: [Double] -> Int -> Double -- type sig breaks it
    scaleOctave scale n = (31 *) . fromIntegral . floor . ((fromIntegral n) /) $ fromIntegral $ length scale  
      -- fmap (scaleOctave s) [-1..1] --test
      -- fmap (scaleOctave s) [-5..5] --test

    sc s n = scaleOctave s n + scaleElt s n -- "scale" already = "stretch" 
      -- scale s 1
      -- fmap (scale s) [-1..1]

  -- scale data
    -- 31et harmonics: 10 (5/4), 14 (11/8), 18 (3/2), 22 (13/8), 25 (7/4)
    sDia = [ 0, 5, 10, 13, 18, 23, 28] :: [Double]
    sMel = [ 0, 5, 10, 15, 20, 23, 28] :: [Double]
    sHar = [ 0, 5, 10, 13, 20, 23, 28] :: [Double]
    sAnt = [ 0, 5, 10, 13, 18, 21, 28] :: [Double]

  -- tuning (in 31et) to jvbass
    psrCorr = (+1.82) -- psr correction, to harmonize jvbass
      -- to prove that correction
      -- d1 $ sound "psr*4" |+| up "1.82"
      -- d2 $ (1/8) <~ sound "jvbass*4"
    fCorr = (+ 7.0)
      -- fcorr = (+ 7)
      -- d1 $ sound "jvbass*3" |+| pit 0 "0"
      -- d2 $ sound "f" |+| gain "0.7" |+| pit (fcorr 0) "0"
--

