### TIDYING ALSPAC DATA AND CREATING WEIGHTS FOR USE IN TRAJECTORIES ###

# packages
library(haven)
library(tidyverse)
library(mice)
library(lme4)
library(here)

# load get_data_dict() and n_occ_missed()
i_am("PREP/alspac_prep.R")
source(here::here("FUNS", "prep.R"))

# Selecting variables to extract ----

# SDQ scores for each timepoint
emot = c("kq348c", "ku707b", "kw6602b", "ta7025a", "tc4025a")
conduct = c("kq348d", "ku708b", "kw6603b", "ta7025b", "tc4025b")
hyper = c("kq348b", "ku706b", "kw6601b", "ta7025c", "tc4025c")
peer = c("kq348e", "ku709b", "kw6604b", "ta7025d", "tc4025d")
prosoc = c("kq348a", "ku705b", "kw6600b", "ta7025e", "tc4025e")

# Age at each timepoint
age = c("kq998a","ku991a","kw9991a", "ta9991a", "tc9991a")

# Covariates
covars = c("cidB3421", "qlet", "k6200", "k6221", "kz021", "h470", "kimd2010q5")

# EPDS questions
epds = c("k3030","k3031","k3032","k3033","k3034","k3035","k3036","k3037","k3038","k3039")

# For generating weights 
# Variables used: maternal age, maternal education level, maternal social class, parity, housing status,
# financial difficulties, smoking during pregnancy, EPDS prenatal, EPDS postnatal, ethnicity
weightvars = c("mz028b", "c645a", "c755", "b032", "a006", "c525", "b665", "c601", "e391", "c804") 

vars = c(covars, age, epds, emot, conduct, hyper, peer, prosoc, weightvars)

# Read in data ----

dat = read_dta("/exports/cmvm/datastore/scs/groups/ALSPAC/data/B3421/B3421_Whalley_20Mar25.dta", 
               col_select = all_of(vars)) # saves reading the full thing in

# Keep data dictionary in environment to explore
dict = get_data_dict(dat)

# Remove labelling
dat = dat |> zap_labels() |> zap_label() |> zap_formats()

# Recode NAs ----

# invalid completion, triplet/quadruplet, not completed, omitted, missing, not known, not enrolled, don't know - all set to NA

missings=c(-9999, -2, -1, -9, -8, -11, -10, -6, -5, -7)
income_miss = c(0, 9)
dat = dat |> mutate(across(everything(), ~ifelse(.x %in% missings, NA, .x)),
                    h470 = ifelse(h470 %in% income_miss, NA, h470),
                    across(all_of(epds), ~na_if(.x,0)),
                    ID = str_c(cidB3421, qlet, sep = "_"))
head(dat[,1:3])
dat = dat |> relocate(ID, .before = cidB3421)

# Recode factors ----

alspac = dat |> mutate(
  
  # covariates 
  
  sex = factor(kz021, levels = c(1, 2), labels = c("Male", "Female")),
  income = factor(h470, levels = c(5, 4, 3, 2, 1), 
                labels = c(">400", "300-399", "200-299", "100-199", "<100"),
                ordered = T),
  foodDiff = factor(k6200, levels = c(4, 3, 2, 1), 
                 labels = c("Not difficult", "Slightly", "Fairly", "Very"),
                 exclude = 5),
  matHelp = factor(k6221, levels = c(2, 1, 3), 
                 labels = c("Right amount", "Too much", "Too little")),
  IMD = factor(kimd2010q5, levels = c(1, 2, 3, 4, 5), ordered = T),
  
  # weights 
  
  matAge = mz028b,
  matEd = case_match(c645a,
                    c(4, 5) ~ ">=A level",
                    3 ~ "O level",
                    c(1, 2) ~ "<O level") |> fct_relevel(">=A level"),
  matClass = case_match(c755,
                        c(1, 2) ~ "I-II",
                        c(3:6) ~ "III-V",
                        65 ~ NA) |> fct_relevel("I-II"),
  parity = case_match(b032,
                      0 ~ "1st born",
                      1 ~ "2nd born",
                      c(2:22) ~ "3rd +") |> fct_relevel("1st born"),
  housing = case_match(a006,
                       c(0, 1) ~ "Mortgage/Owned",
                       c(3, 4) ~ "Private rented",
                       c(2, 5) ~ "Subsidised rented",
                       6 ~ NA) |> fct_relevel("Mortgage/Owned"),
  finDiff = case_match(c525, c(0:4) ~ "0", c(5:15) ~ "1") |> fct_relevel("0"),
  smokePreg = case_match(b665, 1 ~ "0", c(2:5) ~ "1") |> fct_relevel("0"),
  epdsPre = c601,
  epdsPost = e391,
  ethnicity = case_match(c804, 1 ~ "White", 2 ~ "Non-white") |> fct_relevel("White")
)

