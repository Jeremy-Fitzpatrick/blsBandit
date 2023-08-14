#' Shiny Server Logic for blsViewer
#'
#' This function should not be run by the user.
#' @param input,output,session Internal shiny parameters.
#' @noRd
blsViewerServer <- function(input, output, session) {
  ## Update selections based on available unemployment series.
  updateSelectizeInput("unemploymentSeries",
    session = session,
    choices = blsSelect("SELECT uiName FROM blsSeriesNames;")$uiName,
    selected = blsSelect("SELECT uiName FROM blsSeriesNames;")$uiName[3]
  )

  ## Update years selections, based on unemployment series selection.
  observeEvent(input$unemploymentSeries,
    {
      years <- blsSelect(paste0(
        "SELECT DISTINCT year FROM blsDataSeries ",
        "INNER JOIN blsSeriesNames ON ",
        "blsSeriesNames.seriesID = blsDataSeries.fk_seriesID ",
        "WHERE uiName IN ('",
        paste(input$unemploymentSeries, collapse = "','"),
        "');"
      ))$year
      years <- sort(years)
      updateSelectizeInput("selectStartYear",
        session = session, choices = head(years, -1),
        selected = min(years)
      )
      updateSelectizeInput("selectEndYear",
        session = session, choices = tail(years, -1),
        selected = max(years)
      )
    },
    ignoreInit = TRUE,
    ignoreNULL = TRUE
  )

  ## Ensure that the start year is acceptable. Create plot based on years selected.
  observeEvent(input$selectStartYear,
    {
      if (input$selectStartYear > input$selectEndYear) {
        updateSelectizeInput("selectEndYear",
          session = session, selected = as.character(as.numeric(input$selectStartYear) + 1)
        )
      } else {
        output$unemploymentPlot <- renderPlotly({
          unemploymentPlot(
            input$unemploymentSeries, input$selectStartYear, input$selectEndYear
          )
        })
      }
    },
    ignoreNULL = TRUE,
    ignoreInit = TRUE
  )

  ## Ensure that the end year is acceptable. Create plot based on years selected.
  observeEvent(input$selectEndYear,
    {
      if (input$selectStartYear > input$selectEndYear) {
        updateSelectizeInput("selectStartYear",
          session = session, selected = as.character(as.numeric(input$selectEndYear) - 1)
        )
      } else {
        output$unemploymentPlot <- renderPlotly({
          unemploymentPlot(
            input$unemploymentSeries, input$selectStartYear, input$selectEndYear
          )
        })
      }
    },
    ignoreNULL = TRUE,
    ignoreInit = TRUE
  )
}
