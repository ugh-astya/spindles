//C2C length macro
//For this to work, you must already have .tif files with each channel z-projected.
//The .tif files also need to have a line ROI/spline (15 pixels) going through the 2 centrioles of the image, along which the plot need to be calculated to identify the centrioles.

dir = getDirectory("Choose Source Directory with the .tif files:"); //get directory of z-projected .tif input files
list = getFileList(dir);  //to get a list of files in the given directory
run("Set Measurements...", "area mean standard min bounding area_fraction limit redirect=None decimal=3");
Table.create("C2C length"); //creating a c2c width table to store the values
index=0; //initializing the index for the c2c width table
setOption("ExpandableArrays", true); //so that i can specify an array without knowing its size
      namelist=newArray;
for (i = 0; i < list.length; i++){

    input=dir+list[i]; //specifying the input path

    if(endsWith(input, ".tif") && matches(list[i], ".*63x.*")) { //checking if the input file is a .tif file and 63x or not

      open(input);
      imageName = getTitle(); //get the name of the image
      selectWindow(imageName);
      //creating an array to store imagename values
      Stack.setChannel(2); //set the channel to green channel
      run("Plot Profile"); //plot the profile of the spline
		run("Find Peaks"); //plot the peaks of the green channel (centrioles will show up as peaks. Not the highest peaks always.
		selectWindow(imageName);
		run("ROI Manager...");
		roiManager("Add");
		run("Split Channels");
		C1="C1-"+imageName;
      	C2="C2-"+imageName;
      	C3="C3-"+imageName;
      	//code to create a merge image and display it right above the green channel plot profile to better identify the centrioles.
      	windowname=split(imageName,".");
      	mergewindow="MAX_"+imageName;
		run("Merge Channels...", "c1=["+C1+"] c2=["+C2+"] c3=["+C3+"] create keep");
		close(C1);
		close(C3);
		plotwindow="Peaks in Plot of "+windowname[0];
		close("Plot of "+windowname[0]);
		selectWindow(C2);
		setLocation(1078,120);
		selectWindow(imageName);
		setLocation(578,120);
		roiManager("Select", 0);
		selectWindow(plotwindow);
		setLocation(500,520,636,493);
		
		waitForUser("Draw a C2C ROI using line tool", "Click OK");
		//if no roi, make sure the peak profile window is selected before clicking okay, otherwise it will measure the spline ROI of the image!!!
		
		roiManager("reset");
		//measure only if user has dran a line ROI on the peak plot profile
		//aslo store the name of the image in a list called "namelist"
		if(selectionType()!=-1){
			run("Measure");
			namelist[index]=imageName;
			index++; 
		}
		close(plotwindow);
		close("*");
		//incrementing index
		//close("*");
		}}
		selectWindow("Results");
		width=newArray();
		width=Table.getColumn("Width");
		selectWindow("C2C length");
		//in the results table, save the imagename and the c2c length next to it.
		Table.setColumn("Filename",namelist);
		Table.setColumn("C2C length",width);
		saveAs("Results", dir+"Centriol-to-Centriole Length.csv");
	  	close("Results");