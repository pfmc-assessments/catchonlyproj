#' A helper function to combine two projection tables
#'
#'
#'
#' @param base_model_table Data frame created by [get_model_values()]. This should
#'   be the base model.
#' @param cop_table Data frame created by [get_model_values()]. This should be the
#'   catch-only projection model.
#' @param assess_year  A single numeric value that corresponds to the assessment
#'   year of the model
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
#'   cop_model = projection_table_cop,
#'   assess_year = 2023
#' )
#' }
#'
combine_tables <- function(
  base_model_table,
  cop_model_table,
  assess_year
) {
  dplyr::full_join(
    base_model_table |>
      dplyr::select(-Buffer, -Buffer_from_ratio, -`Spawning Output`),
    cop_model_table,
    by = "Year"
  ) |>
    dplyr::rename(
      `OFL (yyyy)` = OFL.x,
      OFL = OFL.y,
      `ABC (yyyy)` = ABC.x,
      ABC = ABC.y,
      `ACL (yyyy)` = ACL.x,
      ACL = ACL.y,
      `Actual & Assumed Removals (yyyy)` = `Actual & Assumed Removals.x`,
      `Actual & Assumed Removals` = `Actual & Assumed Removals.y`,
      `Stock Status (yyyy)` = `Stock Status.x`,
      `Stock Status` = `Stock Status.y`,
    ) |>
    dplyr::select(
      c(
        "Year",
        "OFL (yyyy)",
        "OFL",
        "Buffer",
        "ABC (yyyy)",
        "ABC",
        "Actual & Assumed Removals (yyyy)",
        "Actual & Assumed Removals",
        "ACL (yyyy)",
        "ACL",
        "Spawning Output",
        "Stock Status (yyyy)",
        "Stock Status"
      )
    ) |>
    dplyr::rename_with(.fn = function(x) {
      gsub("yyyy", assess_year, x)
    })
}
