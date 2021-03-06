
vr_summarize <- function(x) UseMethod("vr_summarize")

#' Title
#'
#' @param x 
#'
#' @return
#' @export
#'
#' @examples
vr_summarize.factor <- function(x){
  dat <- tibble::enframe(x) %>%
    dplyr::group_by(value) %>%
    dplyr::summarise(N = n()) %>%
    dplyr::mutate(`%` = round(100 * N/sum(N), 3)) %>%
    tidyr::pivot_wider(names_from = value, values_from = c("N", "%"), names_sep=" ") %>%
    as.list()
  list(dat)
}

#' Title
#'
#' @param x 
#'
#' @return
#' @export
#'
#' @examples
vr_summarize.numeric <- function(x){
  dat <- list(
    mean = mean(x, na.rm = T),
    min = min(x, na.rm = T),
    Q1 = quantile(x, probs=0.25),
    median = median(x, na.rm = T) ,
    Q3 = quantile(x, probs=0.75),
    max = max(x, na.rm = T),
    sd = sd(x, na.rm = T)
  )
  list(dat)
}

#' Title
#'
#' @param x 
#'
#' @return
#' @export
#'
#' @examples
vr_summarize.default <- function(x){
  dat <- list(
    unique_values = length(unique(x)),
    nmiss = sum(is.na(x))
  )
  list(dat)
}

#' Create Summary Table (also known as Table 1)
#' 
#' @description Create a summary table of descriptive statistics from a dataframe or tibble. 
#' 
#' By default the following summary stats are calculated:
#' * Numeric variables: mean, min, 25th-percentile, median, 75th-percentile, maximum, standard deviation
#' * Factor variables: proportion of each factor level in the overall dataset
#' * Default: number of unique values and number of missing values
#'
#' @param data The dataset to summarize as dataframe or tibble
#' @param groupCols Stratifying/Grouping variable name(s) as character vector. If NULL, only overall results are returned
#' @param overall If TRUE, the summary statistics for the overall dataset are also calculated 
#' @param summary_function A function defining summary statistics for numeric and categorical values
#' 
#' @details It is possible to provide your own summary function. Please have a loot at vr_summary for inspiration.
#' 
#' @note All columns in the table will be summarized. If only some columns shall be used, please select only those
#' variables prior to creating the summary table by using dplyr::select()
#' 
#' @export
#' 
#' @examples
#' library(survival)
#' library(tidyverse)
#' ovarian %>% 
#' select(-fustat) %>% 
#'   mutate(age_group = factor(case_when(age <= 50 ~ "<= 50 years",
#'                                       age <= 60 ~ "<= 60 years",
#'                                       age <= 70 ~ "<= 70 years",
#'                                       TRUE ~ "> 70 years")),
#'          rx = factor(rx),
#'          ecog.ps = factor(ecog.ps)) %>% 
#'   select(age, age_group, everything()) %>% 
#'   vr_create_tableone()
vr_create_tableone <- function(data, groupCols = NULL, overall=TRUE, summary_function = vr_summarize){
  
  summary_FUN <- match.fun(summary_function)
  
  if(overall & !is.null(groupCols)){
    overall_table1 <- vr_create_tableone(data, groupCols = NULL, overall = FALSE)
    combine_dfs <- TRUE
  }
  else{
    combine_dfs = FALSE
  }
  
  if(is.null(groupCols)){
    data <- data %>% 
      dplyr::mutate(all = "Overall")
    groupCols <- c("all")
  }
  
  data <- data %>% 
    dplyr::group_by(!!!syms(groupCols))
  
  data_ns <- data %>% 
    dplyr::summarise(summary = n()) %>% 
    tidyr::pivot_wider(names_from = tidyselect::any_of(groupCols), values_from = "summary") %>%
    dplyr::mutate(variable = "Sample", summary_id = "N")
  
  data_summary <- data %>% 
    dplyr::summarise_all(summary_FUN) %>% 
    dplyr::ungroup() %>% 
    tidyr::pivot_longer(cols = setdiff(names(.), groupCols), names_to = "variable", values_to = "summary") %>% 
    tidyr::unnest_longer(summary) %>% 
    tidyr::pivot_wider(names_from = tidyselect::any_of(groupCols), values_from = "summary")
  
  data_table1 <- rbind(data_ns, data_summary) %>% 
    dplyr::rename(statistic = summary_id) %>% 
    dplyr::select(variable, statistic, everything())
  
  if(overall & combine_dfs){
    data_table1 <- data_table1 %>% dplyr::left_join(overall_table1, by=c("variable", "statistic"))
  }
  
  return(data_table1)
}

