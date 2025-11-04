# FIGURES ----

library(here)
library(patchwork)
library(ggpubr)
i_am("ANALYSIS/makeFigs.R")
source(here("FUNS", "packages.R"))
source(here("FUNS", "plot.R"))

# FI Legend ----
# legend needs to be added as a separate object in patchwork
# dummy df with desired factor labels
leg.df = data.frame(
  x = rnorm(9),
  y = rnorm(9),
  FI = rep(c("No FI", "Low FI", "High FI"), times = 3)
) |> mutate(low = y-1, hi = y+1)

# plot dummy df
leg = ggplot(leg.df) +
  geom_line(aes(x, y, colour = FI), linewidth = 1.5) +
  geom_ribbon(aes(x = x, y = y, ymin = low, ymax = hi, fill = FI), 
              alpha = 0.2) +
  scale_discrete_manual(aesthetics = c("colour", "fill"), 
                        values = c("High FI" = "#56B4E9", "Low FI" = "#009E73",
                                   "No FI" = "#E69F00")) +
  theme_minimal() + theme(legend.background = element_blank(),
                          legend.key = element_rect(colour = "transparent"), 
                          legend.text = element_text(size = 12), 
                          legend.key.spacing.y = unit(10, units = "pt"), 
                          legend.title = element_blank())

leg

# extract legend from plot
legend = ggpubr::get_legend(leg)
as_ggplot(legend)

# Figure 1: Fully-adjusted trajectories ----

# load data
load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat_adjusted.rda"))
alspac = list(conduct = c.adj, emot = e.adj, hyper = h.adj, peer = p.adj)
rm(c.adj, e.adj, h.adj, p.adj)
load(file = here("OUTPUT/GUS", "GUS_plotdat_adjusted.rda"))
gus = list(conduct = c.adj, emot = e.adj, hyper = h.adj, peer = p.adj)
rm(c.adj, e.adj, h.adj, p.adj)

## Individual plots ----
alspac.plots = alspac |> 
  map(\(x) traj_plot(x, colour = "foodDiff3") + xlab("Age (years)"))
names(alspac.plots) = names(alspac.plots) |> 
  map(\(x) paste0("alspac_", x))

gus.plots = gus |> 
  map(\(x) traj_plot(x, colour = "MeFaff3lvl") + xlab("Age (years)"))
names(gus.plots) = names(gus.plots) |> 
  map(\(x) paste0("gus_", x))

# make x axes limits consistent for all plots
plotlist = list(alspac.plots, gus.plots) |> unlist(recursive = FALSE)
plotlist = plotlist |> map(\(x) x + scale_x_continuous(
  breaks = c(4,6,8,10,12,14,16,18)))

# make y axes consistent between ALSPAC and GUS
# conduct
plotlist[c(1,5)] = plotlist[c(1,5)] |> 
  map(\(x) x + scale_y_continuous(
    limits = c(0.5, 2.6), n.breaks = 5, breaks = waiver()))
# emot
plotlist[c(2,6)] = plotlist[c(2,6)] |>
  map(\(x) x + scale_y_continuous(
    limits = c(1, 3), n.breaks = 5, breaks = waiver()))
# hyper
plotlist[c(3,7)] = plotlist[c(3,7)] |>
  map(\(x) x + scale_y_continuous(
    limits = c(1.7, 4.2), n.breaks = 5, breaks = waiver()))
# peer
plotlist[c(4,8)] = plotlist[c(4,8)] |> 
  map(\(x) x + scale_y_continuous(
    limits = c(0.7, 2.6), breaks = c(0.5, 1, 1.5, 2, 2.5)))

## Assemble into 2 rows, 4 columns ----
ptch = wrap_plots(plotlist, ncol = 4, nrow = 2, 
                  guides = "collect", axes = "collect") + 
  plot_annotation(tag_levels = "A") & 
  theme(legend.position = "none", plot.margin = margin(10,10,10,10,"pt")) &
  ylab(NULL) 

ptch

## Add figure legend ----

## specify layout 
layout = "
AAAAAAA#
AAAAAAAB
AAAAAAAB
AAAAAAAB
AAAAAAAB
AAAAAAA#"

## assemble patchwork
nolabs = wrap_elements(ptch) + legend + 
  plot_layout(design = layout) & 
  theme(plot.margin = margin(0,0,0,0,"pt"))
nolabs

par("din")

ggsave(plot = nolabs, 
       filename = here("OUTPUT", "Traj_Adjusted_nolabs.svg"),
       height = 5, width = 11, units = "in")
ggsave(plot = nolabs, 
       filename = here("OUTPUT", "Traj_Adjusted_nolabs.png"), 
       height = 5, width = 11, units = "in")


## Try adding labels ----
## make text labels for rows (study) and columns (SDQ)

r1 = text_grob("ALSPAC", rot = 90, size = 14)
r2 = text_grob("GUS", rot = 90, size = 14)
c1 = text_grob("Conduct Problems", size = 14)
c2 = text_grob("Emotional Problems", size = 14)
c3 = text_grob("Hyperactivity", size = 14)
c4 = text_grob("Peer Problems", size = 14)

