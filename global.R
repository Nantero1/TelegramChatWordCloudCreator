library(tm)
library(wordcloud)
library(memoise)
library(stringr)
library(stringi)
library(lambda.tools)


getMessages <- memoise(function (csvdata = as.data.frame(), user = NA) {
  
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if ( !( is.na(user) || is.null(user) ) )
    if (user %in% unique(csvdata$Sender.Name))
      csvdata <- csvdata[csvdata$Sender.Name == user,]
  messages <- data.frame(csvdata$Message, stringsAsFactors = FALSE)
  
  if(.Platform$OS.type == "windows") {
    messages <- data.frame(iconv(messages[,1],from = "UTF-8", to = "UTF-8"), stringsAsFactors = FALSE)
  }
  
  messages <- data.frame(messages[!is.na(messages)],stringsAsFactors = FALSE)
  messages <- data.frame(messages[apply(messages,2,nchar)>0],stringsAsFactors = FALSE) ## you can use sapply,rapply
  if(.Platform$OS.type == "windows") {
    Encoding(messages[,1]) <- "UTF-8"
  }
  messages <- cbind(c(1:nrow(messages)), messages)
  names(messages) <- c("doc_id","text") 
  return(messages)
  
}
)

# Using "memoise" to automatically cache the results
getCorpus <- memoise(function(messages = as.data.frame(), lang = "english") {
  
  myCorpus = Corpus(DataframeSource(messages), readerControl = list(language = "de", reader = readPlain))
  myCorpus = tm_map(myCorpus, content_transformer(stringi::stri_trans_tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, removeWords, stopwords(lang))
  myCorpus = tm_map(myCorpus, stripWhitespace)
  
  return(myCorpus)
})
