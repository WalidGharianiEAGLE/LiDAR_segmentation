# This file is meant to merge multiple las files and handle invalid ReturnNumber/NumberOfReturns into a single (las/laz) file
# expected export format: laz/las file
# Version 1.0.0: 
# changes : initial script
# Author: Walid Ghariani

import sys
import pdal
import json

def merge_pts(mergedfile):
    ''' Point clouds proccessing pipeline to create a segmented 
    Args: 
        mergedfile (str): output laz/las file for the merged point clouds

    '''
    pipe_merge =\
    {
        "pipeline":[
            "input_lidar/laser_1_2021-02-25-10-13-37_344_RemoveOutliers.las",
            "input_lidar/laser_1_2021-02-25-10-13-37_392_RemoveOutliers.las",
            "input_lidar/laser_1_2021-02-25-10-13-37_608_RemoveOutliers.las",
            "input_lidar/laser_1_2021-02-25-10-13-37_704_RemoveOutliers.las",
           {
		        "type": "filters.merge"
            },
            {
                "type":"filters.assign","assignment":"NumberOfReturns[:]=1"
            },
        	{
		        "type":"filters.assign","assignment":"ReturnNumber[:]=1"
	        },
            {
                "type":"writers.las",
		        "filename":"./input_lidar/"+ mergedfile
            }
        ]
    }
    # Generate DTM
    print("-----> Merging las/laz files : In progress")
    pipelineMerge = pdal.Pipeline(json.dumps(pipe_merge))
    pipelineMerge.validate()
    pipelineMerge.execute()
    print("-----> Merging las/laz files: Done")

def main() :
    mergedfile = sys.argv[1]
    merge_pts(mergedfile)
    
if __name__ == "__main__":
    main()