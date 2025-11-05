# BIOS-611-clustering-assignmet
# Hypercube Clusters & Gap Statistic

This repo reproduces the assignment:
- Generate `n` clusters in `n`-D at centers `(L,0,...,0)`, `(0,L,0,...,0)`, ..., `(0,...,0,L)`.
- Points per cluster `k = 100`, noise `sd = 1.0`.
- For each `n in {6,5,4,3,2}` and `L in {10,9,...,1}`, estimate `k` using `clusGap(kmeans)`.
- `kmeans` uses `nstart = 20`, `iter.max = 50`. Gap selection uses Tibshirani's rule.

## Quick start
```bash
make install     # installs CRAN pkgs if needed
make all         # runs the simulation and produces plots
# outputs:
#   results/gap_results.csv
#   results/thresholds.txt
#   figures/summary_gap.png
