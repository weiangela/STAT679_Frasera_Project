

ui <- fluidPage(
  theme = shinytheme("sandstone"),
  navbarPage("Frasera",
    tabPanel("Intro Page",
             h1("Frasera Introduction Page"),
             p("Frasera is a plant genus in Gentianaceae. It has 14 species native to North America. Most of the Frasera spp. are perennial, while 3 of the species have a special life style: monocarpy, meaning they stay in vegetative states for multiple years, flower once, then die. The 3 monocarpic species includes two closely related widely distributed species: F. speciosa and F. caroliniensis. These two species have different geographical distribution, different niche and evolution history (climate vs. icesheet). In this study, we are using visualization to help illustrate the biogeography of the genus Frasera, the historical distribution of Frasera spp. under the changing climate, as well as how human behaviour impact the nowaday distribution of the eastern NA species Frasera caroliniensis in compare to the similar widely distributed species Frasera speciosa."),
             h4("Phylogenetic Tree Selection"),
             p("The root of the tree represents the ancestral lineage, and the tips of the branches represent the descendants of that ancestor. As you move from the root to the tips, you are moving forward in time. When a lineage splits (speciation), it is represented as branching on a phylogeny."),
             fluidRow(
               column(6, plotOutput("plot1", click = "species_click")),
               column(6, imageOutput("plantImage", width = "200px"))
             ),
             span(textOutput("speciesName"), style="font-size:20px; font-style:bold"),
             textOutput("speciesInfo"),
             h2("Species Distribution"),
             p("Below is a map identifying the distribution of the species selected. Each green dot represents a coordinate location where the plant species has been identified."),
             tmapOutput("map")),
    tabPanel("Human Impact",
             sidebarPanel(radioButtons("species_select", "Choose a Frasera species:", choices = c("Frasera caroliniensis", "Frasera speciosa"))),
             mainPanel(h1("Human Impact - Human Population"),
                       p("In this tab, you can select which species to observe the effects of human population and farmland!"),
                       leafletOutput("pop_map"),
                       h1("Human Impact - Farmland"),
                       p("Below is the image displaying farmland compared to actual and predicted distribution of Frasera species."),
                       imageOutput("farm_map", width = "50%"))),
    tabPanel("Historical Distribution",
             h1("Historical Distribution of Frasera Species"),
             p("The visual below uses Maxent climate modeling to predict the distribution hotspot in the past 18,000 years using the historical climate data and ancient climate data from WorldClim. Users have the option to slide the slider to observe the anticipated distribution corresponding to the specific number of time periods they are interested in. "),
             sliderInput("kyr", "Thousands years ago", min = -18, max = 0, value = 0, step = 3, animate = animationOptions(interval = 1000, loop = TRUE)),
             imageOutput("Distribution"))
  )
)
