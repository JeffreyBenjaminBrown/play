import Data.Ratio

type Dur = Rational -- duration
type When = Rational -- the time something happens
type Count = Rational -- how many durations

type Meter = [Count] -> When
  -- TODO: inverseMeter :: Meter -> When -> [Count]
    -- done the obvious way, this might not terminate, if the When is from a different Meter

straightTime :: Count -> Meter
straightTime divisor = sum . snd 
  $ foldl (\(unitLength, lengths) nUnits
            -> ( unitLength / divisor
               , unitLength * nUnits : lengths))
      (1 / divisor,[])
  -- examples
    -- straight 4 [0] = 0
    -- straight 4 [1] = 1 % 4
    -- straight 4 [0,1] = 1 % 16
    -- straight 4 [1,1] = 5 % 16
    -- straight 3 [0,0,1] = 1 % 27
    -- etc.
