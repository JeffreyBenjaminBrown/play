
    cps 0.1
    let ionian = [0,2,4,5,7,9,11]
    let runUpTwoOctaves = run $ 2 * length ionian
    let runUpAndDown = append runUpTwoOctaves $ (+1) <$> rev runUpTwoOctaves

    d1 $ (up $ sc ionian <$> runUpAndDown) |+| sound "psr"

It relies on this function:
  
    sc s n = scaleOctave s n + scaleElt s n

which relies on these thre functions:
  
    remPos num den = if x<0 then x+den else x 
      where x = rem num den
    
    scaleElt scale n = fromIntegral . (scale !!)
      $ fromIntegral $ remPos n (fromIntegral $ length scale) 
    
    scaleOctave scale n = (12 *) . fromIntegral . floor 
      . ((fromIntegral n) /) $ fromIntegral $ length scale  
  
If you add a couple more functions:

    rotl :: Int -> [a] -> [a] -- rotate left
    rotl n xs = take (length xs) . drop n . cycle $ xs

    md tones rotn = toFirstOctaveIfJustUnder  -- maybe flip order 
      . (relToRotatedTones rotn tones) <$> shift 
      where relToRotatedTones rotn tones x = x - (shift !! 0)
            toFirstOctaveIfJustUnder x = if x < 0 then x + 31 else x
            shift = rotl rotn tones

then you can compute a scale's modes:

    let dorian = mode ionian 2
    let phrygian = mode ionian 3
