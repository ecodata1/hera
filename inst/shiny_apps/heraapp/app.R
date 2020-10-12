#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
library(shiny)
library(hera)
library(leaflet)
library(htmltools)

# Define UI for application

  ui <- tagList(
  #  shinythemes::themeSelector(),
    navbarPage(
      # theme = "cerulean",  # <--- To use a theme, uncomment this
      "hera",
      tabPanel("Predict & Classify",
               sidebarPanel(
      h3("Options"),
      fileInput("dataset", "Choose CSV File",
        accept = c(
          "text/csv",
          "text/comma-separated-values,text/plain",
          ".csv"
        )
      )
    ),
    # Show tables
    mainPanel(
      leafletOutput("map"),
      p(),
      htmlOutput("tables")
    )
  ),
  tabPanel("Diagnose", "This panel is intentionally left blank.")
)
)

# Define server logic ------------------------------------------------------------------
server <- function(input, output) {
  output$tables <- renderUI({
    inFile <- input$dataset
    if (is.null(inFile)) {
      return(NULL)
    }
    # Create a Progress object
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    progress$set(message = "Calculating", value = 1)
    data <- read.csv(inFile$datapath, check.names = F)

    output_files <- list(data)
    classification_table <- data.frame()
    if (!is.null(data)) {
      output_files <- list(data)
    }

    output$download_file <- downloadHandler(
      filename = function() {
        paste("hera-output", "zip", sep = ".")
      },
      content = function(fname) {
        fs <- c()
        tmpdir <- tempdir()
        setwd(tempdir())
        for (i in seq_along(output_files)) {
          path <- paste0("output_", i, ".csv")
          fs <- c(fs, path)
          write.csv(output_files[[i]], file = path)
        }
        zip(zipfile = fname, files = fs)
      }
    )

    download_data <- renderUI({
      downloadButton("download_file", "Download Outputs")
    })

    map <- leaflet(data) %>%
             addTiles() %>%
              addMarkers(~LONGITUDE, ~LATITUDE, popup = ~ htmlEscape(SITE))

    output$map <- renderLeaflet(map)

    return(list(
      download_data,
      h3("Data"), DT::renderDataTable({
       data
      }),
      h3("Predictions"), DT::renderDataTable({

      }),
      h3("Classification"), DT::renderDataTable({

      })
    ))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
