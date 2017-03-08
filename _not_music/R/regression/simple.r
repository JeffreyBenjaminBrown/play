# a simple reg
  n <- 20
  x1 <- runif(n,0,1)
  x2 <- runif(n,0,1)
  e  <- runif(n,0,1)
  y <- 3 + x1 - 2 * x2 + e
  df <- data.frame( x1, x2, y )
  fit <- lm( y ~ x1 + x2, data=df )
