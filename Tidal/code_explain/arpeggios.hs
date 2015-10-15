In 12 tone equal temperament, which is today the most common representation of musical pitch, a major chord is [0,4,7]. Since a note sounds the same as the note 12 steps higher, the major chord can be thought of as repeating:
    [ 0,   4,  7
    , 12, 16, 19      -- the same chord, an octave higher
    , 24, 28, 31 ..]  -- the same chord, two octaves higher ...

Hence you'd like a function something like
  arpeggio :: [Double] -> Int -> Double
such that, for instance,
  fmap (arpeggio [0,3,7]) [-1,0,1,3,6] == [-5,0,3,12,24]


