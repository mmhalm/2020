cont = 1
while (cont==1){
	run("Duplicate...", "title=copy");
	
	setTool("rectangle");
	waitForUser("Make a rectangle");
	
	getBoundingRect(x1, y1, width1, height1);
	lanes = getNumber("number of lanes", 1);
	
	widthAll = width1/(lanes);
	makeRectangle(x1, y1, widthAll, height1);
	run("Select First Lane");
	
	for (i=0; i<(lanes-1); i++) {
		
		x1 = x1 + widthAll;
		
		makeRectangle(x1, y1, widthAll, height1);
		run("Select Next Lane");
	}
	
	Dialog.create("Check-up");
	label = "Proceed to plotting?";
	Dialog.addChoice(label, newArray("Yes, continue", "No, restart"));
	Dialog.show();
	inChoice  = Dialog.getChoice();
	
	if (inChoice=="Yes, continue") {
		run("Plot Lanes");
		break
	} else {
		close();
		continue
	}
}

waitForUser("Analyze the plots");
waitForUser("Closing all windows");
run("Close All");