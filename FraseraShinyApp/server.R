
server <- function(input, output, session){
  #have a variable store the drop down selection
  selection <- eventReactive(input$species_click, {
    plot(frasera_tree)
    plotinfo <- get("last_plot.phylo", envir = .PlotPhyloEnv)
    tips_xy <- data.frame(Tip = rep(frasera_tree$tip.label, times = 96),
                          x = unlist(lapply(seq(11, 30, by = 0.2), function (x) rep(x, times = 10))),
                          y = rep(plotinfo$yy[1:Ntip(frasera_tree)], times = 96))

    brushed_points <- nearPoints(tips_xy, input$species_click, xvar = "x", yvar = "y")

    if (nrow(brushed_points) > 0) {
      brushed_points$Tip[1]
    } else {
      ""
    }
  }, ignoreNULL = FALSE)

  output$generalInfo <- renderText("Frasera is a plant genus in Gentianaceae. It has 14 species native to North America. Most of the frasera_df spp. are perennial, while 3 of the species have a special life style: monocarpy, meaning they stay in vegetative states for multiple years, flower once, then die. The 3 monocarpic species includes two closely related widely distributed species: F. speciosa and F. caroliniensis. These two species have different geographical distribution, different niche and evolution history (climate vs. icesheet). In this study, we are using visualization to help illustrate the biogeography of the genus frasera_df, the historical distribution of frasera_df spp. under the changing climate, as well as how human behaviour impact the nowaday distribution of the eastern NA species frasera_df caroliniensis in compare to the similar widely distributed species frasera_df speciosa.\n\nThe root of the tree represents the ancestral lineage, and the tips of the branches represent the descendants of that ancestor. As you move from the root to the tips, you are moving forward in time. When a lineage splits (speciation), it is represented as branching on a phylogeny.
")

  #plot location on map using decimalLongitude and decimalLatitude
  output$map <- renderTmap({
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

  # Human Impact
  output$pop_map <- renderLeaflet({
    if (input$species_select == "Frasera speciosa") {
      view_select <- c(-125, 30, -104, 49) # min long, min lat, max long, max lat
    } else {
      view_select <- c(-95, 31, -77, 47) # min long, min lat, max long, max lat
    }

    leaflet() %>%
      addTiles() %>%
      addPolygons(data = merge_data,
                  fillColor = ~qpal(merge_data$logpop),
                  fillOpacity = 0.7,
                  color = "white",
                  weight = 1) %>%
      addCircleMarkers(data = frasera_df[frasera_df$species == input$species_select, ],
                       lng = ~decimalLongitude,
                       lat = ~decimalLatitude,
                       radius = 1,
                       color = "black") %>%
      fitBounds(lng1 = view_select[1], lat1 = view_select[2], lng2 = view_select[3], lat2 = view_select[4]) %>%
      addLegend(position = "bottomright",
                colors = qpal_colors,
                labels = c("Very Low","Low","Medium","High","Very high"),
                opacity = 0.7,
                title = "Population Density")
  })
  output$farm_map <- renderImage({
    filename <- normalizePath(file.path(paste0("./www/", input$species_select, " Dist Plot.png")))
    list(src = filename, alt = paste("Species:", input$species_select), width = "600px")
    }, deleteFile = FALSE)

  output$Distribution <- renderImage({
    filename <- normalizePath(file.path(paste0("./www/", (input$kyr + 18) / 3 + 1, ".png")))
    list(src = filename, alt = "/")
  }, deleteFile = FALSE)
}
