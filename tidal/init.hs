-- SETUP discussed here. (Thanks, Ben!)
  -- http://lurk.org/groups/tidal/messages/topic/123JqmA0MsCFrOUb9zOfzc/
    {-# LANGUAGE FlexibleContexts #-}
    {-# LANGUAGE ViewPatterns #-}
    {-# LANGUAGE KindSignatures #-}
    {-# LANGUAGE RecordWildCards #-}
    module Tidal_JBB where

    import qualified Data.List as L
    import qualified Data.Map as M
    import Data.Maybe
    import Control.Applicative
    import Data.String
    import Data.Ratio
    import Data.Random
    import Data.Random.Source.DevRandom
    import Data.Fixed (mod',div')
    import Sound.Tidal.Context as T

    infixr 3 $. -- binds before |+|, after <$> and <*>
    ($.) :: (a -> b) -> a -> b
    f $. x = f x

---- ========== Tuning the samples to 100 Hz
    instPsr = sound "psr" |*| up 4 |*| speed (400/440)
    instBass = sound "bass" |*| up "0.4"

-- ========== Synonyms: short for my screen, long enough to understand
    fromi = fromIntegral
    jrand n = irand (n+1) - 1 -- ranges in [0,n] not [1,n]
    prob = sometimesBy -- probabilistic application
    euclid = e
    samp = s
    sampNum = n

    type PS = Pattern String
    type PD = Pattern Double
    type PI = Pattern Integer

    duty phase duty wavelen = when (\n -> mod (n - phase) wavelen < duty)
    si = silence
    rl = (<~)
    rr = (~>)
    pp = preplace (1,1)
    lin min max x = x*(max - min) + min
    st' fracs = stack $ map pure fracs
    ca' fracs = cat $ map pure fracs

-- ========== Pitch
    to1to2 x = x / 2**(fromIntegral $ floor $ log x / log 2) -- for normalizing a just scale with numbers outside of [1,2). For fixed real number r and any integer k, to1to2 $ r*2**k has the same value.
  -- scales
    remUnif :: Integral a => a -> a -> a
    remUnif num den = -- positive remainder
      if x<0 then x+den else x where x = rem num den
      -- fmap (flip remUnif 3) [-5..5] -- test
      -- ifdo speed: could use one divide instead of many adds

    quotUnif :: Integral a => a -> a -> a
    quotUnif num den = if num < 0 then q - 1 else q
      where q = quot num den

    lk12 :: [Double] -> Int -> Double -- 12 tone scale lookup
    lk12 sc idx =
      let len = length sc
          idx' = floor $ fromIntegral $ remUnif idx len
          octaves = quotUnif idx len
      in (12 * fromIntegral octaves) + (sc !! idx')

    lkji :: [Double] -> Int -> Double -- (scale) lookup, just inton
    lkji sc idx =
      let len = length sc
          idx' = floor $ fromIntegral $ remUnif idx len
          octaves = quotUnif idx len
      in (2 ** fromIntegral octaves) * (sc !! idx')

    rotl :: Int -> [a] -> [a] -- rotate left
    rotl n xs = take (length xs) . drop n . cycle $ xs

    equalTemperamentMode :: Int -> Int -> [Int] -> [Int]
    equalTemperamentMode temperament rotation scale = -- maybe flip order
      toFirstOctaveIfJustUnder . (relToRotatedScale rotation scale) <$> shift
      where relToRotatedScale rotation scale x = x - (shift !! 0)
            toFirstOctaveIfJustUnder x = if x < 0 then x + temperament else x
            shift = rotl rotation scale
    
    mode12 :: Int -> [Int] -> [Int]
    mode12 = equalTemperamentMode 12

    mode31 :: Int -> [Int] -> [Int]
    mode31 tones rotn = toFirstOctaveIfJustUnder  -- maybe flip order
      . (relToRotatedTones rotn tones) <$> shift
      where relToRotatedTones rotn tones x = x - (shift !! 0)
            toFirstOctaveIfJustUnder x = if x < 0 then x + 31 else x
            shift = rotl tones rotn

    denSca denom = map (flip (/) denom) [denom..denom*2-1] -- **
      -- one-octave JI scale defined by a denominator

    runDegPat :: ([Double] -> Int -> Double) -- e.g. lk12, lkji
      -> (Int -> [Double]) -- probably a map lookup
      -> Pattern Int -- args for the (probably a)map lookup
      -> Pattern Int -- scale degrees, i.e. indices into a [Double]
      -> Pattern Double
    runDegPat temperedLookup scaleFromInt scalePat degreePat = unwrap
      $ fmap (fmap . temperedLookup . scaleFromInt) scalePat
        <*> pure degreePat
    
-- ========== transition between two patterns
    -- based on playWhen, which transitions from silence to one pattern
    changeWhen :: (Time -> Bool) -> Pattern a -> Pattern a -> Pattern a
    changeWhen test (Pattern before) (Pattern after) =
      stack [b,a] where
      b = Pattern $ (filter $ \e -> not $ test $ eventOnset e) . before
      a = Pattern $ (filter $ \e ->       test $ eventOnset e) . after

-- ========== Parameters for my SuperCollider synths
  -- these are based on the definition of "gain"
    amp_p = F "amp" (Just 1) -- Amplitude
    amp = make' VF amp_p :: Pattern Double -> ParamPattern
  
  -- qf is like n from Sound.Tidal.Params, but using Doubles, not Ints
    qf_p = F "qf" (Just 0) -- Quality: (carrier) Frequency
    qf = make' VF qf_p :: Pattern Double -> ParamPattern
  
  -- each of these next is expressed relative to qf
    -- by default frequencies are 1*qf and amplitudes are 0
    qpf_p = F "qpf" (Just 1) -- Quality: Phase modulator Frequency
    qpf = make' VF qpf_p :: Pattern Double -> ParamPattern
    qpa_p = F "qpa" (Just 0) -- Quality: Phase modulator Amplitude
    qpa = make' VF qpa_p :: Pattern Double -> ParamPattern
    qff_p = F "qff" (Just 1) -- Quality: Freq modulator Frequency
    qff = make' VF qff_p :: Pattern Double -> ParamPattern
    qfa_p = F "qfa" (Just 0) -- Quality: Freq modulator Amplitude
    qfa = make' VF qfa_p :: Pattern Double -> ParamPattern
    qaf_p = F "qaf" (Just 1) -- Quality: Am modulator Frequency
    qaf = make' VF qaf_p :: Pattern Double -> ParamPattern
    qaa_p = F "qaa" (Just 0) -- Quality: Am modulator Amplitude (typ. 0 or 1)
    qaa = make' VF qaa_p :: Pattern Double -> ParamPattern
