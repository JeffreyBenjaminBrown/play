pReplicate ? pRand
------------------
What does pReplicate (which parses "!" symbols) have to do with pRand (which parses "?" symbols)?

Here are their definitions, from Parse.hs:

  pReplicate :: Pattern a -> Parser ([Pattern a])
  pReplicate thing = do extras <- many $ do char '!'
                                            spaces
                                            pRand thing
                        return (thing:extras)
  
  pRand :: Pattern a -> Parser (Pattern a)
  pRand thing = do char '?'
                   spaces
                   return $ degrade thing
                <|> return thing

pReplicate is defined in terms of pRand. pRand makes this disappear, with probability 1/2. But pReplicate never makes something disappear!

  d1 $ sound "bd sn?"-- each cycle has either zero or one sn
  d1 $ sound "bd sn!" -- always two sn, yet (!) is defined in terms of (?)

I ask because I'm trying to write a ** operator, such that "bd sn**3" == "bd sn!!".

