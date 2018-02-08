module HeterogeneousPrisms where

import Control.Lens (makePrisms, (^?))
import Data.Maybe (isJust)

data NumberOrUnit = Number Int | Unit
makePrisms ''NumberOrUnit

-- These work:
isNumber nob = isJust $ nob ^? _Number
isUnit nob = isJust $ nob ^? _Unit

-- But this cannot be defined:
-- isa :: Prism' NumberOrUnit _ -> NumberOrUnit -> Bool
-- because what would go where the blank is?
