# load libraries
library(data.table) # fast data structure
library(googleway) # detailed geocoding
library(stringr)
library(osmar)
library(rgeos)
library(rgdal)
library(geosphere)
library(raster)
library(rjson)


p4string.UK <- "+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs +ellps=airy +towgs84=446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894"
p4string.WGS84 <- "+init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"



#============ Some Helpers
# Create a set of 360 points, evenly distributed around the origin
# We can shift them later to the position of any panorama
createEndpoints <- function( radius=50, numpoints=360){
  endpoints <- list()
  # first point, just go north
  endpoints[[1]] <- c(0, radius)
  for(a in 1:(numpoints-1)){
    ang <- (2* pi) * (a / numpoints)
    endpoints[[ a+1 ]] <- c( endpoints[[1]][1] *cos(ang) - endpoints[[1]][2] *sin(ang),  endpoints[[1]][2] *cos(ang) + endpoints[[1]][1] *sin(ang), ang )
  }
  ep <- as.data.frame( do.call( rbind, endpoints ))
  colnames(ep) <- c("lon","lat", "rad")
  return(ep)
}
# -------------------------------------


# --------------------------
# find the first polygon that intersects with a direct line from pano
firstHit <- function(line, pano, poly){
  hits <- list()
  for(p in 1:nrow(poly)){
    if(gIntersects(line, poly[p,])){
      chopped <- gIntersection(line, poly[p,])
   #   plot(chopped, add=TRUE, col="green", lwd=3)
      poly.id <- as.character( as.data.frame(poly[p,])$TOID )
      hits[[ poly.id ]] <- c( poly.id, gDistance(pano, chopped))
    }
  }
  if(length(hits) > 0){
    h <- as.data.frame( do.call(rbind, hits), stringsAsFactors=FALSE)
    colnames(h)<- c("id","dist")
    h$dist <- as.numeric(h$dist)
    rownames(h) <- NULL
    h <- h[order(h$dist), ]
    return(h[1, ])
  } else {
    return(c(NA, NA))
  }
}

getPanorama <- function( x, api.key, savePano=TRUE ){
  # find panorama that is closest to this centroid
  api.url <- paste("https://maps.googleapis.com/maps/api/streetview/metadata?size=600x300&location=", paste(rev(coordinates( x )), collapse=",") ,"&key=",api.key, sep="")
  panorama <- fromJSON(f=api.url)
  if(panorama$status  == 'OK'){
    pano.wgs84 <- readWKT(paste("POINT(",panorama$location$lng, panorama$location$lat,")"), p4s=p4string.WGS84)
    if( savePano ){
      exportJson <- toJSON( panorama )
      write(exportJson, paste(pano.dir,panorama$pano_id,".json", sep=""))
    }
  return( list( pano.wgs84, panorama ))
  } else {
    return(list(NA,NA))
  }
}
# ================ End Helpers






# This is where stuff really happens 
getMugShot <- function(toid, s, plot=FALSE, fov.ratio=1, subset.radius=70, endpoints, fov=NA, fDest=NA, savePano=TRUE){

  h <- subset(s, TOID == toid)
  
  if(is.na(endpoints)){
    endpoints <- createEndpoints(50, 360)
  }
    
  # find centroid of home
  centr <- gCentroid( h )
  centr.wgs84 <- spTransform(centr, CRS("+init=epsg:4326"))
  
  # subset polygons from close surroundings
  # this is just to speed up things...
  s_sub <- subset(s, abs(centrX-s$centrX[ s$TOID== toid]) < subset.radius & abs(centrY-s$centrY[ s$TOID== toid ]) < subset.radius ) 
  
  if(plot){
    plot(s_sub)
    plot(h, col="red", add=TRUE)
    points(centr, col="blue")
  }

  # find panorama that is closest to this centroid
  pan <- getPanorama( centr.wgs84, api.key, savePano )
  if( is.na(pan[[1]]) ){ return(" NO PANORAMA FOUND ")}
  pano.wgs84 <- pan[[1]]
  panorama <- pan[[2]]
  pano <- spTransform(pano.wgs84, CRS("+init=epsg:27700"))
  
  
  # Find out, which directection the camera should aim
  # How much of the building is visible from the pano position?
  # look in each of the 360 degree directions, and see if one can see the house unobstructed
  linesofsight <- endpoints
  linesofsight$lon <- linesofsight$lon+coordinates(pano)[1]
  linesofsight$lat <- linesofsight$lat+coordinates(pano)[2]
  losCoords <- paste(linesofsight$lon, linesofsight$lat)
  los <- lapply(losCoords, function(x,y,z){ readWKT(paste("LINESTRING(", paste( y, collapse=" ")," , ", x,")"), p4s=z) }, coordinates(pano), p4string.UK)
  fh <- lapply( los, firstHit, pano, s_sub)
  fhdf <- as.data.frame( do.call(rbind, fh), stringsAsFactors=FALSE)
  fhdf$lon <- linesofsight$lon
  fhdf$lat <- linesofsight$lat
  
    
  # focus on lines of sight to the building
  goodangles <- subset(fhdf, id == toid)
  if(nrow(goodangles) > 0){
    # (crudely) assuming that all lines of sight are in one streak,
    # and each line represents one degree
    # then the overall fan should have approx. a max angle of nrow(goodangles) degrees
    # fov.ratio allows some scaling of the fan
    if(is.na(fov)){
      fov <- nrow(goodangles) * fov.ratio 
    } 
    # and the best bearing is the one in the middle (fingers crossed)
    goodangles.index <- median(1:nrow(goodangles))
    midLos <- readWKT( paste("POINT(",paste(goodangles[ goodangles.index , c("lon","lat")], collapse=" "),")", sep=""), p4s = p4string.UK)
    if(plot){
      midLosLine <- readWKT(paste("LINESTRING(", paste( coordinates(pano), collapse=" ")," , ", paste( coordinates(midLos), collapse=" ") ,")"), p4s=p4string.UK)
      plot(midLosLine, col="green", lwd=3, add=TRUE)
    }
    midLos.wgs84 <- spTransform(midLos, CRS("+init=epsg:4326"))
    midLos.string <- paste(rev(coordinates(midLos.wgs84)), collapse=",")
    heading <- bearing(pano.wgs84, midLos.wgs84)
    shotLoc <- paste0('https://maps.googleapis.com/maps/api/streetview?size=640x640&pano=',panorama$pano_id,
                      '&heading=', heading, 
                      '&fov=',fov,
                      '&pitch=-0.76&key=', api.key)

    if(is.na(fDest)){
      fDest <- paste(photo.dir, toid, "_", panorama$pano_id,".jpg", sep="")
    }
    # download the picture from Streetview API
    streetShot <- download.file(shotLoc, fDest)
    return(fDest)
  } else {
    return("no direct line of sight")
  }
}

