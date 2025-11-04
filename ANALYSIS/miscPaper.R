#### miscellaneous code for paper ####
library(here)
library(readxl)
i_am("ANALYSIS/miscPaper.R")
source(here("FUNS", "packages.R"))

# scores at ages formatted for into a neat table for each cohort  ----
# one list for each cohort containing all 4 SDQ subscales 
alspac.path = here("OUTPUT/ALSPAC", "FI_Scores.xlsx") # path to file
alspac.scores = alspac.path |> 
  excel_sheets() |> # iterate over each sheet
  set_names() |> # use sheet names (SDQ subscales)
  map(read_excel, path = alspac.path) # read in each sheet from file path

gus.path = here("OUTPUT/GUS", "FI_Scores.xlsx")
gus.scores = gus.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = gus.path)

# round estimate and CI to 2 d.p. and format as estimate [lower - upper]
alspac.tidy = alspac.scores |> 
  map(\(x) mutate(
    .data = x, 
    across(where(is.numeric), \(x) round(x, digits = 2)),
    comb = paste0(estimate, " [", conf.low, " - ", conf.high, "]"),
    foodDiff3 = factor(foodDiff3, 
                       levels = c("Not difficult", "Slightly","Fairly/Very"))))

gus.tidy = gus.scores |> 
  map(\(x, idx) mutate(
    .data = x, 
    across(where(is.numeric), \(x) round(x, digits = 2)),
    comb = paste0(estimate, " [", conf.low, " - ", conf.high, "]"),
    MeFaff3lvl = factor(MeFaff3lvl, 
                        levels = c("Not at all", "A little",
                                   "A lot/fair amount"))))

# single output table with age, FI and SDQ scores
alspac = alspac.tidy$conduct |> select(Age, foodDiff3) |> mutate(
  conduct = alspac.tidy$conduct$comb,
  emot = alspac.tidy$emot$comb,
  hyper = alspac.tidy$hyper$comb,
  peer = alspac.tidy$peer$comb
) |> arrange(Age, foodDiff3)

gus = gus.tidy$conduct |> select(Age, MeFaff3lvl) |> mutate(
  conduct = gus.tidy$conduct$comb,
  emot = gus.tidy$emot$comb,
  hyper = gus.tidy$hyper$comb,
  peer = gus.tidy$peer$comb
) |> arrange(Age, MeFaff3lvl)

# save both tables together
res = list("alspac" = alspac, "gus" = gus)
openxlsx::write.xlsx(res, here("OUTPUT/", "Scores.xlsx"))


# tidying contrasts ----
alspac.path = here("OUTPUT/ALSPAC", "FI_Contrasts.xlsx")
alspac.cont = alspac.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = alspac.path)

gus.path = here("OUTPUT/GUS", "FI_Contrasts.xlsx")
gus.cont = gus.path |> 
  excel_sheets() |> 
  set_names() |> 
  map(read_excel, path = gus.path)

# round estimate (mean difference) and CI to 2 d.p.
# paste in the format estimate [lower - upper]
alspac.cont = alspac.cont |> 
  map(\(x) addci(dat = x, est = "estimate", lower = "conf.low", 
                 upper = "conf.high", digits = 2))
gus.cont = gus.cont |> 
  map(\(x) addci(dat = x, est = "estimate", lower = "conf.low", 
                 upper = "conf.high", digits = 2))


# select columns to keep, round adjusted p to 2 sig fig, pivot to wide
contrtab <- function(dat) {
  df = dat |> select(Age, contrast, comb, adj.p.value) |> 
    mutate(adj.p.value = signif(adj.p.value, digits = 2)) |> 
    rename(diff = comb, p.adj = adj.p.value)
  out = pivot_wider(df, names_from = Age, values_from = c(diff, p.adj), 
            names_vary = "slowest")
  return(out)
}

# single output table with one row for each SDQ
alspac.tidy = alspac.cont |> map(\(x) contrtab(x)) |> bind_rows(.id = "SDQ")
gus.tidy = gus.cont |> map(\(x) contrtab(x)) |> bind_rows(.id = "SDQ")

res = list("alspac" = alspac.tidy, "gus" = gus.tidy)
openxlsx::write.xlsx(res, here("OUTPUT/", "Contrasts.xlsx"))
