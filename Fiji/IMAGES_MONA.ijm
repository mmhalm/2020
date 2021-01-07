dir =  getDirectory("Choose a folder for analysis");
list = getFileList(dir);
list = Array.sort(list);
saveDir = getDirectory("Folder for saving images");

channels = newArray("C0", "C1", "C2", "C3");
Dialog.create("Choose channel for screening of files");
Dialog.addChoice("Channel", channels, "C0");
Dialog.show();
channel = Dialog.getChoice();


// filters out everythings else besides tif files
setOption("ExpandableArrays", true);
listTifs = newArray;
newIndex = 0
for (j=0;j<list.length;j++) {
	if (indexOf(list[j], ".tif")>=0 && indexOf(list[j], channel)>=0) {
		listTifs[newIndex] = list[j];
		newIndex = newIndex +1 ;
	}
}

// this is needed for the selection of images to be analyzed
rows = (listTifs.length);
columns = 1;
n = listTifs.length;
labels = newArray(n);
defaults = newArray(n);
for (i=0; i<n; i++) {
	labels[i] = listTifs[i];
	defaults[i] = false;
}
Dialog.create("");
Dialog.addCheckboxGroup(rows, columns, labels, defaults);
Dialog.show();
k=0;
images = newArray;
for (i=0; i<n; i++) {
	checkbox = Dialog.getCheckbox();
	if (checkbox == 1) {
		images[k] = labels[i];
		k= k+1;
	}
}

listOfImages = images;

// default intensities and colors
minC0 = 0;
maxC0 = 0;
minC1 = 0;
maxC1 = 0;
minC2 = 0;
maxC2 = 0;
minC3 = 0;
maxC3 = 0;
colorC0 = "Grays";
colorC1 = "Grays";
colorC2 = "Grays";
colorC3 = "Grays";

// this for loop is done for all images chosen

