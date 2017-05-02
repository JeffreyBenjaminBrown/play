# Why I use a custom initialization

BootTidal.hs loads a lot of libraries I find handy, such as Data.List.

init.hs
* abbreviates some types (e.g. "PI" for "Pattern Int")
* elongates some cryptic functions (e.g. "euclid" for "e", since I'm likely to redefine "e" while live-coding)
* some functions for scales and pitch
* some patterns for the synths defined in "SuperCollider/synths sy, sya.scd"
* more functions

# How to use it

The file ~/.atom/packages/tidalcycles/lib/BootTidal.hs is a symbolic link to the BootTidal.hs file here.

That file, in turn, loads the module "init.hs"; to do it on your system you'll have to change the line `:module "git_play/tidal/init.hs"` to whatever is appropriate.
