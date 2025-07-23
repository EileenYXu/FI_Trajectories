#### ALSPAC FIG ####
library(here)
library(patchwork)
library(ggpubr)
i_am("ANALYSIS/makeFigs.R")
source(here("FUNS", "packages.R"))

tplot <- function(pred.df, colour){
  ggplot() + 
  geom_line(data = pred.df,
            aes(x = age_vals, y = emmean, colour = !!sym(colour)),
            linewidth = 1.5, na.rm = T) + 
  geom_ribbon(data = pred.df,
              aes(x = age_vals, y = emmean, fill = !!sym(colour),
                  ymin = lower.CL, ymax = upper.CL),
              alpha = 0.2, na.rm = T)# + scale_x_continuous(breaks = seq(6, 18, 3))
  }

load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat.rda"))

c = tplot(c.pred, "foodDiff3") + labs(title = "Conduct Problems", y = "SDQ score", x = "Age (years)") #+ theme(legend.position = "bottom", legend.direction = "horizontal", legend.title = element_blank())

e = tplot(e.pred, "foodDiff3") + labs(title="Emotional Symptoms", y = "SDQ score", x = "Age (years)")

h = tplot(h.pred, "foodDiff3") + labs(title = "Hyperactivity/Inattention", y = "SDQ score", x = "Age (years)")

p = tplot(p.pred, "foodDiff3") + labs(title = "Peer Problems", y = "SDQ score", x = "Age (years)")

fig1 = wrap_plots(list(c,e,h,p), guides = "collect", axes = "collect") & theme(text = element_text(size = 18), legend.position = "none")

#l = get_legend(c)
#leg1 = as_ggplot(l)+theme(text = element_text(size = 18), 
                            legend.background = element_rect(fill = "transparent"))

ggsave(fig1, filename = here("OUTPUT/ALSPAC", "ALSPAC_Fig.svg"), height = 8, width = 8.5, units = "in")
#ggsave(leg1, filename = here("OUTPUT/ALSPAC", "ALSPAC_Legend.svg"), height = 1, width = 4, units = "in")



#### GUS FIG ####

load(file = here("OUTPUT/GUS", "GUS_plots.rda"))

c = tplot(c.pred, "MeFaff3lvl") + labs(title = "Conduct Problems", y = "SDQ score", x = "Age (years)") 
#+ theme(legend.position = "bottom", legend.direction = "horizontal", legend.title = element_blank())
e = tplot(e.pred, "MeFaff3lvl") + labs(title="Emotional Symptoms", y = "SDQ score", x = "Age (years)") 
h = tplot(h.pred, "MeFaff3lvl") + labs(title = "Hyperactivity/Inattention", y = "SDQ score", x = "Age (years)") 
p = tplot(p.pred, "MeFaff3lvl") + labs(title = "Peer Problems", y = "SDQ score", x = "Age (years)") 

fig2 = wrap_plots(list(c,e,h,p), guides = "collect", axes = "collect") & theme(text = element_text(size = 18), legend.position = "none")

#l = get_legend(c)
#leg2 = as_ggplot(l) & theme(text = element_text(size = 18))

ggsave(fig2, filename = here("OUTPUT/GUS", "GUS_Fig.svg"), height = 8, width = 8.5, units = "in")
#ggsave(leg2, filename = here("OUTPUT/GUS", "GUS_Legend.svg"), height = 1, width = 4, units = "in")
