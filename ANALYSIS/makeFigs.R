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
) |> mutate(low = y-1, hi = y+1, 
            FI = factor(FI, levels = c("No FI", "Low FI", "High FI"),
                        ordered=TRUE))

# plot dummy df
leg = ggplot(leg.df) +
  geom_line(aes(x, y, colour = FI), linewidth = 1) +
  geom_ribbon(aes(x = x, y = y, ymin = low, ymax = hi, fill = FI), 
              alpha = 0.2) +
  scale_discrete_manual(aesthetics = c("colour", "fill"), 
                        values = c("High FI" = "#56B4E9", "Low FI" = "#009E73",
                                   "No FI" = "#E69F00")) +
  theme_minimal() + theme(legend.background = element_blank(),
                          legend.key = element_rect(colour = "transparent"), 
                          legend.key.spacing.y = unit(4, units = "pt"), 
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
plotlist = plotlist |> 
  map(\(x) x + scale_x_continuous(limits = c(4, 18),
                                  breaks = c(4,6,8,10,12,14,16,18)) +
        theme(legend.position = "none") + labs(y=NULL, x = NULL))

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

## Save individual plots and figure legend as .pdf ----

plotlist |> 
  imap(\(plt, idx) 
       ggsave(plot = plt,
              filename = here("OUTPUT/FIGS", paste0(idx, "_adjusted.pdf")),
              height = 40, width = 40, units = "mm"))
ggsave(plot = as_ggplot(legend),
       filename = here("OUTPUT/FIGS", "FI_legend.pdf"),
       height = 25, width = 20, units = "mm")

## Assemble into 2 rows, 4 columns ----
ptch = wrap_plots(plotlist, ncol = 4, nrow = 2, 
                  guides = "collect", axes = "collect") + 
  plot_annotation(tag_levels = "A") & 
  theme(legend.position = "none") &
  ylab(NULL) 

ptch

ggsave(plot = ptch, 
       filename = here("OUTPUT/FIGS", "Traj_Adjusted_noleg.pdf"),
       height = 80, width = 160, units = "mm")

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
       filename = here("OUTPUT/FIGS", "Traj_Adjusted_nolabs.pdf"),
       height = 5, width = 11, units = "in")
#ggsave(plot = nolabs, 
#       filename = here("OUTPUT/FIGS", "Traj_Adjusted_nolabs.png"), 
#       height = 5, width = 11, units = "in")

## Try adding labels ----
## make text labels for rows (study) and columns (SDQ)

r1 = text_grob("ALSPAC", rot = 90, size = 10)
r2 = text_grob("GUS", rot = 90, size = 10)
c1 = text_grob("Conduct Problems", size = 10)
c2 = text_grob("Emotional Problems", size = 10)
c3 = text_grob("Hyperactivity", size = 10)
c4 = text_grob("Peer Problems", size = 10)

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
              widths = c(0.1,1,1,1,1,0.6)) & 
  theme(plot.margin = margin(0,0,0,0,"pt"))
fig

ggsave(plot = fig, filename = here("OUTPUT/FIGS", "Traj_Adjusted_labs.pdf"), 
       height = 6, width = 12, units = "in")
#ggsave(plot = fig, filename = here("OUTPUT/FIGS", "Traj_Adjusted_labs.png"), 
#       height = 6, width = 12, units = "in")


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
ggsave(plot = gus.plot, filename = here("OUTPUT/FIGS", "GUS_AgeOnly.pdf"), 
       height = 80, width = 90, units = "mm")

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
ggsave(plot = alspac.plot, filename = here("OUTPUT/FIGS", "ALSPAC_AgeOnly.pdf"),
       height = 80, width = 90, units = "mm")

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

ggsave(plot = gus.plot, filename = here("OUTPUT/FIGS", "GUS_Unadjusted.pdf"),
       height = 80, width = 90, units = "mm")

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

ggsave(plot = alspac.plot, filename = here("OUTPUT/FIGS", "ALSPAC_Unadjusted.pdf"),
       height = 80, width = 90, units = "mm")
