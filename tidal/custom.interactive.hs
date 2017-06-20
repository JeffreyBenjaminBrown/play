-- Evaluated line-by-line in GHCI, these commands will work,
  -- but not as a standalone .hs file;
  -- I only use that extension so Emacs formats it appropriately.

:set prompt \"\"
:l init.hs

-- :module Sound.Tidal.Context
-- import qualified Data.List as L
-- import qualified Data.Map as M
-- import Data.Maybe
-- import Control.Applicative
-- import Data.String
-- import Data.Ratio
-- import Data.Random
-- import Data.Random.Source.DevRandom
-- import Data.Fixed (mod',div')

(cps, nudger, getNow) <- cpsUtils'

(d0,dt0) <- superDirtSetters getNow -- drums
(d1,dt1) <- superDirtSetters getNow
(d2,dt2) <- superDirtSetters getNow
(d3,dt3) <- superDirtSetters getNow
(d4,dt4) <- superDirtSetters getNow
(d5,dt5) <- superDirtSetters getNow
(d6,dt6) <- superDirtSetters getNow
(d7,dt7) <- superDirtSetters getNow
(d8,dt8) <- superDirtSetters getNow
(d9,dt9) <- superDirtSetters getNow

(v0,vt0) <- superDirtSetters getNow -- voices
(v1,vt1) <- superDirtSetters getNow
(v2,vt2) <- superDirtSetters getNow
(v3,vt3) <- superDirtSetters getNow
(v4,vt4) <- superDirtSetters getNow
(v5,vt5) <- superDirtSetters getNow
(v6,vt6) <- superDirtSetters getNow
(v7,vt7) <- superDirtSetters getNow
(v8,vt8) <- superDirtSetters getNow
(v9,vt9) <- superDirtSetters getNow

let hush = mapM_ ($ silence) [v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,d0,d1,d2,d3,d4,d5,d6,d7,d8,d9]
let hushd = mapM_ ($ silence) [d0,d1,d2,d3,d4,d5,d6,d7,d8,d9]
let hushv = mapM_ ($ silence) [v0,v1,v2,v3,v4,v5,v6,v7,v8,v9]
let solo = (>>) hush
let solov = (>>) hushv
let solod = (>>) hushd

:set prompt "> "