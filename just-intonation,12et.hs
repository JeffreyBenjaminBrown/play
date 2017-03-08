-- module Normalize where

import Data.Ratio

-- octave-normalize any value to be in [1,2)
normz r = if r >= 2 then normz $ r/2
          else if r < 1 then normz $ r*2
          else r
et12 r = 12 * log r / log 2

-- all the just ratios
-- mapM_ print $ map (\x->(x,et12 $ fromRational x)) $ nub $ map normz $ (%)<$>[2..32]<*>[2..32]

-- print the first 16 ratios relative to a root
-- let root = 11 in mapM_ print $ map ((\x->(x,et12 $ normz $ fromRational x)) . (%root)) [1 .. 16]

-- show the first (x+1)/x values in et12
-- mapM_ print $ map (\x -> (x,et12 $ fromRational $ normz x)) $ map (\x->(x+1)%x) [1..16]
