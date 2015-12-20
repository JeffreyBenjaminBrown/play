import System.Random
import Control.Monad (replicateM)

relv :: Int -> Int -> Int
relv tonic p = mod (p - tonic) 12

main = do
  v <- randomIO :: IO Int
  putStrLn $ "visualize as tonic: " ++ (show $ mod v 12)
  x <- replicateM 12 (randomIO :: IO Int)
  let y = map (flip mod 12) x
  putStrLn $ "----what are these? " ++ show y
  c <- getLine
  if c == "q"
    then return ()
    else do putStrLn $ "---- ---- they are: " ++  show (map (relv $ head y) y)
            putStrLn "\n"
            main
