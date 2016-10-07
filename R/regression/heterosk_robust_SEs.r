# a reg with heteroskedasticity-robust stderrs
# http://thomasleeper.com/Rcourse/Tutorials/olsrobustSEs.html	

# brief, no explanation
  library(sandwich)
  # generate data
    set.seed(1)
    x <- runif(500, 0, 1)
    y <- 5 * rnorm(500, x, x)   # y(x) is heterosk
  ols <- lm(y ~ x)
  s <- summary(ols)
  s$coef[, 2] <- sqrt(diag(vcovHC(ols)))   # upgrade the SEs
  s$coef

# verbose, explanatory
  library(sandwich)
  # generate data
    set.seed(1)
    x <- runif(500, 0, 1)
    y <- 5 * rnorm(500, x, x)   # y(x) is heterosk
      plot(y ~ x, col = "gray", pch = 19)
      abline(lm(y ~ x), col = "blue")

  ols <- lm(y ~ x)
  s <- summary(ols)
  s$coef

  vcov(ols)   # the var-covar matrix
  diag(vcov(ols))
  sqrt(diag(vcov(ols)))   # the ordinary SEs

  vcovHC(ols) # the heterosk-(robust|consistent) var-covar mat
  sqrt(diag(vcovHC(ols)))   # the HR SEs

  str(s)   # "structure" of s
  s$coefficients[, 2] <- sqrt(diag(vcovHC(ols)))   # upgrade the SEs
  s$coef

