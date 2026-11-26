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

#' Download Ecologically and Biologically Significant Areas (EBSAs)
#'
#' @description
#' Retrieve the Ecologically and Biologically Significant Areas (EBSAs) shapefile from OpenData and load, with the option to load only specific oceans into your R session
#'
#' @source [https://open.canada.ca/data/en/dataset/d2d6057f-d7c4-45d9-9fd9-0a58370577e0](https://open.canada.ca/data/en/dataset/d2d6057f-d7c4-45d9-9fd9-0a58370577e0)
#' @export
#' @param ocean Character string or vector indicating "pacific", "atlantic","arctic" and/or "pacifique", "atlantique", or "arctique".
#' @return Spatvector of EBSAs.
#' @examples
#' ebsas = get_ebsas()
#' ebsas_arctic = get_ebsas(ocean = "Arctic")
#' ebsas_pac_atl = get_ebsas(ocean = c("pacific","atlantic"))
#'
get_ebsas <- function(ocean = NULL) {
  uuid_ebsas = "d2d6057f-d7c4-45d9-9fd9-0a58370577e0"
  lf = download_opendata(uuid_file = uuid_ebsas, foldername = "ebsas")

  # File to open:
  idxread = grepl(pattern = ".shp$", x = lf)
  ebsas = terra::vect(lf[idxread])

  if (!is.null(ocean) && all(tolower(trimws(ocean)) %in% c("pacifique","pacific","atlantique","atlantic","arctique","arctic"))) {
    print(paste("Area found: region specified:", ocean))
    # Check both the EN and FR columns:
    idx_en = which(grepl(tolower(paste(ocean, collapse = "|")), tolower(ebsas$Ocean_EN)) == TRUE)
    idx_fr = which(grepl(tolower(paste(ocean, collapse = "|")), tolower(ebsas$Ocean_FR)) == TRUE)
    # Grab the index appropriate for the language:
    idx = get(names(which(lengths(list(idx_en = idx_en, idx_fr = idx_fr)) > 0)))
    ebsas = ebsas[idx]
    # To add something here
  } else {
    print("NOTE: this is a large file and may take a while to plot without cropping first")
    print("Use the 'ocean = ' field to subset to Pacific, Atlantic, Arctic / Pacifique, Atlantique, Arctique. (There are no EBSAs in the Great Lakes)")

  }

  return(ebsas)
}

#' Download Ocean's Act Marine Protected Areas (MPAs)
#'
#' @description
#' Retrieve the Ocean's Act Marine Protected Areas (MPAs) shapefile from OpenData and load into your R session.
#'
#' These files have internal Zones delineated within each MPA, so the option `outer` has been added so that the user can specify if they just want the outer bounds of each MPA (`outer = TRUE`, default), or if they also want to load the MPA internal zones (`outer = FALSE`)
#'
#' @source [https://open.canada.ca/data/en/dataset/a1e18963-25dd-4219-a33f-1a38c4971250](https://open.canada.ca/data/en/dataset/a1e18963-25dd-4219-a33f-1a38c4971250)
#' @export
#' @param outer Logical TRUE or FALSE indicating TRUE if you want the MPA boundaries, or FALSE if you want the boundaries including inner zones as well
#' @return Spatvector of MPAs.
#' @examples
#' mpas_zones = get_mpas(outer = FALSE)
#' mpas_boundaries = get_mpas()
#'
get_mpas <- function(outer = TRUE) {
  uuid_mpas = "a1e18963-25dd-4219-a33f-1a38c4971250"
  lf = download_opendata(uuid_file = uuid_mpas, foldername = "mpas")

  # File to open:
  idxread = grepl(pattern = ".shp$", x = lf)
  mpas = terra::vect(lf[idxread])

  if (!isFALSE(outer)) {
    print("outer set to TRUE, aggregating zones into individual MPA polygons")
    mpas = terra::aggregate(mpas, by = "NAME_E", dissolve = T)
    # Rename auto-generated count column:
    names(mpas)[names(mpas) == "agg_n"] <- "NUM_ZONES_COMBINED"
    mpas$mean_KM2 <- NULL # Removing as this is wrong now - could sum for each
    # This auto-ge
  } else if (isFALSE(outer)) {
    print("Retrieving all MPA boundaries in original file, including MPA Zones. For outer boundary, make sure outer = TRUE")
  }
  return(mpas)
}


#' Download Federal Marine Bioregions
#'
#' @description
#' Retrieve the Federal Marine Bioregions shapefile from OpenData and load into your R session.
#'
#' This file includes Bioregions in the Great Lakes.
#'
#' @source [https://open.canada.ca/data/en/dataset/23eb8b56-dac8-4efc-be7c-b8fa11ba62e9](https://open.canada.ca/data/en/dataset/23eb8b56-dac8-4efc-be7c-b8fa11ba62e9)
#' @export
#' @return Spatvector of Bioregions
#' @examples
#' bioregions = get_bioregions()
#'
get_bioregions <- function() {
  uuid_bioregions = "23eb8b56-dac8-4efc-be7c-b8fa11ba62e9"
  lf = download_opendata(uuid_file = uuid_bioregions, foldername = "bioregions")

  # File to open:
  idxread = grepl(pattern = ".shp$", x = lf)
  bioregions = terra::vect(lf[idxread])

  # TO DO: add ability to specify `ocean = ` in the same manner as the get_ebsas() function
  # If a region is specified, extract and crop for that region
  # if (!is.null(region) && (tolower(trimws(region)) %in% c("pacifique","pacific","atlantique","atlantic","arctique","arctic"))) {
  #   print(paste("Area found: region specified:", region))
  #   # To add something here
  # }

  return(bioregions)
}





