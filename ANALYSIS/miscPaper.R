#### miscellaneous code for paper ####
library(here)
library(readxl)
i_am("ANALYSIS/miscPaper.R")
source(here("FUNS", "packages.R"))

# scores at ages formatted for a table ----
alspac.path = here("OUTPUT/ALSPAC", "FI_Scores.xlsx")
alspac.scores = alspac.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = alspac.path)

gus.path = here("OUTPUT/GUS", "FI_Scores.xlsx")
gus.scores = gus.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = gus.path)

# append SE for table
alspac.tidy = alspac.scores |> map(\(x) mutate(.data = x, across(where(is.numeric), \(x) round(x, digits = 2)),
                                               comb = paste0(estimate, " (", std.error, ")")))

gus.tidy = gus.scores |> map(\(x, idx) mutate(.data = x, across(where(is.numeric), \(x) round(x, digits = 2)),
                                              comb = paste0(estimate, " (", std.error, ")")))

alspac = alspac.tidy$conduct |> select(Age, foodDiff3) |> mutate(
  conduct = alspac.tidy$conduct$comb,
  emot = alspac.tidy$emot$comb,
  hyper = alspac.tidy$hyper$comb,
  peer = alspac.tidy$peer$comb
)

gus = gus.tidy$conduct |> select(Age, MeFaff3lvl) |> mutate(
  conduct = gus.tidy$conduct$comb,
  emot = gus.tidy$emot$comb,
  hyper = gus.tidy$hyper$comb,
  peer = gus.tidy$peer$comb
)

res = list("alspac" = alspac, "gus" = gus)
openxlsx::write.xlsx(res, here("OUTPUT/", "Scores.xlsx"))


# tidying contrasts ----
alspac.path = here("OUTPUT/ALSPAC", "FI_Contrasts.xlsx")
alspac.scores = alspac.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = alspac.path)

gus.path = here("OUTPUT/GUS", "FI_Contrasts.xlsx")
gus.scores = gus.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = gus.path)

# we want to keep the estimate (mean difference) and CI
alspac.scores = alspac.scores |> map(\(x) addci(dat = x, est = "estimate", lower = "conf.low", upper = "conf.high"))
gus.scores = gus.scores |> map(\(x) addci(dat = x, est = "estimate", lower = "conf.low", upper = "conf.high"))

# select columns to keep and pivot to wide format
contrtab <- function(dat) {
  df = dat |> select(Age, contrast, comb, adj.p.value) |> 
  rename(diff = comb, p.adj = adj.p.value)

  out = pivot_wider(df, names_from = Age, values_from = c(diff, p.adj), 
            names_vary = "slowest")
  return(out)
}

alspac.tidy = alspac.scores |> map(\(x) contrtab(x)) |> bind_rows(.id = "SDQ")
gus.tidy = gus.scores |> map(\(x) contrtab(x)) |> bind_rows(.id = "SDQ")

res = list("alspac" = alspac.tidy, "gus" = gus.tidy)
openxlsx::write.xlsx(res, here("OUTPUT/", "Contrasts.xlsx"))
