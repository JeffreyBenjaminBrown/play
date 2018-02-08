{-# LANGUAGE
ScopedTypeVariables
, FunctionalDependencies
, MultiParamTypeClasses
, AllowAmbiguousTypes
#-}

module Forall where
import Data.Maybe (fromJust, isNothing)

class Gorp a b | b -> a where
  id' :: b -> b -- why does get require AllowAmbiguousTypes?
  transform :: b -> a

works :: forall a b. Gorp a b => [b] -> [a]
works = map transform

breaks :: forall a b. Gorp a b => [b] -> [b] -- why doesn't this work?
breaks = map id'
