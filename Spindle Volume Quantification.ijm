//Spindle Volume Macro ImageJ

dir = getDirectory("Choose Source Directory with the .czi files:"); //get directory of .czi input files
list = getFileList(dir);  //to get a list of files in the given directory
output = dir+"SpindleSliceAreaResults"+File.separator;
File.makeDirectory(output); //creating a new directory to store area results of every embryo
setBatchMode(true);
index=0;  //initializing the index for iterating through the volume table
Table.create("SpindleVolumes"); //creating anew table to store volumes
//Setting measurements
run("Set Measurements...", "area mean min area_fraction limit redirect=None decimal=3");

for(i=0; i<list.length; i++){ //going through file list
  if(endsWith(list[i],".czi")){ //only open .czi files

    file=dir+File.separator+list[i];  //setting the path of the .czi files
    run("Bio-Formats Importer", "open="+file+" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    imageName=getTitle(); //get image name
    getVoxelSize(px, py, pz, unit); //get voxel calibration data
    //run("Subtract Background...", "rolling=50 stack");  //not in use

    run("Smooth", "stack"); //smoothen the image
    run("Split Channels");  //split the channels

    selectWindow("C1-"+imageName);  //selecting the red channel
    middleslice=round(nSlices/2); //get middle slice number
    setSlice(middleslice);  //set middle slice
    setAutoThreshold("Li dark"); //auto threshod the middle slice
    setOption("BlackBackground", false); //auto threshod the middle slice
    run("Convert to Mask", "method=Li background=Dark"); //auto threshod the middle slice (create a bianry mask with black and white)

    run("Measure Stack..."); //measure the black area in the stack

    sum=0; //initialize the area sum
    IJ.renameResults("Results"); //otherwise code below does not work...
    for (row=0; row<nResults; row++) {
    	sum = sum+getResult("Area", row);
    } //adding every slice area to the sum
    VOLUME=sum*pz;  //calculating the volume from the sum
    
    //saving the slice areas
    selectWindow("Results");
    saveAs("Results", output+imageName+"_SliceAreas.csv");

    //append the sum + filename to a table before moving onto the next image
    selectWindow("SpindleVolumes");
    Table.set("Filename",index,imageName);
    Table.set("Volume",index,VOLUME);

    close("*");
    run("Fresh Start"); //resets the results table
    index++;  //increases index by 1
    }
}
//save the measurements table in the output folder
saveAs("Results", dir+"SpindleVolumes.csv");
close("Results");
