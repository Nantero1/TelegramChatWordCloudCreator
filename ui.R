library(shiny)

shinyUI(fluidPage(
  # Title of the app
  titlePanel("Telegram wordcloud creator for Wenjana!"),

  sidebarLayout(
    sidebarPanel(

      strong("Settings:"),

      # Checkboxes for the wordcloud settings
      selectInput   ("language", label = "Language", choices = c("german", "english", "russian"), selected = "german", multiple = FALSE),
      selectInput   ("user", label = "User", choices = "All", selected = "All", multiple = FALSE),
      checkboxInput("checkbox3", label = "Document stemming", value = TRUE),
      checkboxInput("checkbox4", label = "Random Order", value = FALSE),
      checkboxInput("checkbox2", label = "Repeatable", value = TRUE),

      # Slider input for frequency change
      sliderInput("slider1", "Minimum Frequency:",
        min = 1, max = 50, value = 5),

      # Slider input for rotation change
      sliderInput("slider3", "Rotation:",
        min = 0.0, max = 1.0, value = 0.25),

      # Slider input for number of words change
      sliderInput("slider2", "Max words:",
        min = 10, max = 1000, value = 100),

      # Text file uploader
      fileInput("file", "CSV file", accept=c("text/plain", ".csv"))),

    mainPanel(
      # Image download button
      downloadButton("wordcloud_img", "Download PNG Image"),
      downloadButton("wordcloud_img_eps", "Download EPS Image"),
      # CSV download button
      downloadButton("freq_csv", "Download Freq CSV"),
      # Wordcloud image rendered
      imageOutput("wordcloud"))
  )
))
