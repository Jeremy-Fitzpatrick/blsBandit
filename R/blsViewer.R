#' Run the BLS Viewer
#'
#' This function runs the BLS data viewer. Currently this viewer allows
#' the user to select and view unemployment data.
#' @keywords BLS Unemployment
#' @export
#' @examples
#' \dontrun{
#' # Run the BLS data viewer.
#' blsViewer()
#' }
blsViewer <- function() {
  shinyApp(ui = blsViewUI, server = blsViewerServer)
}
