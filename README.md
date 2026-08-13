# Childhood food insecurity and youth mental health trajectories in two UK longitudinal cohorts

This repository contains code to generate longitudinal growth curve models of SDQ trajectories, stratified by food insecurity (FI) at age 5. Analyses are replicated over Growing Up in Scotland (GUS) and the Avon Longitudinal Study of Parents and Children (ALSPAC). 

Preprint available at https://www.medrxiv.org/content/10.64898/2025.12.10.25341979v1

This project uses the [renv package](https://rstudio.github.io/renv/) in R version 4.5.3. R packages are recorded in the project lockfile (renv.lock), along with the metadata required to reinstall them.

Data files are stored remotely and read in via a symlink (/DATA/).

/PREP/ contains scripts for data cleaning, harmonisation and reshaping from wide to long format.\
/FUNS/ contains global options and general utility functions (packages.R), functions used to calculate IPWs and summarise data (prep.R), and functions to estimate (mods.R) and plot (plot.R) averaged trajectories.\
/ANALYSIS/ contains analysis scripts for ALSPAC and GUS (.Rmd files) and code used to make tables and figures.
