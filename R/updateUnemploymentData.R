#' Get BLS Unemployment Data
#'
#' This function allows the user to update the unemployment data in the
#' blsData.sqlite database.
#' This not only allows the user to pull the latest data but also to update the data.
#' Since data is typically revised in the months after it is release.
#' The year including and preceding nine years are pulled from the BLS.
#' This is because a data set spanning 10 years is the maximum allowed by the
#' BLS's tier 1 API. Learn more about the API here:
#' https://www.bls.gov/developers/api_signature.htm#years
#' The blsAPI package is required and is available from github. See examples.
#' @param lastYear most recent year that data will be pulled from
#' @keywords BLS API Unemployment
#' @export
#' @examples
#' \dontrun{
#' # Install devtools if needed.
#' install.packages("devtools")
#'
#' # Install blsAPI package if needed.
#' library(devtools)
#' install_github("mikeasilva/blsAPI")
#'
#' # Pull and update with the most recent BLS unemployment data.
#' updateUnemploymentData(lastYear = 2023)
#' }
updateUnemploymentData <- function(lastYear = 2023) {
  ## Create request for BLS API
  payload <- list(
    "seriesid" = c(
      "LNS13025670", # U1 unemployment series
      "LNS14023621", # U2 unemployment series
      "LNS14000000", # U3 unemployment series
      "LNS13327707", # U4 unemployment series
      "LNS13327708", # U5 unemployment series
      "LNS13327709" # U6 unemployment series
    ),
    "startyear" = as.character(lastYear - 9),
    "endyear" = as.character(lastYear)
  )

  ## Get API response
  ## Require non-standard blsAPI package. Return warning if not installed.
  if (requireNamespace("blsAPI", quietly = TRUE)) {
    response <- blsAPI::blsAPI(payload)
  } else {
    warning(paste(
      "The blsAPI package is required to load the most recent BLS data.",
      "More information can be found here: https://www.bls.gov/developers/api_r.htm."
    ))
    return(NULL)
  }
  json <- fromJSON(response)

  ## Sort out unemployment series and load them into the database
  for (series in json$Results$series$seriesID) {
    seriesID <- blsSelect(paste0(
      "SELECT seriesID FROM blsSeriesNames WHERE blsSeries ='",
      series, "';"
    ))[1, 1]
    unemploymentDataframe <- json$Results$series[
      json$Results$series$seriesID == series,
    ]$data[[1]]
    if (nrow(unemploymentDataframe) > 0) {
      unemploymentDataframe <- unemploymentDataframe[, c("year", "periodName", "value")]
      names(unemploymentDataframe) <- c("year", "month", "rate")
      unemploymentDataframe$fk_seriesID <- seriesID
      updateDataTable(unemploymentDataframe)
    }
  }
}

#' Update BLS Database From Data Frame
#'
#' This function should not be run by the user.
#' @param unemploymentDataframe data.frame created internally in the updateUnemploymentData
#' function
#' @noRd
updateDataTable <- function(unemploymentDataframe) {
  ## Connect to blsData.sqlite database
  dbLocation <- system.file("extdata", "blsData.sqlite", package = "blsBandit")
  con <- dbConnect(RSQLite::SQLite(), dbname = dbLocation)

  ## Loop to INSERT/UPDATE all unemploymentDataframe data
  for (n in c(1:nrow(unemploymentDataframe))) {
    ## Determine if the data already exists
    test <- dbGetQuery(con, paste0(
      "SELECT * FROM blsDataSeries",
      " WHERE",
      " fk_seriesID = ", unemploymentDataframe$fk_seriesID[n],
      " AND year = ", unemploymentDataframe$year[n],
      " AND month = '", unemploymentDataframe$month[n],
      "';"
    ))

    ## If it does not exist add the data
    if (nrow(test) == 0) {
      dbExecute(con, paste0(
        "INSERT INTO blsDataSeries ",
        "(fk_seriesID, year, month, rate) ",
        "VALUES",
        "(", unemploymentDataframe$fk_seriesID[n], ",",
        unemploymentDataframe$year[n], ",",
        "'", unemploymentDataframe$month[n], "',",
        unemploymentDataframe$rate[n], ");"
      ))

      ## If it does exist update the data
    } else {
      dbExecute(con, paste0(
        "UPDATE blsDataSeries SET rate = ",
        unemploymentDataframe$rate[n],
        " WHERE",
        " fk_seriesID = ", unemploymentDataframe$fk_seriesID[n],
        " AND year = ", unemploymentDataframe$year[n],
        " AND month = '", unemploymentDataframe$month[n],
        "';"
      ))
    }
  }

  ## Disconnect from blsData.sqlite database
  dbDisconnect(con)
}
