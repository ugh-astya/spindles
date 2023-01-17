//Spindle Volume Macro ImageJ
//get directory of files
dir = getDirectory("Choose Source Directory with the .czi files:");
list = getFileList(dir);
output = dir+"AreaResults"+File.separator;
File.makeDirectory(output);
setBatchMode(true);
index=0;
Table.create("Volumes");
//Setting measurements
run("Set Measurements...", "area mean min area_fraction limit redirect=None decimal=3");
//going through file list and opening only the czi files
for(i=0; i<list.length; i++){
  if(endsWith(list[i],".czi")){
    file=dir+File.separator+list[i];
    run("Bio-Formats Importer", "open="+file+" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	//get imageName
    imageName=getTitle();
    getVoxelSize(px, py, pz, unit);
    //run("Subtract Background...", "rolling=50 stack");
    //smooth and split the channels
    run("Smooth", "stack");
    run("Split Channels");
    //selecting the red channel
    selectWindow("C1-"+imageName);
    //auto threshold at the middle slice
    middleslice=round(nSlices/2);
    setSlice(middleslice);
    setAutoThreshold("Li dark");
    setOption("BlackBackground", false);
    run("Convert to Mask", "method=Li background=Dark");
    //measure the binary mask
    run("Measure Stack...");
    //add all the areas
    sum=0;
    IJ.renameResults("Results"); // otherwise below does not work...
    for (row=0; row<nResults; row++) {
    	sum = sum+getResult("Area", row);
    }
    VOLUME=sum*pz;
    //append the sum + filename to a table before moving onto the next image
    selectWindow("Volumes");
    Table.set("Filename",index,imageName);
    Table.set("Volume",index,VOLUME);
    close("*");
    run("Fresh Start");
    index++;
    }
}
//save the measurements table in the output folder
saveAs("Results", dir+"Volumes.csv");
close("Results");
