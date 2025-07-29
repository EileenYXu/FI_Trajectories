# FIGURES ----

library(here)
library(patchwork)
library(grid)
i_am("ANALYSIS/makeFigs.R")
source(here("FUNS", "packages.R"))
source(here("FUNS", "plot.R"))

# Unadjusted trajectories (for ESCAP poster) ----

## ALSPAC ----

load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat.rda"))

c = traj_plot(c.pred, "foodDiff3") + labs(title = "Conduct Problems", y = "SDQ score", x = "Age (years)") #+ theme(legend.position = "bottom", legend.direction = "horizontal", legend.title = element_blank())

e = traj_plot(e.pred, "foodDiff3") + labs(title="Emotional Symptoms", y = "SDQ score", x = "Age (years)")

h = traj_plot(h.pred, "foodDiff3") + labs(title = "Hyperactivity/Inattention", y = "SDQ score", x = "Age (years)")

p = traj_plot(p.pred, "foodDiff3") + labs(title = "Peer Problems", y = "SDQ score", x = "Age (years)")

fig1 = wrap_plots(list(c,e,h,p), guides = "collect", axes = "collect") & theme(text = element_text(size = 18), legend.position = "none")

ggsave(fig1, filename = here("OUTPUT/ALSPAC", "ALSPAC_Fig.svg"), height = 8, width = 8.5, units = "in")

## GUS ----

load(file = here("OUTPUT/GUS", "GUS_plots.rda"))

c = traj_plot(c.pred, "MeFaff3lvl") + labs(title = "Conduct Problems", y = "SDQ score", x = "Age (years)") 
e = traj_plot(e.pred, "MeFaff3lvl") + labs(title="Emotional Symptoms", y = "SDQ score", x = "Age (years)") 
h = traj_plot(h.pred, "MeFaff3lvl") + labs(title = "Hyperactivity/Inattention", y = "SDQ score", x = "Age (years)") 
p = traj_plot(p.pred, "MeFaff3lvl") + labs(title = "Peer Problems", y = "SDQ score", x = "Age (years)") 

fig2 = wrap_plots(list(c,e,h,p), guides = "collect", axes = "collect") & theme(text = element_text(size = 18), legend.position = "none")

ggsave(fig2, filename = here("OUTPUT/GUS", "GUS_Fig.svg"), height = 8, width = 8.5, units = "in")


# Fully-adjusted trajectories figure ----

# load data for plots
load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat_adjusted.rda"))
alspac = list(conduct = c.adj, emot = e.adj, hyper = h.adj, peer = p.adj)
rm(c.adj, e.adj, h.adj, p.adj)
load(file = here("OUTPUT/GUS", "GUS_plotdat_adjusted.rda"))
gus = list(conduct = c.adj, emot = e.adj, hyper = h.adj, peer = p.adj)
rm(c.adj, e.adj, h.adj, p.adj)

alspac.plots = alspac |> 
  map(\(x) traj_plot(x, colour = "foodDiff3") + xlab("Age (years)"))
names(alspac.plots) = names(alspac.plots) |> 
  map(\(x) paste0("alspac_", x))

gus.plots = gus |> 
  map(\(x) traj_plot(x, colour = "MeFaff3lvl") + xlab("Age (years)"))
names(gus.plots) = names(gus.plots) |> 
  map(\(x) paste0("gus_", x))

# make axes limits consistent
plotlist = list(alspac.plots, gus.plots) |> unlist(recursive = FALSE)
plotlist = plotlist |> map(\(x) x + scale_x_continuous(breaks = c(4,6,8,10,12,14,16,18)))
#conduct
plotlist[c(1,5)] = plotlist[c(1,5)] |> 
  map(\(x) x + scale_y_continuous(limits = c(0.5, 2.6), n.breaks = 5, breaks = waiver()))
#emot
plotlist[c(2,6)] = plotlist[c(2,6)] |>
  map(\(x) x + scale_y_continuous(limits = c(1, 3), n.breaks = 5, breaks = waiver()))
#hyper
plotlist[c(3,7)] = plotlist[c(3,7)] |>
  map(\(x) x + scale_y_continuous(limits = c(1.7, 4.2), n.breaks = 5, breaks = waiver()))
#peer
plotlist[c(4,8)] = plotlist[c(4,8)] |> 
  map(\(x) x + scale_y_continuous(limits = c(0.3, 2.75), breaks = c(0.5, 1, 1.5, 2, 2.5)))

# assemble into 2 rows, 4 columns

ptch = wrap_plots(plotlist, ncol = 4, nrow = 2, guides = "collect", axes = "collect") + plot_annotation(tag_levels = "A") & theme(legend.position = "none", plot.margin = margin(5,5,5,5,"pt")) & ylab(NULL) 

ptch

# add text labels for rows (study) and columns (SDQ)
r1 = wrap_elements(textGrob("ALSPAC", rot = 90, gp = gpar(fontsize = 13)), ignore_tag = T)
r2 = wrap_elements(textGrob("GUS", rot = 90, gp = gpar(fontsize = 13)), ignore_tag = T)
c1 = wrap_elements(textGrob("Conduct Problems", gp = gpar(fontsize = 13)), ignore_tag = T)
c2 = wrap_elements(textGrob("Emotional Problems", gp = gpar(fontsize = 13)), ignore_tag = T)
c3 = wrap_elements(textGrob("Hyperactivity", gp = gpar(fontsize = 13)), ignore_tag = T)
c4 = wrap_elements(textGrob("Peer Problems", gp = gpar(fontsize = 13)), ignore_tag = T)

# make joint legend
leg.df = data.frame(
  x = rnorm(9),
  y = rnorm(9),
  FI = rep(c("No FI", "Low FI", "High FI"), times = 3)
) |> mutate(low = y-1, hi = y+1)

leg = ggplot(leg.df) +
  geom_line(aes(x, y, colour = FI), linewidth = 1.5) +
  geom_ribbon(aes(x = x, y = y, ymin = low, ymax = hi, fill = FI), alpha = 0.2) + theme(legend.background = element_rect(fill = NA, colour = "white"), legend.key = element_rect(fill = NA, colour = NA)) + labs(colour = NULL, fill = NULL)
legend = ggpubr::get_legend(leg)

# add text labels and legend to ptch plot
plotlist = list(wrap_elements(ptch), r1, r2, c1, c2, c3, c4, wrap_elements(legend))
# specify layout
layout = "
#DDEEFFGG##
BAAAAAAAA##
BAAAAAAAAHH
BAAAAAAAAHH
CAAAAAAAAHH
CAAAAAAAA##
CAAAAAAAA##"

fig = wrap_plots(plotlist, design = layout, heights = c(0.2,1,1,1,1,1,1), widths = c(0.2,1,1,1,1,1,1,1,1,0.4,0.4)) 

fig[[1]] = fig[[1]] + theme(plot.margin = margin(0,0,0,0,"pt"))

fig

ggsave(plot = fig, filename = here("OUTPUT", "Traj_Adjusted.svg"), height = 6, width = 10, units = "in")
ggsave(plot = fig, filename = here("OUTPUT", "Traj_Adjusted.png"), height = 6, width = 10, units = "in")


# Fig with just legend ----
layout = "
AAAAAAA#
AAAAAAAB
AAAAAAAB
AAAAAAAB
AAAAAAAB
AAAAAAA#"

f1 = wrap_elements(ptch) + legend + plot_layout(design = layout) & theme(plot.margin = margin(0,0,0,0,"pt"))
f1

ggsave(plot = f1, filename = here("OUTPUT", "Traj_Adjusted_nolabs.svg"), height = 5, width = 10, units = "in")
ggsave(plot = f1, filename = here("OUTPUT", "Traj_Adjusted_nolabs.png"), height = 5, width = 10, units = "in")
