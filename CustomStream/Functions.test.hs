-- As far as I can tell, this works perfectly for well-formed streams.
-- However, it will "successfully" parse at least some ill-formed streams;
-- see the section marked "errors".

-- | = One demonstration
f a = a + 1              -- below I will (polymorphically) call f "+1"
u f = \a -> f a * 2
b f g = \a -> f a + g a  -- below I will (polymorphically) call b "+"
f' = funcNotOp' f
u' = unaryOp' u
b' = binaryOp' b
l = LeftBracket
r = RightBracket
stream = [f', b', u', f']
  -- = f `b` u f (because unary ops bind before binary ones)
  -- = (+1) + u (+1)
  -- = (+1) + \a -> (a+1)*2
  -- = \a -> (a+1)*2 + (a+1)
  -- = \a -> 3a + 3
Right g = parse func "" stream
map g [0..5]

-- | = Equivalent expressions, using brackets
stream = [l, f', r, b', u', f']
stream = [l, f', r, l, b', r, u', f']
stream = [l, f', r, l, b', r, l, u', r, f']
stream = [l, l, f', r, l, b', r, l, u', r, f', r]
stream = [l, l, f', r, l, l, b', r, r, l, u', r, f', r]
       -- (  (  f   )  (  (  b   )  )  (  u   )  f   )
stream = [ l, f', r,
           l, b', r,
           l, u', r,
           l, f', r]
stream = [ l, l, f', r, r,
           l, b', r,
           l, u', r,
           l, f', r]
stream = [ l, l, f', r, r,
           l, l, b', r, r,
           l, l, u', r, r,
           l, l, f', r, r]
stream = [l, l, l,
                   l, l, f', r, r,
                   l, l, b', r, r,
                   l, l, u', r, r,
                   l, l, f', r, r,
           r, r, r]


-- | = Errors. Note that these are all ill-formed streams.

-- This is ill-formed (too many ls), and parses wrong.
stream = [ l, l, f', r, r,
           l, l, b', r,
           l, u', r,
           l, f', r]

-- This will not parse.
stream = [ l, l, l, f', r, r]

-- but this will
stream = [ l, l, f', r, r, r]
