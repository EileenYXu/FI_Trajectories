########### standardise SDQ data in wide ######################

dat_wide = readRDS("G://users/eileen/Food_Ins/DATA/GUS_wide.rds")

dat = readRDS("G://users/eileen/Food_Ins/DATA/wt_GUS_long.rds")

social = readRDS("G://users/eileen/Food_Ins/DATA/wt_GUS_social.rds")

socialw = readRDS("G://users/eileen/Food_Ins/DATA/wt_GUS_social_wide.rds")


sw10 = read.delim("G://data/GUS/5760-GUS-Cohort1/tab/gus_bc1sw10_protect.tab")
sw10weights = sw10$Djwtbth2a



