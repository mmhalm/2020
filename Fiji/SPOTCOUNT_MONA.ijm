// In order for this macro to work, you need to have ResultsToExcel -plugin installed

run("Read and Write Excel", "file_mode=write_and_close");
dir =  getDirectory("Choose a File ");
list = getFileList(dir);
Array.sort(list);

Dialog.create("Info");
Dialog.addMessage("If you have any channels in the file that you don't wish to analyse, please mark those in 'Extra channel' fields.");
Dialog.addMessage("Extra channels can be used to tell how to spot the images you want to skip in this analysis.");
Dialog.addChoice("Channel for labeling/ROIs:", newArray("C0","C1","C2","C3"));
Dialog.addChoice("Channel for detecting spots:", newArray("C0","C1","C2","C3"));
Dialog.addChoice("Extra channel 1:", newArray("-","C0","C1","C2","C3"));
Dialog.addChoice("Extra channel 2:", newArray("-","C0","C1","C2","C3"));
Dialog.addMessage("Check these following parametres");
Dialog.addNumber("Prominence", 10);
Dialog.show();

channelLabel = Dialog.getChoice();
channelSpots = Dialog.getChoice();
channelExtra1 = Dialog.getChoice();
channelExtra2 = Dialog.getChoice();
prom = Dialog.getNumber();
analyzeNro = 0;

maxIntensity = 0;
minIntensity = 0;

									// Change this to the file location you want to save your results
run("Read and Write Excel", "file=[C:/Users/Mona/Documents/Työt/Kesä 2020 Taimen/ResultsRENAME.xlsx] file_mode=read_and_open");

for (i=0; i<list.length; i++) {
	a = list[i];
    file = dir+a;
    title = File.getName(file);
	
	if (indexOf(title, ".tif") >= 0) {
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
	
	channelIndexL = indexOf(title, channelLabel);
	channelIndexP = indexOf(title, channelSpots);
	channelIndexExtra1 = indexOf(title, channelExtra1);
	channelIndexExtra1 = indexOf(title, channelExtra2);

	headerLabel = "None";
	if (channelIndexL >= 0) {
		open(file);
		labelTitle = title;
		headerLabel = substring(labelTitle, 0, channelIndexL);

		// print(headerLabel);
		
		run("8-bit");
		run("Z Project...", "projection=[Max Intensity]");
		run("Overlay Options...", "stroke=red width=1 fill=none set");
		run("Median...", "radius=3");
		run("Subtract Background...", "rolling=125 sliding");
		run("Threshold...");
		waitForUser("Threshold...");
		run("Convert to Mask");
		run("Fill Holes");
		roiManager("Reset");

		// Change here size if you want to exclude/include certain labels
		
		run("Analyze Particles...", "size=50-400 show=[Overlay Masks] exclude clear add");
		
		setTool("dropper");
		waitForUser("Delete ROIs you don't want to include into your analysis");
		
		for (j=0; j<list.length; j++) {
			b = list[j];
			current = dir + b ;
			titleSpots = File.getName(current);
			header = "None";
			if (indexOf(titleSpots, channelLabel) >= 0) {
				continue
			}
			if (indexOf(titleSpots, channelExtra1) >= 0) {
				continue
			}
			if (indexOf(titleSpots, channelExtra2) >= 0) {
				continue
			}
			header = substring(titleSpots, 0, channelIndexL);
			
			if (header == headerLabel) {
				open(current);
				selectWindow(titleSpots);
				Stack.getDimensions(w, h, ch, slices, frames);
    			setSlice(slices*(3/4));
    			
    			if (maxIntensity ==0 && minIntensity==0) {
    				resetMinAndMax();
    				run("Brightness/Contrast...");
    				waitForUser("choose intensity");
    				getMinAndMax(minIntensity, maxIntensity);
    				run("Apply LUT", "stack");
    			} else {
    				setMinAndMax(minIntensity, maxIntensity);
    				run("Apply LUT", "stack");
    			}
				print("min intensity: ", minIntensity, "\nmax intensity: ", maxIntensity);
				rename("spots");
				run("8-bit");
				run("Z Project...", "projection=[Max Intensity]");
				run("Subtract Background...", "rolling=125");
				for(k=0; k<roiManager("count"); k++) {
					roiManager("select", k);
					List.setMeasurements;
					area = List.getValue("Area");

					run("Find Maxima...", "prominence=&prom output=Count");
					run("Find Maxima...", "prominence=&prom output=[Point Selection]");
					run("Add Selection...");
					count = getResult("Count", k);
					setResult("Area", k, area);
					setResult("Count", k, count);			
				}
				run("Read and Write Excel", "file_mode=queue_write");

			}
		}
	}
	
	if (headerLabel != "None") {
		print(headerLabel);
		selectWindow("spots");
		waitForUser("Check if the ROI's are on the spots");
		Dialog.create("Confirmation");
		Dialog.addChoice("Continue/Redo/End", newArray("Continue", "Redo", "End"), "Continue");
		Dialog.show();
		answer = Dialog.getChoice();
		
		run("Close All"); 
		
		if (answer == "Redo") {
			i = i-1;
			List.set(title, "")
			Dialog.create("Info");
			Dialog.addMessage("If you have any channels in the file that you don't wish to analyse, please mark those in 'Extra channel' fields.");
			Dialog.addMessage("Extra channels can be used to tell how to spot the images you want to skip in this analysis.");
			Dialog.addChoice("Channel for labeling/ROIs:", newArray("C0","C1","C2","C3"), channelLabel);
			Dialog.addChoice("Channel for detecting spots:", newArray("C0","C1","C2","C3"), channelSpots);
			Dialog.addChoice("Extra channel 1:", newArray("-","C0","C1","C2","C3"), channelExtra1);
			Dialog.addChoice("Extra channel 2:", newArray("-","C0","C1","C2","C3"), channelExtra2);
			Dialog.addMessage("Check these following parametres");
			Dialog.addNumber("Prominence", prom);
			Dialog.show();
			
			channelLabel = Dialog.getChoice();
			channelSpots = Dialog.getChoice();
			channelExtra1 = Dialog.getChoice();
			channelExtra2 = Dialog.getChoice();
			prom = Dialog.getNumber();
			continue
		}
		if (answer == "End") {
			break
		} 
	}
	
}
print("prominence:", prom);
selectWindow("Log");
//rename("Results");
//run("Read and Write Excel", "file_mode=queue_write");
run("Read and Write Excel", "file_mode=write_and_close");