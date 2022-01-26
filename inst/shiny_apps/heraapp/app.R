#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

library(hera)
library(shiny)
library(tidyverse)
library(leaflet)
library(htmltools)
library(dplyr)


# Define UI for application
ui <- tagList(
  #  shinythemes::themeSelector(),
  navbarPage(
    # theme = "cerulean",  # <--- To use a theme, uncomment this
    "hera",
    tabPanel(
      "Validate", sidebarPanel(
        h3("Options"),
        fileInput("dataset", "Choose CSV File",
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        ),
        h4("Or click me!..."),
        actionButton(inputId = "demo", label = "Demo Data"),
        p(),
        selectInput("standard",
          label = "Standard",
          choices = c(
            "rict" = "FW_TX_WHPT",
            "darleq" = "DIAT_TST"
          ),
          multiple = TRUE, selected = c(
            "rict" = "FW_TX_WHPT",
            "darleq" = "DIAT_TST"
          )
        ),
        p(),
        uiOutput("sites"),
        p()
      ),
      # Show tables
      mainPanel(
        htmlOutput("app"),
        leafletOutput("map_first"),
        # p(),
        htmlOutput("data_table")
      )
    ),
    tabPanel(
      "Indices",
      sidebarPanel(
        htmlOutput("indices_filter")
      ),
      # Show tables
      mainPanel(
        leafletOutput("map"),
        p(),
        htmlOutput("indices")
      )
    ),
    tabPanel("Predict", mainPanel(
      htmlOutput("predictions")
    )),
    tabPanel(
      "Compliance",
      mainPanel(
        htmlOutput("compliance")
      )
    ),
    tabPanel("Aggregate", sidebarPanel(
      h3("Options"),
      p(),
      selectInput("grouping",
        label = "Group by",
        choices = c(
          "water_body_id" = "water_body_id",
          "year" = "year"
        ),
        selected = c("water_body_id" = "water_body_id")
      )
    ), mainPanel(
      htmlOutput("aggregation")
    )),
    tabPanel("Compare", "This panel is intentionally left blank."),
    tabPanel("Diagnose", "This panel is intentionally left blank."),
    tabPanel("Simulations", "This panel is intentionally left blank.")
  )
)

# Define server logic ------------------------------------------------------------------
server <- function(input, output) {
  reactiveA <- reactive({
    inFile <- input$dataset
    # Create a Progress object
    progress <- shiny::Progress$new()
    progress$set(message = "Calculating", value = 1)
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())

    if (length(input$sites) == 0) {
     sites_data_frame <- reactive({
    sites <- ead::get_sites(take = 1000)
    sites <- sites[complete.cases(sites), ]
    })
    output$sites <-  renderUI(list(
      selectInput(multiple = TRUE, "sites",
                  label = "Sites",
                  choices = as.character(unique(unlist(c(sites_data_frame()["local_id"], 43378, 43296))))

    )))
    }

    if (is.null(inFile) & input$demo & length(input$sites) > 0) {
      data <- hera::demo_data
      message("ea data")
      # Add in EA data
      ea <- hera:::ead(site_id = input$sites)
      data$location_id <- as.character(data$location_id)
      data$sample_id <- as.character(data$sample_id)
      ea$response <- as.character(ea$response)
      ea$response <- as.factor(ea$response)
      ea$date_taken <- as.Date(ea$date_taken)
      data <- dplyr::bind_rows(data, ea)

      if (length(input$standard) == 1 && input$standard[1] == "FW_TX_WHPT") {
        data <- dplyr::filter(data, analysis_name %in% input$standard |
          analysis_name %in% "SURVEY_INV" |
          quality_element == "River Invertebrates")
      }

      if (length(input$standard) == 1 && input$standard[1] == "DIAT_TST") {
        data <- dplyr::filter(data, analysis_name %in% input$standard)
      }
      data <- data
    } else if (is.null(inFile)) {
      return(NULL)
    } else {
      data <- read.csv(inFile$datapath, check.names = F)
    }
  })


  output$app <- renderUI({
    data <- reactiveA()
    if (!is.null(data)) {
      indices <- indices(data) %>%
        select(sample_number, indices) %>%
        unnest(indices)


      if (!is.null(data)) {
        output_files <- list(
          "input_data" = data,
          "indices" = indices
        )
      }

      output$download_file <- downloadHandler(
        filename = function() {
          paste("hera-files", "zip", sep = ".")
        },
        content = function(fname) {
          fs <- c()
          tmpdir <- tempdir()
          setwd(tempdir())
          for (i in seq_along(output_files)) {
            path <- paste0("output_", names(output_files)[i], ".csv")
            fs <- c(fs, path)
            write.csv(output_files[[i]], file = path)
          }
          zip(zipfile = fname, files = fs)
        }
      )

      # output$download_data <- renderUI({
      #   downloadButton("download_file", "Download Outputs")
      # })

      map_data <- select(data, longitude, latitude, location_id)
      map_data <- unique(map_data)
      map <- leaflet(map_data) %>%
        addTiles() %>%
        addMarkers(~longitude, ~latitude, popup = ~ htmlEscape(location_id))

      output$map <- renderLeaflet(map)
      output$map_first <- renderLeaflet(map)

      output$standard <- renderUI(selectInput(
        inputId = "standard",
        label = "Select Standard",
        choices = unique(data$standard)
      ))

      indices$value <- as.numeric(indices$value)
      chart_data <- indices %>% filter(!is.na(value))
      chart_stuff <- data %>% select(latitude, longitude, sample_id, date_taken)
      chart_stuff <- chart_stuff %>% unique()
      chart_data <- inner_join(chart_stuff,
                               chart_data,
                               by = c("sample_id" = "sample_number"))
      options(digits = 3)
      chart_data$value <- as.numeric(chart_data$value)
      if (nrow(indices) > 0) {
        chart <- ggplot(chart_data, aes(x = date_taken, y = value)) +
          geom_point() +
          facet_wrap(vars(index), scales = "free_y")
      } else {
        chart <- NULL
      }
      output$data_table <- renderUI(list(
        h3("Data"), DT::renderDataTable({
          select(data, location_id, location_description, sample_id, question, response)
        })
      ))

      output$predictions <- renderUI(list(
        h3("Predictions"), DT::renderDataTable({
          predictions <- prediction(data) %>%
            group_by(quality_elements) %>%
            select(sample_number, prediction) %>%
            unnest(prediction) %>%
            unique()
        })
      ))

      output$compliance <- renderUI(list(
        h3("Compliance"), DT::renderDataTable({
          classification(data) %>%
            group_by(quality_elements) %>%
            #slice_sample(n = 4) %>%
            select(sample_number, index, assessment, value) %>%
            unique()
        })
      ))


      output$indices_filter <- renderUI(list(
        renderUI({
          selectInput(selectize = FALSE, "Question", label = "Questions", choices = unique(data$question), multiple = T, selected = unique(data$question))
        })
      ))

      output$indices <- renderUI(list(
        renderUI({
          downloadButton("download_file", "Download Outputs")
        }),
        # h3("Data"), DT::renderDataTable({
        #   select(data, location_id, location_description, sample_id, question, response)
        # }),
        h3("Chart"), renderPlot({
          chart
        }),
        h3("Indices"), DT::renderDataTable({
          indices
        })
      ))

      output$aggregation <- renderUI(list(
        h3("Indices"), DT::renderDataTable({
          select(data, location_id, water_body_id, sample_id, question, response)
        })
      ))


      return(NULL)
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
