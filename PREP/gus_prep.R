#### TIDYING GUS DATA FOR TRAJECTORIES ####

# Packages ----
library(tidyverse)
library(here)

i_am("PREP/gus_prep.R")
source(here("FUNS", "prep.R"))

# Extract ID, age, SDQ and GUS longitudinal weights at each sweep
vars = c("IDNumber|HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|wtbth2")
sw5vars = paste0(vars,
             "|HGsx1$|MeFaff04|DeMedu03|DeYedu03|DeEqv5|AleSNim2|DeHGbord|DeSf12mn|DeMsta01|DeMeth07")

# Sweep 5 data ----
sw5 = read.delim("DATA/GUS/gus_cohort1_sw5_b_protect.tab") |> 
  select(matches(sw5vars, ignore.case = T))

# Recode NAs
na_strings = c(-1:-9)
sw5 = sw5 |> mutate(
  across(
    everything(), .fns = ~ifelse(.x %in% na_strings, NA, .x)))

# Organise factors and set reference levels
# For education, 'Other' was added between 'no qualification' and 'GSCE ...' 
EdLabs = c("Degree", "HNC, HND or equivalent", "A levels", "GCSEs", "Other",
           "No qualification")

sw5 = sw5 |> mutate(
  
  # Highest parental education level
  HighEd = ifelse(as.numeric(DeMedu03)>=as.numeric(DeYedu03), 
                  DeMedu03, DeYedu03) |> 
    factor(levels = c(6, 5, 4, 3, 2, 1),
           labels = c(EdLabs), ordered = T),
  # Child sex
  Sex = factor(MeHGsx1, labels = c("M", "F")),
  # 3-level FI
  MeFaff3lvl = factor(MeFaff04, levels = c(4, 3, 2, 1),
                      labels = c("Not at all", "A little", "A lot/fair amount",
                                 "A lot/fair amount"), ordered = T),
  # 4-level FI
  MeFaff04 = factor(MeFaff04, levels = c(4, 3, 2, 1),
                    labels = c("Not_at_all", "A_little", "A_fair_amount",
                               "A_lot"), ordered = T),
  
  MatEdu = factor(DeMedu03, levels = c(6, 5, 4, 3, 2, 1),
                  labels = c(EdLabs), ordered = T),
  PtnrEdu = factor(DeYedu03, levels = c(6, 5, 4, 3, 2, 1),
                   labels = c(EdLabs), ordered = T),
  
  # Highest income as reference level
  EqvIncome = factor(DeEqv5, levels = c(1, 2, 3, 4, 5),
                     labels = c("Bottom Quintile (<12,217)",
                                "2nd Quintile (>=12,217 <19,643)",
                                "3rd Quintile (>=19,643 <29,126)",
                                "4th Quintile (>=29,126 <37,857)",
                                "Top Quintile (>=37,857)"), ordered = T) |> 
    fct_rev(),
  
  MatEmploy = factor(DeMsta01, 
                    labels = c("Full time", "Part time", "Not working")),
  MatEthnicity = factor(DeMeth07, 
                        labels = c("White", "Other ethnic background")),
  
  # Highest income as reference level 
  DeEqv5 = factor(DeEqv5, levels = c(5, 4, 3, 2, 1),
                  labels = c("Highest", "Q4", "Q3", "Q2", "Lowest")), 
  
  # Least deprived (1st quintile) as reference level for SIMD
  ALeSNim2 = factor(ALeSNim2, ordered = T) 
)

glimpse(sw5)
sw5 |> select(where(is.factor)) |> sapply(levels) # check reference levels

# Sweeps 6-10 SDQ ----
sw6 = read.delim("DATA/GUS/gus_cohort1_sw6_b_protect.tab") |> 
  select(matches(vars, ignore.case = T))

sw7 = read.delim("DATA/GUS/gus_cohort1_sw7_b_oct2020_protect.tab") |> 
  select(matches(vars, ignore.case = T))

