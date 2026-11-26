#' Download spatial datasets from the federal Open Data portal
#'
#' Retrieve the spatial dataset on Canada Open Data (open.canada.ca) given the uuid of the dataset, and save the file locally in the `foldername` folder located within data_raw. Meant to be used within other functions, e.g. within `get_bioregions()`
#'
#' @export
#' @param uuid_file Dataset UUID on open.canada.ca/data/en/dataset/
#' @param foldername Folder name to save the downloaded file to within the "data_raw" folder
#'
#' @return Character vector of the downloaded files within the `foldername` folder
#'
#' @examples
#' \dontrun{
#' uuid_bioregions = "23eb8b56-dac8-4efc-be7c-b8fa11ba62e9"
#' lf = download_opendata(uuid_file = uuid_bioregions, foldername = "bioregions")
#' }
download_opendata <- function(uuid_file, foldername) {

  # Location to save the Open Data files:
  save_dir = "./data_raw/"
  zip_file = file.path(save_dir, "temp_dl.zip") # Renamed the zip file to something temporary as I imagine we'll want to delete them
  unzip_dir = file.path(save_dir, foldername)

  if (!dir.exists(unzip_dir)) { # Changed file exist check to be less dataset specific - will check that folder is found
    url_get = get_COD_url(uuid_file, ext = ".shp")
    dir.create(save_dir, recursive = T)
    download.file(url_get, destfile = zip_file, mode = "wb")
    unzip(zip_file, exdir = unzip_dir) # unzip_dir created in this function
    # To do: figure out what to do with zip file / how to delete safely
  } else {
    message("Folder already exists / Le dossier existe déjà: ", foldername, " (skipping download / sauter le téléchargement)") # I apologize if this translation is very wrong
  }

  # Could finish by returning list of files in the folder that was downloaded:
  lfshp = list.files(unzip_dir, recursive = T, full.names = T)
  return(lfshp)
  # Unzip if not already done
  # if (file.exists(zip_file) && !file.exists(file.path(unzip_dir, "FederalMarineBioregions_SHP"))) {
  # }

}
