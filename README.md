# spindles

This is my online repository for all the code I've written during my MS Thesis at Vertebrate Embryogenesis Lab at IIT Bombay. They are mostly ImageJ macros which run on 3 channel images.

The volume code needs to run on 3 channel .czi files with stacks.

The spindle width and dapi width code can run on z-projected 3 channel images. Make sure you have an ROI of 15x50 (or whatever size is required)
pixels centered along the x and y axis on the image. The profile will be plotted vertically along this ROI.
 
Centrosome volume quantification, DAPI width, Half volume centrosome macro, C2C macro files have commented directions for use. The other macros build on these basic macros. Please go through the above mentioned files and their comments to understand how the macro works. The same process is used in the other macros.
