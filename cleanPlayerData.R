load("playerData.RData")
if(!require(dplyr)){
  install.packages("dplyr")
  require("dplyr")
} else{
  require(dplyr)
}

index <- duplicated(playerTotalStats$seasonId) & duplicated(playerTotalStats$playerId) & duplicated(playerTotalStats$teamId)

playerDuplicate <- playerTotalStats[index,]

uniqueFunction <- function(x){
  if(length(unique(x))<2){
    return(unique(x))
  } else {
    return(unique(x)[2])
  }
}

playerUnique <- as.data.frame(playerDuplicate %>% 
                                group_by(seasonId,playerId,teamId) %>%
                              summarise_each(funs(uniqueFunction)))

playerCleanData <- merge(playerUnique,playerTotalStats[!index,],
                         by=intersect(names(playerUnique),names(playerTotalStats)),all=TRUE)
