{-# LANGUAGE TypeFamilies
           , FlexibleInstances #-}

module Sound.Tidal.Epic.Parse.CustomStreamTest where

import           Data.List (foldl')
import           Data.Proxy (Proxy(..))
import           Data.Semigroup ((<>))
import           Data.Void (Void)

import           Text.Megaparsec
import           Text.Megaparsec.Char (char)


type Parser = Parsec Void [AB]

data AB = A | B deriving (Eq,Ord,Enum,Show)
data XY = X | Y deriving (Eq,Ord,Enum,Show)

convert :: Parser [XY]
convert = many $ (char A >> return X) <|> (char B >> return Y)

-- | nearly identical to "instance Stream String" from Text.Megaparsec.Stream
instance Stream [AB] where
  type Token [AB] = AB -- ^ one difference
  type Tokens [AB] = [AB] -- ^ another difference
  tokenToChunk Proxy = pure
  tokensToChunk Proxy = id
  chunkToTokens Proxy = id
  chunkLength Proxy = length
  chunkEmpty Proxy = null
  advance1 Proxy = defaultAdvance1
  advanceN Proxy w = foldl' (defaultAdvance1 w)
  take1_ [] = Nothing
  take1_ (t:ts) = Just (t, ts)
  takeN_ n s
    | n <= 0    = Just ([], s) -- ^ one more difference ([] instead of "")
    | null s    = Nothing
    | otherwise = Just (splitAt n s)
  takeWhile_ = span

-- | copied from Megaparsec.Stream, from which it is not exported
defaultAdvance1 :: Enum t
  => Pos               -- ^ Tab width
  -> SourcePos         -- ^ Current position
  -> t                 -- ^ Current token
  -> SourcePos         -- ^ Incremented position
defaultAdvance1 width (SourcePos n l c) t = npos
  where
    w  = unPos width
    c' = unPos c
    npos =
      case fromEnum t of
        10 -> SourcePos n (l <> pos1) pos1
        9  -> SourcePos n l (mkPos $ c' + w - ((c' - 1) `rem` w))
        _  -> SourcePos n l (c <> pos1)
