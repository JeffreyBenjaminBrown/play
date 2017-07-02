import Data.Maybe
import Control.Lens

data XO = X | O deriving (Show, Eq)
type Cell = Maybe XO
type Coord = Int
type Board = [Cell]

score :: XO -> Board -> Int
score x b | won x b = 1
          | full b = 0
          | otherwise = negate
                        $ minimum
                        $ map (score $ notXO x)
                        $ tryEverything (notXO x) b

tryEverything :: XO -> Board -> [Board]
tryEverything x b = map f $ openSpots b
  where f :: Int -> Board
        f spot = b & ix spot .~ (Just x)

openSpots :: [Maybe a] -> [Int]
openSpots list = map fst $ filter (isNothing . snd) $ zip [0..] list

full :: Board -> Bool
full = and . map (not . isNothing) 

won :: XO -> Board -> Bool
won x b = hasTwoInARow $ map f b
  where f Nothing = Nothing
        f (Just y) | y == x = Just y
                   | otherwise = Nothing

notXO :: XO -> XO
notXO X = O
notXO O = X

hasTwoInARow :: [Maybe a] -> Bool
hasTwoInARow list = or $ map pred x
  where x = zip list (Nothing : list)
        pred (Just _, Just _) = True
        pred _ = False
