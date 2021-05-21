# This file is meant to extract point clouds classified as Buildings (laz/las)
# expected export format: laz/las file
# Version 1.0.0: 
# changes : initial script
# Author: Walid Ghariani

import sys
import pdal
import json

def buildings_extraction(infile, filtertype, extract_Buildings):
    ''' Point clouds proccessing pipeline to create a segmented 
    Args: 
        infile (str): input laz/las file
        segmented_pts (str): output laz/las file of Segmenetation using Approximate Coplanar Filter
        extract_Buildings (str): output las/las file of extracted buildings 
    '''
    pipe_Build =\
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
                "type":"filters.approximatecoplanar",
                "knn":64,
                "thresh1":25,
                "thresh2":6
            },
            {
                "type":"filters.range",
                "limits":"Coplanar[1:1]"
            },
            {
                "filename":"./output_lidar/"+extract_Buildings,
                "extra_dims":"all"
            }
        ]
    }
    # Buildings extraction
    print("-----> Extracting Buildings point clouds: In progress")
    pipelineBuildings = pdal.Pipeline(json.dumps(pipe_Build))
    pipelineBuildings.validate()
    pipelineBuildings.execute()
    print("-----> Extracting Buildings point clouds: Done")


def main() :
    infile = sys.argv[1]
    filtertype = sys.argv[2]
    extract_Buildings = sys.argv[3]
    buildings_extraction(infile,filtertype, extract_Buildings)
    
if __name__ == "__main__":
    main()