lapply(alspac, class) # check classes 

alspac |> select(where(is.factor)) |> sapply(levels) # check reference levels

# Calculate total EPDS ----

# values need to be recoded to be 0-3
# Correct direction: C24, C25, C27
# To be reverse scored: C26, C28, C29, C30, C31, C32, C33

fwd = c("k3030", "k3031", "k3033")
rev = c("k3032", "k3034", "k3034", "k3036", "k3037", "k3038", "k3039")

alspac = alspac |> mutate(
  across(all_of(fwd), ~ .x - 1),
  across(all_of(rev), ~ 4 - .x)
)

alspac$epds = alspac |> select(all_of(epds)) |> rowSums()

alspac = alspac |> select(-all_of(epds))

saveRDS(alspac, "/exports/eddie/scratch/s1659680/ALSPAC_Wide_Pre_Imputed.rds")

# Count up missings ----

alspac = readRDS("/exports/eddie/scratch/s1659680/ALSPAC_Wide_Pre_Imputed.rds")

countcols = list(emot.miss = emot, conduct.miss = conduct, hyper.miss = hyper, peer.miss = peer, age.miss = age)

alspac = n_occ_missed(df = alspac, cols = countcols)
alspac |> select(ends_with(".miss")) |> head() # just checking the function worked

# exclude anyone with .miss = 5 (no data for any of the sweeps)
# exclude anyone with missing sex, foodDiff or matHelp
keepDat = alspac |> filter(
  if_all(ends_with(".miss"), function(x) x!=5) & 
    if_all(c(sex, foodDiff, matHelp), function(x) is.na(x)==F)) 
nrow(keepDat)
# 8080 ppts total remaining

# drop unused columns, except cid column which has family ids
keepDat = keepDat |> select(-ends_with(".miss"), -all_of(c(weightvars, covars[-1])))

# Now impute ----

to_impute = c("matAge", "matEd", "matClass", "parity", "housing", "finDiff", "smokePreg", "epdsPre", "epdsPost", "ethnicity")
logreg = c("ethnicity", "finDiff", "smokePreg", "matClass")
cont = c("matAge", "epdsPre", "epdsPost")
polyreg = c("matEd", "parity", "housing")

imp = keepDat |> select(all_of(to_impute))
not_imputed = keepDat |> select(!all_of(to_impute))

# only impute variables in to_impute
meth = make.method(imp)
meth[setdiff(names(imp), to_impute)] = ""
meth[logreg] = "logreg"
meth[cont] = "norm"
meth[polyreg] = "polyreg"

meth

# only use variables in to_impute as predictors
predmat = make.predictorMatrix(imp)
predmat

alspac_imp = mice(imp, m = 20, method = meth, seed = 2025)

alspac_imp = cbind(alspac_imp, not_imputed)

save(alspac_imp, file = "ALSPAC_Imputed.rda")

# Make weights ----

load("ALSPAC_Imputed.rda")

# First, make columns for attendance at each sweep
var_cols = c("kq998a","ku991a","kw9991a", "ta9991a", "tc9991a") # age at sweep - proxy for attendance
new_names = paste0("in_", str_extract(var_cols, pattern = "^[:alpha:]{2}")) # alspac sweeps are denoted by the first 2 characters

attend = keepDat |> select(ID, all_of(var_cols))
attend = make_misscols(df=attend, var_cols = var_cols, new_names = new_names) |> select(all_of(new_names))

