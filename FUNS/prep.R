# Make data dictionary of variable names, label (description) and labels (levels) ----

get_data_dict <- function(df) {
  DataDict = data.frame(
  VarName = names(df),
  Description = as.character(lapply(df, function(x) attributes(x)$label)),
  Values = as.character(lapply(df, function(x) attributes(x)$labels)))

## Tidy up strings in columns
  DataDict$Values = stringr::str_remove_all(DataDict$Values, pattern = "^c|\\(|\\`|\\)")
 DataDict$Description = stringr::str_remove_all(DataDict$Description, pattern = "^c|\\(|\\`|\\)")
 return(DataDict)
} 


# Column flagging how many missing columns a ppt has ----
# df = data frame
# cols = list of columns you want to count missings in with corresponding output colname
n_occ_missed <- function(df, cols) {
  newdf = df
  for (i in seq_along(cols)) {
    selectcols = unlist(cols[i])
    newname = names(cols)[i]
    newdf = newdf %>% mutate(
      !!newname := rowSums(is.na(across(all_of(selectcols))))
    )
  }
  return(newdf)
}


# Column with 1 if not missing and 0 if missing ----
# df = dataframe 
# var_cols = vector of columns to check missings in
# new_names = vector of names for the new columns, corresponding to length of var_cols
make_misscols <- function(df, var_cols, new_names) {
  newdf = df
  for (i in seq_along(var_cols)) {
    var = df %>% pull(var_cols[i])
    newdf[[new_names[i]]] = ifelse(is.na(var), 0, 1) |> as.factor()
  }
  return(newdf)
}


# Make weights from multiply imputed dataset ----
# outcome = vector of attendance at each sweep to make weights for
# preds = vector of predictors to use 
# idcol = column with ppt IDs

make_wt = function(mids.df, outcome, preds, idcol) {
  weights_df = data.frame(idcol=mids.df$data[[idcol]])
  sweep_prob = c()
  
  for (i in seq_along(outcome)) {
    
    if (i==1) {
      
      #the first iteration doesn't add weight from the previous sweep
      rhs = paste(preds, collapse = " + ")  
      form = paste0(outcome[i]," ~ ", rhs) 
    
      #logistic regression predicting attendance
      fit = with(mids.df, glm(formula = as.formula(form), family = binomial))
      
    } else {
      
      #add weight from previous sweep to existing formula
      wt = paste0("ipw_", outcome[i-1])
      rhs = paste(c(preds, wt), collapse = " + ")
      form = paste0(outcome[i]," ~ ", rhs)
      
      #specify to use new imputed data with the ipw
      fit = with(mids.df.ipw, glm(formula = as.formula(form), family = binomial))
    }
    
    # calculate pooled predicted probability for each ppt
    prob_pooled = predict_mi(fit, pool = TRUE, type = "response", se.fit = F)
    
    ipw = 1/prob_pooled
    marginal_prob = as.character(mids.df$data[[outcome[i]]]) |> as.numeric() |> 
      mean()
    ipw_stable = ipw*marginal_prob
    
    df = data.frame(prob_pooled, ipw_stable)
    names(df) = c(paste0("prob_", outcome[i]), paste0("ipw_", outcome[i]))
    
    # save to output df
    weights_df = cbind(weights_df, df)
    
    # add to mids.df
    mids.df.ipw = cbind(mids.df, df)
    sweep_prob[[outcome[i]]] = marginal_prob
  } 
  
  return(list(weights_df = weights_df, sweep_prob = sweep_prob))
}

