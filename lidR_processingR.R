# Processing    : Generate the the DTM, Normalize the lidar data, Filter the point clouds from the first return, remove the outlines, segmentation of trees and Buildings
# version 1.0.0 : testing
# Author : Walid Ghariani

library(lidR)
library(rLiDAR)
library(rasterVis)
library(ggspatial)
library(dplyr)
library(ggplot2)
# call lidR functions for Visualisations
source("lidR_functions.R")
############## ~~Read the laz file: We choosed 4 aois with most coverage on buildings to merge and work with 
# This data are not provided in github dues to the size of the files
lid1<- lidR::readLAS("input_lidar/laser_1_2021-02-25-10-13-37_392_RemoveOutliers.las")
lid2<- lidR::readLAS("input_lidar/laser_1_2021-02-25-10-13-37_608_RemoveOutliers.las")
lid3<- lidR::readLAS("input_lidar/laser_1_2021-02-25-10-13-37_344_RemoveOutliers.las")
lid4<- lidR::readLAS("input_lidar/laser_1_2021-02-25-10-13-37_704_RemoveOutliers.las")

############## ~~Merge the data into a single las/laz file  
lid_wurz <- rbind(lid1, lid2, lid3, lid4)
# make a copy
lidR_wurz <- lid_wurz
lid_wurz
#plot(lidR_wurz)
writeLAS(lidR_wurz, "./output_lidar/merged_lidar.laz")

ld <- lidR::readLAS("./output_lidar/merged_lidar.laz",
                    filter = "-keep_random_fraction 0.1",
                    select = "xyzrn"
                    )
ld
writeLAS(ld, "./output_lidar/merged_lidar_10.laz")

############## ~~ This data will be then used with pdal 
# Use of classify_ground function to classify the point clouds into ground and non-ground
# here we are using the lidar data processed by the pdal pipeline 
#{
#"type":"filters.assign","assignment":"NumberOfReturns[:]=1"
#},
#{
#  "type":"filters.assign","assignment":"ReturnNumber[:]=1"
#}"""

#############  Testing with 10% of the data 
# https://github.com/Jean-Romain/lidR/issues/209
lidR_wurz2 <- lidR::readLAS("./input_lidar/merged_lidar_nr.laz",
                            filter = "-keep_random_fraction 0.1",
                            select = "xyzrn")

lidR_wurz2

lidR_wurz <- lidR::readLAS("./input_lidar/merged_lidar_nr2.laz",
                            filter = "-keep_random_fraction 0.1",
                            select = "xyzrn")

lidR_wurz
plot(lidR_wurz,bg = "white")

writeLAS(lidR_wurz2, "./output_lidar/merged_lidar_nr_10percent.laz")
# ----- option 1:Using the Cloth Simulation Filter
# (Parameters chosen mainly for speed)
mycsf <-  csf(rigidness = 3, cloth_resolution = 1)
lidR_wurz2 <- classify_ground(lidR_wurz2, mycsf)
lidR_wurz2
plot(lidR_wurz2, color = "Classification",bg = "white")

# ----- option 2: Progressive morphological filter
ws  <- seq(3,12, 3)
th  <- seq(0.1, 1.5, length.out = length(ws))

#lidR_wurz2 <- classify_ground(lidR_wurz2, pmf(ws, th))

# Lets viz a cross section
p1 <- c(570300, 5515400)
p2 <- c(570200, 5515400)

plot_crossection(lidR_wurz2, p1 = p1, p2 = p2, 
                 colour_by = factor(Classification),
                 title = "Cloth Simulation Filter")

# uncomment this part when the classification was done with pmf
#plot_crossection(lidR_wurz2, p1 = p1, p2 = p2, 
#                 colour_by = factor(Classification),
#                 title = "Progressive Morphological Filter")

############## ~~Generate the DTM
DTM2 = grid_terrain(lidR_wurz2,  res = .1,algorithm = knnidw(k = 6L, p=2))
DTM2

plot(DTM2, main = "DTM at Wurzburg AOI")

vIZ_parameter(DTM2)+
  ggtitle("DTM at Wurzburg AOI")
