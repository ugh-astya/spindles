//Spindle Width Macro
//This macro uses 3 channel images, where each channel has been max-intensity projected and saved as a .tif file

dir = getDirectory("Choose Source Directory with the .tif files:"); //get directory of z-projected .tif input files
list = getFileList(dir);  //to get a list of files in the given directory
output = dir+"DAPI Width Results"+File.separator; //Specifying output directory
File.makeDirectory(output); //creating a new directory to store width results of every cell

run("ROI Manager..."); //starting roi manager
roipath="D:/MSThesis/Confocal_Images/15x50rectangle.roi" //specifying the roi path
//This ROI is a 15x50 rectangle that is centered on the image along x and y axis. You can create your own ROI and specify the path here.
Table.create("DAPI Width"); //creating a dapi width table to store the values
index=0; //initializing the index for the dapi width table

//iterate through the files in the directory and only open .tif and 63x files
for (i = 0; i < list.length; i++){

    input=dir+list[i]; //specifying the input path

    if(endsWith(input, ".tif") && matches(list[i], ".*63x.*")) { //checking if the input file is a .tif file and 63x or not

      open(input);
      imageName = getTitle(); //get the name of the image

	  //print("check1");

      run("Split Channels"); //splitting channels
      C1="C1-"+imageName; //Saving channel 1 name (red) in C1
      C2="C2-"+imageName; //Saving channel 2 name (green) in C2
      C3="C3-"+imageName; //Saving channel 3 name (blue) in C3
	  //print("check2");
      selectWindow(C3); //selecting the dapi channel window
      //print("check3");
      roiManager("Open", roipath); //opening the roi path in roi manager
      roiManager("Select", 0); //overlaying the roi on dapi channel
      //print("check4");
	  run("Plots...", "width=600 height=340 font=14 draw_ticks minimum=0 maximum=0 vertical interpolate"); //specifying the plot settings to plot vertically
      run("Plot Profile");
      //print("check5");
      run("Fit Polynomial", "polynomial=12 degree=2-40 guess"); //Use the BAR plugin function fit polynomial to the plot profile
      windowname=split(C3,".");
      plotwindow="Polynomial fit Plot of "+windowname[0];
      //print("check6");
      Plot.showValues("Plot Values"); //initializing and creating the fit polynomial values table
      selectWindow(C3); //selecting the dapi channel
      setAutoThreshold("Triangle dark"); //thresholding
	  getThreshold(lower,upper); //retrieving the threshold values
      //print("check6.2");
      //saving the plot values table with threshold values
      selectWindow("Plot Values"); //selecting the polynomial fit values table
      IJ.renameResults("Plot Values","Results"); //renaming the values table to results for further operations
      selectWindow("Results"); //selecting the newly renamed results table
      middlevalue=getResult("Y1",(nResults/2)); //getting the middle value of the plot table (Value around the DAPI peak)

      //if the middle value is greater than the lower traingle threshold value, go ahead and save it in the table and find the width
      if(middlevalue>lower){

      Table.set("X0",nResults,"Threshold"); //creating an entry for the threshold value
      Table.set("Y1",nResults-1,lower); //concatenating the threshold value
      saveAs("Results", output+imageName+"_DAPI-Plot.csv"); //saving the values table with the triangle threshold values for debugging

      setOption("ExpandableArrays", true); //allows dynamic array allocation (means we can set aside an unspecified amount of space in the memory for an array that we might create in the future)
      xtemp=newArray; //creating an array to store x values that lie above the threshold (its a dynamic array, ie its size can be allocated later as well

      counter=0; //initializing array counter

      //running a loop to iterate over the results table and append the x values above threshold to an array
      for (row = 0; row < nResults; row++) {
      	xp=getResult("X0", row);
      	yp=getResult("Y1", row);
      	if(yp>=lower){
      		xtemp[counter]=xp; //appending the x values to the array xtemp specified earlier
      		counter++;
      	}
      }
      Array.print(xtemp); //this array has all the x-values where the DAPI value is more than the threshold

      low=xtemp[0]; //start of the width
      high=xtemp[xtemp.length-2]; //end of the width
	  dapiwidth=high-low; //difference is the dapi width
	  print(dapiwidth);
  } else {//if the middle value is less than the lower triangle threshold, we should use Mean thresholding to find the width. the rest of the code is same
      	selectWindow(C3); //selecting the spindle channel
      setAutoThreshold("Mean dark"); //thresholding using mean
	  getThreshold(lower,upper); //retrieving the threshold value
	  selectWindow("Results");
	  Table.set("X0",nResults,"Threshold"); //creating an entry for the threshold value
      Table.set("Y1",nResults-1,lower); //enumerating the threshold value
      saveAs("Results", output+imageName+"_Spindle-Plot.csv"); //saving the values table with the threshold values for debugging
      setOption("ExpandableArrays", true);
      xtemp=newArray; //creating an array to store x values that lie above the threshold
      counter=0; //initializing array counter
      //running a loop to iterate over the results table and append the x values above threshold to an array
      for (row = 0; row < nResults; row++) {
      	xp=getResult("X0", row);
      	yp=getResult("Y1", row);
      	if(yp>=lower){
      		xtemp[counter]=xp; //appending the x values
      		counter++;
      		}
      	}
      Array.print(xtemp);//this array contains the x values above the mean threshold lower value

      low=xtemp[0]; //start of the width
      high=xtemp[xtemp.length-2]; //end of the width
	  dapiwidth=high-low; //difference is the spindle width
	  print(dapiwidth);
      }


      //appending values to the dapi width table
      selectWindow("DAPI Width");
      Table.set("Filename",index,imageName);
      Table.set("DAPI Width",index,dapiwidth);

      close("*");
      //run("Fresh Start");
      close("ROI Manager","keep");
      //print("check7");
      index++;
      }}

      //saving the dapi width table
      selectWindow("DAPI Width");
      saveAs("Results", dir+"DAPI Width.csv");
	  close("Results");
