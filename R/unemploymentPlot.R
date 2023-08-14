#' Create Unemployment Plot
#'
#' This function should not be run by the user.
#' @param series selection of unemployment series
#' @param yearStart selection of start year for series
#' @param yearEnd selection of end year for series
#' @noRd
unemploymentPlot <- function(series, yearStart, yearEnd) {
  ## Get unemployment data from data base.
  unemploymentData <- blsSelect(paste0(
    "SELECT uiName, year, month, rate FROM blsDataSeries ",
    "INNER JOIN blsSeriesNames ON ",
    "blsSeriesNames.seriesID = blsDataSeries.fk_seriesID ",
    "WHERE uiName IN ('",
    paste(series, collapse = "','"),
    "') AND ", " year >= ", yearStart, " AND year <= ", yearEnd, ";"
  ))

  ## If no data is found return a warning.
  if (nrow(unemploymentData) == 0) {
    warning("No Unemployment Data For Selection")
    return(NULL)
  }

  ## Create sortable month/year formatted column.
  unemploymentData$yearMonth <- as.yearmon(paste(
    unemploymentData$month,
    unemploymentData$year
  ))
  unemploymentData <- unemploymentData[order(unemploymentData$yearMonth), ]

  ## Create Plotly plot of unemployment data.
  blsPlot <- plot_ly(unemploymentData, split = ~uiName,
    x = ~yearMonth, y = ~rate, type = "scatter", mode = "lines"
  ) %>%
    layout(
      xaxis = list(title = "Year"),
      yaxis = list(title = "Unemployment Rate"),
      title = series
    )

  return(blsPlot)
}
