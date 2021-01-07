dir =  getDirectory("Choose a folder for analysis");
list = getFileList(dir);
list = Array.sort(list);
saveDir = getDirectory("Folder for saving coloc images");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
dayOfMonthStr = "" + dayOfMonth;
minuteStr = "" + minute;

//setBatchMode(false);

run("Read and Write Excel", "file_mode=write_and_close");
//CHANGE THE RESULT FILE LOCATION HERE. Write the location/path inside the [ ]
run("Read and Write Excel", "file=[C:/Users/Mona/Documents/Työt/Kesä 2020 Taimen/RENAMEResults.xlsx] file_mode=read_and_open");

channels = newArray("C0", "C1", "C2", "C3");
Dialog.create("Info");
Dialog.addChoice("Channel for label (DAPI etc.)", channels , "C0");
Dialog.addChoice("Channel for spots", channels, "C1");
Dialog.addNumber("Min value for 'Size Opening 2D/3D", 100000);
Dialog.addNumber("Rolling pixel size for background substraction for label image", 40);
Dialog.show();
labelChannel = Dialog.getChoice();
intensityChannel = Dialog.getChoice();
minValue = Dialog.getNumber();
rollingNro = Dialog.getNumber();

function segmentSpots(im) {
	selectWindow(im);
	run("Subtract Background...", "rolling=1 stack");
	run("Gamma...", "value=2 stack");
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=MaxEntropy background=Dark calculate black");
	run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
	run("Set Label Map", "colormap=[RGB 3-3-2] background=Black shuffle");
	rename("spots");
}

for (i=0; i<list.length; i++) {
    a = list[i];
    file = dir+a;
    title = File.getName(file);

	// This chaos just makes sure same picture doesn't get analuzed twice and that 
	// the image analyzed is from the label channel
	
    headerLabel = "None";
	if (indexOf(title, ".tif") >= 0) {
		
		if (indexOf(title, labelChannel) >=0) {
			if (List.size == 0) {
				List.set(title, i);
			} else { 
				check = List.get(title);
			    if (check != "") {
			    	continue
			    } else {
			    	List.set(title, i);
			    }
			}
		} else {
			continue
		}	
		
		Dialog.create(title);
		Dialog.addMessage(title);
		Dialog.addCheckbox("Analyze?", true);
		Dialog.addMessage("Label channel: "+labelChannel);
		Dialog.addMessage("Input channel: "+intensityChannel);
		Dialog.show();
		analyze = Dialog.getCheckbox();
		
		if (analyze == true) {
			open(file);
			headerLabel = substring(title, 0, indexOf(title, labelChannel));
		} else {
			continue	
		}
	} else {
		continue
	}

	//setBatchMode("show");
    run("Median...", "radius=2 + stack");
    setSlice(20);
    run("Threshold...");    
    waitForUser("Threshold...");
  //  setBatchMode("hide");
    selectWindow("Threshold");
	run("Close");
    run("Convert to Mask", "method=Default background=Default black");
    run("Fill Holes", "stack");    
    run("Size Opening 2D/3D", "min=&minValue");
    close("\\Others");
    run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
    //run("Distance Transform Watershed 3D", "distances=[City-Block (1,2,3)] output=[16 bits] normalize dynamic=2 connectivity=6");
    run("Set Label Map", "colormap=Spectrum background=Black");
    run("Remove Border Labels", "left right top bottom");
    run("Properties...", "voxel_depth=0.27");
    rename("labl");
    close("\\Others");
//    setBatchMode("show");
    run("Label Edition");
    waitForUser("Select labels to remove and press 'Remove selected' and then close the Label Edition from top right corner");
    selectWindow("labl");
    run("Close");
    selectWindow("labl-edited");
    rename("labl");
    //setBatchMode("hide");
    
	for (j=0; j<list.length; j++) {
		b = list[j];
		current = dir + b ;
		titleIntensity = File.getName(current);
		header = "None";
		if (indexOf(titleIntensity, intensityChannel) >= 0) {
			header = substring(titleIntensity, 0, indexOf(titleIntensity, intensityChannel) );
			if (header == headerLabel) {
				open(current);
				run("Properties...", "voxel_depth=0.27");
				spotTitle = getTitle();
				segmentSpots(spotTitle);
				run("DiAna_Analyse", "img1=labl img2=spots lab1=labl lab2=spots coloc");
				
			}
		} else {
			continue
		}	
	}
	
	if (headerLabel != "None") {		
		selectWindow("labl");
		rename(header); // for the excel table header/title
		
	//	setBatchMode("show");
		selectWindow("ColocResults");

		Table.deleteColumn("ColocFromAvolume");
		Table.deleteColumn("ColocFromBvolume");
		Table.deleteColumn("ColocFromABvolume");
		Table.deleteColumn("Dist min CenterA-EdgeB");
		Table.rename("ColocResults", "Results");
		Table.update;
		
		run("Read and Write Excel", "file_mode=queue_write");
		
		selectWindow("coloc");
		saveFile = saveDir + header + "_colocalization_" + labelChannel + "_" + intensityChannel;
        saveAs("tiff", saveFile);
        close("\\Others");

		waitForUser("Save the Results");
        
		Dialog.create("Confirmation");
		Dialog.addChoice("Continue/Redo/End", newArray("Continue", "Redo", "End"), "Continue");
		Dialog.show();
		answer = Dialog.getChoice(); 
		selectWindow("Results");
		run("Close");
		
		if (answer == "Redo") {
			i = i-1;
			List.set(title, "");
			run("Close All");
			run("Close");
			continue
		}
		if (answer == "End") {
			break
		}
    } 
    run("Close All");
    continue
}

run("Read and Write Excel", "file_mode=write_and_close");
run("Close All");
