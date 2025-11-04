#### Demographics of included and excluded ppts in ALSPAC and GUS ####

library(here)
i_am("ANALYSIS/desc_missingdata.R")
source(here("FUNS", "packages.R"))
source(here("FUNS", "prep.R"))

# ALSPAC ----

# full sample (wide format)
alspac_wide = readRDS(here("DATA", "ALSPAC_Wide_Pre_Imputed.rds"))
nrow(alspac_wide) #15645 participants

# included sample (long format)
alspac_inc = readRDS(here("DATA","ALSPAC_long.rds"))

## Code included/excluded ----
included = unique(alspac_inc$ID)
length(included) #8078 participants included
rm(alspac_inc)

alspac_wide$included = ifelse(alspac_wide$ID %in% included, 1, 0) |> as.factor()
summary(alspac_wide$included) #7567 excluded

## Code attendance at each sweep ----
# age at sweep used as proxy for attendance
agecols = c("kq998a","ku991a","kw9991a", "ta9991a", "tc9991a") 
# sweeps denoted by first 2 letters
new_names = paste0("in_", str_extract(agecols, pattern = "^[:alpha:]{2}")) 

attend = alspac_wide |> select(ID, all_of(agecols))
attend = make_misscols(df=attend, var_cols = agecols, new_names = new_names) |> 
  select(ID, all_of(new_names))
alspac_wide = merge(alspac_wide, attend, by = "ID")

## Rename age columns to be timepoint_age and convert to years ----
alspac_wide = rename_with(.data = alspac_wide, .cols = all_of(agecols), 
                          ~gsub(pattern = "\\d{3,}a", replacement = "_age", .x)) |> 
  mutate(across(.cols = ends_with("_age"), ~ .x/12))

## Filter demographic vars and code as factors ----
sumvars = c("sex", "income", "foodDiff", "IMD", "matAge", "matEd",
            "matClass", "parity", "housing", "finDiff", "smokePreg", "epdsPre",
            "epdsPost", "ethnicity", "epds", "foodDiff3", 
            grepv(pattern = "_age", x = names(alspac_wide)),
            grepv(pattern = "in_", x = names(alspac_wide)))

## Recode 4-level FI to 3-level
alspac_wide = alspac_wide |> 
  select(included, any_of(sumvars)) |> 
  mutate(foodDiff3 = case_when(foodDiff == "Not difficult" ~ "Not difficult",
                               foodDiff == "Slightly" ~ "Slightly",
                               foodDiff %in% c("Fairly", "Very") ~ "Fairly/Very") |>
           fct_relevel("Not difficult"))

## Get ALSPAC demogs ----

indat = alspac_wide |> filter(included=="1")
alspac_in = get_sum_stats(dat = indat, vars = sumvars) |> 
  filter(!str_detect(pattern = "^[in]{2}\\_[:alpha:]{2}\\_[0]{1}", Var))

exdat = alspac_wide |> filter(included=="0")
alspac_ex = get_sum_stats(dat = exdat, vars = sumvars) |> 
  filter(!str_detect(pattern = "^[in]{2}\\_[:alpha:]{2}\\_[0]{1}", Var))

rm(indat, exdat, alspac_wide)

# GUS ----

## Sweep 1 data to compare weighting demographic vars used in ALSPAC ----
vars = c("Idnumber", "DaHGmag5", "DaZten02", "DaHGbord", "MaHcig01",
         "DaMedu03", "DaMsec01", "DaEthGpC")

sw1 = read.delim(
  "G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw1_b_v4_protect.tab") |> 
  select(all_of(vars))

