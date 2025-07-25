#### Packages and global options used across analysis scripts ####

# packages ----
library(lme4)
library(lmerTest)
library(kableExtra)
library(tidyverse)
library(emmeans)
library(broom.mixed)
emm_options(lmerTest.limit = 40000, pbkrtest.limit = 40000)

# ggplot theme ----

# use Okabe-Ito (2008) colourblind-friendly palette by default
pal <- c("#E69F00","#56B4E9","#009E73",
         "#F5C710","#0072B2","#D55E00",
         "#CC79A7","#999999","#000000")

options(ggplot2.discrete.colour=pal, ggplot2.discrete.fill=pal)

# change other features of theme_bw
my_theme <- function(base_size = 12, base_family = ""){
  theme_bw(base_size = base_size, base_family = base_family) %+replace%
    theme(
      panel.background = element_rect(fill = "transparent"),
      plot.background = element_rect(fill = "transparent", color = NA),
      panel.grid.major = element_line(colour = "grey88"),
      panel.grid.minor = element_line(colour = "grey99"),
      legend.background = element_rect(fill = "transparent"),
      legend.box.background = element_rect(fill = "transparent"),
      panel.ontop = FALSE
    )
}

theme_set(my_theme()) # use new theme