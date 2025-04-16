### EXTRACTING ALSPAC VARIABLES FOR FI TRAJECTORIES ###

#packages
library(haven)
library(tidyverse)

# Specify variable names to extract
#SDQ scores for each timepoint
emot = c("kq348c", "ku707b", "kw6602b", "ta7025a", "tc4025a")
conduct = c("kq348d", "ku708b", "kw6603b", "ta7025b", "tc4025b")
hyper = c("kq348b", "ku706b", "kw6601b", "ta7025c", "tc4025c")
peer = c("kq348e", "ku709b", "kw6604b", "ta7025d", "tc4025d")
prosoc = c("kq348a", "ku705b", "kw6600b", "ta7025e", "tc4025e")

age = c("kq998a","ku991a","kw9991a", "ta9991a", "tc9991a")

demogs = c("cidB3421", "k6200", "k6221", "kz021", "h470", "kimd2010q5")
epds = c("k3030","k3031","k3032","k3033","k3034","k3035","k3036","k3037","k3038","k3039")

vars = c(demogs, age, epds, emot, conduct, hyper, peer, prosoc)

# Read in data
dat = read_dta("/exports/cmvm/datastore/scs/groups/ALSPAC/data/B3421/B3421_Whalley_20Mar25.dta", 
               col_select = all_of(vars))

# Remove labelling
dat = dat |> zap_labels() |> zap_label() |> zap_formats()

# Code NAs (invalid completion, triplet/quadruplet, not completed, omitted, 
#missing, not known, not enrolled, don't know)
missings=c(-9999, -2, -1, -9, -8, -11, -10, -6, -5)
exmiss = c(0, 9)
dat = dat |> mutate(across(everything(), ~ifelse(.x %in% missings, NA, .x)),
                    across(h470:kimd2010q5, ~ifelse(.x %in% exmiss, NA, .x)))

# Recode factors
dat.test = dat |> mutate(
  kz021 = factor(kz021, levels = c(1, 2), labels = c("Male", "Female")),
  h470 = factor(h470, levels = c(1, 2, 3, 4, 5), 
                labels = c("<100", "100-199", "200-299", "300-399", ">400"),
                ordered = T),
  k6200 = factor(k6200, levels = c(1, 2, 3, 4), 
                 labels = c("Very", "Fairly", "Slightly", "Not difficult"),
                 exclude = 5) |> relevel(ref = "Not difficult"),
  k6221 = factor(k6221, levels = c(1, 2, 3), 
                 labels = c("Too much", "Right amount", "Too little")) |> 
    relevel(ref = "Right amount"),
  kimd2010q5 = factor(kimd2010q5, levels = c(1, 2, 3, 4, 5), ordered = T))

# EPDS needs recoded to be 0-3
# Correct direction: C24, C25, C27
# Reversed: C26, C28, C29, C30, C31, C32, C33
fwd = c("k3030", "k3031", "k3033")
rev = c("k3032", "k3034", "k3034", "k3036", "k3037", "k3038", "k3039")

dat.test = dat.test |> mutate(
  across(all_of(fwd), ~ .x - 1),
  across(all_of(rev), ~ 4 - .x)
)

dat.test$epds = dat.test |> select(all_of(epds)) |> rowSums()
dat = dat.test |> select(-all_of(epds))
#saveRDS(dat, "ALSPAC_wide.rds")

### WIDE TO LONG ###
# make new column names for long columns

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
      str_extract(.x, pattern = "^[:alpha:]{2}"),"_prosoc"))

dat.long = dat |> 
  pivot_longer(cols = kq_prosoc:tc_age, names_sep = "_",
               names_to = c("sweep", ".value"))

##For consistent sample size, restrict sample to those with complete SDQ data (listwise deletion of missing rows - i.e. if they missed a timepoint they can still be included), food insecurity data and covariate data (DeEqv5, DeSf12mn, ALeSNim2)
completecols = c(demogs, "age", "conduct", "emot", "hyper", "peer", "prosoc")
dat.long = dat.long[complete.cases(dat.long[, completecols]),]
dat.long$Age = dat.long$age/12 #change age into years

#mean centre age
dat.long$age.cent = dat.long$Age - mean(dat.long$Age, na.rm = T)

write.csv(dat.long, "G://users/eileen/Food_Ins/DATA/ALSPAC_long.csv")
saveRDS(dat.long, "G://users/eileen/Food_Ins/DATA/ALSPAC_long.rds")
