### EXTRACTING ALSPAC DATA DICTIONARY ###

#packages
library(haven)

# Read in data
dat = read_dta("A://data/B3421/B3421_Whalley_20Mar25.dta")

#### Make a data dictionary of variable names, label (description) and labels (levels) ####

DataDict = data.frame(
  VarName = names(dat),
  Description = as.character(lapply(dat, function(x) attributes(x)$label)),
  Values = as.character(lapply(dat, function(x) attributes(x)$labels)))

## Tidy up strings in columns
DataDict$Values = stringr::str_remove_all(DataDict$Values, pattern = "^c|\\(|\\`|\\)")
DataDict$Description = stringr::str_remove_all(DataDict$Description, pattern = "^c|\\(|\\`|\\)")


write.csv(DataDict, "G://users/eileen/alspac_dict.csv", row.names = F)
