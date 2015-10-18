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

  mode tones n = g . f <$> shift where
    shift = rotl n tones
    root = shift !! 0
    f x = x - root
    g x = if x < 0 then x + 31 else x

  -- copy, fewer terms
  md tones rotn = toFirstOctaveIfJustUnder . (relToRotatedTones n tones) <$> shift where
    relToRotatedTones rotn tones x = x - ((rotl n tones) !! 0)
    toFirstOctaveIfJustUnder x = if x < 0 then x + 31 else x


