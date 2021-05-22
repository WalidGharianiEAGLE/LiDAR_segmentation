# LiDAR Segmentation

Sets of python scripts for lidar data processing with batsh processing 
## Python Dependencies
```
* pdal
* json 
```
#### Main processing 

1. `pdal_merge.py`
   * Merge multiple las files and handle invalid ReturnNumber/NumberOfReturns into a single (las/laz) file
   * `python pdal_merge.py <mergedfile>` 
   * Example `python pdal_merge.py merged_lidar.laz`

2. `pdal_segmentation.py`
   * Generate segmented point coulds as buildings and trees (laz/las)
   * `python pdal_segmentation.py <infile> <filtertype> <segmented_pts>` 
   * Example `python pdal_segmentation.py merged_lidar_10percent.laz csf segmented_pts.laz` 
 
3. `buildings_extraction.py`
   * Extract point clouds classified as Buildings (laz/las)
   * `python buildings_extraction.py <infile> <filtertype> <extract_Buildings>` 
   * Example `buildings_extraction.py merged_lidar_10percent.laz csf extract_Buildings.laz` 


#### Extra processing 
1. `pdal_pipeline.py`
   * Generate a pdal pipeline able to output segmented Gound-Nongound point clouds las/las, DTM and DSM (tif)
   * `python pdal_pipeline.py <infile> <filtertype> <Gr_NGr_pts> <dtm> <dsm>` 
   * Example `python pdal_pipeline.py merged_lidar_10percent.laz csf Gr_NGr_csf.laz dtm_pdal.tif dsm_pdal.tif`

2. `pdal_FirstReturns`
   * Generate first returns point clouds (laz/las)
   * `python pdal_FirstReturns.py <filtertype> <first_returns>` 
   * Example `python pdal_FirstReturns.py csf first_returns.laz`

#### lidR capabilities
`lidR_funcrtions` include different functions for point clouds manipulation, vizualisation and an automated processing chain with lidR

## Author

* **Walid Ghariani** - *MSc. Student*  [Applied Earth Observation and Geoanalysis (EAGLE)](http://eagle-science.org/) [linkedin](https://www.linkedin.com/in/walid-ghariani-893365138/) E-mail: walid.ghariani@stud-mail.uni-wuerzburg.de
