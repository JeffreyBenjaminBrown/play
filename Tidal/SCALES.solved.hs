import Control.Applicative

s = [0,3,7]

remPos num den = if x < 0 then x + den else x 
  where x = rem num den                      
t1 = fmap (flip remPos 3) [-5..5]

fStep :: [Double] -> Int -> Double
fStep scale n = (scale !!) $ fromIntegral $ remPos n (fromIntegral $ length scale) 
t2 = fmap (fStep [0,3,7]) [-5..5]

fOct :: [Double] -> Int -> Double -- can't add type sig
fOct scale n = (12 *) . fromIntegral . floor . ((fromIntegral n) /) $ fromIntegral $ length scale  
t3 = fmap (fOct s) [-1..1]
t3' = fmap (fOct s) [-5..5]
 
scale s n = fOct s n + fStep s n 
t4 = scale s 1
t4' = fmap (scale s) [-1..1]
-- 
--