for (m=0;m<listOfImages.length;m++) {
	
	open(dir + listOfImages[m]);
	name = getTitle(); 
	identifier = substring(name, 0, indexOf(name, channel));
	channelName = substring(name, indexOf(name, channel), (indexOf(name, channel) + 2));
	imageType = substring(name, lastIndexOf(name, "."));
	run("Close");

	// colors of the channels

	if (colorC0 == colorC1 && colorC1 == colorC2 && colorC2 == colorC3) {
		colors = newArray("Grays", "Green", "Red", "Magenta", "Yellow", "-");
		Dialog.create("Color Info");
		Dialog.addMessage("Choose the colors for each channel");
		Dialog.addChoice("C0", colors, "Grays");
		Dialog.addChoice("C1", colors, "Green");
		Dialog.addChoice("C2", colors, "Red");
		Dialog.addChoice("C3", colors, "Magenta");
		Dialog.show();
		colorC0 = Dialog.getChoice();
		colorC1 = Dialog.getChoice();
		colorC2 = Dialog.getChoice();
		colorC3 = Dialog.getChoice();
	}
	
	numberOfChannels = 0;

	// finds the images with same identifier as the selcted image and asks
	// for the user to set the intensities that will be used on all
	// images to be analyzed
	
	for (j=0; j<list.length; j++) {
		a = list[j];
		file = dir + a;
		title = File.getName(file);
	
		if (substring(title, 0, indexOf(name, channel)) == identifier && indexOf(title, ".tif")>=0) {
			open(file);
			Stack.getDimensions(w, h, ch, slices, frames);
	    	setSlice(slices*(3/4));
	    	
	    	if (substring(title, indexOf(name, channel), (indexOf(name, channel) + 2)) == "C0") {
	    		run(colorC0);
	    		if (minC0 == 0 && maxC0 == 0) {
		 			run("Brightness/Contrast...");
		    		waitForUser("Set the intensity");
		    		getMinAndMax(minC0, maxC0);
		    		run("Apply LUT", "stack");
	    		} else {
	    			setMinAndMax(minC0, maxC0);
	    			getMinAndMax(minC02, maxC02);
	    			run("Apply LUT", "stack");
	    		}
	    		numberOfChannels = numberOfChannels + 1;
	    		continue
	    		
	    	}
	    	if (substring(title, indexOf(name, channel), (indexOf(name, channel) + 2)) == "C1") {
	    		run(colorC1);
	    		if (minC1 == 0 && maxC1 == 0) {
		 			run("Brightness/Contrast...");
		    		waitForUser("Set the intensity");
		    		getMinAndMax(minC1, maxC1);
		    		run("Apply LUT", "stack");
	    		} else {
	    			setMinAndMax(minC1, maxC1);
	    			getMinAndMax(minC12, maxC12);
	    			run("Apply LUT", "stack");
	    		}
	    		numberOfChannels = numberOfChannels + 1;
	    		continue
	    		
	    	}
	    	if (substring(title, indexOf(name, channel), (indexOf(name, channel) + 2)) == "C2") {
	    		run(colorC2);
	    		if (minC2 == 0 && maxC2 == 0) {
		 			run("Brightness/Contrast...");
		    		waitForUser("Set the intensity");
		    		getMinAndMax(minC2, maxC2);
		    		run("Apply LUT", "stack");
	    		} else {
	    			setMinAndMax(minC2, maxC2);
	    			getMinAndMax(minC22, maxC22);
	    			run("Apply LUT", "stack");
	    		}
	    		numberOfChannels = numberOfChannels + 1;
	    		continue
	    		
	    	}
	    	if (substring(title, indexOf(name, channel), (indexOf(name, channel) + 2)) == "C3") {
	    		run(colorC3);
	    		if (minC3 == 0 && maxC3 == 0) {
		 			run("Brightness/Contrast...");
		    		waitForUser("Set the intensity");
		    		getMinAndMax(minC3, maxC3);
		    		run("Apply LUT", "stack");
	    		} else {
	    			setMinAndMax(minC3, maxC3);
	    			getMinAndMax(minC32, maxC32);
	    			run("Apply LUT", "stack");
	    		}
	    		numberOfChannels = numberOfChannels + 1;
	    		continue
	    	}
		}
	}

	selectWindow(identifier + channel + imageType);
	makeRectangle(0, 0, 600, 600);
	waitForUser("Choose ROI and preferred Z plane");
	bestSlice = getSliceNumber();
	roiManager("Add");

	if (numberOfChannels >=1) {
		selectWindow(identifier + "C0" + imageType);
		setSlice(bestSlice);
		roiManager("Select", 0);
		run("Crop");
		run("Scale Bar...", "width=10 height=4 font=14 color=White background=None location=[Lower Right] hide overlay");
		saveAs("Jpeg", saveDir + identifier + "C0.jpg");
		wait(500);
		c1 = identifier + "C0" + imageType;

	}
	
	if (numberOfChannels >= 2) {
		selectWindow(identifier + "C1" + imageType);
		setSlice(bestSlice);
		roiManager("Select", 0);
		run("Crop");
		run("Scale Bar...", "width=10 height=4 font=14 color=White background=None location=[Lower Right] hide overlay");
		saveAs("Jpeg", saveDir + identifier + "C1.jpg");
		wait(500);
		c2 = identifier + "C1" + imageType;

	}
	if (numberOfChannels >= 3) {
		selectWindow(identifier + "C2" + imageType);
		setSlice(bestSlice);
		roiManager("Select", 0);
		run("Crop");
		run("Scale Bar...", "width=10 height=4 font=14 color=White background=None location=[Lower Right] hide overlay");
		saveAs("Jpeg", saveDir + identifier + "C2.jpg");
		wait(500);
		c3 = identifier + "C2" + imageType;

	}
	if (numberOfChannels == 4) {
		selectWindow(identifier + "C3" + imageType);
		setSlice(bestSlice);
		roiManager("Select", 0);
		run("Crop");
		run("Scale Bar...", "width=10 height=4 font=14 color=White background=None location=[Lower Right] hide overlay");
		saveAs("Jpeg", saveDir + identifier + "C3.jpg");
		wait(500);
		c4 = identifier + "C3" + imageType;

	}
	print("Best slice: ", bestSlice);
	print("Identifier: ", identifier);

	Dialog.create("Name");
	Dialog.addString("Name for saving the file (see log for useful info): ", identifier);
	Dialog.show();
	saveName = Dialog.getString();
	
	waitForUser("Merge and save");

	if (numberOfChannels == 2) {
	run("Merge Channels...", "c1=&c1 c2=&c2  create");
	}

	if (numberOfChannels == 3) {
	run("Merge Channels...", "c1=&c1 c2=&c2 c3=&c3  create");
	}

	if (numberOfChannels == 4) {
	run("Merge Channels...", "c1=&c1 c2=&c2 c3=&c3 c4=&c4 create");
	}
	
	selectWindow("Composite");
	run("Scale Bar...", "width=10 height=4 font=14 color=White background=None location=[Lower Right] bold hide overlay");
	setSlice(bestSlice*numberOfChannels);
	wait(500);
	run("Channels Tool...");
	waitForUser("Save");
	saveAs("Jpeg", saveDir + "Composite_" + saveName + ".jpg");
	wait(500);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Jpeg", saveDir + "MAX_Composite_" + saveName + ".jpg");
	waitForUser("Check if all is saved");
	selectWindow("Composite");
	run("Close");
	selectWindow("MAX_Composite");
	run("Close");
	
	
	Dialog.create("Confirmation");
	Dialog.addChoice("Continue/Redo/End", newArray("Continue", "Redo", "End"), "Continue");
	Dialog.show();
	answer = Dialog.getChoice();
	roiManager("Delete");
	
	if (answer == "Redo") {
		m = m-1;
		open(dir+identifier+channel+imageType);
		Dialog.create("Check");
		Dialog.addChoice("Set new intensity values?", newArray("Yes", "No"), "Yes");
		Dialog.show();
		newIntensities = Dialog.getChoice();
		if (newIntensities == "Yes") {
			minC0 = 0;
			maxC0 = 0;
			minC1 = 0;
			maxC1 = 0;
			minC2 = 0;
			maxC2 = 0;
			minC3 = 0;
			maxC3 = 0;
		}
		continue
	}
	if (answer == "End") {
		break
	}
	print("C0: ", minC0, maxC0, "\nC1: ", minC1, maxC1, "\nC2: ", minC2, maxC2, "\nC3: ", minC3, maxC3);
}
waitForUser("Finished");