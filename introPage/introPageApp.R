library(ggplot2)
library(tidyverse)
library(leaflet)
library(sf)
library(tmap)
library(spData)

frasera <- read.csv(file= "frasera_all.csv", header=T, na.strings=c("NA","NaN",""), sep="\t")
frasera <- frasera %>%
  select("species","countryCode","decimalLatitude","decimalLongitude") %>%
  drop_na() %>%
  filter(countryCode == "US",
         decimalLatitude > 0)
frasera[frasera$species == "Frasera carolinensis", ]$species = "Frasera caroliniensis"
frasera_map <- st_as_sf(frasera, coords = c("decimalLongitude", "decimalLatitude")) %>%
  st_set_crs(value = 4326)

us_geo <- us_states %>%
  filter(!(NAME %in% c("Alaska", "Hawaii", "District of Columbia", "Puerto Rico"))) %>%
  select(NAME, geometry)

species_choice <- sort(unique(frasera$species))

tmap_options(basemaps = "Esri.WorldTopoMap")

ui <- fluidPage(
  h1("Frasera Introduction Page"),
  sidebarLayout(
    sidebarPanel(
      #create drop down to allow user to select verbatim ScientificName
      selectInput("species","Select Species to Plot", choices=species_choice, selected = "Frasera caroliniensis"),
      imageOutput("plantImage", width = "200px"),
      width = 4
    ),
    mainPanel(
      textOutput("speciesInfo"),
      h2("Species Distribution"),
      tmapOutput("map"))
  )
)

server<-function(input, output){
  #have a variable store the drop down selection
  selection <- reactive({
    frasera[frasera$species==input$species,]
  })
  # add a dataframe with information on each of the species that we have
  output$speciesInfo <- renderText({input$species})

  output$plantImage <- renderImage({
    filename <- normalizePath(file.path(paste0("./www/", input$species, ".jpg")))
    list(src = filename, alt = paste("Species:", input$species), width = "200px")
  }, deleteFile = FALSE)

  #plot location on map using decimalLongitude and decimalLatitude
  output$map<-renderTmap({
    tm_shape(frasera_map[frasera_map$species == input$species, ]) +
      tm_dots(size = 0.05, col = "darkgreen")
  })

}

shinyApp(ui,server)
