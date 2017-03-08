import Numeric (showIntAtBase)
import Data.Char (ord,chr)

showUpTo36 :: Int -> Char
showUpTo36 i | i < 0 = err
     | i < 10 = head $ show i
     | i < 36 = chr $ ord 'a' + i - 10
     | otherwise = err
  where err = error "s' is only defined on [0,36] (the digits + a through z)"

test12 = f "" where
  f = showIntAtBase 12 showUpTo36 $ round (pi*(12^10) :: Double)

test36 = f "" where
  f = showIntAtBase 36 showUpTo36 $ round (pi*(36^8) :: Double)
