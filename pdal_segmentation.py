# This file is meant to generate segmented point coulds as buildings and trees (laz/las)
# expected export format: laz/las file
# Version 1.0.0: 
# changes : initial script
# Author: Walid Ghariani

import sys
import pdal
import json

def pdal_seg(infile, filtertype, segmented_pts):
    ''' Point clouds proccessing pipeline to create a segmented 
    Args: 
        infile (str): input laz/las file
        segmented_pts (str): output laz/las file of Segmenetation using Approximate Coplanar Filter
    '''
    pipe_Seg =\
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
                "filename":"./output_lidar/"+segmented_pts,
                "extra_dims":"all"
            }
        ]
    }
    # HAG Segmenetation using Approximate Coplanar Filter
    print("-----> Approximate Coplanar Filter Segmentation Processing: In progress")
    pipelineSeg = pdal.Pipeline(json.dumps(pipe_Seg))
    pipelineSeg.validate()
    count = pipelineSeg.execute()
    print("-----> Approximate Coplanar Filter Segmentation Processing: Done")

def main() :
    infile = sys.argv[1]
    filtertype = sys.argv[2]
    segmented_pts = sys.argv[3]
    pdal_seg(infile, filtertype, segmented_pts)
    
if __name__ == "__main__":
    main()