library(shiny)

ui <- fluidPage(
  titlePanel("genus Frasera historical distribution modeling"),
  sliderInput("kyr", "thousands years ago", min = -18, max = 0, value = 0, step = 3, animate = TRUE),
  imageOutput("Distribution")
)

server <- function(input, output) {
  
  output$Distribution <- renderImage({
    filename <- normalizePath(file.path(paste0("C:/Users/75180/679visualization/grouppj/maxent/", (input$kyr + 18) / 3 + 1, ".png")))
    list(src = filename, alt = "/")
  }, deleteFile = FALSE)
}

shinyApp(ui, server)
