#' Grab and combine model quantities for reporting
#'
#'
#'
#' @param model Model list object created by [r4ss::SS_output()] to summarize
#'   values from.
#' @param all_years A numeric range of years (e.g., 2025:2036) that should correspond
#'   with the model projection years to pull the SSB and stock status.
#'   OFL, ABC, and ACL will be pull for each year.
#' @param catch_years A numeric range of years where catches are pre-specified in
#'   the forecast.ss file for a Stock Synthesis model.
#' @param proj_years A numeric range of years to summarize the OFL, ABC, and ACL
#'   from  a Stock Synthesis model object. The `proj_years` should be the years
#'   where there are no pre-specified catches in the forecast.ss file.
#'
#'
#' @author Chantel Wetzel, Ian Taylor, Brian Langseth
#' @export
#' @return data frame
#' @examples
#' \dontrun{
#' model_output <- r4ss::SS_output("C:/model_directory")
#' projection_table <- get_model_values(
#'   model = model_output,
#'   all_years = (model_output$endyr + 1):(model_output$endyr + model_output$N_forecast_yrs),
#'   catch_years = (model_output$endyr + 1):(model_output$endyr + 4),
#'   proj_years = (model_output$endyr + 5):(model_output$endyr + model_output$N_forecast_yrs)
#' )
#' }
#
get_model_values <- function(
  model,
  all_years,
  catch_years,
  proj_years
) {
  model_years <- model$startyr:(model$endyr + model$N_forecast_yrs)
  if (any(!all_years %in% model_years)) {
    cli::cli_abort(
      "Years provided in the all_years that are not included in the model years"
    )
  }
  model_proj <- (model$endyr + 1):(model$endyr + model$N_forecast_yrs)
  if (any(!proj_years %in% (model_proj))) {
    cli::cli_abort(
      "Years provided in the proj_years that are not included in the model projection years"
    )
  }
  if (any(!catch_years %in% model_proj)) {
    cli::cli_abort(
      "Years provided in the catch_years that are not included in the model projection years"
    )
  }

  # get realized catch from model output
  catch <- model$derived_quants |>
    dplyr::filter(Label %in% paste0("ForeCatch_", catch_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      Catch = Value
    )
  ofl <- model$derived_quants |>
    dplyr::filter(Label %in% paste0("OFLCatch_", proj_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      OFL = Value
    )
  acl <- model$derived_quants |>
    dplyr::filter(Label %in% paste0("ForeCatch_", proj_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      ACL = Value
    )
  sb <- model$derived_quants |>
    dplyr::filter(Label %in% paste0("SSB_", all_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      SB = Value
    )
  status <- model$derived_quants |>
    dplyr::filter(Label %in% paste0("Bratio_", all_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      status = round(Value, 3)
    )

  # get buffer from PEPtools function
  Buffer <- PEPtools::get_buffer(
    years = all_years,
    sigma = sigma,
    pstar = p_star,
    verbose = FALSE
  ) |>
    dplyr::rename(Year = year, Buffer = buffer) |>
    dplyr::filter(Year %in% proj_years)

  # combine all the tables above (joined by year)
  table <- purrr::reduce(
    list(ofl, Buffer, acl, sb, status, catch),
    ~ dplyr::full_join(.x, .y, by = "Year")
  ) |>
    dplyr::arrange(Year) |>
    dplyr::relocate(Catch, .after = Year) |>
    dplyr::mutate(
      Buffer_from_ratio = dplyr::case_when(
        status >= model$btarg ~ round(ACL / OFL, 3),
        .default = NA # ratio doesn't work for years with 40-10 adjustment
      ),
      .after = Buffer
    ) |>
    dplyr::mutate(
      ABC = Buffer * OFL,
      .after = Buffer_from_ratio
    ) |>
    dplyr::rename(
      `Actual & Assumed Removals` = Catch,
      `Stock Status` = status,
      `Spawning Output` = SB,
    )
  return(table)
}
