# collect mugshots for all of Cambridge


setwd("~/research/streetview.address/")
source("~/research/streetviewanalysis/r/harvestImages/functions_mugshots.R")

# Add your own API key here!
source("~/.api.key.R")
# api.key <- ""


photo.dir <- "photos/cambridge/"
pano.dir <- "streetview/panoramas/"

# load shapefile
s <- shapefile("shp/buildings_with_centroids_area.shp")

# get an intital set of 360 endpoints in a 50m radius
ep <- createEndpoints(50, 360)



# Create a sample for mid-sized homes
#s$area <- NA
#for(i in 1:nrow(s)){
#  s$area[i] <- area( s[i,] )
#}
samp <- subset(s, area > 40 & area < 200)


# loop through all buildings
while(TRUE){
  # get a list of all pictures that have already been taken
  done <- list.files( photo.dir )
  # remove the pano information
  done <- gsub("_.+$","",done, perl=TRUE)
  
  # only keep those that have not been downloaded yet
  samp <- samp[ ! samp$TOID %in% done,]
  
  # sample a few hundred
  sampl <- samp[sample(1:nrow(samp), 100, replace=FALSE),]
  for(i in 1:nrow(sampl)){
    getMugShot(sampl$TOID[i], s, plot=FALSE, fov.ratio=1.3, endpoints=ep)

    # A little update on progress...
    totaldone <- length(done)+i
    print(c(i, totaldone, paste(round(totaldone/nrow(s), 3)*100, '%', sep="") ))
  }
  # and do this again...
}