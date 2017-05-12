library(raster)

shp <- shapefile("~/Downloads/os_grids/gb-grids_1867540/10km_grid_region.shp")

source("~/.ravenLogin.R")
source("/home/thies/research/streetviewanalysis/r/downloadOSShapefiles/functionsEdinaDownload.R")

try( remDr$close() )
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L)
remDr$open()

# login with Raven
loginBoth <- function(){
  try( loginRaven(remDr, ravenLogin[[1]], ravenLogin[[2]]) )
  remDr$navigate("http://edina.ac.uk/Login/digimap")
  #remDr$screenshot(display = TRUE)
  login <- remDr$findElement(using = "css", "[class = 'as-input']")
  #login$getElementAttribute("outerHTML")[[1]]
  
  login$sendKeysToElement(list( "University of Cambridge", key = "enter"))
  remDr$screenshot(display = TRUE)
  
  l <- remDr$findElement(using="partial link text", "University of Cambridge")
  l$clickElement()
  remDr$screenshot(display = TRUE)
}  
loginBoth()


# which tiles are still missing?
done <- list.files("~/Downloads/")
done <- done[grepl('Download_', done)]
done <- gsub("Download_","",done)
done <- gsub("_.+$","",done, perl=TRUE)
tbd <- shp$TILE_NAME[ ! shp$TILE_NAME %in% done ]

print(c("still to be done", length(tbd)))

i<-1
j <- 1
for( tile in tbd[2:145] ){
  done <- list.files("~/Downloads/")
  done <- done[grepl(paste('Download_', tile,"_", sep=""), done)]
  if(length(done) == 0){
    print(c(j, i, tile))
    try( orderTileDate( tile ))
    Sys.sleep( 15 )
  } else {
    print(paste("already done:", tile))
  }
  i <- i+1
  j <- j+1
  if(i%%15 == 0){
    remDr$close()
    remDr$open()
    loginBoth()
    i <- 1
  }
  if (j == 300){
    break
  }
}
