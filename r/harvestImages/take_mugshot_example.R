setwd("~/research/streetview.address/")
source("R code/functions_mugshots.R")

api.key <- "AIzaSyDgKKGNom-pZqDlZo_i4ZTE4_bWfig7d4c"
photo.dir <- "photos/cambridge/"
pano.dir <- "streetview/panoramas/"

# load shapefile
s <- shapefile("shp/buildings_with_centroids.shp")

# get an intital set of 360 endpoints in a 50m radius
ep <- createEndpoints(50, 360)

#================================================
# run it!
# parameters
# - ID of polygon
# - Polygons (from shape file)
# - fov.ratio: how much wider than the exact fan should the picture be taken?
# - endpoints: preset it to save a little time when taking many shots
# - savePano: TRUE
getMugShot("1000002500086405", s, fov.ratio=1.2, endpoints=ep, savePano=TRUE)
# ==================================================

