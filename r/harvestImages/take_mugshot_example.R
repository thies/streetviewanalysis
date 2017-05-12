setwd("~/research/streetview.address")
source("~/research/streetviewanalysis/r/harvestImages/functions_mugshots.R")

# Add your own API key here!
source("~/.api.key.R")
# api.key <- ""

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
getMugShot("1000002500677754", s, fov.ratio=1.2, endpoints=ep, plot=TRUE, savePano=TRUE, api.key = api.key)
# ==================================================

