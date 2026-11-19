# To download our shapefiles from the Open Data site
library(terra)
# NOT OUR FUNCTION, this was taken from here: https://github.com/dfo-mar-mpas/MarConsNetData/blob/main/R/get_COD_url.R
# Use for csv:  url <- get_COD_url("2d9cce9a-d634-4b49-879f-87c40c52acf2", "csv")
#   datadict <- read.csv(url)
get_COD_url <- function(uuid, ext, silent = FALSE) {

  if (!silent) message(paste0("Searching for resources with extension '", ext, "' in on https://open.canada.ca/data/en/dataset/", uuid))

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

# Downloading a file ####

# Canada Bioregions shapefile
url_bioregions = "23eb8b56-dac8-4efc-be7c-b8fa11ba62e9"
url_get = get_COD_url(url_bioregions, ext = ".shp")

# Location to save - needs update to auto-detect path on user's system
save_dir = "./data_raw/"
zip_file = file.path(save_dir, "canada_bioregions.zip")
unzip_dir = file.path(save_dir, "canada_bioregions")

# Download and unzip
download.file(url_get, destfile = zip_file, mode = "wb")
dir.create(unzip_dir, showWarnings = FALSE)
unzip(zip_file, exdir = unzip_dir)

# List the file names you just downloaded
bioregions_files = list.files(unzip_dir, full.names = TRUE, recursive = T)

# Open the shapefile using terra

idxread = grepl(pattern = ".shp$", x = bioregions_files)
bioregions = vect(bioregions_files[idxread])

# To do:
# remove the zip file
# detect if file already exists so it isn't re-downloaded

