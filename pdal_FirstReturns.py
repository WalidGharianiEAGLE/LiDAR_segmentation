# This file is meant to generate first returns point clouds (laz/las)
# expected export format: laz/las file
# Version 1.0.0: 
# changes : initial script
# Author: Walid Ghariani

import sys
import pdal
import json

def pdal_FirstReturns(infile, filtertype, first_returns):
    ''' Point clouds proccessing pipeline to create a segmented 
    Args: 
        infile (str): input laz/las file
        Gr_NGr_pts (str): output laz/las file of segmented Gound-Nongound point clouds
        dtm (str): DTM tif file 
        dsm (str): DSM tif file
    '''
    pipe_firstreturns =\
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
                "filename":"./output_lidar/"+first_returns,
                "extra_dims":"all"
            }
        ]
    }

    # Generate DTM
    print("-----> Generating first return: In progress")
    pipelineFR = pdal.Pipeline(json.dumps(pipe_firstreturns))
    pipelineFR.validate()
    pipelineFR.execute()
    print("-----> Generating first returns: Done")

def main() :
    infile = sys.argv[1]
    filtertype = sys.argv[2]
    first_returns = sys.argv[3]
    pdal_FirstReturns(infile, filtertype, first_returns)
    
if __name__ == "__main__":
    main()