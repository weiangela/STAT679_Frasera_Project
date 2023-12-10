library(sf)
library(tidyverse)
library(terra)
library(tmap)

farm <- rast("my_hopes_and_dreams.tif")
coltab(farm) <- data.frame(value = 1:2, col = c("black", "darkgreen"))

# low_res <- aggregate(farm, fact = 5)
# new_proj <- project(low_res, "epsg:4326")
# writeRaster(new_proj, "my_hopes_and_dreams.tif")
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

f_c_dist <- rast("Frasera_caroliniensis.asc")
f_s_dist <- rast("Frasera_speciosa.asc")

png("F_carolineinsis_Distribution_Plot.png")
plot(f_c_dist, legend = F, xlab = "Longitude", ylab = "Latitude", main = "Farmland Throughout The USA vs\n Frasera Carolineinsis Distribution", ylim = c(25.84, 49.38))
plot(farm, legend = F, cex.lab = 1, add = T)
points(f_c$decimalLongitude, f_c$decimalLatitude, cex = 0.5, col = "black", pch = 16)
legend(-124, 34, legend = c("Farmland", "Frasera carolineinsis"), col = c("darkgreen", "black"), pt.cex = c(0.6, 1), pch = 16)
dev.off()

png("F_speciosa_Distribution_Plot.png")
plot(f_s_dist, legend = F, xlab = "Longitude", ylab = "Latitude", main = "Farmland Throughout The USA vs\n Frasera Speciosa Distribution", ylim = c(25.84, 49.38))
plot(farm, legend = F, cex.lab = 1, add = T)
points(f_s$decimalLongitude, f_s$decimalLatitude, cex = 0.5, col = "black", pch = 18)
legend(x = -90, y = 49, legend = c("Farmland", "Frasera speciosa"), col = c("darkgreen", "black"), pt.cex = c(0.6, 1), pch = 16)
dev.off()
