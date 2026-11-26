#' Download Northwest Atlantic Fisheries Organization (NAFO) Subareas, Divisions, and Subdivisions
#'
#' @description
#' Retrieve the Northwest Atlantic Fisheries Organization (NAFO) shapefile from OpenData and load into your R session.
#'
#' The shapefile includes 5 layer types: one point layer, two line layers, and two polygon layers. This function loads the polygon layer of the entire regions as the default.
#'
#' This function re-projects the downloaded files so that they can be easily stacked with the others in this package.
#'
#' @source [https://open.canada.ca/data/en/dataset/59af1c96-fc8f-4fa0-b398-d65e953eadaa](https://open.canada.ca/data/en/dataset/59af1c96-fc8f-4fa0-b398-d65e953eadaa)
#' @export
#' @param type A character indicating file type to load:
#'   * `"polygons"` (the default): NAFO areas as individual polygons.
#'   * `"lines"`: NAFO areas as lines, including edges (looks identical to the `"polygons"`, but is separate line segments)
#'   * `"points"`: points of the vertices of the NAFO areas.
#'   * `"lines_noedges"`: Lines of internal boundaries, but no external edges
#'   * `"polygons_landclip"`: NAFO polygons over ocean, with area overlapping land clipped out.
#' @return Spatvector of NAFO points, lines or polygons
#' @examples
#' nafo_points = get_nafo(type = "points")
#' nafo_lines = get_nafo(type = "lines")
#' nafo_polygons = get_nafo(type = "polygons")
#' # Polygons with land masses removed:
#' nafo_noland = get_nafo(type = "polygons_landclip")
#' # Line layer with just the internal boundaries:
#' nafo_lines_noedges = get_nafo(type = "lines_noedges")
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


