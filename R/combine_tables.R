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
#'
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
