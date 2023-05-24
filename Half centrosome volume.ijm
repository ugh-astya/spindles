//Spindle Half-Volume Macro ImageJ

dir = getDirectory("Choose Source Directory with the .czi files:"); //get directory of .czi input files
list = getFileList(dir);  //to get a list of files in the given directory
output = dir+"CentrosomeHalfSliceAreaResults"+File.separator;
File.makeDirectory(output); //creating a new directory to store area results of every embryo
setBatchMode(true);
index=0;  //initializing the index for iterating through the volume table
Table.create("HalfCentrosomeVolumes"); //creating anew table to store volumes
//Setting measurements
run("Set Measurements...", "area mean min area_fraction limit redirect=None decimal=3");

for(i=0; i<list.length; i++){ //going through file list
  if(endsWith(list[i],".czi")&& matches(list[i], ".*63x.*")){ //only open .czi and 63x files

    file=dir+File.separator+list[i];  //setting the path of the .czi files
    run("Bio-Formats Importer", "open="+file+" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    imageName=getTitle(); //get image name
    getVoxelSize(px, py, pz, unit); //get voxel calibration data
    //run("Subtract Background...", "rolling=50 stack");  //not in use

    run("Smooth", "stack"); //smoothen the image
    run("Split Channels");  //split the channels

    selectWindow("C2-"+imageName);  //selecting the red channel
    middleslice=round(nSlices/2); //get middle slice number
    setSlice(middleslice);  //set middle slice
    setAutoThreshold("Triangle dark stack");
    setOption("BlackBackground", false); //auto threshod the middle slice
    run("Convert to Mask", "method=Triangle background=Dark"); //auto threshod the middle slice (create a bianry mask with black and white)

    //extra steps for half volume calculation (compared to normal volume calculation, rest of the code is the same)
  run("ROI Manager...");
	roiManager("Open", "D:/MSThesis/Confocal_Images/Left HALF ROI.roi");//this opens the ROI that covers left half of the image inside which the area will be measured and volume calculated.
	roiManager("Select", 0);
      //extra steps over

    run("Measure Stack..."); //measure the black area in the stack

    sum=0; //initialize the area sum
    IJ.renameResults("Results"); //otherwise code below does not work...
    for (row=0; row<nResults; row++) {
    	sum = sum+getResult("Area", row);
    } //adding every slice area to the sum
    LEFTVOLUME=sum*pz;  //calculating the volume from the sum

    //saving the slice areas
    selectWindow("Results");
    saveAs("Results", output+imageName+"_leftSliceAreas.csv");

    //append the sum + filename to a table before moving onto the next image
    selectWindow("HalfCentrosomeVolumes");
    Table.set("Filename",index,imageName);
    Table.set("HalfCentrosomeVolume",index,LEFTVOLUME);

    close("*");
    run("Fresh Start"); //resets the results table
    index++;  //increases index by 1
    }
}
//save the measurements table in the output folder
saveAs("Results", dir+"LeftCentrosomeVolumes(Triangle stack).csv");
close("Results");
