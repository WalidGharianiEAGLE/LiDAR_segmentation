# This file is meant to generate a pdal pipeline able to output segmented Gound-Nongound point clouds las/las, DTM and DSM (tif)
# expected export format: laz/las ,tif files
# Version 1.0.0: 
# changes : initial script
# Author: Walid Ghariani

import sys
import pdal
import json

def pdal_processing(infile, filtertype, Gr_NGr_pts, dtm, dsm):
    ''' Point clouds proccessing pipeline to create a segmented 
    Args: 
        infile (str): input laz/las file
        Gr_NGr_pts (str): output laz/las file of segmented Gound-Nongound point clouds
        dtm (str): DTM tif file 
        dsm (str): DSM tif file
    '''
    pipe_Gound_nongound =\
    {
        "pipeline":[
            "./output_lidar/"+infile,
            {
                "type":"filters.elm",
                "threshold":2.0
            },
            {
                "type":"filters.outlier",
                "method":"statistical",
                "mean_k":8,
                "multiplier":2
            },
            {
                "type":"filters."+filtertype
            },
            {
                "type":"filters.hag"
            },
            {
                "filename":"./output_lidar/"+Gr_NGr_pts,
                "extra_dims":"all"
            }
        ]
    }
    pipe_featuresDTM =\
    {
        "pipeline":[
            "./output_lidar/"+infile,
            {
                "type":"filters.elm",
                "threshold":2.0
            },
            {
                "type":"filters.outlier",
                "method":"statistical",
                "mean_k":8,
                "multiplier":2
            },
            {
                "type":"filters."+filtertype
            },
            {
                "type":"filters.hag"
            },
            {
                "type":"filters.range",
                "limits":"Classification[2:2]"
            },
            {
                "type":"writers.gdal",
                "filename":"./output_lidar/"+dtm,
                "output_type":"min",
                "gdaldriver":"GTiff",
                "window_size":3,
                "resolution":0.1
            }
        ]
    }
    pipe_featuresdsm =\
    {
        "pipeline":[
            "./output_lidar/"+infile,
            {
                "type":"filters.elm",
                "threshold":2.0
            },
            {
                "type":"filters.outlier",
                "method":"statistical",
                "mean_k":8,
                "multiplier":2
            },
            {
                "type":"filters."+filtertype
            },
            {
                "type":"filters.hag"
            },
            {
                "type":"filters.range",
                "limits":"Classification[1:1]"
            },
            {
                "type":"writers.gdal",
                "filename":"./output_lidar/"+dsm,
                "output_type":"min",
                "gdaldriver":"GTiff",
                "window_size":3,
                "resolution":0.1
            }
        ]
    }
    # Ground - NonGround Segmentation
    print("-----> Ground - NonGround Segmentation output file Processing: In progress")
    pipelineGNG = pdal.Pipeline(json.dumps(pipe_Gound_nongound))
    pipelineGNG.validate()
    count = pipelineGNG.execute()
    print("-----> Ground - NonGround Segmentation output file Processing: Done")
    data = pipelineGNG.arrays[0]
    metadata = pipelineGNG.metadata
    print('processed', count, 'points with', len(data.dtype), 'dimensions')
    print('Dimension names are', data.dtype.names)
    
    # Generate DTM
    print("-----> Generating DTM: In progress")
    pipelineDTM = pdal.Pipeline(json.dumps(pipe_featuresDTM))
    pipelineDTM.validate()
    pipelineDTM.execute()
    print("-----> Generating DTM: Done")
   
    # Generate dsm
    print("-----> Generating DSM: In progress")
    pipelinedsm = pdal.Pipeline(json.dumps(pipe_featuresdsm))
    pipelinedsm.validate()
    pipelinedsm.execute()
    print("-----> Generating DSM: Done")

def main() :
    infile = sys.argv[1]
    filtertype = sys.argv[2]
    Gr_NGr_pts = sys.argv[3]
    dtm = sys.argv[4]
    dsm = sys.argv[5]
    pdal_processing(infile, filtertype, Gr_NGr_pts, dtm, dsm)
    
if __name__ == "__main__":
    main()