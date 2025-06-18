#### generic helper functions associated with making trajectory models ####

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


# fit_lmer() ----

# takes data, outcome variable, age variable, covariates, grouping variable, weights and linear/quadratic/cubic/quartic polynomial
# fits model, runs check_fit
# modType can be "linear", "quadratic", "cubic", "quartic"
# dat should be long
# age should be pre-centred

fit_lmer <- function(dat, outcome, age, grp = NULL, covs = NULL, id, wt = NULL, modType) {
  rhs_ranef = paste0("(1 + ", age, " | ", id, ")")
  
  rhs_age <- if (!is.null(grp)) {
    case_when(
      modType == "linear" ~ 
        paste0(age,"*", grp),
      modType == "quadratic" ~ 
        paste0(age,"*", grp," + I(", age, "^2)*", grp),
      modType == "cubic" ~ 
        paste0(age,"*",grp, " + I(", age, "^2)*",grp,
               " + I(", age, "^3)*",grp),
      modType == "quartic" ~ 
        paste0(age,"*",grp, " + I(", age, "^2)*",grp,
               " + I(", age, "^3)*",grp," + I(", age, "^4)*",grp))
  } else {
    case_when(
    modType == "linear" ~ paste0(age),
    modType == "quadratic" ~ paste0(age, " + I(", age, "^2)"),
    modType == "cubic" ~ paste0(age, " + I(", age, "^2) + I(", age, "^3)"),
    modType == "quartic" ~ paste0(age, " + I(", age, "^2) + I(", age, 
                                  "^3) + I(", age, "^4)"))}
  
  rhs_cov <- if (!is.null(covs)) {
    paste(covs, sep = " + ")
  }
  
  rhs <- paste(c(rhs_age, rhs_cov, rhs_ranef), collapse = " + ")
  
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

# get_fitstats ----

# extracts fit statistics from a list of fit_lmer outputs
# turns into a nice dataframe with corresponding model covariates for each model
# modguide is a named dataframe column with each row corresponding to an element of fitlist
# this is used as a reference

get_fitstats <- function(fitlist, modguide) {
  out <- fitlist |> 
    map(\(x) glance(x$fit)) |> reduce(rbind) |> cbind(modguide) |> relocate(names(modguide))
}

# get_ests ----

# extracts model estimates a list of fit_lmer outputs
# turns into a nice dataframe with corresponding model covariates for each model

get_ests <- function(fitlist) {
  out <- fitlist |> 
    map(\(x) tidy(x$fit, effects="fixed", conf.int = T, conf.level = 0.95)) |> reduce(rbind) |>  select(-effect)
}
