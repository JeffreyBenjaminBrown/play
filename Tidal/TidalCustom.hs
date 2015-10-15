--  Setup discussed here. Thank you Mr. Gold! http://lurk.org/groups/tidal/messages/topic/123JqmA0MsCFrOUb9zOfzc/

-- imports
  import Data.List
  import Data.Maybe
  import Control.Applicative
  import Data.String
  
  import Data.Monoid
  import Data.Fixed
  import Data.Ratio
  import Debug.Trace
  import Data.Typeable
  import Data.Function
  import Music.Theory.Bjorklund
  
  import Sound.Tidal.Dirt
  import Sound.Tidal.Pattern
  import Sound.Tidal.Stream
  import Sound.Tidal.Strategies
  import Sound.Tidal.Tempo
  import Sound.Tidal.Time
  import Sound.Tidal.Utils
  import Data.Time (getCurrentTime, UTCTime, diffUTCTime)
  import Data.Time.Clock.POSIX
  import Control.Concurrent.MVar
  import Control.Monad.Trans (liftIO)

-- functions
  hi transpose = -- |+| hi 13 "0 10 18 10" = major chord, up a fourth
    speed . ((step**) . (+ transpose) <$>)
    where step = 2**(1/31) 
  up = speed . ((step**) <$>) where step = 2**(1/31)

  scal :: [Double] -> Int -> Double
  scal tones n
    | n < 0 = scal tones (n + len) - 31
    | n >= len = scal tones (n - len) + 31
    | otherwise = tones !! n
    where len = length tones

  sDia = [ 0, 5, 10, 13, 18, 23, 28] :: [Double]
  sMel = [ 0, 5, 10, 15, 20, 23, 28] :: [Double]
  sHar = [ 0, 5, 10, 13, 20, 23, 28] :: [Double]
  sAnt = [ 0, 5, 10, 13, 18, 21, 28] :: [Double]
  -- harmonics: 10 (5/4), 14 (11/8), 18 (3/2), 22 (13/8), 25 (7/4)

  rotl :: Int -> [a] -> [a]
  rotl n xs = take (length xs) . drop n . cycle $ xs

  mode tones n = g . f <$> shift where
    shift = rotl n tones
    root = shift !! 0
    f x = x - root
    g x = if x < 0 then x + 31 else x

  -- copy, fewer terms
  md tones rotn = toFirstOctaveIfJustUnder . (relToRotatedTones n tones) <$> shift where
    relToRotatedTones rotn tones x = x - ((rotl n tones) !! 0)
    toFirstOctaveIfJustUnder x = if x < 0 then x + 31 else x

-- aliases
  fast = density                             
  cyc = slowspread -- cycle through functions

-- tuning(in 31et) to jvbass
  psrc = (+1.82) -- psr correction, to harmonize jvbass
    -- to prove that correction
    -- d1 $ sound "psr*4" |+| up "1.82"
    -- d2 $ (1/8) <~ sound "jvbass*4"
  fcorr = (+ 7.0)
    -- let fcorr = (+ 7)
    -- d1 $ sound "jvbass*3" |+| pit 0 "0"
    -- d2 $ sound "f" |+| gain "0.7" |+| pit (fcorr 0) "0"

