Prelude> let primes = [2,3,5,7,11,13,17,19,23,29,31]
Prelude> zip primes [1..]
[(2,1),(3,2),(5,3),(7,4),(11,5),(13,6),(17,7),(19,8),(23,9),(29,10),(31,11)]
Prelude> zip [1..] primes
[(1,2),(2,3),(3,5),(4,7),(5,11),(6,13),(7,17),(8,19),(9,23),(10,29),(11,31)]
