#' Format a projection table for a pdf report created using `quarto`
#'
#' Create and format a projection table using created by [get_model_values()]
#' or [combine_tables()].
#'
#' @param table Data frame created by [get_model_values()] or [combine_tables()]
#'   to apply formatting to for reporting.
#' @param assess_year  A single numeric value that corresponds to the assessment
#'   year of the model. Default is NULL.
#' @param sb_decimal_number A single numeric value to determine the number of decimals
#'   to include for spawning biomass/output reporting in the formatted table object.
#'   The default is 2.
#' @param hl_decimal_number A single numeric value to determine the number of decimals
#'   to include for OFL, ABC, and ACL reporting in the formatted table object. The
#'   default is 0.
#'
#'
#' @author Chantel Wetzel, Ian Taylor, Brian Langseth
#' @export
#' @examples
#' \dontrun{
#' base_model <- r4ss::SS_output("C:/model_directory/base_model")
#' cop_model <- r4ss::SS_output("C:/model_directory/cop_model")
#'
#' projection_table_base_model <- get_model_values(
#'   model = base_model
#' )
#'
#' projection_table_cop <- get_model_values(
#'   model = cop_model
#' )
#' output <- combine_tables(
#'   base_model_table = projection_table_base_model,
#'   cop_model_table = projection_table_cop,
#'   assess_year = 2023
#' )
#'
#' format_table(
#'   table = output
#' )
#' }
#'
#'
format_table <- function(
  table,
  assess_year = NULL,
  sb_decimal_number = 2,
  hl_decimal_number = 0
) {
  table |>
    gt::gt() |>
    gt::fmt_number(
      columns = tidyselect::starts_with("Actual") |
        tidyselect::starts_with("OFL") |
        tidyselect::starts_with("ABC") |
        tidyselect::starts_with("ACL"),
      decimals = hl_decimal_number
    ) |>
    gt::fmt_number(
      columns = tidyselect::contains("Spawning"),
      decimals = sb_decimal_number
    ) |>
    gt::tab_options(
      table.font.size = 11,
      latex.use_longtable = TRUE
    ) |>
    gt::cols_align(
      align = "center"
    ) |>
    gt::cols_width(
      tidyselect::everything() ~ px(65)
    ) |>
    gt::data_color(
      columns = tidyselect::contains(paste(assess_year)),
      palette = "gray90",
      na_color = "gray90"
    ) |>
    gt::sub_missing(
      columns = tidyselect::everything(),
      missing_text = "---"
    ) |>
    gt::as_latex()
}
