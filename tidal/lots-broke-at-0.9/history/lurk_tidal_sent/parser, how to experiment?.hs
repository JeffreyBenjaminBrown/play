Parser: How to experiment?
==========================

What's a good workflow|file tree setup for trying modifications to Tidal? I'm facing something of a deadline [3] so any help is immensely appreciated!

I have been trying to load both the original Parse.hs and an experimental copy of it. I'm getting stuck on an "Overlapping instances" error. Should I be trying to load both copies? 

I see a stack.yaml file at the top of Github/Tidal/. I suspect Stack is the way to go, but I don't know how to integrate Stack and Emacs-GHCI. Or maybe I should skip the editor entirely and run "stack ghci" from the command line?

I can imagine editing Tidal's original Parse.hs and then running "cabal install" after each edit, but with a feedback cycle that slow I'd never get anything done ...

The rest of this email describes what I did:

------

I created a file, MyParse.hs [1], that is just a copy of Sound.Tidal.Parse, with the only exception being that I substituded the line
  module MyParse where
for
  module Sound.Tidal.Parse where

Then I modified my TidalCustom.hs file [2] to import it.

Tidal starts fine, loads everything without complaint, but when I try anything I get an error like this:

  tidal> d1 $ "bd"
  
  <interactive>:116:6:
      Overlapping instances for IsString OscPattern
        arising from the literal ‘"bd"’
      Matching instances:
        instance [incoherent] Sound.Tidal.Context.Parseable a =>
                              IsString (Pattern a)
          -- Defined in ‘Sound.Tidal.Parse’
        instance [incoherent] MP.Parseable a => IsString (Pattern a)
          -- Defined at MyParse.hs:45:10
      In the second argument of ‘($)’, namely ‘"bd"’
      In the expression: d1 $ "bd"
      In an equation for ‘it’: it = d1 $ "bd"
  tidal> 


[1], MyParse.hs: https://github.com/JeffreyBenjaminBrown/play/blob/master/tidal/MyParse.hs

[2], TidalCustom.hs: https://github.com/JeffreyBenjaminBrown/play/blob/master/tidal/TidalCustom.hs

[3]: http://www.meetup.com/santa-monica-haskell/events/225732250/

