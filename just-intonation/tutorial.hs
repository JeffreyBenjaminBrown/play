-- Harmony is about ratios.
    import Data.Ratio

  -- This code also relies on
    -- the "sy" synth defined at "git_play/tidal/synths sy, sya.scd.hs"
    -- the "qf" parameter defined at "git_play/tidal/init.hs"

-- Octaves
  -- For some reason, frequencies that differ by a power of two sound similar
    d1 $ sound "sy" |*| qf 100 -- This plays the `sy` synthesizer at the frequency 100 Hz. (`qf` stands for "the quality of frequency".)
      -- TODO: qf ->rename freq
    d1 $ sound "sy" |*| qf [100,200] -- This plays two `sy` synths, one at each frequency
    d1 $ sound "sy" |*| qf [100,200,400] -- Three frequencies
    d1 $ sound "sy" |*| qf 400 -- Just the highest frequency

  -- We call 100, 200, 400, 800, etc. the "same frequency", "modulo octave".
    -- "Modulo" means "ignoring", roughly.

-- The ratio 2/3
  -- You might hear this ratio called a "fifth" or a "power chord".
  -- Next to the octave, the ratio 2/3 is as close as two frequencies come to
  -- being the same frequency -- a quality harmony theorists call "simplicity".
    d1 $ sound "sy" |*| qf [200,300]
    d1 $ sound "sy" |*| qf [250,375]
    d1 $ sound "sy" |*| qf [300,450]

-- Separating root from ratio
  -- Computing (3/2)*F in your head can be difficult for certain values of F.
  -- Separating root from ratio lets you sidestep that math:
    d1 $ sound "sy" |*| qf 300 |*| qf "[2,3]"
    d1 $ sound "sy" |*| qf 300 |*| qf "[1,1.5]"
    d1 $ sound "sy" |*| qf 450 |*| qf "[1,0.666]" -- TODO: use a ratio
  -- We can do that because when |*| comes between two `qf` expressions,
  -- it multiplies their values: 300 * [2,3] = [600,900], etc.

-- 4/3 is the inverse of 3/2
  -- Here is another power chord:
    d1 $ sound "sy" |*| qf [200,300]
  -- Recall that 200 and 400 are the same note, except 400 is an octave higher.
  -- Therefore this sounds similar:
    d1 $ sound "sy" |*| qf [400,300]
  -- We call 3/2 and 4/3 "inverses".
    -- In math, 3/2 and 2/3 are inverses: 3/2 * 2/3 = 1.
    -- But in music, 2/3 is the same as 4/3, except an octave higher,
    -- which allows 3/2 and 4/3 to also be inverses.
    -- In general, if A * B is a power of two, then A and B are inverses.
    -- You can think of A as taking you from 1 to A,
    -- and B as taking you the rest of the way across the octave, from A to 2.
  -- On a piano keyboared,
    -- 3/2 is approximated by 7 semitones, for instance from C to the G above
    -- 4/3 is approximated by 5 semitones, for instance from G to the C above
  -- 3/2 and 4/3 sound so similar that guitarists commonly call them both "power chords"