alspac_imp = cbind(alspac_imp, attend)

# glm to make weights ----

wt_preds = c("sex", "ethnicity", "finDiff", "smokePreg", "matClass", "matAge", "epdsPre", "epdsPost", "matEd", "parity", "housing")
att = names(alspac_imp$data)[grep("in_", names(alspac_imp$data))]

# Fit glm, get predicted probabilities, make ipw and stabilise sample size
alspac_weighted = make_wt(mids.df = alspac_imp, outcome = att, preds = wt_preds, idcol = "ID")

# check probability at each sweep
alspac_weighted$sweep_prob

final_alspac = cbind(alspac_imp$data, alspac_weighted$weights_df)

head(final_alspac)
nrow(final_alspac)
tail(final_alspac)
dim(final_alspac)
names(final_alspac)
glimpse(final_alspac)

final_alspac %>% select(grep("in_", names(.))) %>% summary()
final_alspac %>% select(grep("in_", names(.))) %>% head()

## save weights

saveRDS(alspac_weighted, file="estimated_alspac_weights.rds")

## save final dataset? 
head(final_alspac)

saveRDS(final_alspac, file="alspac_weighted.rds")

# to long ----

# make new column names for long columns

dat = readRDS("/exports/eddie/scratch/s1659680/alspac_weighted.rds")

dat = dat |> 
  rename_with(
  .cols = all_of(age),
  ~paste0(
    str_extract(.x, pattern = "^[:alpha:]{2}"),"_age")) |> 
  rename_with(
    .cols = all_of(conduct),
    ~paste0(
      str_extract(.x, pattern = "^[:alpha:]{2}"),"_conduct")) |> 
  rename_with(
    .cols = all_of(emot),
    ~paste0(
      str_extract(.x, pattern = "^[:alpha:]{2}"),"_emot")) |> 
  rename_with(
    .cols = all_of(hyper),
    ~paste0(
      str_extract(.x, pattern = "^[:alpha:]{2}"),"_hyper")) |> 
  rename_with(
    .cols = all_of(peer),
    ~paste0(
      str_extract(.x, pattern = "^[:alpha:]{2}"),"_peer")) |> 
  rename_with(
    .cols = all_of(prosoc),
    ~paste0(
      str_extract(.x, pattern = "^[:alpha:]{2}"),"_prosoc")) |> 
  rename_with(
    .cols = all_of(grep("ipw_in_", names(dat))),
    ~paste0(
      str_extract(.x, pattern = "[:alpha:]{2}$"),"_ipw"))

dat.long = dat |> 
  pivot_longer(cols = grep(pattern = "^kq_|^ku_|^kw_|^ta_|^tc_", names(dat)), names_sep = "_",
               names_to = c("sweep", ".value"))

##For consistent sample size, restrict sample to those with complete SDQ data (listwise deletion of missing rows - i.e. if they missed a timepoint they can still be included), food insecurity data and covariate data
completecols = c("age", "conduct", "emot", "hyper", "peer", "prosoc", "sex",
                 "income", "foodDiff", "IMD", "epds")
dat.long = dat.long[complete.cases(dat.long[, completecols]),]
dat.long$Age = dat.long$age/12 #change age into years

#mean centre age and make 3-level FI
dat.long = dat.long |> mutate(
  age.cent = Age - mean(Age),
  foodDiff3 = case_when(foodDiff == "Not difficult" ~ "Not difficult",
                        foodDiff == "Slightly" ~ "Slightly",
                        foodDiff %in% c("Fairly", "Very") ~ "Fairly/Very") |>
    fct_relevel("Not difficult")
)

# make matHelp binary and make food_help
dat.long = dat.long |> mutate(
  help_bin = ifelse(matHelp=="Too little", "Not enough", "Enough") |> fct_relevel("Enough"),
  food_help = paste0(foodDiff3,".", help_bin) |> fct_relevel("Not difficult.Enough")
)

saveRDS(dat.long, "/exports/igmm/datastore/GenScotDepression/users/eileen/Food_Ins/DATA/ALSPAC_long.rds")
