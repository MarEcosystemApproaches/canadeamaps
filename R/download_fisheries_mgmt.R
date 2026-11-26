#' Download Northwest Atlantic Fisheries Organization (NAFO) Subareas, Divisions, and Subdivisions
#'
#' @description
#' Retrieve the Northwest Atlantic Fisheries Organization (NAFO) shapefile from OpenData and load into your R session.
#'
#'
#' @source [https://open.canada.ca/data/en/dataset/59af1c96-fc8f-4fa0-b398-d65e953eadaa](https://open.canada.ca/data/en/dataset/59af1c96-fc8f-4fa0-b398-d65e953eadaa)
#' @export
#' @return Spatvector of Bioregions
#' @examples
#' bioregions = get_bioregions()
#'
get_nafo <- function(type = "polygons") {
  uuid_bioregions = "59af1c96-fc8f-4fa0-b398-d65e953eadaa"
  lf = download_opendata(uuid_file = uuid_bioregions, foldername = "nafo_subareas")

  shp_files = lf[grepl(pattern = ".shp$", x = lf)]

  # Since there are a number of options for loading the data:
  type_opts <- list("lines" = "NAFO_Divisions_2021_line_enclosed",
                    "lines_noedges" = "NAFO_Divisions_2021_line_not_enclosed",
                    "polygons_landclip" = "NAFO_Divisions_2021_poly_clipped",
                    "polygons" = "NAFO_Divisions_2021_poly_not_clipped",
                    "points" = "NAFO_Divisions_2021_pts")
  stopifnot(type %in% names(type_opts))

  # File to open:
  file_open = type_opts[[type]]
  idxread = which(grepl(pattern = file_open, x = shp_files))
  nafo_regs = terra::vect(shp_files[idxread])

  crs_check = terra::same.crs(nafo_regs, "epsg:102001")
  if (crs_check == FALSE) {
    message("Please note: projection differs from Canada Lambert Conformal Conic. Reprojecting in R session.")
    nafo_regs = terra::project(nafo_regs, "epsg:102001")
  }

  return(nafo_regs)
}


