# canadeamaps
**This is an experimental R package currently in development!**

The goals are:

* Make it easy to download commonly used spatial layers relevant to DFO. For example, the EEZ, national Bioregions, and other files that are currently provided Canada-wide on Federal data platforms
* Also serve as another way to download these files to your computer in their original format (e.g. .shp, .csv, etc).
* Reduce the number of dependendies, and use the `terra` package for any data wrangling.
    * If you prefer to use `sf`, you can transform loaded vector data using the `st_as_sf()` function

Wishlist layers:
- [ ] oceans act MPAs
- [ ] EEZs
- [ ] Bioregions
- [ ] NAFO zones
- [ ] Coastlines - future ability to add region-specific high resolution ones?
