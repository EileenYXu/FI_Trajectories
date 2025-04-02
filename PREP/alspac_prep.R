### EXTRACTING ALSPAC VARIABLES

#packages
library(haven)
library(tidyverse)

dat = read_dta("//cmvm.datastore.ed.ac.uk/cmvm/scs/groups/ALSPAC/data/B3421/B3421_Whalley_18Oct2023.dta")

#SDQ
emot = c("cidB3421","kq348c", "ku707b", "kw6602b", "ta7025a", "tc4025a")
conduct = c("cidB3421","kq348d", "ku708b", "kw6603b", "ta7025b", "tc4025b")
hyper = c("cidB3421","kq348b", "ku706b", "kw6601b", "ta7025c", "tc4025c")
peer = c("cidB3421","kq348e", "ku709b", "kw6604b", "ta7025d", "tc4025d")
prosoc = c("cidB3421","kq348a", "ku705b", "kw6600b", "ta7025e", "tc4025e")

#Food, SES, Demographics
age = c("cidB3421","kq998a","ku991a","kw9991a", "ta9991a", "tc9991a")
demogs = c("cidB3421", "kz021", "qlet", "c520", "jan2014imd2010q5_YP", "c525", "h470")

datlabs = as.vector(lapply(dat, function(x) attributes(x)$label)) %>% unlist() %>% data.frame(.)
datlabs$name = rownames(datlabs)
datdescL = as.matrix(lapply(dat, function(x) attributes(x)$labels)) %>% data.frame()
datdescL$name = rownames(datdescL)
datdesc = apply(datdescL,2,as.character) %>% data.frame()

ddict = merge(datlabs, datdesc, by = "name", all.x = T)
names(ddict) = c("Name", "Description", "Levels")

write.csv(ddict, "G://users/eileen/Food_Ins/PREP/alspac_dict.csv", row.names = F)
