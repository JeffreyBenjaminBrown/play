import Data.List
import Data.Maybe
import Control.Applicative
import Control.Monad.State
import Control.Monad.List
import Control.Monad.Writer
import Control.Monad.Trans.Maybe

boardSize = 3

data XO = X | O deriving (Show, Eq)
newtype Cell = Cell { mxo :: Maybe XO } deriving (Eq)
newtype Row = Row { cells :: [Cell] }
newtype Board = Board { rows' :: [Row] }
type BoardCoord = (Int, Int)

instance Show Cell where
    show = maybe "_" show . mxo

instance Show Row where
    show = intercalate "  " . map show . cells

instance Show Board where
    show = intercalate "\n" . map show . rows'

eitherToMaybe :: Either a b -> Maybe b
eitherToMaybe (Left _) = Nothing
eitherToMaybe (Right x) = Just x

notXO :: XO -> XO
notXO X = O
notXO O = X

emptyBoard :: Board
emptyBoard = Board $ replicate boardSize emptyRow where
    emptyRow = Row $ replicate boardSize $ Cell Nothing

emptyBoardCoords :: Board -> [BoardCoord]
emptyBoardCoords board = filter (maybe False (isNothing . mxo) . eitherToMaybe . flip cell board) boardCoords

boardCoords :: [BoardCoord]
boardCoords = let x = [0..boardSize - 1] in (,) <$> x <*> x

nth :: Int -> [a] -> Maybe a
nth n = listToMaybe . drop n

maybeRead :: Read a => String -> Maybe a
maybeRead s = case reads s of
   [(x, "")] -> Just x
   _ -> Nothing

setList :: Int -> a -> [a] -> Maybe [a]
setList _ _ [] = Nothing
setList 0 x (y : ys) = Just $ x : ys
setList n x (y : ys) = (y :) <$> setList (n - 1) x ys

cell :: BoardCoord -> Board -> Either String Cell
cell (x, y) board = maybe (Left "Invalid board coordinate") Right $ nth y (rows board) >>= nth x

setCell :: BoardCoord -> XO -> Board -> Either String Board
setCell (x, y) xo board = fromMaybe (Left "Invalid board coordinate") $ do
    oldRow <- nth y $ rows board
    newRow <- setList x (Cell $ Just xo) oldRow
    newRows <- setList y newRow $ rows board
    return $ Right $ Board $ map Row newRows

allAreSame :: (Eq a) => [a] -> Maybe a
allAreSame [] = Nothing
allAreSame [a] = Just a
allAreSame (x : xs @(y : _)) = if x == y then allAreSame xs else Nothing

rows :: Board -> [[Cell]]
rows = map cells . rows'

columns :: Board -> [[Cell]]
columns = transpose . rows

diagonals :: Board -> [[Cell]]
diagonals = flip map [g, g . reverse] . flip ($) . rows where
    f (i, a) x = (i + 1, nth i x : a)
    g = catMaybes . snd . foldl f (0, [])

allCellGroups :: Board -> [[Cell]]
allCellGroups = flip concatMap [rows, columns, diagonals] . flip ($)

winner :: Board -> Maybe XO
winner = listToMaybe . mapMaybe mxo . mapMaybe allAreSame . allCellGroups

countXOs :: XO -> Board -> Int
countXOs xo = length . filter (== Just xo) . map mxo . concat . rows

checkPlayersMove :: XO -> Board -> Either String ()
checkPlayersMove xo board =
  if countXOs xo board == (countXOs (notXO xo) board
                           - case xo of {X -> 0; O -> 1})
    then Right ()
    else Left $ "Not " ++ show xo ++ "'s turn"

checkNotWon :: Board -> Either String ()
checkNotWon board = maybe (Right ())
  (const $ Left "Game already won") $ winner board

checkIsntOccupied :: BoardCoord -> Board -> Either String ()
checkIsntOccupied coord board =
    cell coord board >>= maybe 
        (Right ()) 
        (const $ Left "Cell already occupied") 
      . mxo

aiMove :: XO -> Board -> Either String BoardCoord
aiMove xo board = maybe 
  (Left "No moves available") 
  Right $ find 
    (\coord -> isJust $ eitherToMaybe $ move coord xo board) 
    $ emptyBoardCoords board

move :: BoardCoord -> XO -> Board -> Either String Board
move coord xo board = do
    checkNotWon board
    checkPlayersMove xo board
    checkIsntOccupied coord board
    setCell coord xo board

type MoveGetter = XO -> Board -> IO BoardCoord

playerMoveGetter :: MoveGetter
playerMoveGetter xo board = do
    putStrLn $ show xo ++ "'s move"
    print board
    line <- getLine
    let coord = maybeRead line
    case coord of
        Just coord' -> return coord'
        Nothing -> do
            putStrLn "Couldn't parse coord"
            playerMoveGetter xo board

aiMoveGetter :: MoveGetter
aiMoveGetter xo board = return $ fromMaybe (0,0)
  $ eitherToMaybe $ aiMove xo board

consoleGame :: MoveGetter -> MoveGetter -> StateT (XO, Board) IO ()
consoleGame moveGetterA moveGetterB = do
    (xo, board) <- get
    case winner board of
        Just xo -> do lift $ putStrLn $ show xo ++ " wins!"
                      lift $ print board
        Nothing -> do
            moveCoord <- lift $ moveGetterA xo board
            case move moveCoord xo board of
                Left s -> do
                    lift $ putStrLn s
                    consoleGame moveGetterA moveGetterB
                Right newBoard -> do
                    put (notXO xo, newBoard)
                    lift $ putStrLn ""
                    consoleGame moveGetterB moveGetterA

main = void $ runStateT
  (consoleGame playerMoveGetter aiMoveGetter) 
  (X, emptyBoard)

x = Cell $ Just X
o = Cell $ Just O
n = Cell $ Nothing
b = Board [Row [x,o,n], Row [o,x,n], Row [n,n,n] ]
