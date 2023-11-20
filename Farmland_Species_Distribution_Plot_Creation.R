library(sf)
library(tidyverse)
library(terra)

farm <- rast("filtered_farmland.tif")
low_res <- aggregate(farm, fact = 5)
new_proj <- project(low_res, "epsg:4326")
writeRaster(new_proj, "my_hopes_and_dreams.tif")
a <- tigris::states() %>%
  filter(!(STATEFP %in% c("02", "11", "15", "60", "66", "69", "72", "78"))) %>%
  select(STATEFP, geometry)

GBIF <- read.csv(file= "frasera_all.csv", header=T, na.strings=c("NA","NaN",""), sep="\t")
GBIF <- GBIF %>%
  dplyr::select("species","countryCode","decimalLatitude","decimalLongitude") %>%
  drop_na() %>%
  filter(countryCode == "US",
         decimalLatitude > 20)
f_c <- GBIF[GBIF$species %in% c("Frasera caroliniensis", "Frasera carolinensis"), ] %>% select(-species, -countryCode)
f_s <- GBIF[GBIF$species == "Frasera speciosa", ] %>% select(-species, -countryCode)

png(filename="Visual2/Farmland.png")
plot(new_proj, legend = FALSE, xlab = "Longitude", ylab = "Latitude", main = "Farmland Throughout The USA vs Frasera Species Distribution ", cex.lab = 1)
polys(a)
points(f_c$decimalLongitude, f_c$decimalLatitude, cex = 0.5, col = "blue", pch = 16)
points(f_s$decimalLongitude, f_s$decimalLatitude, cex = 0.5, col = "black", pch = 18)
legend(x = -127, y = 30, legend = c("Farmland", "Frasera carolineinsis", "Frasera speciosa"), col = c("darkgreen", "blue", "black"), pch = c(16, 16, 18))
dev.off()
