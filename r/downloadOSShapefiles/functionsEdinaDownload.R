# start docker: sudo docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.0
# sudo docker run -d -p 4445:4444 -p 5901:5900 -v /home/thies/Downloads:/home/seluser/Downloads selenium/standalone-firefox:2.53.0
library('RSelenium')

loginRaven <- function( remDr, username, password ){
  # first, login in Cambridge
  remDr$navigate("https://raven.cam.ac.uk/auth/login.html")
  remDr$screenshot(display = TRUE)
  
  uid <- remDr$findElement(using = "css", "[name = 'userid']")
  uid$sendKeysToElement(list( username ))
  pwd <- remDr$findElement(using = "css", "[name = 'pwd']")
  pwd$sendKeysToElement(list( password, key = "enter"))
  remDr$screenshot(display = TRUE)
}


orderTileDate <- function(tileId, username, password){
  remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4445L)
  remDr$open()

  # login with Raven
  loginRaven(remDr, username, password)
  
  remDr$navigate("http://edina.ac.uk/Login/digimap")
  remDr$screenshot(display = TRUE)
  login <- remDr$findElement(using = "css", "[class = 'as-input']")
  #login$getElementAttribute("outerHTML")[[1]]
  
  login$sendKeysToElement(list( "University of Cambridge", key = "enter"))
  remDr$screenshot(display = TRUE)

  l <- remDr$findElement(using="partial link text", "University of Cambridge")
  l$clickElement()
  remDr$screenshot(display = TRUE)
  
  #l <- remDr$findElement(using="partial link text", "University of Cambridge"))
  #l$clickElement()
  #remDr$screenshot(display = TRUE)
  
  
  # go to downloads page
  remDr$navigate("http://digimap.edina.ac.uk/datadownload/osdownload")
  remDr$screenshot(display = TRUE)
  # click on master map
  webElem <- remDr$findElement(using = "css", "[class = 'x-grid-group-title']")
  webElem$clickElement()
  remDr$screenshot(display = TRUE)
  # click on "Topography"
  webElem <- remDr$findElements(using="css", "[class = 'x-grid-row-checker']")
  webElem[[4]]$clickElement()
  remDr$screenshot(display = TRUE)
  # click "use tile name"
  webElem <- remDr$findElements(using="css", "[class = 'x-btn-inner']")
  webElem[[2]]$clickElement()
  remDr$screenshot(display = TRUE)
  # enter the tile name
  tilename <- remDr$findElement(using = "css", "[name = 'os-tile-name-input-inputEl']")
  tilename$sendKeysToElement(list(tileId))
  remDr$screenshot(display = TRUE)
  btn <- remDr$findElement(using = "css", "[id = 'os-tile-go-button-btnEl']")
  btn$clickElement()
  remDr$screenshot(display = TRUE)
  # add to basket
  btn <- remDr$findElement(using = "css", "[id = 'addToBasketButton-btnEl']")
  btn$clickElement()
  remDr$screenshot(display = TRUE)
  # Select the format
  e <-remDr$findElements(using = "css", "[class = 'panel-open-text']") 
  e[[5]]$clickElement()
  remDr$screenshot(display = TRUE)
  e <-remDr$findElements(using = "css", "[class = 'x-boundlist-list-ct']") 
  li <- e[[1]]$findChildElements(using="tag name","li")
  li[[3]]$clickElement()
  remDr$screenshot(display = TRUE)
  e <-remDr$findElement(using = "css", "[name = 'ordername']") 
  e$sendKeysToElement(list( tileId ))
  # and request download
  
  btn <- remDr$findElement(using = "css", "[id = 'placeOrderButton-btnEl']") 
  btn$clickElement()
  remDr$screenshot(display = TRUE)
  remDr$close()
}



