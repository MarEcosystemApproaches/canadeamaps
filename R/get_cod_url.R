#' Find the download URL for a resource on the federal Open Data portal
#'
#' Queries the Canada Open Data (open.canada.ca) CKAN API for a dataset UUID and
#' returns the URL(s) of the resource(s) whose URL ends in `ext` or whose CKAN
#' `format` field matches `ext`.
#'
#' Based on https://github.com/dfo-mar-mpas/MarConsNetData/blob/main/R/get_COD_url.R
#'
#' @export
#' @param uuid Dataset UUID on open.canada.ca/data/en/dataset/
#' @param ext File extension or format to match, e.g. ".shp" or "csv"
#' @param silent Suppress the lookup message and the multiple-match warning
#'
#' @return Character vector of matching resource URL(s)
#'
#' @examples
#' \dontrun{
#' get_COD_url("23eb8b56-dac8-4efc-be7c-b8fa11ba62e9", ".shp")
#' }
get_COD_url <- function(uuid, ext, silent = FALSE) {

  if (!silent) message(paste0("Searching for resources with extension '", ext, "' on https://open.canada.ca/data/en/dataset/", uuid))

  api_url <- sprintf("https://open.canada.ca/data/api/action/package_show?id=%s",
                     uuid)

  resp <- httr2::request(api_url) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (!isTRUE(resp$success)) {
    stop("CKAN API call failed for dataset ", uuid)
  }

  resources <- resp$result$resources

  urls <- vapply(resources, function(r) {
    if (is.null(r$url)) NA_character_ else r$url
  }, character(1))

  fmts <- vapply(resources, function(r) {
    if (is.null(r$format) || !nzchar(r$format)) NA_character_ else r$format
  }, character(1))

  ext_clean   <- sub("^\\.", "", ext)
  ext_pattern <- paste0("\\.", ext_clean, "$")

  # match on URL file extension OR on the CKAN `format` field
  idx <- which(
    grepl(ext_pattern, urls, ignore.case = TRUE) |
      tolower(fmts) == tolower(ext_clean)
  )

  if (length(idx) == 0) {
    stop("No resource with extension/format '", ext, "' found. Available resources:\n",
         paste0(fmts, " | ", urls, collapse = "\n"))
  }
  if (length(idx) > 1 && !silent) {
    warning("Multiple resources matched '", ext, "'; returning all matches.")
  }

  urls[idx]
}