#' The User-Interface for the blsViewer
#'
#' This function should not be run by the user.
#' @noRd
blsViewUI <- function() {
  fluidPage(
    theme = shinytheme("superhero"),
    ## Title
    fluidRow(h1("BLS Viewer", style = "text-align: center;")),
    fluidRow(br()),

    ## Unemployment Plot
    fluidRow(column(offset = 1, 10, plotlyOutput("unemploymentPlot"))),
    fluidRow(br()),

    ## Selections for Series and Years
    fluidRow(
      column(
        offset = 2, 3, align = "center",
        selectizeInput("unemploymentSeries", "Select Unemployment Series",
          choices = NULL, multiple = TRUE
        )
      ),
      column(2,
        align = "center",
        selectizeInput("selectStartYear", "Select Start Year",
          choices = NULL
        )
      ),
      fluidRow(column(
        2,
        align = "center",
        selectizeInput("selectEndYear", "Select End Year",
          choices = NULL
        )
      ))
    )
  )
}
