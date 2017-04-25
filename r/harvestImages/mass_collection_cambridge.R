# collect mugshots for all of Cambridge


setwd("~/research/streetview.address/")
source("R code/functions_mugshots.R")

api.key <- "AIzaSyDgKKGNom-pZqDlZo_i4ZTE4_bWfig7d4c"
photo.dir <- "photos/cambridge/"
pano.dir <- "streetview/panoramas/"

# load shapefile
s <- shapefile("shp/buildings_with_centroids.shp")

# get an intital set of 360 endpoints in a 50m radius
ep <- createEndpoints(50, 360)


homeTOID <- "0001000010142211"

# get a list of all pictures that have already been taken
done <- list.files( photo.dir )
# remove the pano information
done <- gsub("_.+$","",done, perl=TRUE)


# Create a sample for mid-sized homes
s$area <- NA
for(i in 1:nrow(s)){
  s$area[i] <- area( s[i,] )
}
samp <- subset(s, area > 40 & area < 200)

# randomly draw 2000 buildings
sampl <- samp[sample(1:nrow(samp), 2000, replace=FALSE),]
for(i in 1:nrow(sampl)){
  if(! sampl$TOID[i] %in% done){ 
    getMugShot(sampl$TOID[i], s, plot=FALSE, fov.ratio=1.3, endpoints=ep)
  }
  print(i)
}
