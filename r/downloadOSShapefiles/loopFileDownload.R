source("~/.ravenLogin.R")
source("/home/thies/research/streetviewanalysis/r/downloadOSShapefiles/functionsEdinaDownload.R")

library('RSelenium')
ePrefs <- makeFirefoxProfile(
  list(
    browser.download.dir = "/home/seluser/Downloads",
    "browser.download.folderList" = 2L,
    "browser.download.manager.showWhenStarting" = FALSE,
    "browser.helperApps.neverAsk.saveToDisk" = "multipart/x-zip,application/zip,application/x-zip-compressed,application/x-compressed,application/msword,application/csv,text/csv,image/png ,image/jpeg, application/pdf, text/html,text/plain,  application/excel, application/vnd.ms-excel, application/x-excel, application/x-msexcel, application/octet-stream"))

remDr <- remoteDriver(remoteServerAddr = "localhost", extraCapabilities = ePrefs, port = 4445L)
remDr$open()
# login at Raven, both needed for email and edina
loginRaven( remDr, ravenLogin[[1]],ravenLogin[[2]])
  
remDr$navigate("https://webmail-1.hermes.cam.ac.uk/?_task=mail&_mbox=done")
remDr$screenshot(display = TRUE)
l <- remDr$findElement(using="partial link text", "Click here for login page")
l$clickElement()
remDr$screenshot(display = TRUE)
l <- remDr$findElement(using="partial link text", "Click here to login using Raven")
l$clickElement()
remDr$screenshot(display = TRUE)
remDr$navigate("https://webmail-1.hermes.cam.ac.uk/?_task=mail&_mbox=done")
remDr$screenshot(display = TRUE)

l <- remDr$findElements(using="partial link text", "Your Digimap Data Order")
# get URLs
mailUrls <- sapply( l, function(x){ return( x$getElementAttribute('href')) } )

# login at edina
remDr$navigate("http://edina.ac.uk/Login/digimap")
remDr$screenshot(display = TRUE)
login <- remDr$findElement(using = "css", "[class = 'as-input']")
#login$getElementAttribute("outerHTML")[[1]]

login$sendKeysToElement(list( "University of Cambridge", key = "enter"))
remDr$screenshot(display = TRUE)

l <- remDr$findElement(using="partial link text", "University of Cambridge")
l$clickElement()
remDr$screenshot(display = TRUE)


for (u in mailUrls){
  print(u)
  remDr$navigate(unlist(u))
  remDr$screenshot(display = TRUE)
  # check if data has already been downloaded
  text <- remDr$findElement(using = "css", "[class = 'mcnTextContent']")
  orderId <- unlist( strsplit( unlist( text$getElementText()), '\\s', perl=TRUE) )[7]
  done <- list.files("~/Downloads/")
  done <- done[grepl(paste('Download_', orderId,"_", sep=""), done)]
  # only try again if it had not been downloaded before
  if(length(done) == 0){
    dl <- remDr$findElement(using="partial link text", "Download your data")
    remDr$navigate( unlist( dl$getElementAttribute('href') ))
    remDr$screenshot(display = TRUE)
    dlink <- remDr$findElements(using="tag name", "button")
    dlink[[1]]$clickElement()
    remDr$screenshot(display = TRUE)
    print(paste(c("Downloading:",orderId)))
    Sys.sleep(30) 
  }  else {
    print(paste(c("already done",orderId)))
  }
}