# version 1.0.0 : testing
# Author : Walid Ghariani

# Function for extracting a percentage of the point clouds 

fractionPts <- function (input,percent){ 
  ptc <- paste("-keep_random_fraction",percent, sep =" ")
  readPts <- lidR::readLAS(input,
                            filter = "-keep_random_fraction 0.1",
                            select = "xyzrn")
  return(readPts)
}
  
  
# function for cross plotting
plot_crossection <- function(las,
                             p1 = c(min(las@data$X), mean(las@data$Y)),
                             p2 = c(max(las@data$X), mean(las@data$Y)),
                             width = 4, colour_by = NULL,
                             title)
{
  colour_by <- enquo(colour_by)
  data_clip <- clip_transect(las, p1, p2, width)
  p <- ggplot(data_clip@data, aes(X,Z)) +
    geom_point(size = 0.5) + 
    coord_equal() + 
    theme_minimal()+
    theme(plot.title = element_text(hjust = 0.5))+
    ggtitle(title)+
    labs(x="Longitude", y="N")
  
  
  if (!is.null(colour_by))
    p <- p + aes(color = !!colour_by) + labs(color = "")
  
  return(p)
}

# function for raster vizualisation
vIZ_parameter<- function(parameter){
  parameter %>% 
    gplot() +
    geom_raster(aes(x=x, y=y, fill=value))+
    scale_fill_viridis_c(na.value="transparent")+
    coord_equal()+
    theme(text = element_text(size = 12),
          plot.title = element_text(hjust = 0.5),
          panel.grid = element_blank())+
    labs(x="Longitude", y="Latitude")+
    annotation_scale(location = "bl", width_hint = 0.3, height = unit(0.1, "cm"),
                     pad_x = unit(0.4, "cm"), pad_y = unit(.15, "cm"))
  
}

# function for lidR automated segmentation
automated_Seg <- function (input, dtm, ndsm){
  lidR_wurz <- lidR::readLAS(input,
                             filter = "-keep_random_fraction 0.1",
                             select = "xyzrn")
  mycsf <-  csf(rigidness = 3, cloth_resolution = 1)
  lidR_wurz <- classify_ground(lidR_wurz, mycsf)
  DTM = grid_terrain(lidR_wurz,  res = .1,algorithm = knnidw(k = 6L, p=2))
  dtm_output <- paste("./output_lidar/",dtm, sep ="")
  writeRaster(DTM , dtm_output)
  lidar_aoi <- lidR_wurz
  lidar_aoi <- normalize_height(lidar_aoi, DTM)
  lidar_aoi = lasfilter(lidar_aoi, Classification != 2L & ReturnNumber == 1L)
  lidar_aoi <- filter_poi(lidar_aoi, Z >= 0)
  nDSM <- grid_canopy(lidar_aoi, res = .1, p2r())
  ndsm_output <- paste("./output_lidar/",ndsm, sep ="")
  writeRaster(nDSM , ndsm_output)
  lidar_seg <- lidar_aoi 
  lidar_seg <- segment_shapes(lidar_seg, shp_plane(th1 = 25, th2 = 6, k = 64), "Coplanar")
  plot(lidar_seg,bg = "white", axis=TRUE, color = "Coplanar",colorPalette = c("darkgreen", "red"))
  buildings = filter_poi(lidar_seg, Coplanar == TRUE)
  plot(buildings,bg = "white", axis=TRUE,color = "Coplanar",colorPalette = c("red"))
}
