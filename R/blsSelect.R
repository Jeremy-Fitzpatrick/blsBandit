#' Select BLS Data
#'
#' This function should not be run by the user.
#' @param query A valid SQL SELECT query
#' @noRd
blsSelect <- function(query) {
  dbLocation <- system.file("extdata", "blsData.sqlite", package = "blsBandit")
  con <- dbConnect(RSQLite::SQLite(), dbname = dbLocation)
  queryResult <- dbGetQuery(con, query)
  dbDisconnect(con)
  return(queryResult)
}
