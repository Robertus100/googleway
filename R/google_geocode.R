#' Google geocoding
#'
#' Geocoding is the process of converting addresses (like "1600 Amphitheatre
#' Parkway, Mountain View, CA") into geographic coordinates (like latitude 37.423021
#' and longitude -122.083739), which you can use to place markers on a map, or position the map.
#'
#' @param address \code{string}. The street address that you want to geocode, in the
#' format used by the national postal service of the country concerned
#' @param bounds list of two, each element is a vector of lat/lon coordinates
#' representing the south-west and north-east bounding box
#' @param language \code{string}. Specifies the language in which to return the results.
#' See the list of supported languages:
#' \url{https://developers.google.com/maps/faq#using-google-maps-apis}. If no
#' langauge is supplied, the service will attempt to use the language of the domain
#' from which the request was sent
#' @param region \code{string}. Specifies the region code, specified as a ccTLD
#' ("top-level domain"). See region basing for details
#' \url{https://developers.google.com/maps/documentation/directions/intro#RegionBiasing}
#' @param key \code{string}. A valid Google Developers Geocode API key
#' @param components \code{data.frame} of two columns, component and value. Restricts
#' the results to a specific area. One or more of "route","locality","administrative_area",
#' "postal_code","country"
#' @param simplify \code{logical} - TRUE indicates the returned JSON will be coerced into a list. FALSE indicates the returend JSON will be returned as a string
#' @param curl_proxy a curl proxy object
#' @return Either list or JSON string of the geocoded address
#' @examples
#' \dontrun{
#' df <- google_geocode(address = "MCG, Melbourne, Australia",
#'                      key = "<your valid api key>",
#'                      simplify = TRUE)
#'
#' df$results$geometry$location
#'         lat      lng
#' 1 -37.81659 144.9841
#'
#' ## using bounds
#' bounds <- list(c(34.172684,-118.604794),
#'                c(34.236144,-118.500938))
#'
#' js <- google_geocode(address = "Winnetka",
#'                      bounds = bounds,
#'                      key = "<your valid api key>",
#'                      simplify = FALSE)
#'
#' ## using components
#' components <- data.frame(component = c("postal_code", "country"),
#'                          value = c("3000", "AU"))
#'
#'df <- google_geocode(address = "Flinders Street Station",
#'                    key = "<your valid api key>",
#'                    components = components,
#'                    simplify = FALSE)
#'
#' }
#' @export
google_geocode <- function(address,
                           bounds = NULL,
                           key = get_api_key("geocode"),
                           language = NULL,
                           region = NULL,
                           components = NULL,
                           simplify = TRUE,
                           curl_proxy = NULL
                           ){

  ## parameter check - key
  if(is.null(key))
    stop("A Valid Google Developers API key is required")

  logicalCheck(simplify)

  address <- check_address(address)
  address <- tolower(address)
  bounds <- validateBounds(bounds)
  language <- validateLanguage(language)
  region <- validateRegion(region)
  components <- validateComponents(components)

  map_url <- "https://maps.googleapis.com/maps/api/geocode/json?"
  map_url <- constructURL(map_url, c("address" = address,
                                     "bounds" = bounds,
                                     "language" = language,
                                     "region" = region,
                                     "components" = components,
                                     "key" = key))

  return(downloadData(map_url, simplify, curl_proxy))

}