## specify layout
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

fig = wrap_elements(full=ptch) + 
  r1 + r2 + c1 + c2 + c3 + c4 + legend + 
  plot_layout(design = arr, ncol = 6, nrow = 3, 
              heights = c(0.1,1,1),
              widths = c(0.1,1,1,1,1,0.5)) & 
  theme(plot.margin = margin(0,0,0,0,"pt"), 
        legend.margin = margin(0,0,0,0,"pt"))
fig

ggsave(plot = fig, filename = here("OUTPUT", "Traj_Adjusted_labs.svg"), 
       height = 6, width = 12, units = "in")
ggsave(plot = fig, filename = here("OUTPUT", "Traj_Adjusted_labs.png"), 
       height = 6, width = 12, units = "in")


# Supplementary figures ----

## GUS age only trajectories ----

load(file = here("OUTPUT/GUS", "GUS_ageonly_plotdat.rda"))
gus = list("Conduct Problems" = c.dat, "Emotional Symptoms" = e.dat,
           "Hyperactivity/Inattention" = h.dat, "Peer Problems" = p.dat)
rm(c.dat, e.dat, h.dat, p.dat)

gus.age = gus |> 
  imap(\(x, idx) traj_plot(x) + xlab("Age (years)") + ylab(idx) +
         scale_x_continuous(breaks = c(4,6,8,10,12,14,16)))
gus.age

gus.plot = wrap_plots(gus.age, axes = "collect") + 
  plot_annotation(tag_levels = "A")
gus.plot
ggsave(plot = gus.plot, filename = here("OUTPUT", "GUS_AgeOnly.png"), 
       height = 5, width = 6, units = "in")

## ALSPAC age only trajectories ----

load(file = here("OUTPUT/ALSPAC", "ALSPAC_ageonly_plotdat.rda"))
alspac = list("Conduct Problems" = c.dat, "Emotional Symptoms" = e.dat,
              "Hyperactivity/Inattention" = h.dat, "Peer Problems" = p.dat)
rm(c.dat, e.dat, h.dat, p.dat)

alspac.age = alspac |> 
  imap(\(x, idx) traj_plot(x) + xlab("Age (years)") + ylab(idx) +
         scale_x_continuous(breaks = c(6,8,10,12,14,16,18)))
alspac.age

alspac.plot = wrap_plots(alspac.age, axes = "collect") + 
  plot_annotation(tag_levels = "A")
ggsave(plot = alspac.plot, filename = here("OUTPUT", "ALSPAC_AgeOnly.png"),
       height = 5, width = 6, units = "in")

## GUS unadjusted trajectories by FI ----

load(file = here("OUTPUT/GUS", "GUS_plotdat.rda"))
gus = list("Conduct Problems" = c.preds, "Emotional Symptoms" = e.preds,
           "Hyperactivity/Inattention" = h.preds, "Peer Problems" = p.preds)
rm(c.preds, e.preds, h.preds, p.preds)

# individual plots with consistent x axis
gus.age = gus |> 
  imap(\(x, idx) 
       traj_plot(x,"MeFaff3lvl") + labs(y = idx, x = "Age (years)") +
         scale_x_continuous(breaks = c(4,6,8,10,12,14,16)))
gus.age

gus.plot = wrap_plots(gus.age, axes = "collect") + 
  plot_annotation(tag_levels = "A") & theme(legend.position = "none")

# add legend
layout = "
AAAA#
AAAAB
AAAA#"

gus.unadj = wrap_elements(gus.plot) + legend + plot_layout(design = layout) &
  theme(plot.margin = margin(0,0,0,0,"pt"), text = element_text(size = 12))
gus.unadj

ggsave(plot = gus.unadj, filename = here("OUTPUT", "GUS_Unadjusted.png"),
       height = 5, width = 7.5, units = "in")

## ALSPAC unadjusted trajectories by FI ----

load(file = here("OUTPUT/ALSPAC", "ALSPAC_plotdat.rda"))
alspac = list("Conduct Problems" = c.preds, "Emotional Symptoms" = e.preds,
              "Hyperactivity/Inattention" = h.preds, "Peer Problems" = p.preds)
rm(c.preds, e.preds, h.preds, p.preds)

# individual plots with consistent x axis
alspac.age = alspac |> 
  imap(\(x, idx) traj_plot(x,"foodDiff3") + labs(y = idx, x = "Age (years)") +
         scale_x_continuous(breaks = c(6,8,10,12,14,16,18)))
alspac.age

alspac.plot = wrap_plots(alspac.age, axes = "collect") + 
  plot_annotation(tag_levels = "A") & theme(legend.position = "none")

# add legend
layout = "
AAAA#
AAAAB
AAAA#"

alspac.unadj = wrap_elements(alspac.plot) + legend + 
  plot_layout(design = layout) & 
  theme(plot.margin = margin(0,0,0,0,"pt"), text = element_text(size = 12))
alspac.unadj

ggsave(plot = alspac.unadj, filename = here("OUTPUT", "ALSPAC_Unadjusted.png"),
       height = 5, width = 7.5, units = "in")
