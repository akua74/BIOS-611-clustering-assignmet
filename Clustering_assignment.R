# install and load package 
if (!requireNamespace("cluster", quietly = TRUE)) install.packages("cluster")
library(cluster)

generate_hypercube_clusters <- function(n, k, side_length, noise_sd = 1.0) {
  centers <- diag(side_length, nrow = n, ncol = n)   # n centers, n dims
  X <- matrix(NA_real_, n * k, n)
  y <- rep(seq_len(n), each = k)
  row <- 1
  for (i in seq_len(n)) {
    Z <- matrix(rnorm(k * n, sd = noise_sd), ncol = n)
    X[row:(row + k - 1), ] <- sweep(Z, 2, centers[i, ], `+`)
    row <- row + k
  }
  list(x = X, y = y)
}

estimate_k_gap <- function(X, K.max) {
  set.seed(1)
  cluster_fun <- function(x, k) kmeans(x, centers = k, nstart = 20, iter.max = 50)
  gap <- cluster::clusGap(X, FUNcluster = cluster_fun, K.max = K.max, B = 50)
  cluster::maxSE(gap$Tab[,"gap"], gap$Tab[,"SE.sim"])
}

generate_shell_clusters <- function(n_shells, k_per_shell, max_radius, noise_sd = 0.1) {
  radii <- seq(max_radius / (n_shells * 2), max_radius, length.out = n_shells)
  N <- n_shells * k_per_shell
  X <- matrix(NA_real_, N, 3); y <- rep(seq_len(n_shells), each = k_per_shell)
  row <- 1
  for (s in seq_len(n_shells)) {
    r  <- rnorm(k_per_shell, mean = radii[s], sd = noise_sd)
    u  <- runif(k_per_shell); v <- runif(k_per_shell)
    theta <- acos(2*u - 1); phi <- 2*pi*v
    X[row:(row + k_per_shell - 1), ] <- cbind(r*sin(theta)*cos(phi),
                                              r*sin(theta)*sin(phi),
                                              r*cos(theta))
    row <- row + k_per_shell
  }
  list(x = X, y = y)
}

spectral_k_wrapper <- function(x, k, d_threshold = 1) {
  D <- as.matrix(dist(x))
  A <- (D < d_threshold) * 1; diag(A) <- 0
  deg <- rowSums(A); L <- diag(deg) - A
  Dm12 <- diag(1 / sqrt(pmax(deg, 1e-8)))
  Lsym <- Dm12 %*% L %*% Dm12
  ee <- eigen(Lsym, symmetric = TRUE)
  # pick k smallest eigenvalues' eigenvectors
  idx <- order(ee$values)[1:k]
  U <- ee$vectors[, idx, drop = FALSE]
  U <- sweep(U, 1, sqrt(rowSums(U^2)) + 1e-12, `/`)
  km <- kmeans(U, centers = k, nstart = 20, iter.max = 50)
  list(cluster = km$cluster)
}

set.seed(42)
g <- generate_hypercube_clusters(n = 4, k = 100, side_length = 8, noise_sd = 1)

# estimate K with corrected function
k_est_hyper <- estimate_k_gap(g$x, K.max = 8)
cat("Estimated K (hypercube):", k_est_hyper, "\n")

# alternative direct use of clusGap for inspection/plot
gap1 <- cluster::clusGap(
  g$x,
  FUNcluster = function(x, k) kmeans(x, centers = k, nstart = 20, iter.max = 50),
  K.max = 8, B = 50
)
print(gap1, method = "firstSEmax")
plot(gap1, main = "Gap statistic (hypercube demo)")

# shells example
set.seed(42)
s <- generate_shell_clusters(n_shells = 4, k_per_shell = 100, max_radius = 10, noise_sd = 0.1)

# using spectral wrapper within clusGap (note: FUNcluster must accept (x, k))
gap2 <- cluster::clusGap(
  s$x,
  FUNcluster = function(x, k) spectral_k_wrapper(x, k, d_threshold = 1.0),
  K.max = 8, B = 50
)
print(gap2, method = "firstSEmax")
plot(gap2, main = "Gap statistic (spectral on shells)")
