-- https://wiki.haskell.org/HXT/Practical/Simple1

{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}
import Text.XML.HXT.Core
import Data.Tree.NTree.TypeDefs -- for GHCI queries like ":i NTree"

data Guest = Guest { firstName, lastName :: String }
  deriving (Show, Eq)

--
testData = runX $ readDocument [withValidate no, withRemoveWS yes] "data.xml"
                   >>> (multi $ isElem >>> hasName "guest")

atTag tag = multi (isElem >>> hasName tag)
text = getChildren >>> getText

-- runX $ readDocument [withValidate no] "data.xml" >>> multi getGuest
getGuest = atTag "guest" >>>
  proc x -> do
    fname <- text <<< atTag "fname" -< x
    lname <- text <<< atTag "lname" -< x
    returnA -< Guest { firstName = fname, lastName = lname }
