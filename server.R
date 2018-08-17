library(shiny)
library(wordcloud)
library(tm)
library(SnowballC)
# This above package is loaded by the tm by default but is not installed
# when the above packages were being installed
# so naturally shinyapp.io doesn't install this too.
# So, it is explicitly loaded here to be installed by the shinyapps server.

shinyServer(function(input, output, session) {

  datainput <- reactive({

    # Outputs a helpful message when neither text is entered nor
    # the text file uploaded.
    validate(
      need( (!is.null(input$file)),
        "Please give me some text to work upon!"
      )
    )
    
    if (!is.null(input$file)){
      a <- input$file$datapath
      a <- substr(a, 1, nchar(a) - 1)
      
      
      chathistoryCSV <- read.csv(file=input$file$datapath, header=TRUE, sep=",", encoding = "UTF-8")
      
      updateSelectInput(session, "user",
                        choices = c("All", paste(unique(chathistoryCSV$Sender.Name))),
                        selected = input$user
      )
      
      withProgress(message = "Processing corpus...", {
        setProgress(0.1)
        messages <- getMessages(chathistoryCSV, user = input$user)
        setProgress(0.5)
        words <- getCorpus(messages, lang = input$language)
        setProgress(0.9)
      })
      words
    }
    
    })

  # Reactive element to transform the data on the basis of
  # (de)selection of checkbox3 in ui.R
  finalinput <- reactive({
    if (input$checkbox3) datainput <- tm_map(datainput(), function(x) stemDocument(x = x, language = input$language))
    datainput()
    })

  # Reactive element to transform the data on the basis of
  # (de)selection of checkbox2 in ui.R
  asdas <- reactive({
    if (input$checkbox2) wordcloud_rep <- repeatable(wordcloud)
    else wordcloud_rep <- wordcloud
  })
  
  # Reactive element to generate the wordcloud and save it as a png
  # and return the filename.
  make_cloud <- reactive ({
    withProgress(message = "Sorting wordcloud...", {
      wordcloud_rep <- asdas()
      setProgress(0.1)
      png("wordcloud.png", width=10, height=10, units="in", res=350)
      par(mar = rep(0,4))
      setProgress(0.2)
      w <- wordcloud_rep(finalinput(),
                         scale=c(5, 0.5),
                         min.freq=input$slider1,
                         max.words=input$slider2,
                         random.order=input$checkbox4,
                         rot.per=input$slider3,
                         use.r.layout=FALSE,
                         colors=brewer.pal(8, "Dark2"))
      dev.off()
      
      setProgress(1)
    })
    
    filename <- "wordcloud.png"
  })
  
  # Reactive element to generate the wordcloud and save it as a png
  # and return the filename.
  make_cloud_eps <- reactive ({
    withProgress(message = "Sorting wordcloud...", {
      wordcloud_rep <- asdas()
      setProgress(0.1)
      postscript("wordcloud.eps", width = 10, height = 10, horizontal = TRUE, onefile = FALSE)
      setProgress(0.2)
      w <- wordcloud_rep(finalinput(),
                         scale=c(5, 0.5),
                         min.freq=input$slider1,
                         max.words=input$slider2,
                         random.order=input$checkbox4,
                         rot.per=input$slider3,
                         use.r.layout=FALSE,
                         colors=brewer.pal(8, "Dark2"))
      dev.off()
      
      setProgress(1)
    })
    
    filename <- "wordcloud.eps"
  })

  # Download handler for the image.
  output$wordcloud_img <- downloadHandler(
    filename = "wordcloud.png",
    content = function(cloud) {
      file.copy(make_cloud(), cloud)
    })
  
  # Download handler for the image.
  output$wordcloud_img_eps <- downloadHandler(
    filename = "wordcloud.eps",
    content = function(cloud) {
      file.copy(make_cloud_eps(), cloud)
    })
  

  # Download handler for the csv.
  output$freq_csv <- downloadHandler(
    filename = "freq.csv",
    content = function(freq) {
      a <- DocumentTermMatrix(finalinput())
      b <- sort(colSums(as.matrix(a)), decreasing=TRUE)
      write.csv(b, freq)
    })

  # Sending the wordcloud image to be rendered.
  output$wordcloud <- renderImage({
    list(src=make_cloud(), alt="Image being generated!", height=600)
  },
  deleteFile = FALSE)
})
