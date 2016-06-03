In order to be able to evaluate the music in music/, you will need a system with Tidal, SuperCollider and SuperDirt installed.

In order to initialize: First start SuperCollider (and SuperDirt). Then evaluate SuperDirt.startup.scd. Then start Tidal, loading LoadEveryTIme.hs automatically*. Then evaluate the code in init.hs, by hand, from within Tidal.

* To do this in emacs, I had to add these two lines to my ~/.emacs file:
  (add-to-list 'load-path "~/tidal/emacs")
  (require 'tidal)