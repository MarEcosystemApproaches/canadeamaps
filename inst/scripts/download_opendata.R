# Download Canada Bioregions shapefile from the Open Data portal
#
# Ships in the package (inst/scripts/). Run it manually:
#   source(system.file("scripts", "download_opendata.R", package = "canadeamaps"))
# It is idempotent: skip the download and unzip when the files already exist.

# Canada Bioregions shapefile
url_bioregions = "23eb8b56-dac8-4efc-be7c-b8fa11ba62e9"

# Location to save
save_dir = "./data_raw/"
zip_file = file.path(save_dir, "canada_bioregions.zip")
unzip_dir = file.path(save_dir, "canada_bioregions")

if (!file.exists(zip_file)) {
  url_get = get_COD_url(url_bioregions, ext = ".shp")
  dir.create(save_dir, showWarnings = FALSE, recursive = T)
  download.file(url_get, destfile = zip_file, mode = "wb")
} else {
  message("Zip already exists: ", zip_file, " (skipping download)")
}

# Unzip if not already done
if (file.exists(zip_file) && !file.exists(file.path(unzip_dir, "FederalMarineBioregions_SHP"))) {
  dir.create(unzip_dir, showWarnings = FALSE)
  unzip(zip_file, exdir = unzip_dir)
}

# List the file names you just downloaded
bioregions_files = list.files(unzip_dir, full.names = TRUE, recursive = TRUE)

# Open the shapefile using terra
idxread = grepl(pattern = ".shp$", x = bioregions_files)
bioregions = terra::vect(bioregions_files[idxread])