# recode factors and levels to meaningful names
gus_base = sw1 |> mutate(
  delivery_age = case_when(
    DaHGmag5==1 ~ "<20",
    DaHGmag5==2 ~ "20-29",
    DaHGmag5==3 ~ "30-39",
    DaHGmag5==4 ~ "40+",
    .default = NA),
  tenure = case_when(
    DaZten02==1 ~ "Owner occupied",
    DaZten02==2 ~ "Social rented",
    DaZten02==3 ~ "Private rented",
    .default = NA),
  birthorder = case_match(DaHGbord,
                          1 ~ "1st born",
                          2 ~ "2nd born",
                          c(3:8) ~ "3+ born"),
  smokepreg = case_match(MaHcig01, c(1,2) ~ "1", 3 ~ "0", .default = NA),
  MatEdu = case_match(DaMedu03,
                      c(1,2) ~ "<GCSE",
                      3 ~ "GCSEs",
                      c(4:6) ~ ">=A level"),
  occupation = case_match(DaMsec01,
                      1 ~ "Professional/Managerial",
                      c(2:6) ~ "Intermediate - Unemployed"),
  ethnicity = case_match(DaEthGpC,
                         1 ~ "White",
                         2 ~ "Non-white")) |> 
  select(Idnumber, delivery_age, tenure, birthorder, smokepreg, MatEdu, 
         occupation, ethnicity)

gus_base = gus_base |> mutate(across(where(is.character), as.factor))
rm(sw1)

# full sample (wide format)
gus_wide = readRDS(here("DATA", "GUS_wide.rds")) |> select(-MatEdu)
nrow(gus_wide) #3833 participants

# merge in baseline details
gus_wide = merge(gus_wide, gus_base, by = "Idnumber", all.x = T, all.y = F)

# included sample (long format)
gus_inc = readRDS(here("DATA","GUS_long.rds"))

# get unique IDs for included participants and make column of included/excluded
included = unique(gus_inc$Idnumber)
length(included) #3167 participants included

gus_wide$included = ifelse(gus_wide$Idnumber %in% included, 1, 0) |> as.factor()
summary(gus_wide$included) #666 excluded

## Attendance at each sweep ----
var_cols = grepv(pattern = "HGagC", names(gus_wide))
new_names = paste0("in_", str_extract(var_cols, pattern = "^[:alpha:]{2}")) 

attend = gus_wide |> select(Idnumber, all_of(var_cols))
attend = make_misscols(df=attend, var_cols = var_cols, new_names = new_names) |> 
  select(Idnumber, all_of(new_names))
gus_wide = merge(gus_wide, attend, by = "Idnumber")

## Rename age columns and convert into years ----
gus_wide = gus_wide |> mutate(across(.cols = ends_with("HGagc"), ~ .x/12)) |> 
  rename_with(.cols = ends_with("HGagC"), 
                          ~gsub(pattern = "HGagC", replacement = "_age", .x))

## Filter demographic vars and code as factors ----
sumvars = c("MeFaff04", "ALeSNim2", "Sex", "MeFaff3lvl", "EqvIncome",
            "DeSf12mn", "delivery_age", "tenure", "birthorder", "smokepreg",
            "MatEdu", "occupation", "ethnicity",
            grepv("D[[:alpha:]]\\_age", names(gus_wide)),
            grepv("in_", names(gus_wide)))

gus_wide = gus_wide |> 
  select(included, any_of(sumvars))

## Get GUS demogs ----
indat = gus_wide |> filter(included=="1")
gus_in = get_sum_stats(dat = indat, vars = sumvars) |> 
  filter(!str_detect(pattern = "^[in]{2}\\_[:alpha:]{2}\\_[0]{1}", Var))

exdat = gus_wide |> filter(included=="0")
gus_ex = get_sum_stats(dat = exdat, vars = sumvars) |> 
  filter(!str_detect(pattern = "^[in]{2}\\_[:alpha:]{2}\\_[0]{1}", Var))

descs = list("ALSPAC_included" = alspac_in, "ALSPAC_excluded" = alspac_ex,
             "GUS_included" = gus_in, "GUS_excluded" = gus_ex)

openxlsx::write.xlsx(descs, here("OUTPUT/", "Descriptives.xlsx"))
