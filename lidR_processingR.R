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

############# Automate the whole prpocess
automated_Seg(input = "./input_lidar/merged_lidar.laz",dtm = "dtm_lidR.tif",  ndsm =  "nDSM_lidR.tif")

########### 3Dviz with rLiDAR
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