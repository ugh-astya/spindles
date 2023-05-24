//Spindle Width Macro
//Befroe running make sure you have an ROI already made that is centered on where the spindle equator would be.

dir = getDirectory("Choose Source Directory with the .tif files:"); //get directory of z-projected .tif input files
list = getFileList(dir);  //to get a list of files in the given directory
output = dir+"Spindle Width Results"+File.separator; //Specifying output directory
File.makeDirectory(output); //creating a new directory to store width results of every cell

//setBatchMode(true);

run("ROI Manager..."); //starting roi manager
roipath="D:/MSThesis/Confocal_Images/15x50rectangle.roi" //specifying the roi path
//roiManager("Open", roipath); //opening the roi path in roi manager
Table.create("Spindle Width"); //creating a spindle width table to store the values
index=0; //initializing the index for the spindle width table

//iterate through the files in the directory and only open .tif files
for (i = 0; i < list.length; i++){

    input=dir+list[i]; //specifying the input path

    if(endsWith(input, ".tif") && matches(list[i], ".*63x.*")) { //checking if the input file is a .tif file or not

      open(input);
      imageName = getTitle(); //get the name of the image

	  //print("check1");

      run("Split Channels");
      C1="C1-"+imageName;
      C2="C2-"+imageName;
      C3="C3-"+imageName;

	  //print("check2");

      selectWindow(C1); //selecting the spindle channel window

      //print("check3");

      roiManager("Open", roipath); //opening the roi path in roi manager
      roiManager("Select", 0); //overlaying the roi on spindle channel

      //print("check4");

	  run("Plots...", "width=600 height=340 font=14 draw_ticks minimum=0 maximum=0 vertical interpolate"); //specifying the setting to plot vertically
      run("Plot Profile");

      //print("check5");

      run("Fit Polynomial", "polynomial=12 degree=2-40 guess");

      //print("check6");

      Plot.showValues("Plot Values"); //initializing the fit polynomial values table
      selectWindow(C1); //selecting the spindle channel
      setAutoThreshold("Otsu dark"); //thresholding
	  getThreshold(lower,upper); //retrieving the threshold value

      //print("check6.2");

      //saving the plot values table with threshold values
      selectWindow("Plot Values"); //selecting the polynomial fit values table
      IJ.renameResults("Plot Values","Results"); //renaming the values table to results for further operations
      selectWindow("Results"); //selecting the newly renamed results table
      y1array=Table.getColumn("Y1");
      Array.getStatistics(y1array, min, max, mean, std);
      //middlevalue=getResult("Y1",(nResults/2));
      
      if(max-lower>20){//the condition to use Otsu thresholding is if the maximum dapi value and the threshold lower limit have a difference of greater than 20 
      temp=nResults;
      Table.set("X0",nResults,"Threshold"); //creating an entry for the threshold value
      Table.set("Y1",nResults-1,lower); //enumerating the threshold value
      saveAs("Results", output+imageName+"_Spindle-Plot.csv"); //saving the values table with the threshold values for debugging

      setOption("ExpandableArrays", true); //so that i can specify an array without knowing its size
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
      Array.print(xtemp);

      low=xtemp[0]; //start of the width
      high=xtemp[xtemp.length-2]; //end of the width
	  spindlewidth=high-low; //difference is the spindle width
	  print(spindlewidth);
      } else {
      selectWindow(C1); //selecting the spindle channel
      setAutoThreshold("Triangle dark"); //thresholding
	  getThreshold(lower,upper); //retrieving the threshold value
	  selectWindow("Results");
	  Table.set("X0",nResults,"Threshold"); //creating an entry for the threshold value
      Table.set("Y1",nResults-1,lower); //enumerating the threshold value
      saveAs("Results", output+imageName+"_Spindle-Plot.csv"); //saving the values table with the threshold values for debugging
      setOption("ExpandableArrays", true); //so that i can specify an array without knowing its size
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
      Array.print(xtemp);
      low=xtemp[0]; //start of the width
      high=xtemp[xtemp.length-2]; //end of the width
	  spindlewidth=high-low; //difference is the spindle width
	  print(spindlewidth);
      } //else block ends


      //appending values to the spindle width table
      selectWindow("Spindle Width");
      Table.set("Filename",index,imageName);
      Table.set("Spindle Width",index,spindlewidth);

      close("*");
      //run("Fresh Start");
      close("ROI Manager","keep");
      print("check7");
      //close("*");
      index++;
      }}

      //saving the spindle width table
      selectWindow("Spindle Width");
      saveAs("Results", dir+"Spindle Width.csv");
	  close("Results");
