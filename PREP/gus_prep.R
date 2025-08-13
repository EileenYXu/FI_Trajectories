#### Preparing GUS data for trajectory models ####

#### packages
library(tidyverse)

## variable names to extract at each sweep
vars = c("IDNumber|HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1|wtbth2")

#### Sweep 5 data ####
sw5 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw5_b_protect.tab") %>%
  select(grep(paste0(vars, "|HGsx1$|MeFaff04|DeMedu03|DeYedu03|DeEqv5|AleSNim2|DeHGbord|DeSf12mn|DeMsta01|DeMeth07"), names(.), ignore.case = TRUE))

## code NAs, organise factor levels
na_strings = c(-1:-9)
sw5 = sw5 %>% mutate(
  across(
    everything(), .fns = ~ifelse(.x %in% na_strings, NA, .x)))

sw5 = sw5 %>% mutate(
  HighEd = ifelse(as.numeric(DeMedu03)>=as.numeric(DeYedu03), 
                  DeMedu03, DeYedu03) %>% 
    factor(labels = c("No qualification", "Other", "GCSEs", 
                      "A levels", "HNC, HND or equivalent", "Degree")) %>%
  relevel(ref = "No qualification"),

  Sex = factor(MeHGsx1, labels = c("M", "F")),
  
  Food = factor(MeFaff04, labels = c(1, 1, 1, 0)) %>% relevel(ref = "0"),
  
  MeFaff3lvl = factor(MeFaff04,
                      labels = c("A lot/fair amount", "A lot/fair amount",
                                 "A little", "Not at all")) %>% 
    relevel(ref = "Not at all"),
  
  MeFaff04 = factor(MeFaff04,
                    labels = c("A_lot", "A_fair_amount", "A_little",
                               "Not_at_all")) %>% relevel(ref = "Not_at_all"),
  
  MatEdu = factor(DeMedu03, 
                    labels = c("No qualification", "Other",
                               "GCSEs", "A levels", "HNC, HND or equivalent",
                               "Degree")),
  
  PtnrEdu = factor(DeYedu03, 
                    labels = c("No qualification", "Other",
                               "GCSEs", "A levels", "HNC, HND or equivalent",
                               "Degree")),
  
  EqvIncome = factor(DeEqv5,
                  labels = c("Bottom Quintile (<B#12,217)",
                             "2nd Quintile (>=B#12,217 <B#19,643)", 
                             "3rd Quintile (>=B#19,643 < B#29,126)",
                             "4th Quintile (>=B#29,126 < B#37,857)",
                             "Top Quintile (>=B#37,857)")),
  
  MatEmploy = factor(DeMsta01, 
                    labels = c("Full time", "Part time", "Not working")),
  
  MatEthnicity = factor(DeMeth07, 
                    labels = c("White", "Other ethnic background")),
  
  #for easier model output, keep education vars and income to numbers
  DeMedu03 = as.factor(DeMedu03),
  DeYedu03 = as.factor(DeYedu03),
  DeEqv5 = as.factor(DeEqv5) %>% relevel(ref = 5), #reference level is highest income
  ALeSNim2 = factor(ALeSNim2) %>% relevel(ref = 1) #ref is highest SIMD, 1 is lowest i.e. least deprived
)

# how many individuals are missing FI or covariates?

completecols = c("MeFaff04","MeHGsx1", "DeEqv5", "ALeSNim2", "DeSf12mn")
table(complete.cases(sw5[,completecols]))


#### Sweeps 6-10 SDQ ####

sw6 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw6_b_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw7 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw7_b_oct2020_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw8 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw8_b_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw9 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw9_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

#make sure to read in sweep 10 longitudinal weights
sw10 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_bc1sw10_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw10 = sw10 |> select(-Djwtbth2f)

#### Merge SDQ data into wide dataset ####
names(sw9)[1] = "Idnumber"
names(sw10) = c("Idnumber", "DjHGagC", "DjDsdem1", "DjDsdco1", "DjDsdhy1", "DjDsdpr1", "DjDsdps1", "DjDsdto1", "DjWTbth2")

# first merge sweeps 5 - 8 which have all the SDQ data but no boost sample
sdq = list(sw5, sw6, sw7, sw8) %>% reduce(left_join, by='Idnumber')

# now merge in sweep 9 and 10 data, dropping unmatched rows from boost sample
dat_wide = list(sdq, sw9, sw10) %>% reduce(left_join, by ="Idnumber", unmatched = "drop")

na_strings = c(-1:-9)
dat_wide = dat_wide %>% mutate(
  across(
    where(is.numeric), .fns = ~ifelse(.x %in% na_strings, NA, .x)))
dat_wide = droplevels(dat_wide)

#### sweep 4 social support ####

sw4 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw4_b_nov11_protect.tab") %>% select(grep("Idnumber|MdSNsp01", names(.), ignore.case = T))

sw4 = sw4 %>% mutate(across(c(MdSNsp01), ~na_if(., -1)),
                     MdSNsp01 = factor(MdSNsp01, labels = c("Enough", "Not enough", "None", "Don't need any")) %>% relevel(ref = "Enough"),
                     help_bin = case_when(
                       MdSNsp01=="Enough" ~ "Enough",
                       MdSNsp01=="Don't need any" ~ NA,
                       .default = "Not enough") %>% as.factor() %>% relevel("Enough")
)

dat_wide = merge(dat_wide, sw4, by = "Idnumber", all.x = T, all.y = F)

dat_wide = dat_wide %>% mutate(
  food_help = case_when(
    is.na(help_bin)==T ~ NA,
    .default = paste(MeFaff3lvl, help_bin, sep = ".")
  ) %>% fct_relevel("Not at all.Enough")
)

# Save wide dataset 
saveRDS(dat_wide, "G://users/eileen/Food_Ins/DATA/GUS_wide.rds")

# for analysis, remove columns with descriptive factor levels
dat_wide = dat_wide %>% select(-c(MatEdu, PtnrEdu, EqvIncome, MatEmploy, MatEthnicity))

#### Wide to long ####
sdq = c("HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1|WTbth2")

dat_long = dat_wide %>% pivot_longer(
  cols = grep(paste0(sdq), names(.), ignore.case = T),
  cols_vary = "slowest",
  names_to = c("sweep", ".value"),
  names_pattern = "(^D[efghij])(HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1|WTbth2)"
)

#### For main FI analyses ####

## Remove rows with missing age/SDQ/covariates 
completecols = c("HGagC", "Dsdem1", "Dsdco1", "Dsdhy1", "Dsdpr1", "Dsdto1", 
                 "MeFaff3lvl", "DeEqv5", "DeSf12mn", "ALeSNim2", "WTbth2")
index = complete.cases(dat_long[,completecols])
dat_complete = dat_long[index,]

## Now remove individuals with less than 2 datapoints. (need at least 2 for linear model)
ids_remove = dat_complete |> group_by(Idnumber) |> summarise(N = n()) |> 
  filter(N < 2) |> pull(Idnumber)

dat_mod = dat_complete |> filter(!(Idnumber %in% ids_remove)) |> 
  mutate(Age = HGagC/12, #age in years
         age.cent = (HGagC/12) - mean((HGagC/12), na.rm = T)) #age in years and mean centred

saveRDS(dat_mod, "G://users/eileen/Food_Ins/DATA/GUS_long.rds")