plot_dtm3d(DTM2)
# Generate slope
Slope <- terrain(DTM2, opt=c('slope'), unit='degrees')
plot(Slope)
vIZ_parameter(Slope)+
  ggtitle("Slope at Wurzburg AOI")

# generate aspect
aspect <- terrain(DTM2, opt=c('aspect'), unit='degrees')
plot(aspect)
vIZ_parameter(aspect)+
  ggtitle("Slope at Wurzburg AOI")

# Select the first returns classified as ground

firstground = filter_poi(lidR_wurz2, Classification == 2L & ReturnNumber == 1L)
firstground
plot(firstground,bg = "white")

############## ~~Normalize the lidar data = Remove the topography
lidar_aoi2 <- lidR_wurz2
lidar_aoi2 <- normalize_height(lidar_aoi2, DTM2)
lidar_aoi2
plot(lidar_aoi2,bg = "white")
############## ~~ Filter pts clouds from the first return  classified as ground
lidar_aoi2 = lasfilter(lidar_aoi2, Classification != 2L & ReturnNumber == 1L)
lidar_aoi2
plot(lidar_aoi2,bg = "white")
############## ~~remove pts clouds lower then or eq to 0 
lidar_aoi2 <- filter_poi(lidar_aoi2, Z >= 0)
lidar_aoi2
plot(lidar_aoi2,bg = "white")
############## ~~generate the nDSM aka HAG
nDSM2 <- grid_canopy(lidar_aoi2, res = .1, p2r())
nDSM2
plot(nDSM2, main ="nDSM at Wurzburg AOI")

vIZ_parameter(nDSM2)+
  ggtitle("nDSM at Wurzburg AOI")+
  scale_fill_viridis_c(na.value="transparent",name="Height (m)")

############# Segmentation of normalized data : potential trees and buildings segmentation
lidar_seg2 <- lidar_aoi2 
lidar_seg2
lidar_seg2 <- segment_shapes(lidar_seg2, shp_plane(th1 = 25, th2 = 6, k = 64), "Coplanar")#k=174 when "-keep_random_fraction 0.3" 
lidar_seg2
seg_plot <- plot(lidar_seg2, color = "Coplanar",colorPalette = c("darkgreen", "red"),
     bg = "white",axis = TRUE)

str(lidar_seg2)

############# Buildings extraction : Here we filter the segmenated point cloud to take only the Coplanar == TRUE (classified as Buildings)
buildings = filter_poi(lidar_seg2, Coplanar == TRUE)
buildings
plot(buildings,bg = "white", axis=TRUE,color = "Coplanar",colorPalette = c("red"))

############# Automate the whole prpocess
automated_Seg(input = "./output_lidar/merged_lidar.laz",dtm = "dtm_lidR2.tif",  ndsm =  "nDSM_lidR2.tif")

########### 3Dviz with rLiDAR
# save the filtered data as .las
writeLAS(lidar_aoi2 , "./Output_lidar/lidar_filtered.las")

rLAS <- rLiDAR::readLAS("./Output_lidar/lidar_filtered.las",short=TRUE)

summary(rLAS)
str(rLAS)
df_rlas <- as.data.frame(rLAS)
df_rlas %>% 
  ggplot(aes(Z))+
  geom_histogram()

# Define the color ramp
# color ramp
myColorRamp <- function(colors, values) {
  v <- (values - min(values))/diff(range(values))
  x <- colorRamp(colors)(v)
  rgb(x[,1], x[,2], x[,3], maxColorValue = 255)
}

# Color by height
col <- myColorRamp(c("blue","green","yellow","red"),rLAS[,3])

# plot 2D
plot(rLAS[,1], rLAS[,2], col=col, xlab="UTM.Easting", ylab="UTM.Northing", main="Color by height")

# plot 3D
library("rgl")
points3d(rLAS[,1:3], col=col, axes=FALSE, xlab="", ylab="", zlab="")
axes3d(c("x+", "y-", "z-"))                     # axes
grid3d(side=c('x+', 'y-', 'z'), col="gray")     # grid
title3d(xlab = "UTM.Easting", ylab = "UTM.Northing",zlab = "Height(m)", col="red") # title
planes3d(0, 0, -1, 0.001, col="gray",alpha=0.7) # terrain