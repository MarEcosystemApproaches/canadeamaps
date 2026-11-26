# Testing area and future example script
#
# Ships in the package (inst/scripts/). Run it manually:
#   source(system.file("scripts", "canadeamaps_examples.R", package = "canadeamaps"))
# It is idempotent: skip the download and unzip when the files already exist.

nafo_points = get_nafo(type = "points")
nafo_lines = get_nafo(type = "lines")
nafo_lines_noedges = get_nafo(type = "lines_noedges")
nafo_polys = get_nafo(type = "polygons")
nafo_polys_landclip = get_nafo(type = "polygons_landclip")

nafo = c(nafo_points, nafo_lines, nafo_lines_noedges, nafo_polys, nafo_polys_landclip)
names(nafo) = c("points","lines","lines_noedges","polygons","polygons_landclip")

plot(nafo)