-- The ratios 5/4 and 6/5
  -- We covered 2/1, 3/2, and 4/3. Two more simple ratios are 5/4 and 6/5:
    d1 $ sound "sy" |*| qf 100 |*| qf "[4,5]" -- 5/4, the "major third"
    d1 $ sound "sy" |*| qf 100 |*| qf "[5,6]" -- 6/5, the "minor third"
  -- Notice that 5/4 * 6/5 = 6/4 = 3/2.
    -- If a major third takes you part of the way from 1 to 3/2,
    -- then a minor third takes you the rest of the way.
  -- On a piano keyboard,
    -- 4/5 is approximated by 4 halfsteps, for instance from C to the E above.
    -- 5/6 is approximated by 3 halfsteps, for instance from E to the G above.

  -- A "major chord" contains three notes, in the ratio [4,5,6]:
    d1 $ sound "sy" |*| qf 100 |*| qf "[4,5,6]"
    -- Some people prefer to write all frequencies relative to the root note.
    d1 $ sound "sy" |*| qf 400 |*| qf "[1,1.25,1.5]" -- TODO: ratios, not decimal
    -- Notice the equation: [4,5,6] / 4 = [1,5/4,3/2] = [1,1.25,1.5]
    -- We don't have to write it relative to the root (the 4 in [4,5,6]).
    -- We could write it relative to the middle note [the 5 in [4,5,6]]:
      -- [4,5,6] / 5 = [4/5,1,6/5]
    -- But for some reason the 4 in [4,5,6] sounds like the center, so it's useful to normalize to the 4.

  -- A "minor chord" contains three notes, in the ratio [10,12,15]:
    d1 $ sound "sy" |*| qf 50 |*| qf "[10,12,15]
    -- Equivalently, relative to the root: [10,12,15]/10 = [1,6/5,3/2] = [1,1.2,1.5]
    d1 $ sound "sy" |*| qf 500 |*| qf "[1,1.2,1.5]" -- TODO: ratios, not decimal

-- Computing pitch equivalencies
  -- Converting JI to 12-ET
    -- Using just intonation, there are an infinite number of ratios.
    -- Historically, we decided some ratios especially useful in music.
    -- Then we discovered we could approximate those ratios by dividing the octave into 12 equal pieces.
    -- This radically reduced the complexity of music: There were now only 12 intervals to think about!
  -- Here's a function to convert a just ratio to 12-ET:
    let et12 r = 12 * log r / log 2
    -- Let's find the 12-ET approximation to the ratio 3/2:
    et12 $ 3/2
    -- It's pretty close!

  -- Octave-normalization
    -- Octaves sound the same, and low numbers are easier to think about.
    -- Therefore we like to rewrite ratios so they fall in [1,2]:
      -- 11/3 can be divided by 2, to become 11/6, which is between 1 and 2.
      -- 5/11 can be multiplied by 4, to become 20/11, which is between 1 and 2.
    -- Here's some code to do that. (In the next section we'll use it.)
    let normz r = if r >= 2 then normz $ r/2
                 else if r < 1 then normz $ r*2
                 else r

-- Diatonic scales
  -- On a piano,
    -- 3 major chords configured the right way makes a major scale.
    -- For instance, C E G + F A C + G B D = C D E F G A B

  -- In Just Intonation,
    -- 3 major chords, configured [1,4/3,3/2] relative to each other, produce a major (or "ionian") scale:
    d1 $ sound "sy" |*| qf 100 |*| qf "[4,5,6]" |*| qf "[1,1.333,1.5]
    -- Here's one way to find the notes in that scale:
    let major = sort $ nub $ map normz $ [x*y | x <- [1,5%4,3%2], y <- [1,3%2,4%3]]
    -- Divide by the second member of that list to get a "dorian" scale:
    sort $ map normz $ map (/ (9%8)) major

  -- 3 minor chords in the same configuration produces a minor ("aeolian") scale:
    d1 $ sound "sy" |*| qf 100 |*| qf "[10,12,15]" |*| qf "[1,1.333,1.5]

-- These might also be interesting:
  -- all the just ratios on [2..32]
  -- mapM_ print $ map (\x->(x,et12 $ fromRational x)) $ nub $ map normz $ (%)<$>[2..32]<*>[2..32]
  
  -- print the first 16 ratios relative to a root (in this case, 11):
  -- let root = 11 in mapM_ print $ map ((\x->(x,et12 $ normz $ fromRational x)) . (%root)) [1 .. 16]
  
  -- show the first (x+1)/x values in et12
  -- mapM_ print $ map (\x -> (x,et12 $ fromRational $ normz x)) $ map (\x->(x+1)%x) [1..16]
