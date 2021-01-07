setBatchMode(true);

dir =  getDirectory("Choose a folder for analysis");
list = getFileList(dir);
list = Array.sort(list);
saveDir = getDirectory("Folder for saving labeled images");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
dayOfMonthStr = "" + dayOfMonth;
minuteStr = "" + minute;

run("Read and Write Excel", "file_mode=write_and_close");
//CHANGE THE RESULT FILE LOCATION HERE. Write the location/path inside the [ ]
run("Read and Write Excel", "file=[C:/Users/Mona/Documents/Työt/Kesä 2020 Taimen/ResultsRENAME.xlsx] file_mode=read_and_open");

channels = newArray("C0", "C1", "C2", "C3");
Dialog.create("Info");
Dialog.addChoice("Channel for label (DAPI etc.)", channels , "C0");
Dialog.addChoice("Channel for intensity measurement", channels, "C1");
Dialog.addNumber("Min value for 'Size Opening 2D/3D", 100000);
Dialog.addNumber("Rolling pixel size for background substraction", 40);
Dialog.show();
labelChannel = Dialog.getChoice();
intensityChannel = Dialog.getChoice();
minValue = Dialog.getNumber();
rollingNro = Dialog.getNumber();

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
	
    run("Median...", "radius=2 + stack");
    setBatchMode("show");
    setSlice(20);
    run("Threshold...");    
    waitForUser("Threshold...");
    selectWindow("Threshold");
	run("Close");
	setBatchMode("hide");
    run("Convert to Mask", "method=Default background=Default black");
    run("Fill Holes", "stack");    
    run("Size Opening 2D/3D", "min=&minValue");
    close("\\Others");
    run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
    run("Set Label Map", "colormap=Spectrum background=Black");
    run("Remove Border Labels", "left right top bottom");
    run("Properties...", "voxel_depth=0.27");
    saveFile = saveDir + headerLabel + dayOfMonthStr + minuteStr;
    saveAs("tiff", saveFile);
    rename("labl");
    
	for (j=0; j<list.length; j++) {
		b = list[j];
		current = dir + b ;
		titleIntensity = File.getName(current);
		header = "None";
		if (indexOf(titleIntensity, intensityChannel) >= 0) {
			header = substring(titleIntensity, 0, indexOf(titleIntensity, intensityChannel) );
			if (header == headerLabel) {
				open(current);
				setBatchMode("show");
				run("Properties...", "voxel_depth=0.27");
				rename("inp");
				setBatchMode("hide");
				run("Subtract Background...", "rolling=&rollingNro stack");
				run("Intensity Measurements 2D/3D", "labels=&labl input=&inp mean numberofvoxels volume");					

				label = Table.getColumn("Label");
				means = Table.getColumn("Mean");
				numberOfVoxels = Table.getColumn("NumberOfVoxels");
				volumes = Table.getColumn("Volume");
				
				setOption("ExpandableArrays", true);
				titles = newArray;
				for (t=0; t<label.length; t++) {
					titles[t] = header;
				}
				tableName = header + "table";
				Table.create(tableName);
				Table.setColumn("Label", label);
				Table.setColumn("Mean Intensity", means);
				Table.setColumn("Number Of Vowels", numberOfVoxels);
				Table.setColumn("Volume", volumes);	
				Table.setColumn("Title", titles);
				Table.rename(tableName, "Results");
			}
		} else {
			continue
		}	
	}
	if (headerLabel != "None") {		
		selectWindow("inp-intensity-measurements");
		run("Close");
		selectWindow("labl");
		rename(header.substring(0, lengthOf(header))); // for the excel table header/title
		setBatchMode("show");
		waitForUser("Check the labels you want to exclude and delete them from the result table");
		selectWindow("Results");
		run("Read and Write Excel", "file_mode=queue_write");
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
			//run("Close");
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
waitForUser("Finished");