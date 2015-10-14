import Data.List
import Data.Maybe
import Control.Monad.State
import Control.Monad.List
import Control.Monad.Writer
import Control.Monad.Trans.Maybe
import Control.Applicative -- If using old GHC, need this line.

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

emptyBoard' :: Board -- Equivalent to the previous.
emptyBoard' = Board $ replicate boardSize
              $ Row $ replicate boardSize
              $ Cell Nothing

nth :: Int -> [a] -> Maybe a -- nth 1 [1] = Nothing, nth 1 [1..3] = Just 2
nth n = listToMaybe . drop n

cell :: BoardCoord -> Board -> Either String Cell  -- pretty rad
  -- nth returns Nothing if a lookup fails
  -- The >>= applies nth x to inside the Maybe from the first nth call.
  -- If either call to nth fails, 
    -- then the >>= returns Nothing, so cell returns the Left.
  -- Otherwise cell returns the Right, holding the result of the >>=
cell (x, y) board = maybe -- TO EMUL
  (Left "Invalid board coordinate") 
  Right 
  $ nth y (rows board) -- rows returns [[Cell]], is not accessor.
    >>= nth x          -- nth returns Maybe.
                       -- x horiz, y vert 

emptyBoardCoords :: Board -> [BoardCoord]
emptyBoardCoords board = filter
  (maybe False (isNothing . mxo) . eitherToMaybe . flip cell board)
    -- mxo expects a Cell, cannot be applied to a Maybe Cell 
    -- That's okay, because maybe reaches inside the Maybe.
  boardCoords

boardCoords :: [BoardCoord]
boardCoords = let x = [0..boardSize - 1] in (,) <$> x <*> x

maybeRead :: Read a => String -> Maybe a
maybeRead s = case reads s of -- TO EMUL
  [(x, "")] -> Just x
  _ -> Nothing -- Finding multiple parses would trigger this case.

setList :: Int -> a -> [a] -> Maybe [a]
setList _ _ [] = Nothing
setList 0 x (y : ys) = Just $ x : ys
setList n x (y : ys) = (y :) <$> setList (n - 1) x ys

columns :: Board -> [[Cell]]
columns = transpose . rows

rows :: Board -> [[Cell]]
rows = map cells . rows'

setCell :: BoardCoord -> XO -> Board -> Either String Board -- TO EMUL
setCell (x, y) xo board = fromMaybe (Left "Invalid board coordinate") $ do
    -- oldRow, newRow are not type Row, rather type [Cell]
      -- because rows is not rows'
    oldRow <- nth y $ rows board
    newRow <- setList x (Cell $ Just xo) oldRow
    newRows <- setList y newRow $ rows board
    return $ Right $ Board $ map Row newRows

allAreSame :: (Eq a) => [a] -> Maybe a
allAreSame [] = Nothing
allAreSame [a] = Just a
allAreSame (x : xs @(y : _)) = if x == y then allAreSame xs else Nothing
  -- The @ is an "as-pattern".

diagonals :: Board -> [[Cell]] -- TO READ
diagonals = flip map [g, g . reverse] . flip ($) . rows where
    f (i, a) x = (i + 1, nth i x : a)
    g = catMaybes . snd . foldl f (0, [])

allCellGroups :: Board -> [[Cell]] -- TO READ
allCellGroups = flip concatMap [rows, columns, diagonals] . flip ($)

winner :: Board -> Maybe XO
winner = listToMaybe . mapMaybe mxo . mapMaybe allAreSame . allCellGroups
  -- mapMaybe f xs returns a list with only the non-Nothing values of f x.
  -- listToMaybe takes the first.
    -- If there were a row of Xs and another of Os, 
    -- the first listed in allCellGroups would be declared the winner.
    -- In ordinary gameplay, though, that should not happen.

countXOs :: XO -> Board -> Int
countXOs xo = length . filter (== Just xo) . map mxo . concat . rows

checkPlayersMove :: XO -> Board -> Either String ()
checkPlayersMove xo board = -- TO EMUL (the Right () part) 
  if countXOs xo board 
     == (countXOs (notXO xo) board - case xo of {X -> 0; O -> 1})
       -- X starts, so if equal number, is X's move
       -- whereas if |Y|=|X|-1, then is Y's move 
        -- where |p| means number of p-type pieces on the board
  then Right () -- Right indicates success; () b/c no other data needed.
  else Left $ "Not " ++ show xo ++ "'s turn"

checkNotWon :: Board -> Either String ()
checkNotWon board = maybe
  (Right ()) 
  (const $ Left "Game already won") 
  $ winner board

checkIsntOccupied :: BoardCoord -> Board -> Either String ()
checkIsntOccupied coord board = cell coord board >>= 
  maybe 
    (Right ()) 
    (const $ Left "Cell already occupied") 
  . mxo

aiMove :: XO -> Board -> Either String BoardCoord
aiMove xo board = maybe
  (Left "No moves available") 
  Right
  $ find (\coord -> isJust $ eitherToMaybe $ move coord xo board)
      -- Why is the previous line so much work? 
      -- Doesn't the AI just take the first available position?
      -- move (next function) checks three conditions. 
      -- Is checkNotWon the only one of those three that aiMove needs?
    $ emptyBoardCoords board

move :: BoardCoord -> XO -> Board -> Either String Board
move coord xo board = do
  checkNotWon board
  checkPlayersMove xo board
  checkIsntOccupied coord board
  setCell coord xo board

type MoveGetter = XO -> Board -> IO BoardCoord

playerMoveGetter :: MoveGetter -- ? EMUL
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
aiMoveGetter xo board = 
  return $ fromMaybe (0,0) $ eitherToMaybe $ aiMove xo board
  -- Magic number? Why (0,0)?

consoleGame :: MoveGetter -> MoveGetter -> StateT (XO, Board) IO ()
  -- TO EMUL
  -- TODO: understand last arg of type sig
consoleGame moveGetterA moveGetterB = do
  -- Lifts are, I think, from (IO _) to MonadTrans IO BoardCoord,
    -- based on what GHCI tells me.
    -- Is MonadTrans different from StateT?
  (xo, board) <- get
  case winner board of
    Just xo -> do
      lift $ putStrLn $ show xo ++ " wins!"
      lift $ print board
    Nothing -> do
      moveCoord <- lift $ moveGetterA xo board
        -- moveGetter returns IO BoardCoord
        -- lift returns MonadTrans IO BoardCoord
        -- (<-) then (executes the IO and?) unwraps the BoardCoord 
      case move moveCoord xo board of
        Left s -> do
          lift $ putStrLn s
          consoleGame moveGetterA moveGetterB -- try again
        Right newBoard -> do
          put (notXO xo, newBoard)
          lift $ putStrLn ""
          consoleGame moveGetterB moveGetterA -- next player, swap getters

main = void $ runStateT -- TO EMUL
  -- void prevents the finished game from returning its state.
  (consoleGame playerMoveGetter aiMoveGetter) 
  (X, emptyBoard)

