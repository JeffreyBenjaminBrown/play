-- lang, lib
    {-# LANGUAGE OverloadedStrings, TypeSynonymInstances, OverlappingInstances, IncoherentInstances, FlexibleInstances #-}

    module Sound.Tidal.Parse where

    import Text.ParserCombinators.Parsec
    import qualified Text.ParserCombinators.Parsec.Token as P
    import Text.ParserCombinators.Parsec.Language ( haskellDef )
    import Data.Ratio
    import Data.Colour
    import Data.Colour.Names
    import Data.Colour.SRGB
    import GHC.Exts( IsString(..) )
    import Data.Monoid
    import Control.Applicative ((<$>), (<*>), (<*), (*>), pure)
    import Data.Functor (($>))
    import Data.Functor.Identity (Identity)
    import Data.Maybe

    import Sound.Tidal.Pattern

-- Parseable a
    class Parseable a where
      p :: String -> Pattern a
    instance Parseable Double where
      p = parseRhythm pDouble
    instance Parseable String where
      p = parseRhythm pVocable
    instance Parseable Bool where
      p = parseRhythm pBool
    instance Parseable Int where
      p = parseRhythm pInt
    instance Parseable Rational where
      p = parseRhythm pRational
    type ColourD = Colour Double
    instance Parseable ColourD where
      p = parseRhythm pColour

    instance (Parseable a) => IsString (Pattern a) where
      fromString = p

    --instance (Parseable a, Pattern p) => IsString (p a) where
    --  fromString = p :: String -> p a
-- lexer
    lexer = P.makeTokenParser haskellDef
    symbol  = P.symbol  lexer
    natural = P.natural lexer
    integer = P.integer lexer

-- data Sign
    data Sign      = Positive | Negative

    applySign :: Num a => Sign -> a -> a
    applySign Positive =  id
    applySign Negative =  negate

    sign  :: Parser Sign
    sign  =  do char '-'
                return Negative
             <|> do char '+'
                    return Positive
             <|> return Positive

-- the hard part
  -- building pSequence and pSequenceN
    pSingle :: Parser (Pattern a) -> Parser (Pattern a)
    pSingle f = f >>= pRand >>= pMult

    pPart :: Parser (Pattern a) -> Parser ([Pattern a])
    pPart f = do -- part <- parens (pSequence f) <|> pSingle f <|> pPolyIn f <|> pPolyOut f
                 part <- pSingle f <|> pPolyIn f <|> pPolyOut f
                 part <- pE part
                 part <- pRand part
                 spaces
                 parts <- pReplicate part
                 spaces
                 return $ parts

    pSequenceN :: Parser (Pattern a) -> GenParser Char () (Int, Pattern a)
    pSequenceN f = do spaces
                      d <- pDensity -- parses a num from angle-brackets
                      ps <- many $ pPart f
                      return $ (length ps, density d $ cat $ concat ps)

    pSequence :: Parser (Pattern a) -> GenParser Char () (Pattern a)
    pSequence f = do (_, p) <- pSequenceN f
                     return p

  -- using pSequence and pSequenceN
    parseRhythm :: Parser (Pattern a) -> String -> (Pattern a)
    parseRhythm f input =
      either (const silence) id $ parse (pSequence f') "" input
        -- parse returns Either ParseError a; errors become silence
      where f' = f <|> (symbol "~" <?> "rest") $> silence
        -- in any kind of Pattern (Int, String ...), "~" is also valid

    pPolyIn :: Parser (Pattern a) -> Parser (Pattern a)
    pPolyIn f = do ps <- P.brackets lexer 
                         $ pSequence f `sepBy` symbol ","
                   spaces
                   pMult $ mconcat ps

    pPolyOut :: Parser (Pattern a) -> Parser (Pattern a)
    pPolyOut f = do ps <- P.braces lexer $ pSequenceN f `sepBy` symbol ","
                    spaces
                    base <- do char '%'
                               spaces
                               i <- integer <?> "integer"
                               return $ Just (fromIntegral i)
                            <|> return Nothing
                    pMult $ mconcat $ scale base ps
      where scale _ [] = []
            scale base (ps@((n,_):_)) = map 
              (\(n',p) -> density 
                (fromIntegral (fromMaybe n base)/ fromIntegral n') 
                p
              ) ps

    pE :: Pattern a -> Parser (Pattern a)
    pE thing = do (n,k,s) <- P.parens lexer pair
                  return $ unwrap $ eoff <$> n <*> k <*> s <*> atom thing
                <|> return thing
       where pair = do a <- pSequence pInt
                       spaces
                       symbol ","
                       spaces
                       b <- pSequence pInt
                       c <- do symbol ","
                               spaces
                               pSequence pInt
                            <|> return (atom 0)
                       return (fromIntegral <$> a, fromIntegral <$> b, fromIntegral <$> c)
             eoff n k s p = ((s%(fromIntegral k)) <~) (e n k p)

-- smaller-scale functions
  -- we futzed with these
    pSample :: Parser String
    pSample = flatten <$> pSample' -- flatten for Dirt
      where flatten (name, Nothing) = name
            flatten (name, Just idx) = name ++ ":" ++ show idx

    pSample' :: Parser ([Char], Maybe Integer)
    pSample' = (,) <$> pSound <*> (option Nothing pTraversal)
      where pSound = many1 (letter <|> pDigit)
            pDigit = oneOf "0123456789"
            pTraversal  = Just <$> (char ':' *> integer)

    pReplicate :: Pattern a -> Parser ([Pattern a]) -- edited: added ^
    pReplicate thing = do
      extras <- do char '^'
                   spaces
                   n <- natural <?> "multiples"
                   return $ replicate (fromIntegral $ n - 1) thing
                <|> (many $ do char '!'
                               spaces
                               pRand thing)
      return (thing:extras)

    pMult :: Pattern a -> Parser (Pattern a) -- pMult ? pReplicate
    pMult thing = subdivide <|> rotate <|> return thing
      where
        subdivide =  char '*' >> spaces
          >> (\n -> density n thing) <$> pRatio
        rotate = char '/' >> spaces
          >> (\r -> slow r thing) <$> pRatio

    pRand :: Pattern a -> Parser (Pattern a)
    pRand thing = pRand' $ return thing
      -- return thing is the "parser" that, whatever it's told to parse, returns thing

    -- want: pRand like this, using thing as parser of pattern rather than pattern
    pRand' :: Parser (Pattern a) -> Parser (Pattern a) -- new!
    pRand' thing = (char '?' >> spaces >> degrade <$> thing) <|> thing

  -- get a number (basically)
    pVocable :: Parser (Pattern String)
    pVocable = atom <$> pSample

    pColour :: Parser (Pattern ColourD)
    pColour = do name <- many1 letter <?> "colour name"
                 colour <- readColourName name <?> "known colour"
                 return $ atom colour

    pRatio :: Parser (Rational)
    pRatio = do n <- natural <?> "numerator"
                d <- do  oneOf "/%"
                         natural <?> "denominator"
                     <|> return 1
                return $ n % d
    -- how to rewrite without do notation?  this fails:
      --pRatio' = (%) <$> (natural <?> "numerator") <*> d
      --  where d = oneOf "%/" $> (natural <?> "denominator") <|> noDenom
      --        noDenom = return 1 :: Parser Integer
      --        noDenom = return 1 :: Text.Parsec.Prim.ParsecT String u Data.Functor.Identity.Identity Integer

    intOrFloat :: Parser (Either Integer Double)
    intOrFloat =  do s   <- sign
                     num <- P.naturalOrFloat lexer
                     return $ case num of Right x -> Right (applySign s x)
                                          Left  x -> Left  (applySign s x)

    pDouble :: Parser (Pattern Double)
    pDouble = atom . either fromIntegral id <$> (intOrFloat <?> "float")

    pBool :: Parser (Pattern Bool)
    pBool = do oneOf "t1"
               return $ atom True
            <|> do oneOf "f0"
                   return $ atom False
      -- how to avoid do-notation? this fails:
        -- pBool' = atom <$> (oneOf "t1" $> True <|> oneOf "f0" $> False)

    pInt :: Parser (Pattern Int)
    pInt = do s <- sign
              i <- integer <?> "integer"
              return $ atom (applySign s $ fromIntegral i)

    pRational :: Parser (Pattern Rational)
    pRational = atom <$> pRatio

    pDensity :: Parser (Rational)
    pDensity = P.angles lexer (pRatio <?> "ratio")
               <|> return (1 % 1)

-- eof

