import Data.Maybe
import Control.Lens (ix, (.~), (&))

data XO = X | O deriving (Show, Eq)
type Cell = Maybe XO
type Coord = Int
type Board = [Cell]

score :: XO -> Board -> Int  -- the value to xo of moving the board to state b
score xo b | won xo b = 1
           | full b = 0
           | otherwise = negate
                         $ maximum
                         $ map (score opponent)
                         $ tryEverything opponent b
  where opponent = notXO xo

tweakList :: Int -> a -> [a] -> [a] -- change one element
tweakList position newMember original =
  original & ix position .~ newMember -- Lens magic, not critical

tryEverything :: XO -> Board -> [Board]
tryEverything xo b = map (\spot -> tweakList spot (Just xo) b) $ openSpots b

openSpots :: [Maybe a] -> [Int]
openSpots list = map fst $ filter (isNothing . snd) $ zip [0..] list

full :: Board -> Bool
full = and . map (not . isNothing) 

won :: XO -> Board -> Bool
won xo b = hasTwoInARow $ map f b
  where f Nothing = Nothing
        f (Just y) | y == xo = Just y
                   | otherwise = Nothing

hasTwoInARow :: [Maybe a] -> Bool
hasTwoInARow list = or $ map pred listWithLag
  where listWithLag = zip list (Nothing : list)
        pred (Just _, Just _) = True
        pred _ = False

notXO :: XO -> XO
notXO X = O
notXO O = X
