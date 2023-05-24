//Spindle Volume Macro ImageJ
//this uses the raw .czi files. no roi required.
dir = getDirectory("Choose Source Directory with the .czi files:"); //get directory of .czi input files
list = getFileList(dir);  //to get a list of files in the given directory
output = dir+"CentrosomeSliceAreaResults"+File.separator; //string denoting the output location
File.makeDirectory(output); //creating a new directory to store area results of every embryo
setBatchMode(true);
index=0;  //initializing the index for iterating through the volume table
Table.create("CentrosomeVolumes"); //creating a new table to store volumes
//Setting measurements
run("Set Measurements...", "area mean min area_fraction limit redirect=None decimal=3");

//Creating a loop to go through "list" and open only .czi files and files that have "63x" in their name
for(i=0; i<list.length; i++){
  if(endsWith(list[i],".czi")&& matches(list[i], ".*63x.*")){ //only open .czi and 63x files

    file=dir+File.separator+list[i];  //setting the path of the .czi files
    run("Bio-Formats Importer", "open="+file+" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"); //opening the image
    imageName=getTitle(); //get image name
    getVoxelSize(px, py, pz, unit); //get voxel calibration data

    run("Smooth", "stack"); //smoothen the image
    run("Split Channels");  //split the channels

    selectWindow("C2-"+imageName);  //selecting the green channel
    middleslice=round(nSlices/2); //get middle slice number
    setSlice(middleslice);  //set middle slice

    setAutoThreshold("Triangle dark stack"); //Thresholding using Triangle algorithm, using the complete stack histogram
    setOption("BlackBackground", false); //auto threshold the middle slice
    run("Convert to Mask", "method=Triangle background=Dark"); //auto threshold the middle slice (create a binary mask with black and white)
    run("Measure Stack..."); //measure the black area in the stack

    sum=0; //initialize the area sum
    IJ.renameResults("Results"); //renaming required, otherwise the code below does not work...
    for (row=0; row<nResults; row++) {
    	sum = sum+getResult("Area", row);
    } //adding every slice area to the sum
    VOLUME=sum*pz;  //calculating the volume from the sum by multiplying by the z-distance (pz)

    //saving the slice areas
    selectWindow("Results");
    saveAs("Results", output+imageName+"_SliceAreas.csv");

    //append the sum + filename to the centrosome table (created at the start) before moving onto the next image
    selectWindow("CentrosomeVolumes");
    Table.set("Filename",index,imageName);
    Table.set("CentrosomeVolume",index,VOLUME);

    close("*");
    run("Fresh Start"); //resets the results table
    index++;  //increases index by 1
    }
}
//save the measurements table in the output folder
saveAs("Results", dir+"CentrosomeVolumes(Triangle stack).csv");
close("Results");
