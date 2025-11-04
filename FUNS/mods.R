#### functions associated with making trajectory models ####

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

# takes data, outcome variable, age variable, covariates, grouping variable, 
# weights and linear/quadratic/cubic/quartic polynomial
# fits model, runs check_fit
# modType can be "linear", "quadratic", "cubic", "quartic"
# dat should be long
# age should be pre-centred

fit_lmer <- function(dat, outcome, age, grp = NULL, covs = NULL, id, 
                     wt = NULL, modType) {
  # random effects
  rhs_ranef = paste0("(1 + ", age, " | ", id, ")")
  
  # fixed effects
  rhs_age <- if (!is.null(grp)) {
    # specify polynomial term(s) and add grouping variable
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
    # specify polynomial term(s) only (no grouping variable)
    case_when(
    modType == "linear" ~ paste0(age),
    modType == "quadratic" ~ paste0(age, " + I(", age, "^2)"),
    modType == "cubic" ~ paste0(age, " + I(", age, "^2) + I(", age, "^3)"),
    modType == "quartic" ~ paste0(age, " + I(", age, "^2) + I(", age, 
                                  "^3) + I(", age, "^4)"))}
  # covariates (if specified)
  rhs_cov <- if (!is.null(covs)) {
    paste(covs, sep = " + ")
  }
  
  # paste into one formula
  rhs <- paste(c(rhs_age, rhs_cov, rhs_ranef), collapse = " + ")
  
  form <- paste(outcome, rhs, sep = " ~ ")
  
  # fit lmer model
  fit <- lmer(formula = as.formula(form),
              REML = FALSE ,
              data = dat,
              weights = wt,
              control = lmerControl(optimizer="bobyqa",
                                    optCtrl=list(maxfun=2e5)))
  
  # check for convergence and singular fit
  diagnostics <- check_fit(fit)
  
  # combine into single output
  out <- list(fit, diagnostics, form, modType)
  names(out) <- c("fit", "diagnostics", "formula", "model type")
  return(out)
}

# get_fitstats ----

# extracts each model's fit statistics
# fitlist = a list of fit_lmer outputs
# modguide = vector of names corresponding to each element of fitlist

get_fitstats <- function(fitlist, modguide) {
  out <- fitlist |> 
    map(\(x) glance(x$fit)) |> reduce(rbind) |> cbind(modguide) |> 
    relocate(names(modguide))
}

# get_ests ----

# extracts fixed effects estimates with 95% CI
# fitlist = a list of fit_lmer outputs

get_ests <- function(fitlist) {
  out <- fitlist |> 
    map(\(x) tidy(x$fit, effects="fixed", conf.int = T, conf.level = 0.95)) |> 
    reduce(rbind) |>  select(-effect)
}
