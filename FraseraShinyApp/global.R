library(ape)
library(leaflet)
library(sf)
library(shiny)
library(shinythemes)
library(spData)
library(tidyverse)
library(tmap)

# Pull Frasera data
frasera_df <- read.csv(file= "https://raw.githubusercontent.com/weiangela/STAT679_Frasera_Project/main/data/frasera_all.csv", header=T, na.strings=c("NA","NaN",""), sep="\t")
frasera_df <- frasera_df %>%
  select("species","countryCode","decimalLatitude","decimalLongitude") %>%
  drop_na() %>%
  filter(countryCode == "US",
         decimalLatitude > 0,
         complete.cases(decimalLatitude, decimalLongitude))
frasera_df[frasera_df$species == "Frasera carolinensis", ]$species = "Frasera caroliniensis"

frasera_map <- st_as_sf(frasera_df, coords = c("decimalLongitude", "decimalLatitude")) %>%
  st_set_crs(value = 4326)

frasera_desc <- read.csv("https://raw.githubusercontent.com/weiangela/STAT679_Frasera_Project/main/introPage/www/Frasera%20Images.csv")
us_geo <- us_states %>%
  filter(!(NAME %in% c("Alaska", "Hawaii", "District of Columbia", "Puerto Rico"))) %>%
  select(NAME, geometry)

species_choice <- sort(unique(frasera_df$species))

tmap_options(basemaps = "Esri.WorldTopoMap")

frasera_string <- "((Frasera_speciosa, (Frasera_fastigiata,Frasera_caroliniensis)), (((Frasera_parryi,Frasera_paniculata), Frasera_albomarginata), (Frasera_tubulosa, (Frasera_puberulenta, ((Frasera_montana,Frasera_albicaulis))))));"
frasera_tree <- read.tree(text = frasera_string)
frasera_tree$tip.label <- gsub("_", " ", frasera_tree$tip.label)

counties <- read_sf("https://raw.githubusercontent.com/weiangela/STAT679_Frasera_Project/main/data/usacounties.json")
pop <- read.csv("https://raw.githubusercontent.com/weiangela/STAT679_Frasera_Project/main/data/Population-Density%20By%20County.csv")

counties <- counties %>%
  mutate(
    STATE = str_replace(STATE, "^0+", ""),
    id = paste0(STATE, COUNTY)
  ) %>%
  filter(st_is_valid(counties),
         !(STATE %in% c("02", "11", "15", "72")))

pop <- pop %>%
  mutate(id = as.character(GCT_STUB.target.geo.id2))

merge_data <- full_join(counties, pop, by = "id") %>%
  mutate(logpop = log(Density.per.square.mile.of.land.area))

qpal <- colorQuantile("YlOrRd", merge_data$logpop, n = 5)
qpal_colors <- unique(qpal(sort(merge_data$logpop)))

source('ui.R', local = TRUE)
source('server.R')
shinyApp(ui = ui, server = server)
