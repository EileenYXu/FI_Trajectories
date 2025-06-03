#####################################################
#### Testing out contrasts for group differences ####
#####################################################

##---Contrasts-----

#packages----
library(lme4)
library(lmerTest)
library(kableExtra)
library(tidyverse)
library(emmeans)
emm_options(lmerTest.limit = 20000, pbkrtest.limit = 20000)

#data and model setup----
dat = readRDS("G://users/eileen/Food_Ins/DATA/wt_GUS_long.rds")

age_vals = seq(min(dat$Age), max(dat$Age), 0.5) #list of ages to make scores for
age_cent = age_vals - mean(dat$Age, na.rm = T) #mean center to fit with the model
at_vals = list(age.cent = age_cent, DeEqv5 = levels(dat$DeEqv5), Sex = levels(dat$Sex), ALeSNim2 = levels(dat$ALeSNim2))

fit = lmer(Dsdco1 ~ age.cent*MeFaff3lvl + I(age.cent^2)*MeFaff3lvl + (1 + age.cent |Idnumber),
           REML = TRUE ,
           data = dat ,
           weights = Djwtbth2a,
           control = lmerControl(optimizer="bobyqa",
                                 optCtrl=list(maxfun=2e5)))

#maybe for contrasts I'll use mean age at each sweep
age_vals_c = c(mean(dat[dat$sweep == "De",]$Age, na.rm = T), 
               mean(dat[dat$sweep == "Dg",]$Age, na.rm = T), 
               mean(dat[dat$sweep == "Dj",]$Age, na.rm = T))
age_cent_c = age_vals_c - mean(dat$Age, na.rm = T)
ages_c = data.frame(age_vals_c, age_cent_c)
at_vals_c = list(age.cent = age_cent_c, DeEqv5 = levels(dat$DeEqv5), Sex = levels(dat$Sex), ALeSNim2 = levels(dat$ALeSNim2))

emm_c = emmeans(fit, specs = ~ MeFaff3lvl*age.cent, 
              at = at_vals_c, 
              lmer.df = "satterthwaite")

#fit contrasts between MeFaff3lvl level at 3 timepoints
emm_comparisons = pairs(emm_c, simple = "MeFaff3lvl") |> broom::tidy()

#replace emm_comparisons age.cent column with actual age values
emm_comparisons$Age = c(rep(age_vals_c[1], 3), rep(age_vals_c[2], 3), rep(age_vals_c[3], 3))

emm_comparisons |> relocate(Age) |> select(-age.cent, -term)

