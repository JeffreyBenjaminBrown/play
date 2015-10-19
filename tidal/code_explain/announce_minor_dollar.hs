An operator like $ with lower precedence, for fewer parens
----------------

$ has precedence 0; it binds last. |+| and its siblings have precedence 1; they bind almost last.

Today I started using a new operator, which I'm calling ($.), that behaves identically to $ except that it has precedence 3: 

    infixr 3 $. -- binds before |+|, after <$> and <*>
    ($.) :: (a -> b) -> a -> b
    f $. x = f x

It's defined in my TidalCustom.hs file [1]. It lets you do things like this:

    d1 $ slow 2 $. up "0 7" |+| sound "psr"

Without it (or something similar) you would have to use more parens:

    d1 $ (slow 2 $ up "0 7") |+| sound "psr"

Since the functor|applicative operators <*> and <$> have precedence 4, it also takes no parens to write this:

  d1 $ slow 2 $. up $. (* 2) <$> "0 7 4 7" |+| sound "psr"

[1] https://github.com/JeffreyBenjaminBrown/play/blob/master/tidal/TidalCustom.hs

