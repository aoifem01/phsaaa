#' Create backup and update new historical database of AAA screening KPIs, only runs if season is "autumn"
#'
#' Function requires multiple global environment variables to be specified:
#' 'season' - either 'autumn' or 'spring'
#' 'hist_path' - path to directory where historical files are to be stored
#' 'kpi_report_years' - vector containing 3 character strings of financial years - third is the FY due to be published next
#' 'fy_list' - list of financial years covering time since AAA screening started, in chronological order
#' 'hb_list' - list of NHS Health Boards in alphabetical order
#'
#' @param df_hist Dataframe/tibble which contains historical data for relevant KPI.
#' @param df_new Dataframe/tibble containing new data for relevant KPI.
#' @param kpi KPI being added to the historical database, options are: "1.1-1.3", "1.4", "2", or "3"
#'
#' @return New historical dataframe/tibble updated for this analysis round.
#' @export
#'
#' @examples
#' # (example does not account for additional global environments required)
#'
#' old <- dplyr::tibble(fin_year = c("2021/22", "2022/23"), kpi = "2.2", hbres = "Lothian", value = c(1,2))
#' new <- dplyr::tibble(fin_year = "2023/24", kpi = "2.2", hbres = "Lothian", value = 4)
#'
#' new_hist_db <- build_history(old, new, "2")
#'
#' print(new_hist_db)
#'
#' # A tibble: 3 × 4
#' #    fin_year     kpi      hbres     value
#' #     <fct>      <chr>     <fct>     <dbl>
#' # 1  2021/22      2.2      Lothian     1
#' # 2  2022/23      2.2      Lothian     2
#' # 3 2023/24       2.2      Lothian     4

build_history <- function(df_hist, df_new, kpi) {
  if (season == "spring") {
    table(df_hist$kpi, df_hist$fin_year)

    print("Don't add to the history file. Move along to next step")

  } else {

    if (season == "autumn") {
      # initial tests
      build_history_checks(df_hist, df_new, kpi)

      # create filename based on KPI inputted
      theme <- paste0("theme", as.numeric(substr(kpi, 1, 1))+1)
      filename_bckp <- paste0("/aaa_kpi_historical_", theme, "_bckp.rds") # backup file
      filename_hist <- paste0("/aaa_kpi_historical_", theme, ".rds") # new historical db


      # save a backup of df_hist
      # if kpi_report_year[2] already present, means it's already been updated this analysis round
      if(!kpi_report_years[2] %in% df_hist$fin_year & !kpi == "1.4"){
        # write backup file
        readr::write_rds(df_hist, paste0(hist_path, filename_bckp))
        # change permissions to give the group read/write
        Sys.chmod(paste0(hist_path, filename_bckp),
                  mode = "664", use_umask = FALSE)

        print("Backup of historical database written.")
      } else {
        print("Backup already created for this analysis round.")
      }

      # format df_new for inclusion
      if(kpi == "1.1-1.3"){
        df_new <- df_new |>
          dplyr::filter(kpi != "KPI 1.1 Sept coverage",
                 fin_year != year2)
      } else {
        df_new <- df_new |>
          dplyr::filter(fin_year == kpi_report_years[3])
      }

      print("Table of df_new$kpi, df_new$fin_year:")
      print(table(df_new$kpi, df_new$fin_year))

      ## New historical database ----
      new_hist_db <- add_new_rows(df1 = df_hist, df2 = df_new, fin_year, kpi) |>
        dplyr::mutate(fin_year = forcats::fct_relevel(fin_year, c(fy_list)),
                      hbres = forcats::fct_relevel(hbres, c(hb_list)))

      if(kpi == "1.1-1.3"){
        new_hist_db <- new_hist_db |>
          dplyr::mutate(
            kpi = forcats::fct_relevel(
              kpi, c("KPI 1.1", "KPI 1.1 Scotland SIMD",
                     "KPI 1.1 Scotland SIMD Sept coverage",
                     "KPI 1.2a", "KPI 1.2a Sept coverage",
                     "KPI 1.2b", "KPI 1.3a Scotland SIMD",
                     "KPI 1.3a Sept coverage", "KPI 1.3a HB SIMD",
                     "KPI 1.3b Scotland SIMD", "KPI 1.3b HB SIMD",
                     "KPI 1.4a", "KPI 1.4b")))
      }

      new_hist_db <- new_hist_db |>
        dplyr::arrange(kpi, fin_year, hbres)

      print("Table of new_hist_db$kpi, new_hist_db$fin_year:")
      print(table(new_hist_db$kpi, new_hist_db$fin_year))

      # write new hist_db
      readr::write_rds(new_hist_db, paste0(hist_path, filename_hist))
      # change permissions to give the group read/write
      Sys.chmod(paste0(hist_path, filename_hist),
                mode = "664", use_umask = FALSE)

      print("You made history! Proceed.")

    } else {

      stop("Season is not 'spring' or 'autumn'. Go check your calendar!")
    }
  }
}
