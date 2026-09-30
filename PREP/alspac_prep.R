### TIDYING ALSPAC DATA AND CREATING WEIGHTS FOR USE IN TRAJECTORIES ###

# packages
library(haven)
library(tidyverse)
library(mice)
library(lme4)
library(here)

# load get_data_dict() and n_occ_missed()
i_am("PREP/alspac_prep.R")
source(here("FUNS", "prep.R"))

# Selecting variables to extract ----

# pregnancy ID, birth order, ID for mothers with >1 eligible pregnancies
ids = c("cidB3421", "qlet", "mz005l")

# SDQ scores for each timepoint
emot = c("kq348c", "ku707b", "kw6602b", "ta7025a", "tc4025a")
conduct = c("kq348d", "ku708b", "kw6603b", "ta7025b", "tc4025b")
hyper = c("kq348b", "ku706b", "kw6601b", "ta7025c", "tc4025c")
peer = c("kq348e", "ku709b", "kw6604b", "ta7025d", "tc4025d")

# Age at each timepoint
age = c("kq998a","ku991a","kw9991a", "ta9991a", "tc9991a")

# Covariates
covars = c("k6200", "kz021", "h470", "kimd2010q5")

# EPDS questions
epds = c("k3030","k3031","k3032","k3033","k3034","k3035","k3036","k3037","k3038","k3039")

# For generating weights 
# Variables used: maternal age, maternal education level, maternal social class, 
# parity, housing status, financial difficulties, smoking during pregnancy, 
# EPDS prenatal, EPDS postnatal, ethnicity
weightvars = c("mz028b", "c645a", "c755", "b032", "a006", "c525", "b665", "c601", "e391", "c804") 

vars = c(ids, covars, age, epds, emot, conduct, hyper, peer, weightvars)

# Tidying ALSPAC data ----
dat = read_dta("ALSPAC.dta", col_select = all_of(vars)) # saves reading the full thing in

# Keep data dictionary in environment to explore
dict = get_data_dict(dat)
write.csv(dict, "DATA/dict_usedvars.csv", row.names = F)

# Remove labelling
dat = dat |> zap_labels() |> zap_label() |> zap_formats()

# Recode NAs
# consent withdrawn (-9999), not known (-2), not enrolled (-1),
# invalid completion date (-9), triplet/quadruplet (-11), 
# not completed (-10), section omitted (-6), >2 components omitted (-5), 
missings=c(-9999, seq.int(from = -11, to = -1, by = 1))
income_miss = c(0, 9) # other and dk

dat = dat |> mutate(across(everything(), ~ifelse(.x %in% missings, NA, .x)),
                    h470 = ifelse(h470 %in% income_miss, NA, h470),
                    across(all_of(epds), ~na_if(.x,0)), #other text answer
                    ID = str_c(cidB3421, qlet, sep = "_")) #make unique ppt ID
dat = dat |> relocate(ID, .before = cidB3421)
head(dat[,1:3])