sw8 = read.delim("DATA/GUS/gus_cohort1_sw8_b_protect.tab") |> 
  select(matches(vars, ignore.case = T))

sw9 = read.delim("DATA/GUS/gus_cohort1_sw9_protect.tab") |> 
  select(matches(vars, ignore.case = T))

sw10 = read.delim("DATA/GUS/gus_bc1sw10_protect.tab") |> 
  select(matches(vars, ignore.case = T))

# Remove longitudinal weight from face-to-face data collection only
sw10 = sw10 |> select(-Djwtbth2f)

# Merge SDQ data into wide dataset ----
names(sw9)[1] = "Idnumber"
names(sw10) = c("Idnumber", "DjHGagC", "DjDsdem1", "DjDsdco1", "DjDsdhy1", "DjDsdpr1", "DjWTbth2")

# first merge sweeps 5 - 8 which have all the SDQ data but no boost sample
sdq = list(sw5, sw6, sw7, sw8) |> reduce(left_join, by="Idnumber")

# now merge in sweep 9 and 10 data, dropping unmatched rows from boost sample
dat_wide = list(sdq, sw9, sw10) |> reduce(left_join, by ="Idnumber", unmatched = "drop")

# recode NAs in sweep 6-10 data
na_strings = c(-1:-9)
dat_wide = dat_wide |> mutate(
  across(
    where(is.numeric), .fns = ~ifelse(.x %in% na_strings, NA, .x))) |> droplevels()

glimpse(dat_wide)

# Save wide dataset 
saveRDS(dat_wide, "DATA/GUS_wide.rds")
rm(sw5, sw6, sw7, sw8, sw9, sw10, sdq)

# Remove columns not used in analyses
dat_wide = readRDS("DATA/GUS_wide.rds")

cols = "IDNumber|MeFaff|Sex|Eqv5|Sf12mn|ALeSNim2|HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|wtbth2"
dat_wide = dat_wide |> select(matches(cols))
glimpse(dat_wide)

# Check missing values ----
# Exclude participants with missing FI/covariate data
completecols = c("MeFaff04","Sex", "DeEqv5", "ALeSNim2", "DeSf12mn") 
include = complete.cases(dat_wide[,completecols])
table(include) # 243 ppts missing FI/covariate data were excluded
inc_wide = dat_wide[include,]

sdqcols = list(emot.miss = grepv("Dsdem1", names(dat_wide)), 
               conduct.miss = grepv("Dsdco1", names(dat_wide)), 
               hyper.miss = grepv("Dsdhy1", names(dat_wide)), 
               peer.miss = grepv("Dsdpr1", names(dat_wide)))

n_occ_missed(df = inc_wide, cols = sdqcols) |> 
  select(ends_with(".miss")) |> apply(2, max)

# Keep participants with at least 2 measurements on any SDQ subscale
inc_wide = n_occ_missed(df = inc_wide, cols = sdqcols) |> 
  filter(if_any(ends_with(".miss"), function(x) x<5))
nrow(dat_wide[include,]) - nrow(inc_wide) #188 excluded

# Wide to long ----
sdq = c("HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|WTbth2")

dat_long = inc_wide |> pivot_longer(
  cols = grep(paste0(sdq), names(inc_wide), ignore.case = T),
  cols_vary = "slowest",
  names_to = c("sweep", ".value"),
  names_pattern = "(^D[efghij])(HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|WTbth2)"
)

# Drop rows with no data on any SDQ subscales
dat_long = dat_long |> 
  filter(if_any(.cols = c(Dsdem1, Dsdco1, Dsdhy1, Dsdpr1), 
                .fns = function(x) !is.na(x))) |> 
  mutate(Age = HGagC/12, #Convert age to years
         age.cent = (HGagC/12) - mean((HGagC/12), na.rm = T)) #mean centre age

saveRDS(dat_long, "DATA/GUS_long.rds")
