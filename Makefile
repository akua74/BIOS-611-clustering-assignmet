R := Rscript

.PHONY: all install run plots clean

all: figures/summary_gap.png

install:
	$(R) -e "req <- c('cluster','ggplot2','dplyr','readr','tidyr','purrr','tibble','scales'); \
	         inst <- setdiff(req, rownames(installed.packages())); \
	         if (length(inst)) install.packages(inst, repos='https://cran.r-project.org')"

results/Clustering_Assignment.R

figures/summary_gap.png: R/plot_results.R results/gap_results.csv | figures
	$(R) R/plot_results.R

run: results/gap_results.csv
plots: figures/summary_gap.png

results:
	mkdir -p results
figures:
	mkdir -p figures

clean:
	rm -rf results figures
