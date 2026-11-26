# Testing area and future example script
#
# Ships in the package (inst/scripts/). Run it manually:
#   source(system.file("scripts", "canadeamaps_examples.R", package = "canadeamaps"))
# It is idempotent: skip the download and unzip when the files already exist.

n1 = get_nafo(type = "points")
n2 = get_nafo(type = "lines")
n25 = get_nafo(type = "lines_noedges")
n3 = get_nafo(type = "polygons")
n35 = get_nafo(type = "polygons_landclip")

n = c(n1, n2, n25, n3, n35)
names(n) = c("points","lines","lines_noedges","polygons","polygons_landclip")

plot(n)
