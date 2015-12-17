import Numeric (showIntAtBase)

showUpTo12 :: Int -> Char
showUpTo12 i = head $ f i where
  f d | d < 0 = err
      | d < 10 = show d
      | d == 10 = "a"
      | d == 11 = "b"
      | otherwise = err
  err = error "showBase12 is only defined on [0,11]"

test = f "" where
  f = showIntAtBase 12 showUpTo12 $ round (pi*(12^10) :: Double)
