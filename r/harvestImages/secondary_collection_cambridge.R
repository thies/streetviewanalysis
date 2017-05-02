user.name <- Sys.info()[which(names(Sys.info())=='user')]

# collect mugshots for all of Cambridge

if (user.name == 'ejohnso4') { # Laptop
  setwd("~/GitHub/streetviewanalysis/")   
  source("~/GitHub/streetviewanalysis/r/harvestImages/functions_mugshots.R")
  source("~/Dropbox/api.key.R")
  photo.dir <- "~/Dropbox/cambridge/"
  photo.archive.dir <- '~/Dropbox/cambridge.archive/'
  pano.dir <- "~/Dropbox/panoramas/"
  shp.file <- "~/Dropbox/shp/buildings_with_centroids_area.shp"
  osm.dir <- "/Users/ejohnso4/Dropbox/shp/osm.cambridge/cambridgeshire-latest-free.shp/"
  tmp.dir <- '~/Dropbox/tmp/'
}
if (user.name == 'erik'){ # Server
  setwd("~/Dropbox/git/streetviewanalysis/")   
  source("~/Dropbox/git/streetviewanalysis/r/harvestImages/functions_mugshots.R")
  source("~/Dropbox/api.key.R")
  photo.dir <- "~/Dropbox/cambridge/"
  photo.archive.dir <- "~/Dropbox/cambridge.archive/"
  pano.dir <- "~/Dropbox/panoramas/"
  shp.file <- "~/Dropbox/shp/buildings_with_centroids_area.shp"
  tmp.dir <- '~/Dropbox/tmp/'
  osm.dir <- "/Users/ejohnso4/Dropbox/shp/osm.cambridge/cambridgeshire-latest-free.shp/"
}
if (!user.name %in% c('ejohnso4', 'erik')){ # Thies
  setwd("~/research/streetview.address/")
  source("~/research/streetviewanalysis/r/harvestImages/functions_mugshots.R")
  # Add your own API key here!
  source("~/.api.key.R")
  # api.key <- ""
  photo.dir <- "photos/cambridge/"
  photo.archive.dir <- 'photos/cambridge.archive/'
  pano.dir <- "streetview/panoramas/"
  shp.file <- "shp/buildings_with_centroids_area.shp"
  osm.dir <- "shp/osm.cambridge/cambridgeshire-latest-free.shp/"
  tmp.dir <- 'tmp/'
}
osm.location <- paste0(osm.dir, 'osm.cambridge.rdata')
if (!(dir.exists(photo.archive.dir))) dir.create(photo.archive.dir)

# load shapefile
s <- shapefile(shp.file)

# get an intital set of 360 endpoints in a 50m radius
ep <- createEndpoints(50, 360)

# Check for 'bad' set
# loop through photos with bad panorama
photos.check <- funPhotos.check(photo.dir, tmp.dir)
l.panoIds <- getPanoIds(s, api.key = api.key)

for(photo.check in photos.check){
  for(i in 1:nrow(photo.check)){
    panoid <- NA
    toid <- photo.check[i]$TOID
    error.type <- photo.check[i]$error.type
    panoid <- photo.check[i]$panoid
    cat("Trying: ", toid, error.type, 'error', '\n')
    try <- 0
    # Search for already cleaned photo
    photos.base <- list.files(photo.dir)
    photos.remove.bad <- photos.base[!(photos.base %in% photo.check[i]$fDest)]
    photos.replaced <- which(str_detect(photos.remove.bad, regex(paste0('(?<=^)', toid, '\\_'), perl=TRUE)))
    if (length(photos.remove.bad[photos.replaced])>0){
      good.pic <- TRUE
    } else {
      good.pic <- FALSE
    }
    while (try < 4 & good.pic == FALSE){
      cat('try:', try)
      if (!is.na(panoid) | try > 0){
        # If there is a starting panoId remove (since it was bad)
        shp.panoIds <- l.panoIds$shp.panoIds[!(l.panoIds$shp.panoIds@data$pano_id %in% panoid),]
      } else {
        shp.panoIds <- l.panoIds$shp.panoIds
      }
      mugShot <- try(getMugShot(toid=toid, s, plot=FALSE, fov.ratio=1.3, endpoints=ep, api.key=api.key, shp.panoIds=shp.panoIds))
      cat(mugShot, '\n')
      good.pic <- !str_detect(mugShot, regex(paste0('(', paste0(names(photos.check), collapse='|'), ')'), perl=TRUE))
      # Delete the original (poor picture)
      if (good.pic){
        cat('Copy ', photo.check[i]$fDest, 'to', photo.archive.dir, 'and replacing with', mugShot, '\n')
        f.copy <- file.copy(paste0(photo.dir, photo.check[i]$fDest), paste0(photo.archive.dir, photo.check[i]$fDest))
        f.remove <- file.remove(paste0(photo.dir, photo.check[i]$fDest))
      }
      try <- try+1
    }
  }
  # and do this again...
}
