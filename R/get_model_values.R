#' Grab and return data frame of projection values from a list object
#'
#' Pull out projection values using list items created by [r4ss::SS_output()] and
#' [r4ss::SS_readforecast()] (ran inside the function) and return formatted
#' data frame.
#'
#'
#'
#' @param replist Model list object created by [r4ss::SS_output()] to summarize
#'   values from.
#' @param buffer Default NULL. If NULL, the function will return the buffer
#' fraction from the model forecast file. A data frame created by
#' [PEPtools::get_buffer()] can be passed to the function via this
#' arguement that will be used in the formatted data frame rather than the
#' values in the forecast file.
#'
#'
#' @author Chantel Wetzel, Ian Taylor, Brian Langseth
#' @export
#' @return data frame
#' @examples
#' \dontrun{
#' model_output <- r4ss::SS_output("C:/model_directory")
#' projection_table <- get_model_values(
#'   replist = model_output
#' )
#' }
#
get_model_values <- function(
  replist,
  buffer = NULL
) {
  if (replist$inputs$forecast) {
    forecast <- r4ss::SS_readforecast(
      file = file.path(replist$inputs$dir, "forecast.ss"),
      verbose = FALSE
    )
  } else {
    cli::cli_abort(
      "The model output from r4ss::SS_output has forecast = FALSE."
    )
  }

  all_years <- (replist$endyr + 1):(replist$endyr + replist$N_forecast_yrs)
  catch_years <- sort(unique(forecast$ForeCatch$year))
  proj_years <- all_years[!all_years %in% catch_years]

  # get realized catch from model output
  catch <- replist$derived_quants |>
    dplyr::filter(Label %in% paste0("ForeCatch_", catch_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      Catch = Value
    )
  ofl <- replist$derived_quants |>
    dplyr::filter(Label %in% paste0("OFLCatch_", proj_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      OFL = Value
    )
  acl <- replist$derived_quants |>
    dplyr::filter(Label %in% paste0("ForeCatch_", proj_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      ACL = Value
    )
  sb <- replist$derived_quants |>
    dplyr::filter(Label %in% paste0("SSB_", all_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      SB = Value
    )
  status <- replist$derived_quants |>
    dplyr::filter(Label %in% paste0("Bratio_", all_years)) |>
    dplyr::reframe(
      Year = stringr::str_extract(Label, "\\d+") |> as.numeric(),
      status = round(Value, 3)
    )

  if (is.null(buffer)) {
    Buffer <- data.frame(
      Year = forecast$Flimitfraction_m$year,
      Buffer = forecast$Flimitfraction_m$fraction
    ) |>
      dplyr::filter(Year %in% proj_years)
  } else {
    Buffer <- buffer
    colnames(Buffer) <- c("Year", "Buffer")
    Buffer <- Buffer |>
      dplyr::filter(Year %in% proj_years)
  }

  buffer_ratio <- dplyr::left_join(
    ofl,
    acl
  ) |>
    dplyr::mutate(
      Buffer_ratio = round(ACL / OFL, 3)
    ) |>
    dplyr::select(Year, Buffer_ratio) |>
    dplyr::filter(Year %in% proj_years)

  # combine all the tables above (joined by year)
  table <- purrr::reduce(
    list(ofl, Buffer, acl, sb, status, catch),
    ~ dplyr::full_join(.x, .y, by = "Year")
  ) |>
    dplyr::arrange(Year) |>
    dplyr::relocate(Catch, .after = Year) |>
    dplyr::mutate(
      ABC = Buffer * OFL,
    ) |>
    dplyr::relocate(
      OFL,
      .after = Year
    ) |>
    dplyr::relocate(
      Buffer,
      .after = OFL
    ) |>
    dplyr::relocate(
      ABC,
      .after = Buffer
    ) |>
    dplyr::relocate(
      Catch,
      .after = ABC
    ) |>
    dplyr::relocate(
      ACL,
      .after = Catch
    ) |>
    dplyr::relocate(
      SB,
      .after = ACL
    ) |>
    dplyr::relocate(
      status,
      .after = SB
    ) |>
    dplyr::rename(
      `Actual & Assumed Removals` = Catch,
      `Stock Status` = status,
      `Spawning Output` = SB,
    )
  if (any(Buffer$Buffer != buffer_ratio$Buffer_ratio)) {
    table <- dplyr::left_join(
      table,
      buffer_ratio
    ) |>
      dplyr::relocate(
        Buffer_ratio,
        .after = Buffer
      )
  }
  return(table)
}
