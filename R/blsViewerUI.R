#' The User-Interface for the blsViewer
#'
#' This function should not be run by the user.
#' @noRd
blsViewUI <- function() {
  fluidPage(
    ## Title
    fluidRow(h1("BLS Viewer", style = "text-align: center;")),
    fluidRow(br()),

    ## Unemployment Plot
    fluidRow(column(offset = 1, 10, plotlyOutput("unemploymentPlot"))),
    fluidRow(br()),

    ## Selections for Series and Years
    fluidRow(
      column(
        offset = 2, 3,
        selectizeInput("unemploymentSeries", "Select Unemployment Series",
          choices = NULL
        )
      ),
      column(2, selectizeInput("selectStartYear", "Select Start Year",
        choices = NULL
      )),
      fluidRow(column(
        2,
        selectizeInput("selectEndYear", "Select End Year",
          choices = NULL
        )
      ))
    )
  )
}
