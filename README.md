# canadeamaps
**This is an experimental R package currently in development!**

The goals are:

* Make it easy to download commonly used spatial layers relevant to DFO. For example, the EEZ, national Bioregions, and other files that are currently provided Canada-wide on Federal data platforms
* Also serve as another way to download these files to your computer in their original format (e.g. .shp, .csv, etc).
* Reduce the number of dependendies, and use the `terra` package for any data wrangling.
    * If you prefer to use `sf`, you can transform loaded vector data using the `st_as_sf()` function

This project is part of the Ecosystem Approach to Fisheries Management workshop, to support the [`marea`](https://marecosystemapproaches.github.io/marea/), [`gslea`](https://github.com/duplisea/gslea/), [`pacea`](https://github.com/pbs-assess/pacea/tree/main), `arcea`, and `nlea` R packages.

Wishlist layers:
- [x] oceans act MPAs
- [ ] EEZs
- [x] Bioregions
- [ ] NAFO zones
- [ ] Coastlines - future ability to add region-specific high resolution ones?

## Examples

- `get_bioregions()` will retrieve the [Federal Marine Bioregions](https://open.canada.ca/data/en/dataset/23eb8b56-dac8-4efc-be7c-b8fa11ba62e9)
- `get_ebsas()` retrieves [Ecologically and Biologically Significant Areas](https://open.canada.ca/data/en/dataset/d2d6057f-d7c4-45d9-9fd9-0a58370577e0). Since this file is large, it might be slow to display. You can subset to one or more specific oceans with the `ocean = ` variable. For example:
    - `get_ebsas(ocean = "Pacific")` will pull only Pacific Ocean EBSAs into your R environment.
    - `get_ebsas(ocean = c("Arctic","Atlantic"))` will subset all EBSAs in both the Atlantic and Arctic oceans. 
- `get_mpas()` retrieves [Ocean's Act Marine Protected Areas](https://open.canada.ca/data/en/dataset/a1e18963-25dd-4219-a33f-1a38c4971250)
