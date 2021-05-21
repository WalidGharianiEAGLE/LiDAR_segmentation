# Processing    : Postprocessing of pdal bash processing pipeline for Vizualisation purposes with lidR
# version 1.0.0 : testing
# Author : Walid Ghariani

library(lidR)
library(rasterVis)
library(ggspatial)
library(dplyr)
library(ggplot2)
source("lidR_functions.R")

############## ~~ Reading the merged files and extrat a percentage of point clouds
pct_data <-  fractionPts("./input_lidar/merged_lidar.laz",.1)
pct_data
plot(pct_data,bg = "white")
# write the output to be processed with pdla pipeline:
# Notee: adjust the percetnt in fractionPts() according to your requirements will require to adapt the parameters for "filters.approximatecoplanar"

writeLAS(pct_data, "./output_lidar/merged_lidar_10percent.laz")
############## ~~ Viz Ground-NonGroung segmentation
# 1. data processed with CSF
Gr_NGr_csf<- lidR::readLAS("./output_lidar/Gr_NGr_csf.laz")
Gr_NGr_csf
str(Gr_NGr_csf)
plot(Gr_NGr_csf, bg = "white", color = "Classification")

p1 <- c(570300, 5515400)
p2 <- c(570200, 5515400)

plot_crossection(Gr_NGr_csf, p1 = p1, p2 = p2, 
                 colour_by = factor(Classification),
                 title = "Cloth Simulation Filter")

# 2.data processed with pmf
Gr_NGr_pmf<- lidR::readLAS("./output_lidar/Gr_NGr_pmf.laz")
Gr_NGr_pmf
str(Gr_NGr_pmf)
plot(Gr_NGr_pmf, bg = "white", color = "Classification")

p1 <- c(570300, 5515400)
p2 <- c(570200, 5515400)

plot_crossection(Gr_NGr_pmf, p1 = p1, p2 = p2, 
                 colour_by = factor(Classification),
                 title = "Progressive Morphological Filter")

############## ~~VIZ the DTM
DTM_pdal <- raster("./output_lidar/dtm_pdal.tif")
DTM_pdal
vIZ_parameter(DTM_pdal)+
  ggtitle("DTM at Wurzburg AOI")

############## ~~VIZ the DSM
DSM_pdal <- raster("./output_lidar/dsm_pdal.tif")
DSM_pdal
vIZ_parameter(DSM_pdal)+
  ggtitle("DSM at Wurzburg AOI")+
  scale_fill_viridis_c(na.value="transparent")

############## ~~VIZ "segmented_pts.laz" processed using Approximate Coplanar Filter Segmentation:
# potential trees and buildings segmentation
segmented_pts<- lidR::readLAS("./output_lidar/segmented_pts.laz")
segmented_pts
str(segmented_pts)
plot(segmented_pts, color = "Coplanar",colorPalette = c("darkgreen", "red"),bg = "white")
plot(segmented_pts,bg = "white")

############# Buildings extraction 
extract_Buildings <- lidR::readLAS("./output_lidar/extract_Buildings.laz")
extract_Buildings 
plot(extract_Buildings ,bg = "white", color = "Coplanar",colorPalette = c("red"))
