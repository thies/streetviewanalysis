library(raster)

shp <- shapefile("~/Downloads/os_grids/gb-grids_1867540/10km_grid_region.shp")

done <- list.files("~/Downloads/")
done <- done[grepl('Download_', done)]
done <- gsub("Download_","",done)
done <- gsub("_.+$","",done, perl=TRUE)

plot(shp, col="red")
for(d in done){
  plot(shp[shp$TILE_NAME == d,], add=TRUE, col="green")
}