## Recode factor levels
alspac = dat |> mutate(
  
  # covariates 
  
  sex = factor(kz021, levels = c(1, 2), labels = c("Male", "Female")),
  income = factor(h470, levels = c(5, 4, 3, 2, 1), 
                labels = c(">400", "300-399", "200-299", "100-199", "<100"),
                ordered = T),
  foodDiff = factor(k6200, levels = c(4, 3, 2, 1), 
                 labels = c("Not difficult", "Slightly", "Fairly", "Very"),
                 exclude = 5, ordered = T),
  IMD = factor(kimd2010q5, levels = c(1, 2, 3, 4, 5), ordered = T),# 1=least deprived
  
  # weighting variables
  matAge = mz028b,
  matEd = case_match(c645a,
                    c(4, 5) ~ ">=A level",
                    3 ~ "O level",
                    c(1, 2) ~ "<O level") |> fct_relevel(">=A level"),
  matClass = case_match(c755,
                        c(1, 2) ~ "I-II",
                        c(3:6) ~ "III-V",
                        65 ~ NA) |> fct_relevel("I-II"), #65 = armed forces
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

# Calculate EPDS ----

# values need to be recoded to be 0-3
# Correct direction: C24, C25, C27
# To be reverse scored: C26, C28, C29, C30, C31, C32, C33

fwd = c("k3030", "k3031", "k3033")
rev = c("k3032", "k3034", "k3035", "k3036", "k3037", "k3038", "k3039")

alspac = alspac |> mutate(
  across(all_of(fwd), ~ .x - 1),
  across(all_of(rev), ~ 4 - .x)
)

alspac |> select(all_of(epds)) |> mutate(across(everything(), as.factor)) |> 
  summary()

alspac$epds = alspac |> select(all_of(epds)) |> rowSums()

alspac = alspac |> select(-all_of(epds))

saveRDS(alspac, "DATA/ALSPAC_Wide_Pre_Imputed.rds")

# Missing values ----
alspac = readRDS("DATA/ALSPAC_Wide_Pre_Imputed.rds")

# Exclude participants with missing FI/covariate data
completecols = c("foodDiff", "sex", "income", "IMD", "epds")
include = complete.cases(alspac[,completecols])
table(include) #8889 with missing FI/covariates were excluded, 6756 included
inc_wide = alspac[include,]

sdqcols = list(emot.miss = emot, conduct.miss = conduct, hyper.miss = hyper, 
                 peer.miss = peer)

inc_wide = n_occ_missed(df = inc_wide, cols = sdqcols)
inc_wide |> select(ends_with(".miss")) |> apply(2, max)

# Keep participants with at least 2 measurements on any SDQ subscale
keepDat = n_occ_missed(df = inc_wide, cols = sdqcols) |> 
  filter(if_any(ends_with(".miss"), function(x) x<4))
nrow(inc_wide) - nrow(keepDat) #957 excluded, 5799 remaining

# Create unrelated sample ----

# Sibling pregnancies to keep/drop
# see 2022 ALSPAC mothers update in Wellcome Open Res (https://doi.org/10.12688/wellcomeopenres.18564.2)
# Yes, drop these mult mums = 1, No, keep all these cases = 2
as.factor(keepDat$mz005l) |> table()
keepDat = keepDat |> filter(mz005l==2) #17 cases dropped, 5782 remaining

# Select one participant from each set of twins, weighted by the proportion of 
# valid information
unrelated = keepDat |> group_by(cidB3421) |> filter(n()==1) |> 
  ungroup() |> pull(ID) #5658 singleton pregnancies
related = keepDat |> group_by(cidB3421) |> filter(n()!=1) |> ungroup() |> 
  select(cidB3421, ID, qlet, ends_with(".miss")) |> 
  mutate(total.miss = (emot.miss + conduct.miss + hyper.miss + peer.miss),
         prop.valid = 1 - total.miss/20)
length(unique(related$cidB3421)) #62 twin pregnancies (124 twin ppts)

set.seed(9093029)

for (i in unique(related$cidB3421)) {
  fam = related |> filter(cidB3421==i)
  A = fam |> filter(qlet == "A") |> pull(prop.valid)
  B = fam |> filter(qlet == "B") |> pull(prop.valid)
  ppt = sample(x = c("A", "B"), prob = c(A, B), size = 1)
  keep = fam |> filter(qlet==ppt) |> pull(ID)
  unrelated = c(unrelated, keep)
}

# drop unused columns, except cid column which has family ids
keepDat = keepDat |> filter(ID %in% unrelated) |> 
  select(-ends_with(".miss"), -all_of(c(weightvars, covars[-1]))) # n=5720
rm(alspac, sdqcols, fam, inc_wide, related)

# Impute missing weights variables ----

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

alspac_imp = futuremice(imp, m = 20, method = meth, parallelseed = 2025)
alspac_imp = cbind(alspac_imp, not_imputed)

# Make weights ----

# First, make columns for attendance at each sweep using age as proxy for attendance
var_cols = c("kq998a","ku991a","kw9991a", "ta9991a", "tc9991a")
# alspac sweeps are denoted by the first 2 characters:
new_names = paste0("in_", str_extract(var_cols, pattern = "^[:alpha:]{2}")) 

attend = keepDat |> select(ID, all_of(var_cols))
attend = make_misscols(df=attend, var_cols = var_cols, new_names = new_names) |> 
  select(all_of(new_names))

alspac_imp = cbind(alspac_imp, attend)

# Predict response at each sweep ----
wt_preds = c("sex", "ethnicity", "finDiff", "smokePreg", "matClass", "matAge", "epdsPre", "epdsPost", "matEd", "parity", "housing")
att = names(alspac_imp$data)[grep("in_", names(alspac_imp$data))]

# Fit glm, get predicted probabilities, make ipw and stabilise sample size
alspac_weighted = make_wt(mids.df = alspac_imp, outcome = att, preds = wt_preds, 
                          idcol = "ID")

# check probability at each sweep
alspac_weighted$sweep_prob

final_alspac = cbind(alspac_imp$data, alspac_weighted$weights_df)

head(final_alspac)
nrow(final_alspac)
names(final_alspac)

final_alspac |>  select(matches("in_")) |>  summary()

## save weights
saveRDS(alspac_weighted, file="DATA/alspac_weights.rds")

# Wide to long ----

# make new column names for long columns

dat = final_alspac |> 
  rename_with(.cols = all_of(age),
              ~paste0(str_extract(.x, pattern = "^[:alpha:]{2}"),"_age")) |> 
  rename_with(.cols = all_of(conduct),
              ~paste0(str_extract(.x, pattern = "^[:alpha:]{2}"),"_conduct")) |> 
  rename_with(.cols = all_of(emot),
              ~paste0(str_extract(.x, pattern = "^[:alpha:]{2}"),"_emot")) |> 
  rename_with(.cols = all_of(hyper),
              ~paste0(str_extract(.x, pattern = "^[:alpha:]{2}"),"_hyper")) |> 
  rename_with(.cols = all_of(peer),
              ~paste0(str_extract(.x, pattern = "^[:alpha:]{2}"),"_peer")) |> 
  rename_with(.cols = all_of(matches("ipw_in_")),
              ~paste0(str_extract(.x, pattern = "[:alpha:]{2}$"),"_ipw"))

dat.long = dat |> 
  pivot_longer(cols = grep(pattern = "^kq_|^ku_|^kw_|^ta_|^tc_", names(dat)), 
               names_sep = "_", names_to = c("sweep", ".value"))

## Drop rows with no data on any SDQ subscales
dat.long = dat.long |> 
  filter(if_any(.cols = c(conduct, emot, hyper, peer), 
                .fns = function(x) !is.na(x))) |> 
  mutate(Age = age/12) |> 
  select("ID", "sweep", "foodDiff", "Age", "sex", "income", "IMD", "epds", 
         "conduct", "emot", "hyper", "peer", "ipw")

## Mean centre age and make 3-level FI
dat.long = dat.long |> mutate(
  age.cent = Age - mean(Age, na.rm = T),
  foodDiff3 = factor(
    foodDiff, levels = c("Not difficult", "Slightly", "Fairly", "Very"),
    labels = c("Not difficult", "Slightly", "Fairly/Very", "Fairly/Very"), 
    ordered = T))

saveRDS(dat.long, "DATA/ALSPAC_long.rds")
