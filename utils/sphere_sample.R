sphere.samp = function(n,dims) {
  d = matrix(NA, nrow=n, ncol=dims)
  for(i in 1:n) {
    # from http://mathworld.wolfram.com/HyperspherePointPicking.html
    x = rnorm(dims)
    d[i,] = x / sqrt(sum(x*x))
  }
  d = data.frame(d)
  names(d) = stringr::str_c("x", 1:dims)
  d
}

upper.samp = function(n,dims) {
  d = matrix(NA, nrow=n, ncol=dims)
  for(i in 1:n) {
    # from http://mathworld.wolfram.com/HyperspherePointPicking.html
    x = rep(-1, dims)
    # keep sampling until everything is positive
    while(any(x < 0)) {
      x = rnorm(dims)
    }
    d[i,] = x / sqrt(sum(x*x))
  }
  d = data.frame(d)
  names(d) = stringr::str_c("x", 1:dims)
  d
}
