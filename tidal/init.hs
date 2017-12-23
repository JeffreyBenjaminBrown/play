-- Evaluated line-by-line in GHCI, these commands will work,
  -- but not as a standalone .hs file;
  -- I only use that extension so Emacs formats it appropriately.

:l tidal-extensions.hs
:set prompt "> "

let lkScale = fmap . lk12 . (M.! scaleNameMap)
  -- ? Why will this definition not work in tidal-extensions.hs
  -- (Even when it works, I stil can't then use it, even though I can use `let lkScale = fmap . lk12 . (\v -> case v of "maj" -> [0,2,4,5,7,9,11]; "dor" -> [0,2,3,5,7,9,10])`,)

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
