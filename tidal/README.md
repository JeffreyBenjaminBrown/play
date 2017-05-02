# What is this stuff?

## synths sy, sya.scd
initializes SuperCollider, and defines two synths:
* sy: a synth with frequency and phase modulation
* sya: similar, but also with amplitude modulation

### Parameters
Control amplitude with `gain` or `amp`. `amp` operates within the synth, `gain` outside it.

Control frequency with `qf`.

Control frequency modulation amplitude and frequency with `qfa` and `qff`.

Control phase modulation amplitude and frequency with `qpa` and `qpf`.

Control amplitude modulation amplitude and frequency with `qaa` and `qaf`.

## init.hs
* abbreviates some types (e.g. `PI` for `Pattern Int`)
* elongates some cryptic functions (e.g. `euclid` for `e`, since I'm likely to redefine `e` while live-coding)
* some functions for scales and pitch
* some patterns for the synths defined in `SuperCollider/synths sy, sya.scd`
* more functions

## BootTidal.hs

A modified version of the default Atom bootup file for Tidal. It loads init.hs, and a lot of libraries I find handy, such as Data.List.

# How to use it

The file `~/.atom/packages/tidalcycles/lib/BootTidal`.hs is a symbolic link to the BootTidal.hs file here.

That file, in turn, loads the module `init.hs`; to do it on your system you'll have to change the line `:module "git_play/tidal/init.hs"` to whatever is appropriate.
