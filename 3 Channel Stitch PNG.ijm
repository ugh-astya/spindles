//get source Directory and create an output directory called "RGB Combined"
dir = getDirectory("Choose Source Directory ");
list = getFileList(dir);
output = dir+"RGB Combined"+File.separator;
File.makeDirectory(output);
setBatchMode(true);

//iterate through the files in the directory and only open .czi files
for (i = 0; i < list.length; i++){
  if(endsWith(list[i],".czi")){
    input=dir+File.separator+list[i];
    run("Bio-Formats Importer", "open="+input+" autoscale color_mode=Colorized rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

    imageName = getTitle(); //get the name of the image
    C1="C1-MAX_"+imageName;
    C2="C2-MAX_"+imageName;
    C3="C3-MAX_"+imageName;

    //set scale = 100 microns for 10x images, for everything else, let it be 10
    if (matches(imageName, ".*10x.*")) {scale = 100;} else {scale = 10;};

    //Z projecting and then merging all 3 channels + scale bar
    run("Z Project...", "projection=[Max Intensity]");
    run("Split Channels");
    run("Merge Channels...", "c1=["+C1+"] c2=["+C2+"] c3=["+C3+"] create");
    run("Scale Bar...", "width="+scale+" height=45 thickness=4 font=14 color=White background=None location=[Lower Right] horizontal bold overlay"); //Scale bar for merge
    saveAs("JPEG",output+imageName+"_merge");
    close();

    //Separating the 3 channels to later combine them (stitching them side-by-side)
    selectWindow(imageName);
    run("Z Project...", "projection=[Max Intensity]");
    run("Scale Bar...", "width=10 height=45 thickness=4 font=14 color=White background=None location=[Lower Right] horizontal bold overlay"); //Scale bar for combined
    run("Split Channels");

    //Have to turn single channel images into RGB else all 3 combined channels look the same color
    selectWindow("C3-MAX_"+imageName);
    run("RGB Color");
    selectWindow("C2-MAX_"+imageName);
    run("RGB Color");
    selectWindow("C1-MAX_"+imageName);
    run("RGB Color");

    //Now stitching them side-by-side
    run("Combine...", "stack1=["+C1+"] stack2=["+C2+"]");
    run("Combine...", "stack1=[Combined Stacks] stack2=["+C3+"]");
    run("Scale Bar...", "width="+scale+" height=45 thickness=4 font=14 color=White background=None location=[Lower Right] horizontal bold overlay");

    //saving the output
    selectWindow("Combined Stacks");
    saveAs("PNG",output+imageName+"_combine");
    close("*");
  };
};
