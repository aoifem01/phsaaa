% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_history_functions.R
\name{build_history}
\alias{build_history}
\title{Create backup and update new historical database of AAA screening KPIs, only runs if 'season_var' is "autumn"}
\usage{
build_history(
  df_hist,
  df_new,
  kpi_number,
  season_var,
  fys_in_report,
  list_of_fys,
  list_of_hbs,
  historical_path
)
}
\arguments{
\item{df_hist}{Dataframe/tibble which contains historical data for relevant KPI.}

\item{df_new}{Dataframe/tibble containing new data for relevant KPI.}

\item{kpi_number}{KPI being added to the historical database, options are: "1.1-1.3", "1.4", "2", or "3"}

\item{season_var}{Season of analysis, options are "Spring" or "Autumn"}

\item{fys_in_report}{Character vector, must be >= 3 length. Includes financial year being published, plus two prior.}

\item{list_of_fys}{Character vector of financial years in data, in chronological order}

\item{list_of_hbs}{Character vector of Health Board names, in alphabetic order}

\item{historical_path}{Filepath that points to the output directory - this is where previous historical data exists.}
}
\value{
New historical dataframe/tibble updated for this analysis round.
}
\description{
Function requires multiple global environment variables to be specified:
'season_var' - either 'autumn' or 'spring'
'historical_path' - path to directory where historical files are to be stored
'fys_in_report' - vector containing 3 character strings of financial years - third is the FY due to be published next
'list_of_fys' - list of financial years covering time since AAA screening started, in chronological order
'list_of_hbs' - list of NHS Health Boards in alphabetical order
}
\examples{


old <- dplyr::tibble(fin_year = c("2021/22", "2022/23"), kpi = "2.2", hbres = "Lothian", value = c(1,2))
new <- dplyr::tibble(fin_year = "2023/24", kpi = "2.2", hbres = "Lothian", value = 4)

new_hist_db <- build_history(old, new, "2", season_var = "autumn", fys_in_report = c("2021/22", "2022/23", "2023/24"), list_of_fys = list_of_fys, list_of_hbs = list_of_hbs)

print(new_hist_db)

# A tibble: 3 × 4
#    fin_year     kpi      hbres     value
#     <fct>      <chr>     <fct>     <dbl>
# 1  2021/22      2.2      Lothian     1
# 2  2022/23      2.2      Lothian     2
# 3 2023/24       2.2      Lothian     4
}
