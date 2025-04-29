#### Preparing GUS data for trajectory models ####

#### packages
library(tidyverse)

## variable names to extract at each sweep
vars = c("IDNumber|HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1")

#### Sweep 5 data ####
sw5 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw5_b_protect.tab") %>%
  select(grep(paste0(vars, "|HGsx1$|MeFaff04|DeMedu03|DeYedu03|DeEqv5|AleSNim2|DeHGbord|DeSf12mn|DeMsta01|DeMeth07"), names(.), ignore.case = TRUE))

## code NAs, organise factor levels
na_strings = c(-1:-9)
sw5 = sw5 %>% naniar::replace_with_na_all(condition = ~.x %in% na_strings)
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

# how many individuals are missing FI or covariates?

completecols = c("MeFaff04","MeHGsx1", "DeEqv5", "ALeSNim2", "DeSf12mn")
table(complete.cases(sw5[,completecols]))


#### Sweeps 6-10 SDQ ####

sw6 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw6_b_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw7 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw7_b_oct2020_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw8 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw8_b_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

sw9 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_cohort1_sw9_protect.tab") %>% select(grep(paste0(vars), names(.), ignore.case = TRUE))

#make sure to read in sweep 10 longitudinal weights
sw10 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_bc1sw10_protect.tab") %>% select(grep(paste0(vars,"|Djwtbth2a"), names(.), ignore.case = TRUE))


#### Merge SDQ data into wide dataset ####
names(sw9)[1] = "Idnumber"
names(sw10) = c("Idnumber", "DjHGagC", "DjDsdem1", "DjDsdco1", "DjDsdhy1", "DjDsdpr1", "DjDsdps1", "DjDsdto1", "Djwtbth2a")

# first merge sweeps 5 - 8 which have all the SDQ data but no boost sample
sdq = list(sw5[complete.cases(sw5[,completecols]),], sw6, sw7, sw8) %>% reduce(left_join, by='Idnumber')

# now merge in sweep 9 and 10 data, dropping unmatched rows from boost sample
dat_wide = list(sdq, sw9, sw10) %>% reduce(left_join, by ="Idnumber", unmatched = "drop")

na_strings = c(-1:-9)
dat_wide = dat_wide %>% naniar::replace_with_na_all(condition = ~.x %in% na_strings)
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
  ) %>% as.factor() %>%
    relevel(ref = "Not at all.Enough")
)

##Save wide
write.csv(dat_wide, "G://users/eileen/Food_Ins/DATA/GUS_wide.csv")
saveRDS(dat_wide, "G://users/eileen/Food_Ins/DATA/GUS_wide.rds")


#### Wide to long ####

sdq = c("HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1")

dat_long = dat_wide %>% pivot_longer(
  cols = grep(paste0(sdq), names(.), ignore.case = T),
  cols_vary = "slowest",
  names_to = c("sweep", ".value"),
  names_pattern = "(^D[efghij])(HGagC|Dsdem1|Dsdco1|Dsdhy1|Dsdpr1|Dsdps1|Dsdto1)"
)

dat_long$Age = dat_long$HGagC/12 #change age into years

#mean centre age
dat_long$age.cent = dat_long$Age - mean(dat_long$Age, na.rm = T)

write.csv(dat_long, "G://users/eileen/Food_Ins/DATA/GUS_long.csv")
saveRDS(dat_long, "G://users/eileen/Food_Ins/DATA/GUS_long.rds")
