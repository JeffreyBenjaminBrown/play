module Arithmetic where

import           Control.Applicative (empty)
import           Data.Void (Void)
import qualified Data.Scientific as S

import           Text.Megaparsec
import           Text.Megaparsec.Expr (makeExprParser, Operator(..))
import qualified Text.Megaparsec.Char as C
import qualified Text.Megaparsec.Char.Lexer as L


type Parser = Parsec Void String

test :: IO ()
test = mapM_ (putStrLn . show) $ map (parse expr "") tests

tests =  [ "4 + 2 * 3"
         , "4 (+) 2 (*) 3"
         , "(4) + (2) * (3)"
         , "(4 (+) 2 (*) 3)"
         , "(4 ((+)) 2 (*) 3)"
         , "((4) ((+)) ((2)) (*) (((3))))"
         ]

expr :: Parser Float
expr = makeExprParser float [ [ InfixL times ]
                            , [ InfixL plus ]
                            ]

test' = mapM_ (putStrLn . k) $ map (parse it "") tests
  where it = times <|> f <|> plus
        f = const (\a b -> a + a * b) <$> float
        k (Right f) = show $ f 3 4
        k (Left e) = show e
tests' = [ "3", "(3)", "((3))"
         , "+", "(+)", "((+))"
         , "*", "(*)", "((*))"
         ]

-- = simpler parsers
float :: Parser Float
float = it <|> bracket expr -- was previously "<|> bracket float"
  where it = S.toRealFloat <$> lexeme L.scientific

plus :: Num a => Parser (a -> a -> a)
plus = const (+) <$> it <|> bracket plus
  where it = lexeme $ C.string "+"

times :: Num a => Parser (a -> a -> a)
times = const (*) <$> it <|> bracket times
  where it = lexeme $ C.string "*"

bracket :: Parser a -> Parser a
bracket p = lexeme $ try $ between (C.char '(') (C.char ')') p
  -- try, because many parsers start with a left bracket

-- = whitespace
sc :: Parser ()
sc = L.space C.space1 empty empty

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc
