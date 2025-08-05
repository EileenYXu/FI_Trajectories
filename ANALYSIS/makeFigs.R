# FIGURES ----

library(here)
library(patchwork)
library(ggpubr)
i_am("ANALYSIS/makeFigs.R")
source(here("FUNS", "packages.R"))
source(here("FUNS", "plot.R"))

# Unadjusted trajectories (for ESCAP poster) ----

## ALSPAC ----

load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat.rda"))

c = traj_plot(c.preds, "foodDiff3") + labs(title = "Conduct Problems", y = "SDQ score", x = "Age (years)") #+ theme(legend.position = "bottom", legend.direction = "horizontal", legend.title = element_blank())

e = traj_plot(e.preds, "foodDiff3") + labs(title="Emotional Symptoms", y = "SDQ score", x = "Age (years)")

h = traj_plot(h.preds, "foodDiff3") + labs(title = "Hyperactivity/Inattention", y = "SDQ score", x = "Age (years)")

p = traj_plot(p.preds, "foodDiff3") + labs(title = "Peer Problems", y = "SDQ score", x = "Age (years)")

fig1 = wrap_plots(list(c,e,h,p), guides = "collect", axes = "collect") & theme(text = element_text(size = 18), legend.position = "none")

ggsave(fig1, filename = here("OUTPUT/ALSPAC", "ALSPAC_Fig.svg"), height = 8, width = 8.5, units = "in")

## GUS ----

load(file = here("OUTPUT/GUS", "GUS_plots.rda"))

c = traj_plot(c.preds, "MeFaff3lvl") + labs(title = "Conduct Problems", y = "SDQ score", x = "Age (years)") 
e = traj_plot(e.preds, "MeFaff3lvl") + labs(title="Emotional Symptoms", y = "SDQ score", x = "Age (years)") 
h = traj_plot(h.preds, "MeFaff3lvl") + labs(title = "Hyperactivity/Inattention", y = "SDQ score", x = "Age (years)") 
p = traj_plot(p.preds, "MeFaff3lvl") + labs(title = "Peer Problems", y = "SDQ score", x = "Age (years)") 

fig2 = wrap_plots(list(c,e,h,p), guides = "collect", axes = "collect") & theme(text = element_text(size = 18), legend.position = "none")

ggsave(fig2, filename = here("OUTPUT/GUS", "GUS_Fig.svg"), height = 8, width = 8.5, units = "in")


# Fully-adjusted trajectories figure ----

# load data
load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat_adjusted.rda"))
alspac = list(conduct = c.adj, emot = e.adj, hyper = h.adj, peer = p.adj)
rm(c.adj, e.adj, h.adj, p.adj)
load(file = here("OUTPUT/GUS", "GUS_plotdat_adjusted.rda"))
gus = list(conduct = c.adj, emot = e.adj, hyper = h.adj, peer = p.adj)
rm(c.adj, e.adj, h.adj, p.adj)

# make individual plots
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

# conduct
plotlist[c(1,5)] = plotlist[c(1,5)] |> 
  map(\(x) x + scale_y_continuous(limits = c(0.5, 2.6), n.breaks = 5, breaks = waiver()))
# emot
plotlist[c(2,6)] = plotlist[c(2,6)] |>
  map(\(x) x + scale_y_continuous(limits = c(1, 3), n.breaks = 5, breaks = waiver()))
# hyper
plotlist[c(3,7)] = plotlist[c(3,7)] |>
  map(\(x) x + scale_y_continuous(limits = c(1.7, 4.2), n.breaks = 5, breaks = waiver()))
# peer
plotlist[c(4,8)] = plotlist[c(4,8)] |> 
  map(\(x) x + scale_y_continuous(limits = c(0.7, 2.6), breaks = c(0.5, 1, 1.5, 2, 2.5)))

# assemble into 2 rows, 4 columns
ptch = wrap_plots(plotlist, ncol = 4, nrow = 2, guides = "collect", axes = "collect") + plot_annotation(tag_levels = "A") & theme(legend.position = "none", plot.margin = margin(10,10,10,10,"pt")) & ylab(NULL) 

ptch

# manually make legend from dummy data
leg.df = data.frame(
  x = rnorm(9),
  y = rnorm(9),
  FI = rep(c("No FI", "Low FI", "Moderate FI"), times = 3)
) |> mutate(low = y-1, hi = y+1)

leg = ggplot(leg.df) +
  geom_line(aes(x, y, colour = FI), linewidth = 1.5) +
  geom_ribbon(aes(x = x, y = y, ymin = low, ymax = hi, fill = FI), alpha = 0.2) +
  scale_discrete_manual(aesthetics = c("colour", "fill"), 
                        values = c("Moderate FI" = "#56B4E9", "Low FI" = "#009E73", "No FI" = "#E69F00")) +
  theme_minimal() + theme(legend.background = element_blank(),
        legend.key = element_rect(colour = "transparent"), 
        legend.text = element_text(size = 12), 
        legend.key.spacing.y = unit(10, units = "pt"), 
        legend.title = element_blank())

leg

legend = ggpubr::get_legend(leg)
as_ggplot(legend)

## No labels ----

## specify layout 
layout = "
AAAAAAA#
AAAAAAAB
AAAAAAAB
AAAAAAAB
AAAAAAAB
AAAAAAA#"

nolabs = wrap_elements(ptch) + legend + plot_layout(design = layout) & theme(plot.margin = margin(0,0,0,0,"pt"))
nolabs
par("din")

ggsave(plot = nolabs, filename = here("OUTPUT", "Traj_Adjusted_nolabs.svg"), height = 5, width = 11, units = "in")
ggsave(plot = nolabs, filename = here("OUTPUT", "Traj_Adjusted_nolabs.png"), height = 5, width = 11, units = "in")


## Try adding labels ----

## make text labels for rows (study) and columns (SDQ)

r1 = text_grob("ALSPAC", rot = 90, size = 14)
r2 = text_grob("GUS", rot = 90, size = 14)
c1 = text_grob("Conduct Problems", size = 14)
c2 = text_grob("Emotional Problems", size = 14)
c3 = text_grob("Hyperactivity", size = 14)
c4 = text_grob("Peer Problems", size = 14)

# specify layout
arr = c(
  area(2,2,3,5),
  area(2,1,2,1),
  area(3,1,3,1),
  area(1,2,1,2),
  area(1,3,1,3),
  area(1,4,1,4),
  area(1,5,1,5),
  area(2,6,3,6)
)

plot(arr)

fig = wrap_elements(full=ptch) + r1 + r2 + c1 + c2 + c3 + c4 + legend + 
  plot_layout(design = arr, ncol = 6, nrow = 3, heights = c(0.1,1,1),
              widths = c(0.1,1,1,1,1,0.5)) & theme(plot.margin = margin(0,0,0,0,"pt"), legend.margin = margin(0,0,0,0,"pt"))
fig

ggsave(plot = fig, filename = here("OUTPUT", "Traj_Adjusted_labs.svg"), height = 6, width = 12, units = "in")
ggsave(plot = fig, filename = here("OUTPUT", "Traj_Adjusted_labs.png"), height = 6, width = 12, units = "in")
