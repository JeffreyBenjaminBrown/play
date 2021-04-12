-- Finds all pairs of ratios that are close.

-- USAGE: Define the three things listed under "define these",
-- and then evaluate `printList close` in GHCI.
-- It will print triplets (a,b,c) where a and b are ratios,
-- and c is the distance in cents between them.

-- To test an odd limit:
-- Define the parameter `disallowed_integers`.
-- For instance, to test the 7-odd-limit, you would define integer-limit
-- to be 14, and then include 11 and 13 in disallowed_integers,
-- since ratios in the 7-odd-limit cannot include primes 11 or 13.
-- PITFALL: This code is not clever enough to compute multiples of the
-- primes you want to omit. If your integer limit is, say, 40,
-- but you want to exclude prime 13, you'll need to include not just 13,
-- but also 26 and 39, in `disallowed_integers`.

import Data.Ratio
import qualified Data.Set as S


-- define these
integer_limit = 29
disallowed_integers = [17,19,23]
max_proximity_in_cents = 10

cents :: Rational -> Double
cents ratio =
  1200 * log (fromRational ratio) / log 2

unique :: Ord a => [a] -> [a]
unique = S.toList . S.fromList

ratios :: [Rational]
ratios = unique
  [ a%b
  | a <- [1..integer_limit],
    b <- [1..integer_limit],
    not $ elem a disallowed_integers,
    not $ elem b disallowed_integers,
    a > b+1 ]

close :: [(Rational, Rational, Double)]
close = [ (r, s, cents $ r/s)
        | r <- ratios,
          s <- ratios,
          r > s,
          ( abs $ cents $ r/s ) < max_proximity_in_cents ]

printList :: Show a => [a] -> IO ()
printList = mapM_ $ putStrLn . show
