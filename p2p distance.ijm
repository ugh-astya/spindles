dir = getDirectory("Choose Source Directory with the .tif files:"); //get directory of z-projected .tif input files
list = getFileList(dir);  //to get a list of files in the given directory
run("Set Measurements...", "area mean standard min bounding area_fraction limit redirect=None decimal=3");
Table.create("P2P length"); //creating a c2c width table to store the values
index=0; //initializing the index for the c2c width table
setOption("ExpandableArrays", true); //so that i can specify an array without knowing its size
      namelist=newArray;
for (i = 0; i < list.length; i++){

    input=dir+list[i]; //specifying the input path

    if(endsWith(input, ".tif") && matches(list[i], ".*63x.*")) { //checking if the input file is a .tif file or not

      open(input);
      imageName = getTitle(); //get the name of the image
      selectWindow(imageName);
      //creating an array to store imagename values
      Stack.setChannel(1);
      run("Plot Profile");
		run("Find Peaks");
		selectWindow(imageName);
		run("ROI Manager...");
		roiManager("Add");
		run("Split Channels");
		C1="C1-"+imageName;
      	C2="C2-"+imageName;
      	C3="C3-"+imageName;
      	windowname=split(imageName,".");
      	mergewindow="MAX_"+imageName;
		run("Merge Channels...", "c1=["+C1+"] c2=["+C2+"] c3=["+C3+"] create keep");
		close(C2);
		close(C3);
		plotwindow="Peaks in Plot of "+windowname[0];
		close("Plot of "+windowname[0]);
		selectWindow(imageName);
		setLocation(1078,120);
		selectWindow(C1);
		setLocation(578,120);
		roiManager("Select", 0);
		selectWindow(plotwindow);
		setLocation(500,520,636,493);
		
		
		//Dialog.create("Measure the distance using line tool on the plot peaks");
		//items=newArray("Measure","Skip");
		//Dialog.addRadioButtonGroup("Function", items, 1, 2, "Measure");
		//Dialog.show();
		//type = Dialog.getRadioButton();
		
		//if (type=="Measure"){
    	//run("Measure");
		//}
		
		waitForUser("Draw a P2P ROI using line tool", "Click OK");
		//if no roi, make sure the peak profile window is selected before clocking okay, otherwise it will measure the spline ROI of the image!!!
		
		roiManager("reset");
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
		selectWindow("P2P length");
		Table.setColumn("Filename",namelist);
		Table.setColumn("P2P length",width);
		saveAs("Results", dir+"Pole-to-Pole Length.csv");
	  	close("Results");