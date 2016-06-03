# This file parses whoscored.com for data and stores it
# file soccerdata.RData

# Load XML package
if(!require(XML)){
  install.packages("XML")
  require(XML)
} else {
  require(XML)
}


# Load RSelenium package
if(!require(RSelenium)){
  install.packages("RSelenium")
  require(RSelenium)
} else {
  require(RSelenium)
}

# Load reshape2 package
if(!require(reshape2)){
  install.packages("reshape2")
  require(reshape2)
} else {
  require(reshape2)
}

# whoscored.com url
url <- "http://www.whoscored.com/Regions/252/Tournaments/2/Seasons/4311/Stages/9155/PlayerStatistics/England-Premier-League-2014-2015"

# user <- ""
# pass <- ""
# port <- 80
# ip <- paste0(user,':',pass,"@ondemand.saucelabs.com")
# browser <- "firefox"
browser <- "phantomjs"
# browser <- "chrome"
# version <- "40"
# platform <- "WINDOWS"
# extraCapabilities <- list(name="EPL Scrape", username=user,accessKey = pass)
checkForServer() # Checking if the files for remoteserver are there
startServer() # Starting the remoteserver

result <- remDr$executeScript("var page = this;
                                var fs = require(\"fs\");
                                page.onLoadFinished = function(status) {
                                var file = fs.open(\"output.htm\", \"w\");
                                file.write(page.content);
                                file.close();
                               };")

# fprof <- getFirefoxProfile("C:\\Users\\AGORE\\AppData\\Roaming\\Mozilla\\Firefox\\Profiles\\3kse0f1k.default",useBase=TRUE) # getting the firefox profile from current directory

remDr <- remoteDriver(browserName=browser)#, extraCapabilities=fprof)

remDr$open()

remDr$navigate(url)

allRegions <- remDr$executeScript("return allRegions;")
allRegions <- remDr$executeScript("return JSONstringify(allRegions);")

firstpage <- remDr$getPageSource()

firstpage.parse <- htmlParse(firstpage,asText = TRUE)
assistData.gs <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[2]/a/text()")
assistData.gs <- melt(xmlApply(assistData.gs,xmlValue),value.name="Goal Scorer")$"Goal Scorer"
assistData.ab <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[3]/a/text()")
assistData.ab <- melt(xmlApply(assistData.ab,xmlValue),value.name="Assist By")$"Assist By"
assistData.tm <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[4]/a")
assistData.tm <- melt(xmlApply(assistData.tm,xmlValue),value.name="Team")$"Team"
assistData.as <- getNodeSet(firstpage.parse,"//*[@id='player-assist-table-body']/tr/td[5]")
assistData.as <- melt(xmlApply(assistData.as,xmlValue),value.name="Assists")$"Assists"

assistData <- data.frame("Goal Scorer" = assistData.gs,
                         "Assist By" = assistData.ab,
                         "Team" = assistData.tm,
                         "Assists" = assistData.as)

webElem <- remDr$findElement(using="xpath","/html/body/div[5]/div[3]/div[1]/div[4]/div[2]/div[1]/div[2]/div[1]/dl/dd[2]/a")
webElem$clickElement()
playertable <- readHTMLTable(htmlParse(remDr$getPageSource(),asText=TRUE),which=1,stringsAsFactors=FALSE)
webElem <- remDr$findElement(using="xpath","/html/body/div[5]/div[3]/div[1]/div[4]/div[2]/div[4]/div/dl[2]/dd[3]/a")
webElem$clickElement()
playertable1 <- readHTMLTable(htmlParse(remDr$getPageSource(),asText=TRUE),which=1,stringsAsFactors=FALSE)
webElem <- remDr$findElement(using="xpath","//*[@id='detailed-statistics-tab']/a")

webElem$clickElement()
webElem <- remDr$findElement(using = "xpath", "//*[@id='home']")
webElem$clickElement()
page.parse <- htmlParse(remDr$getPageSource(),asText=TRUE)
playerdetail.home.name <- getNodeSet(page.parse,"//*[@id='player-table-statistics-body']/tr/td[3]/a[1]")
playerdetail.home.name <- melt(xmlApply(playerdetail.home.name,xmlValue),value.name="Name")$"Name"
first <- "#statistics-paging-detailed > div:nth-child(1) > dl:nth-child(4) > dd:nth-child(2) > a:nth-child(1)"
prev <- "#statistics-paging-detailed > div:nth-child(1) > dl:nth-child(4) > dd:nth-child(3) > a:nth-child(1)"
nextl <- "#statistics-paging-detailed > div:nth-child(1) > dl:nth-child(4) > dd:nth-child(4) > a:nth-child(1)"
last <- "#statistics-paging-detailed > div:nth-child(1) > dl:nth-child(4) > dd:nth-child(5) > a:nth-child(1)"
xpath <- "xpath"
css <- "css"
webElem <- remDr$findElement(using=css,nextl)
webElem <- remDr$findElement(using=css,prev)
!grepl("disabled" , webElem$getElementAttribute("class")[[1]])
webElem$clickElement()
first
webElem <- remDr$findElement(using="css selector","#statistics-paging-detailed > div:nth-child(1) > dl:nth-child(4) > dd:nth-child(4) > a:nth-child(1)")
