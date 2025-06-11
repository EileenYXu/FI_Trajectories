#### Packages, options and functions used across analysis scripts ####

# packages ----
library(lme4)
library(lmerTest)
library(kableExtra)
library(tidyverse)
library(emmeans)
emm_options(lmerTest.limit = 40000, pbkrtest.limit = 40000)

# check_fit() ----
# this flags warning messages about singular fit/convergence issues
check_fit <- function(m) {
  msg <- summary(m)$optinfo$conv$lme4$messages %>% unlist()
  if (any(grepl("isSingular", msg))==T) {
    singular <- "Singular fit"
  } else {singular <- "No singular fit"}
  
  if (any(grepl("failed to converge", msg))==T) {
    converge <- "Failed to converge"
  } else  {converge <- "No convergence issues"}
  
  return(c(singular, converge))
} 

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


# m_sd() ----

# super simple function, just pastes into M (SD) format to 2 dp

m_sd <- function(var){
  m = mean(var, na.rm = T) |> round(digits = 2)
  sd = sd(var, na.rm = T) |> round(digits = 2)
  val = paste0(m, " (", sd, ")")
}


# get_sum_stats() ----

# generic function to extract valid N for each variable and summary stat as mean (SD) or n (%) for factors

get_sum_stats <- function(dat, vars) {
  summarydf <- data.frame()
  
  for (v in vars) {
    variable <- dat[,v]
    n_total <- length(which(is.na(variable)==F))
    
    if (is.numeric(variable)==T) {

      #format as mean (sd)
      descr <- m_sd(variable)
      out <- data.frame("Var" = v, "n_total" = n_total, 
                       "desc" = descr)
      
      # if var is a factor, each level needs to be dealt with separately
    } else if (is.factor(variable)) {
      
      levs <- levels(variable)
      tab_var <- table(variable)
      out <- data.frame()
      
      # stat1 is count for the level, stat2 is percentage of total
      for (lev in levs) {
        #format as count (%)
        descr <- paste0(as.numeric(tab_var[lev]),
                        " (", round((stat1/n_total)*100, digits = 2), 
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


# fit_lmer() ----

# takes data, outcome variable, age variable, covariates, grouping variable, weights and linear/quadratic/cubic/quartic polynomial
# fits model, runs check_fit
# modType can be "linear", "quadratic", "cubic", "quartic"
# dat should be long
# age should be pre-centred

fit_lmer <- function(dat, outcome, age, covs = NULL, id, wt = NULL, modType) {
  rhs_ranef = paste0("(1 + ", age, " | ", id, ")")
  
  rhs_age <- case_when(
    modType == "linear" ~ paste0(age),
    modType == "quadratic" ~ paste0(age, " + I(", age, "^2)"),
    modType == "cubic" ~ paste0(age, " + I(", age, "^2) + I(", age, "^3)"),
    modType == "quartic" ~ paste0(age, " + I(", age, "^2) + I(", age, 
                                  "^3) + I(", age, "^4)"))
  
  rhs_cov <- if (!is.null(covs)) {
    paste(covs, sep = " + ")
  }
  
  rhs <- paste(c(rhs_cov, rhs_age, rhs_cov, rhs_ranef), collapse = " + ")
  
  form <- paste(outcome, rhs, sep = " ~ ")
  
  fit <- lmer(formula = as.formula(form),
              REML = FALSE ,
              data = dat,
              weights = wt,
              control = lmerControl(optimizer="bobyqa",
                                    optCtrl=list(maxfun=2e5)))
  
  diagnostics <- check_fit(fit)
  
  out <- list(fit, diagnostics, form, modType)
  names(out) <- c("fit", "diagnostics", "formula", "model type")
  return(out)
}


# plot_dfs() ----

# make df with raw values and df with predicted values
# dat = data
# sw = sweep/wave/occasion indicator
# age_y = age in years
# obj = output from fit_lmer
# emm_at = list of formula arguments with the level you want them at

plot_dfs <- function(dat, obj, sw, age_y, emm_at = NULL) {

  # extract centred age from formula
  agevar <- str_extract(conduct_fit$formula, pattern = "(?<=\\d{1}\\s{1}\\+\\s{1}).*(?=\\s{1}\\|)")

  # extract outcome from formula
  outcome <- str_extract(obj$formula, pattern = ".*(?=\\s{1}\\~)")
  
  # extract fixed effects from formula
  rhs_fixed <- str_extract(obj$formula, pattern = "\\~.*(?=\\s{1}\\+\\s{1}\\()")
    
  raw.df <- dat %>%
    group_by(across(!!sym(sw))) %>%
    summarise(Age = mean(!!sym(age_y), na.rm = T),
              Phenotype = mean(!!sym(outcome), na.rm = T),
              SD = sd(!!sym(outcome), na.rm = T),
              n = sum(!is.na(!!sym(outcome)))) %>%
    mutate(upper = Phenotype + ( qnorm(0.975)*SD/sqrt(n) ),
           lower = Phenotype - ( qnorm(0.975)*SD/sqrt(n) ))
  
  #list of ages to make scores for
  age_vals <-  seq(min(dat[[age_y]]), max(dat[[age_y]]), 0.5) 
  
  #mean center to fit with the model
  age_cent <-  age_vals - mean(dat[[age_y]], na.rm = T) 
  
  age_at <- list(age_cent) |> `names<-`(agevar)
  emm_at <- append(age_at, emm_at)
  
  # get scores at ages
  emm <- emmeans(obj$fit, specs = as.formula(rhs_fixed), 
                at = emm_at, 
                lmer.df = "satterthwaite")
  
  # add a column with the original age values
  pred.df <- as.data.frame(summary(emm)) %>% cbind(., age_vals)
  
  out <- list(raw.df = raw.df, pred.df = pred.df)
  
  return(out)
}


# traj_plot() ----

# plotdat = output from plot_dfs
# makes plot with predicted trajectory
# still need to manually specify axis labels etc

traj_plot <- function(plotdat) {
  pred.df = plotdat$pred.df
  raw.df = plotdat$raw.df
  
  ggplot() + 
    geom_line(data = pred.df,
              aes(x = age_vals, y = emmean),
              linewidth = 1.5, na.rm = T, colour = "#0072B2") + 
    geom_ribbon(data = pred.df,
                aes(x = age_vals, y = emmean,
                    ymin = lower.CL, ymax = upper.CL),
                alpha = 0.2, na.rm = T, fill = "#0072B2") +
    geom_point(data = raw.df, aes(x=Age, y=Phenotype))+
    geom_line(data = raw.df, aes(x=Age, y=Phenotype)) +
    geom_errorbar(data = raw.df, aes(x=Age, ymin = lower, ymax = upper))
}
  