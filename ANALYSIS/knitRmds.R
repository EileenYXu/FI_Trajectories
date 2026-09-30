library(here)
i_am("ANALYSIS/knitRmds.R")
setwd(here())

#knit alspac files
rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_Diffs.Rmd"),
                  output_dir = here("OUTPUT", "ALSPAC"))
rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_Age_Only.Rmd"), 
                  output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")
rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_FI.Rmd"),
                  output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")
rmarkdown::render(input = here("ANALYSIS", "ALSPAC", "ALSPAC_sens.Rmd"),
                  output_dir = here("OUTPUT", "ALSPAC"), output_format = "all")

#knit gus files
rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_Diffs.Rmd"),
                  output_dir = here("OUTPUT", "GUS"))
rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_Age_Only.Rmd"),
                  output_dir = here("OUTPUT", "GUS"), output_format = "all")
rmarkdown::render(input = here("ANALYSIS", "GUS", "GUS_FI.Rmd"),
                  output_dir = here("OUTPUT", "GUS"), output_format = "all")


