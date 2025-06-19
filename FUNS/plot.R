#### functions associated with plotting and interpreting trajectory models ####


# get_age ----

# extracts whatever variable was used for "age.cent" in lme4 models by pulling
# out the random slope term from a lme4 formula as written by the fit_lmer 
# function
# e.g. for a formula with random effects (1 + MeanCentreAge | ID)

# 3 components to the regex pattern:
# positive look-behind (?<=) tells R to start extracting once it encounters 
# "(1 + "

# positive look-ahead (?=) for the end of a random effect structure, tells R to 
# stop searching once it encounters " |"

# the .* tells R to extract whatever string is between the look-behind and 
# look-ahead - i.e. 1 + "MeanCentreAge" |

get_age <- function(form) {
  agevar <- str_extract(form, pattern = "(?<=\\(\\d{1}\\s{1}\\+\\s{1}).*(?=\\s{1}\\|)")
}


# get_outcome ----

# extracts the outcome variable by using a look-ahead, telling R to stop
# searching when it encounters " ~"

get_outcome <- function(form) {
  outcome <- str_extract(form, pattern = ".*(?=\\s{1}\\~)")
}

# get_fixed ----

# extracts the tilde (\\~) and fixed effects from the model formula, using a 
# positive look-ahead telling R to stop when it encounters " + ("

get_fixed <- function(form) {
  rhs_fixed <- str_extract(form, pattern = "\\~.*(?=\\s{1}\\+\\s{1}\\()")  
}


# get_rawdf ----

# extracts mean phenotype score for each sweep plus error
# useful for plotting the raw data
# dat = data
# sw = sweep/wave/occasion indicator
# age_y = age in years

get_rawdf <- function(dat, sw, age_y, outcome) {
  raw.df <- dat %>%
    group_by(across(!!sym(sw))) %>%
    summarise(Age = mean(!!sym(age_y), na.rm = T),
              Phenotype = mean(!!sym(outcome), na.rm = T),
              SD = sd(!!sym(outcome), na.rm = T),
              n = sum(!is.na(!!sym(outcome)))) %>%
    mutate(upper = Phenotype + ( qnorm(0.975)*SD/sqrt(n) ),
           lower = Phenotype - ( qnorm(0.975)*SD/sqrt(n) ))
  
  return(raw.df)
}
  

# make_emm_at ----

# generates emm_at for making predicted scores, only used if emm_at is NULL,
# producing a sequence of mean-centred ages based on the original data
# age_y = age in years column in dat - can be the name, or the values
# dat (optional) dataframe to find age_y column in
# agevar(optional) = name of the centred age variable used in trajectory models

make_emm_at <- function(dat=NULL, age_y, agevar) {
  
  if (!is.null(dat)) {
    age_y <- dat[[age_y]]  
  }
  
  age_vals <-  seq(min(age_y), max(age_y), 0.5) 
  
  #mean center to fit with the model
  age_cent <-  age_vals - mean(age_y, na.rm = T) 
  
  emm_at <- list(age_cent) |> `names<-`(agevar)
  
  return(emm_at)
}


# get_emm ----

# extracts predicted values from the lme4 model based on input parameters
# emm_at = (optional) named list of covariates included in the model formula 
# and the values/levels which you want estimates to be generated at. 

# obj = output from fit_lmer
# age_y = age in years column name in dat
# dat = data

get_emm <- function(dat, obj, age_y = NULL, emm_at = NULL) {
  
  agevar = get_age(form = obj$formula)
  outcome = get_outcome(form = obj$formula)
  rhs_fixed = get_fixed(form = obj$formula)
  
  if (is.null(emm_at)) { 
    emm_at = make_emm_at(dat = dat, age_y = age_y, agevar = agevar)
  }
  
  # get scores at ages
  emm <- emmeans(obj$fit, specs = as.formula(rhs_fixed), 
                 at = emm_at, 
                 lmer.df = "satterthwaite")
  return(emm)
}

# plot_dfs() ----

# make df with raw values and df with predicted values, combine into a single
# object for plotting
# dat = data
# sw = sweep/wave/occasion indicator
# age_y = age in years

plot_dfs <- function(dat, obj, sw, age_y, emm_at = NULL) {
  
  emm = get_emm(dat = dat, obj = obj, age_y = age_y, emm_at = emm_at)
  
  # add a column with the original age values by adding back the mean age in years
  age_m <- mean(dat[[age_y]], na.rm = T) # get the mean
  agevar = get_age(form = obj$formula)
  
  pred.df <- as.data.frame(summary(emm))
  pred.df$age_vals = pred.df[[agevar]] + age_m
  
  raw.df <- get_rawdf(dat = dat, sw = sw, age_y = age_y, outcome = get_outcome(form = obj$formula))
  
  out <- list(raw.df = raw.df, pred.df = pred.df)
  
  return(out)
}


# pred_add() ----

# function to add columns to pred.df() by splitting one column into two
# pred.df = pred.df from plot_dfs()
# string = name of column to be split
#     this column should be in the format [v1].[v2]
# v1 = name of first new column
# v2 = name of second new column

pred_add <- function(pred.df, string, v1, v2) {
  out <- mutate(pred.df,
    !!v1 := stringr::str_split_i(string = !!sym(string), "\\.", i = 1),
    !!v2 := stringr::str_split_i(string = !!sym(string), "\\.", i = 2)
  )
  return(out)
}

# traj_plot() ----

# plotdat = output from plot_dfs
# makes plot with predicted trajectory
# still need to manually specify axis labels etc

traj_plot <- function(plotdat, colour=NULL) {
  pred.df = plotdat$pred.df
  raw.df = plotdat$raw.df
  
  if (is.null(colour)==T) {
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
  } else {
    ggplot() + 
      geom_line(data = pred.df,
                aes(x = age_vals, y = emmean, colour = !!sym(colour)),
                linewidth = 1.5, na.rm = T) + 
      geom_ribbon(data = pred.df,
                  aes(x = age_vals, y = emmean, fill = !!sym(colour),
                      ymin = lower.CL, ymax = upper.CL),
                  alpha = 0.2, na.rm = T) +
      geom_point(data = raw.df, aes(x=Age, y=Phenotype))+
      geom_line(data = raw.df, aes(x=Age, y=Phenotype)) +
      geom_errorbar(data = raw.df, aes(x=Age, ymin = lower, ymax = upper))
  }
}


# contrasts ----

# emm = emm from get_emm - make sure you have whole numbers for age in your emm_at
# age_m = mean age to reverse mean-centring 
# c_grid = contrast grid to compare levels within a single variable
# simple = variable to use for contrasts, levels correspond to c_grid

mod_contrasts <- function(emm, simple, age_m, emm_at, c_grid) {
  
  emm_comparisons = contrast(emm, method = c_grid, simple = simple) |> broom::tidy()
  
  #add age column
  emm_comparisons$Age = emm_comparisons$age.cent + age_m
  
  emm_comparisons = emm_comparisons |> relocate(Age) |> select(-age.cent, -term) |> filter(!(Age %% 1))
  
  return(emm_comparisons)
}