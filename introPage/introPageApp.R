library(ggplot2)
library(tidyverse)
library(leaflet)
library(sf)
library(tmap)
library(spData)
library(ape)

frasera_df <- read.csv(file= "frasera_all.csv", header=T, na.strings=c("NA","NaN",""), sep="\t")
frasera_df <- frasera_df %>%
  select("species","countryCode","decimalLatitude","decimalLongitude") %>%
  drop_na() %>%
  filter(countryCode == "US",
         decimalLatitude > 0)
frasera_df[frasera_df$species == "Frasera carolinensis", ]$species = "Frasera caroliniensis"
sort(unique(frasera_df$species))
frasera_map <- st_as_sf(frasera_df, coords = c("decimalLongitude", "decimalLatitude")) %>%
  st_set_crs(value = 4326)
frasera_desc <- readxl::read_xlsx("./www/Frasera Images.xlsx")
us_geo <- us_states %>%
  filter(!(NAME %in% c("Alaska", "Hawaii", "District of Columbia", "Puerto Rico"))) %>%
  select(NAME, geometry)

species_choice <- sort(unique(frasera_df$species))

tmap_options(basemaps = "Esri.WorldTopoMap")

frasera_string <- "((Frasera_speciosa, (Frasera_fastigiata,Frasera_caroliniensis)), (((Frasera_parryi,Frasera_paniculata), Frasera_albomarginata), (Frasera_tubulosa, (Frasera_puberulenta, ((Frasera_montana,Frasera_albicaulis_subsp.nitida), (Frasera_albicaulis_var.modocensis,Frasera_albicaulis))))));"
frasera_tree <- read.tree(text = frasera_string)
frasera_tree$tip.label <- gsub("_", " ", frasera_tree$tip.label)

ui <- fluidPage(
  h1("Frasera Introduction Page"),
  textOutput("generalInfo"),
  p(),
  fluidRow(
    column(6, plotOutput("plot1", click = "species_click")),
    column(6, imageOutput("plantImage", width = "200px"))
  ),
  textOutput("speciesName"),
  textOutput("speciesInfo"),
  h2("Species Distribution"),
  tmapOutput("map")
)


server<-function(input, output){
  #have a variable store the drop down selection

  selection <- eventReactive(input$species_click, {
    plot(frasera_tree)
    plotinfo <- get("last_plot.phylo", envir = .PlotPhyloEnv)
    tips_xy <- data.frame(Tip = rep(frasera_tree$tip.label, times = 96),
                          x = unlist(lapply(seq(11, 30, by = 0.2), function (x) rep(x, times = 12))),
                          y = rep(plotinfo$yy[1:Ntip(frasera_tree)], times = 96))

    brushed_points <- nearPoints(tips_xy, input$species_click, xvar = "x", yvar = "y")

    if (nrow(brushed_points) > 0) {
      brushed_points$Tip[1]
    } else {
      ""
    }
  }, ignoreNULL = FALSE)

  output$generalInfo <- renderText("Frasera is a plant genus in Gentianaceae. It has 14 species native to North America. Most of the frasera_df spp. are perennial, while 3 of the species have a special life style: monocarpy, meaning they stay in vegetative states for multiple years, flower once, then die. The 3 monocarpic species includes two closely related widely distributed species: F. speciosa and F. caroliniensis. These two species have different geographical distribution, different niche and evolution history (climate vs. icesheet). In this study, we are using visualization to help illustrate the biogeography of the genus frasera_df, the historical distribution of frasera_df spp. under the changing climate, as well as how human behaviour impact the nowaday distribution of the eastern NA species frasera_df caroliniensis in compare to the similar widely distributed species frasera_df speciosa.")

  #plot location on map using decimalLongitude and decimalLatitude
  output$map<-renderTmap({
    if (selection() != "") {
      tm_shape(frasera_map[frasera_map$species == selection(), ]) +
        tm_dots(size = 0.05, col = "darkgreen")
    } else {
      tm_shape(us_geo) +
        tm_polygons(alpha = 0)
    }
  })
  output$plot1 <- renderPlot({
    plot(frasera_tree)
  })
  output$speciesName <- renderText({selection()})
  output$speciesInfo <- renderText({
    if (selection() != "" & !is.null(selection())) {
      frasera_desc$wikipedia_description[frasera_desc$species == selection()]
    } else {
      ""
    }
  })

  output$plantImage <- renderImage({
    tryCatch({
      if (!is.null(selection()) | selection() != "") {
        filename <- normalizePath(file.path(paste0("./www/", selection(), ".jpg")))
        list(src = filename, alt = paste("Species:", selection()), height = "350px", width = "300px")
      }
    }, error = function(e) {""})
  }, deleteFile = FALSE)

}

shinyApp(ui,server)
