import System.IO
import Data.List.Split

numChars :: [Char]
numChars = map (head . show) [0..9] ++ ['a','b']

extract :: String -> String -> String
extract signature musicFile =
  filter (flip elem numChars)
  $ concatMap (drop $ length signature)  
  $ filter ((== signature) . take 3)  
  $ splitOn "\n" musicFile

digits :: String -> String
digits = filter (flip elem numChars)

test_e_and_pi = do
  f <- readFile "e_and_pi.txt"
  e <- readFile "e/digits.txt"
  pi <- readFile "pi/digits.txt"
  let f_e = extract "e |" f
      f_pi = extract "pi|" f
      e' = digits e
      pi' = digits pi
  putStrLn $ show (e'==f_e, pi'==f_pi)

test_root_2 = do
  musicFile <- readFile "root_2/music.txt"
  digitFile <- readFile "root_2/digits.txt"
  let m = digits $ extract "r2|" musicFile
      f = digits                 digitFile
  putStrLn m
  putStrLn f
  putStrLn $ show $ m==f
