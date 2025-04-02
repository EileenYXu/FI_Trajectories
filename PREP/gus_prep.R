#packages
library(tidyverse)

vars = c("IDNumber|HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1")

#------------------ sweep 5 demographics ----------------

sw5 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw5_b_protect.tab")

sw5 = sw5 %>% select(grep(paste0(vars, "|HGsx1$|MeFaff04|DeMedu03|DeYedu03|DeEqv5|AleSNim2|DeHGbord|DeSf12mn|DeMsta01|DeMeth07"), 
                          names(.), ignore.case = TRUE))
na_strings = c(-1:-9)
sw5 = sw5 %>% naniar::replace_with_na_all(condition = ~.x %in% na_strings)

#------------- recoding levels ----------------
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
  ALeSNim2 = factor(ALeSNim2) %>% relevel(ref = 5) #ref is highest SIMD, 1 is lowest i.e. most deprived
)

# save this demographics file for easy access
write.csv(sw5, "G://users/eileen/Food_Ins/DATA/sw5_demog.csv")
saveRDS(sw5, "G://users/eileen/Food_Ins/DATA/sw5_demog.rds")

# for analysis, remove columns with descriptive factor levels
sw5 = sw5 %>% select(-c(MatEdu, PtnrEdu, EqvIncome, MatEmploy, MatEthnicity))

#-------------------- sweeps 6-10 ----------------

sw6 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw6_b_protect.tab")
sw6 = sw6 %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw7 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw7_b_oct2020_protect.tab")
sw7 = sw7 %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw8 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw8_b_protect.tab")
sw8 = sw8 %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw9 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw9_protect.tab")
sw9 = sw9 %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw10 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_bc1sw10_protect.tab")
sw10 = sw10 %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

#Rename columns to merge into wide dataset
names(sw9)[1] = "Idnumber"
names(sw10) = c("Idnumber", "DjHGagC", "DjDsdem1", "DjDsdco1", "DjDsdhy1", "DjDsdpr1", "DjDsdps1", "DjDsdto1")
dfs = list(sw5, sw6, sw7, sw8, sw9, sw10)
dat_wide = dfs %>% reduce(left_join, by='Idnumber')

na_strings = c(-1:-9)
dat_wide = dat_wide %>% naniar::replace_with_na_all(condition = ~.x %in% na_strings)
dat_wide = droplevels(dat_wide)

##Save wide
write.csv(dat_wide, "G://users/eileen/Food_Ins/DATA/GUS_wide.csv")
saveRDS(dat_wide, "G://users/eileen/Food_Ins/DATA/GUS_wide.rds")


##Make long SDQ scores
dat_wide = readRDS("G://users/eileen/Food_Ins/DATA/GUS_wide.rds")

sdq = c("HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1")

dat_long = dat_wide %>% pivot_longer(
  cols = grep(paste0(sdq), names(.), ignore.case = T),
  cols_vary = "slowest",
  names_to = c("sweep", ".value"),
  names_pattern = "(^D[efghij])(HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1)"
)

##For consistent sample size, restrict sample to those with complete SDQ data (listwise deletion of missing rows - i.e. if they missed a timepoint they can still be included), food insecurity data and covariate data (DeEqv5, DeSf12mn, ALeSNim2)
completecols = c("MeFaff04", "DeEqv5", "ALeSNim2", "Dsdem1", "Dsdco1", "Dsdhy1", "Dsdpr1", "Dsdto1")

dat_long = dat_long[complete.cases(dat_long[, completecols]),]
dat_long$Age = dat_long$HGagC/12 #change age into years

#mean centre age
dat_long$age.cent = dat_long$Age - mean(dat_long$Age, na.rm = T)

write.csv(dat_long, "G://users/eileen/Food_Ins/DATA/GUS_long.csv")
saveRDS(dat_long, "G://users/eileen/Food_Ins/DATA/GUS_long.rds")
