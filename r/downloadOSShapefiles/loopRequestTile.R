library(raster)

shp <- shapefile("~/Downloads/os_grids/gb-grids_1867540/10km_grid_region.shp")

source("~/.ravenLogin.R")
source("/home/thies/research/streetviewanalysis/r/downloadOSShapefiles/functionsEdinaDownload.R")


for( tile in unique(shp$TILE_NAME)[1:200]){
  done <- list.files("~/Downloads/")
  done <- done[grepl(paste('Download_', tile,"_", sep=""), done)]
  if(length(done) == 0){
    print(tile)
    try( orderTileDate( tile ,ravenLogin[[1]], ravenLogin[[2]]) )
    Sys.sleep(30)
  } else {
    print(paste("already done:", tile))
  }
}