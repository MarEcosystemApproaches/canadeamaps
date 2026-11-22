# Download shapefiles from the Open Data portal
#
# Ships in the package (inst/scripts/). Run it manually:
#   source(system.file("scripts", "download_opendata.R", package = "canadeamaps"))
# It is idempotent: skip the download and unzip when the files already exist.

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

# Canada Bioregions shapefile
# - For discussion:
# - Can function-alize some kind of subarea selector. But I think what is "proper" for DFO doesn't always make sense for a user!
# - for example, if we want to select arctic, pacific, or great lakes, we know these are not technically dfo "regions". But a user would find the sytax "region = "great lakes" " more friendly than something like "subarea"
# - could rename this function to canada_bioregions or dfo_bioregions to make it more distinct
# - could have a lookup table of region-specific projections and have it auto-project if a region is specified and cropped to

# From: https://open.canada.ca/data/en/dataset/23eb8b56-dac8-4efc-be7c-b8fa11ba62e9
get_bioregions <- function(region = NULL) {
  uuid_bioregions = "23eb8b56-dac8-4efc-be7c-b8fa11ba62e9"
  lf = download_opendata(uuid_file = uuid_bioregions, foldername = "bioregions")

  # File to open:
  idxread = grepl(pattern = ".shp$", x = lf)
  bioregions = terra::vect(lf[idxread])

  # If a region is specified, extract and crop for that region
  if (!is.null(region) && (tolower(trimws(region)) %in% c("pacifique","pacific","atlantique","atlantic","arctique","arctic"))) {
    print(paste("Area found: region specified:", region))
    # To add something here
  }

  return(bioregions)
}

# Ocean's act marine protected areas:
# From: https://open.canada.ca/data/en/dataset/a1e18963-25dd-4219-a33f-1a38c4971250
# This function has the option "outer = TRUE", as the original download has the Zones delineated within each MPA
# Many users will probably not need that for mapping purposes, so this option aggregates each MPA into its own polygon
# If they want the zones they can set "outer = FALSE"
# Maybe there is a better word than "outer" for this
get_mpas <- function(region = NULL, outer = TRUE) {
  uuid_mpas = "a1e18963-25dd-4219-a33f-1a38c4971250"
  lf = download_opendata(uuid_file = uuid_mpas, foldername = "mpas")

  # File to open:
  idxread = grepl(pattern = ".shp$", x = lf)
  mpas = terra::vect(lf[idxread])

  # If a region is specified, extract and crop for that region
  if (!is.null(region) && (tolower(trimws(region)) %in% c("pacifique","pacific","atlantique","atlantic","arctique","arctic"))) {
    print(paste("Area found: region specified:", region))
    # To add something here
  }

  if (!isFALSE(outer)) {
    print("outer set to TRUE, aggregating zones into individual MPA polygons")
    mpas = aggregate(mpas, by = "NAME_E", dissolve = T)
    # Rename auto-generated count column:
    names(mpas)[names(mpas) == "agg_n"] <- "NUM_ZONES_COMBINED"
    mpas$mean_KM2 <- NULL # Removing as this is wrong now - could sum for each
    # This auto-ge
  } else if (isFALSE(outer)) {
    print("Retrieving all MPA boundaries in original file, including MPA Zones. For outer boundary, make sure outer = TRUE")
  }
  return(mpas)
}

