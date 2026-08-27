#' Pull in model results and format into a data table
#'
#' Create and format a projection table using created by [r4ss::SS_output()]
#' and [get_model_values()].
#'
#' @param dir Model directory for the model to summarize. This should be a
#'   directory that contains Stock Synthesis model files.
#'
#' @author Chantel Wetzel
#' @export
#' @examples
#' \dontrun{
#'   output_table <- get_output_table(
#'     dir = "C:/assessments/2027/my_model"
#'   )
#' }
#'
get_output_table <- function(dir) {
  model_output <- r4ss::SS_output(
    dir = dir,
    verbose = FALSE,
    printstats = FALSE,
    hidewarn = TRUE
  )

  projection_values <- get_model_values(
    replist = model_output
  )
  output <- list()
  output$spawning_text <- tolower(model_output$SpawnOutputLabel)
  output$assess_year <- as.numeric(model_output$endyr + 1)
  output$projection_values <- projection_values
  return(output)
}
