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

# Generic useful functions ----

# age_ym ----

# function turning age in years with decimal places into years and months

age_ym <- function(age){
  yrs = floor(age)
  mths = round((age - yrs)*12, digits = 0)
  out = paste0(yrs, "y ", mths, "m")
  return(out)
}

# m_sd() ----

# super simple function, just pastes into M (SD) format and rounds (2 d.p. by default). Specify digits to change this.

m_sd <- function(var, digits = NULL){
  d = ifelse(is.null(digits), 2, digits)
  m = mean(var, na.rm = T) |> round(digits = d)
  sd = sd(var, na.rm = T) |> round(digits = d)
  val = paste0(m, " (", sd, ")")
  return(val)
}

# range_tab() ----

# generic function to calculate range, round (2 d.p. by default). and output in the format Min - Max
# if age = TRUE, display in months and years

range_tab <- function(var, digits = NULL, age = NULL){
  d = ifelse(is.null(digits), 2, digits)
  r = range(var, na.rm = T) 
  
  if (is.null(age)) {
    r = r |> round(digits = d)
  } else {
    r = age_ym(r)
  }

  val = paste(r, collapse = " - ")
  return(val)
}

# get_sum_stats() ----

# generic function to extract valid N for each variable and summary stat as mean (SD) or n (%) for factors
# digits is 2 by default

get_sum_stats <- function(dat, vars, digits = NULL) {
  d = ifelse(is.null(digits), 2, digits)
  
  summarydf <- data.frame()
  
  for (v in vars) {
    variable <- dat[[paste0(v)]]
    n_total <- length(which(is.na(variable)==F))
    
    if (is.numeric(variable)) {
      
      # format as mean (sd)
      descr <- m_sd(variable)
      out <- data.frame("Var" = v, "n_total" = n_total, 
                        "desc" = descr)
      
      # if var is a factor, each level needs to be dealt with separately
    } else if (is.factor(variable)) {
      
      levs <- levels(variable)
      tab_var <- table(variable) # counts for each level
      out <- data.frame()
      
      for (lev in levs) {
        # format as count (%)
        descr <- paste0(as.numeric(tab_var[lev]),
                        " (", round((tab_var[lev]/n_total)*100, digits = d), 
                        "%)")
        outrow <- data.frame("Var" = paste0(v, "_", lev), "n_total" = n_total,
                             "desc" = descr)
        out <- rbind(out, outrow)
      }
    }
    summarydf <- rbind(summarydf, out)
  }
  return(summarydf)
}

# addci() ----

# function to paste CI with estimate in the format "estimate [lower - upper]"
# rounds to 2 d.p. by default, change by specifying digits 

addci <- function(dat, est, lower, upper, digits = NULL) {
  d = ifelse(is.null(digits), 2, digits)
  
  # only round estimate, lower and upper ci columns
  df = dat |> 
    mutate(across(all_of(c(est, lower, upper)), \(x) round(x, digits = d)))
  
  # now paste into a new column
  df = df |> mutate(
    comb = paste0(!!sym(est), " [", !!sym(lower), " - ", !!sym(upper), "]")
  )
  return(df)
}
