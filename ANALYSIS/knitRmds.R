library(here)
i_am("ANALYSIS/knitRmds.R")
setwd(here())

#knit alspac files
rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_Age_Only.Rmd"), output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")
rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_FI.Rmd"), output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")
#rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_Social.Rmd"), output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")
#rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_FI_Social.Rmd"), output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")
#rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_FI_Social_bySex.Rmd"), output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")


#knit gus files
rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_Age_Only.Rmd"), output_dir = here("OUTPUT", "GUS"), output_format = "all")
rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_FI.Rmd"), output_dir = here("OUTPUT", "GUS"), output_format = "all")
#rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_Social.Rmd"), output_dir = here("OUTPUT", "GUS"), output_format = "all")
#rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_FI_Social.Rmd"), output_dir = here("OUTPUT", "GUS"), output_format = "all")
#rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_FI_Social_bySex.Rmd"), output_dir = here("OUTPUT", "GUS"), output_format = "all")
