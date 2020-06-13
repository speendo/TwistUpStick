/* [Part] */
Part = 1; // [1: Complete Set, 2: Twistpad, 3: Grooved Pipe, 4: Outer Pipe, 5: Handle, 6: Cap, 7: Mold Part 1, 8: Mold Part 2, 9: Mold Holder]
Preview = 1; // [0: Off, 1: On]

/* [ Volume Settings (specify any set of two except Diameter and Area)] */
// in mm
Diameter = 25;
// in mm2
Area = 0;
// in mm
Height = 35;
// in mm3
Volume = 0; // [0:0.1:100000]

/* [ Thread Settings] */
// in mm
Pitch = 3;
// in mm (0 = Pitch)
Thread_Horizontal_Size = 1.5;
// in mm
Thread_Offset = 0.3;
// in mm
Thread_Groove_Width = 6;
// in mm
Thread_Groove_Roundness = 1;

/* [Handle Settings] */
// in mm
Connector_Height = 6;
// in mm
Handle_Height = 10;
// in mm (0 = Automatic)
Handle_Diameter = 0;

// Share of Connector_Offset (in Offset Settings)
Handle_Snap_Share = 0.75; // [0:0.01:1]

// in mm
Handle_Snap_Clearance = 0.2;

/* [Cap] */
// in mm
Cap_Pitch = 4;
// in mm
Cap_Thread_Size = 1;
// in mm
Cap_Thread_Offset = 0.3;
// in mm
Cap_Thread_Height = 6;
Cap_Thread_Starts = 4;

/* [Mold] */
// in mm
Mold_Thread_Height = 10;

// in mm
Mold_Handle_Width = 15;
// in mm
Mold_Handle_Thickness = 5;

/* [Thickness, Offset and Resolution Settings] */
// in mm
Wall_Thickness = 1.2; // [0:0.05:5]
// in mm
Grooved_Pipe_Tapering = 4;
// in mm
Vertical_Offset = 0.3;
// in mm
Thread_Groove_Offset = 0.2;
// in mm
Connector_Offset = 0.15;
// Global Variable $fn
Resolution_fn = 100;

/* [Hidden] */

// Calculate height and diameter (if not specified)

area1 = Area != 0 ?
	Area :
	Height == 0 ?
		0 :
		Volume / Height;

diameter = Diameter != 0 ?
	Diameter :
	sqrt(4 * area1 / PI);

area2 = area1 != 0 ?
	area1 :
	pow(diameter, 2) * PI /4;

height = Height != 0 ?
	Height :
	Volume / area2;

threadHorizontalSize = Thread_Horizontal_Size != 0 ?
	Thread_Horizontal_Size :
	Pitch;

// set other values
debug = Preview;
pitch = Pitch;
threadOffset = Thread_Offset;
threadGrooveWidth = Thread_Groove_Width;
threadGrooveRoundness = Thread_Groove_Roundness;
connectorHeight = Connector_Height;
handleHeight = Handle_Height;
handleSnapShare = Handle_Snap_Share;
handleSnapClearance = Handle_Snap_Clearance;
capPitch = Cap_Pitch;
capThreadSize = Cap_Thread_Size;
capThreadOffset = Cap_Thread_Offset;
capThreadHeight = Cap_Thread_Height;
capThreadStarts = Cap_Thread_Starts;
moldThreadHeight = Mold_Thread_Height;
moldHandleWidth = Mold_Handle_Width;
moldHandleThickness = Mold_Handle_Thickness;
thickness = Wall_Thickness;
groovedPipeTapering = Grooved_Pipe_Tapering;
verticalOffset = Vertical_Offset;
threadGrooveOffset = Thread_Groove_Offset;
connectorOffset = Connector_Offset;
$fn = Resolution_fn;

// this depends on some other variables so it's defined later
handleDiameter = Handle_Diameter != 0 ?
	Handle_Diameter :
	outerPipeDiameter(diameter, thickness, verticalOffset, threadHorizontalSize);

if (Part == 1) {
	color("darkred") {
		twistpad(diameter, thickness, pitch, threadHorizontalSize, threadGrooveWidth, threadGrooveRoundness, verticalOffset, threadOffset, debug = debug);
	}
	color("lightblue") {
		groovedPipe(diameter, height, thickness, pitch, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, connectorHeight, connectorOffset, handleSnapShare, handleSnapClearance);
	}
	color("lightgreen") {
		outerPipe(diameter, height, thickness, pitch, threadHorizontalSize, verticalOffset, groovedPipeTapering, capThreadHeight, capPitch, capThreadSize, capThreadStarts, debug = debug);
	}
	color("yellow") {
		handle(handleDiameter, handleHeight, thickness, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, diameter, connectorHeight, connectorOffset, handleSnapShare, handleSnapClearance);
	}
	color("cyan") {
		twistpadThickness = pitch;
		translate([0,0,height + twistpadThickness - capThreadHeight]) {
			cap(diameter, thickness, capPitch, capThreadOffset, capThreadSize, capThreadStarts, capThreadHeight, verticalOffset, threadHorizontalSize, debug = debug);
		}
	}
} else if (Part == 2) {
	twistpad(diameter, thickness, pitch, threadHorizontalSize, threadGrooveWidth, threadGrooveRoundness, verticalOffset, threadOffset, debug = debug);
} else if (Part == 3) {
	groovedPipe(diameter, height, thickness, pitch, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, connectorHeight, connectorOffset, handleSnapShare, handleSnapClearance);
} else if (Part == 4) {
	outerPipe(diameter, height, thickness, pitch, threadHorizontalSize, verticalOffset, groovedPipeTapering, capThreadHeight, capPitch, capThreadSize, capThreadStarts, debug = debug);
} else if (Part == 5) {
	handle(handleDiameter, handleHeight, thickness, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, diameter, connectorHeight, connectorOffset, handleSnapShare, handleSnapClearance);
} else if (Part == 6) {
	cap(diameter, thickness, capPitch, capThreadOffset, capThreadSize, capThreadStarts, capThreadHeight, verticalOffset, threadHorizontalSize, debug = debug);
} else if (Part == 7) {
	mold1(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = debug);
} else if (Part == 8) {
	mold2(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = debug);
} else if (Part == 9) {
	moldHolder(diameter, height, thickness, pitch, threadHorizontalSize, verticalOffset, threadOffset, moldThreadHeight, debug = debug);
}

use<threads.scad>;
use<roundcubes.scad>;

module twistpad(diameter, thickness, pitch, threadHorizontalSize, threadGrooveWidth, threadGrooveRoundness, verticalOffset, threadOffset, debug = false) {
	threadDiameter = threadDiameter(diameter, thickness, verticalOffset, threadHorizontalSize, threadOffset);
	innerDiameter = diameter - 2*verticalOffset;
	twistpadThickness = pitch;
	
	union() {
		intersection() {
			metric_thread(diameter = threadDiameter, pitch = pitch, thread_size = threadHorizontalSize, length = twistpadThickness, n_starts = 2, internal = false, square = false, leadin = 0, leadfac = 0, test = debug);
			translate([0,0,twistpadThickness/2]) {
				rcube([threadGrooveWidth, threadDiameter, twistpadThickness], true, radius = threadGrooveRoundness, debug = debug, bf = false, tf = false, bb = false, tb = false);
			}
		}
		cylinder(d= innerDiameter, h= twistpadThickness + thickness);
	}
}

module groovedPipe(diameter, height, thickness, pitch, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, connectorHeight, connectorOffset, handleSnapShare, handleSnapClearance) {
	twistpadThickness = pitch;
	totalGrooveHeight = height + thickness + twistpadThickness;

	totalDiameter = diameter + 2*thickness;

	snapXOffset = snapXOffset(connectorOffset, handleSnapShare);
	snapZOffset = snapZOffset(thickness/2, connectorOffset/2-snapXOffset, handleSnapClearance/2);

	difference() {
		union() {
			cylinder(d=totalDiameter, h=totalGrooveHeight);
			translate([0,0,-groovedPipeTapering/2]) {
				cylinder(d1 = totalDiameter - groovedPipeTapering, d2 = totalDiameter, h = groovedPipeTapering/2);
			}
			translate([0,0,-(groovedPipeTapering/2 + connectorHeight)]) {
				cylinder(d = totalDiameter - groovedPipeTapering, h = connectorHeight);
				translate([0,0,connectorHeight/2 - snapZOffset]) {
					rotate_extrude() {
						translate([(totalDiameter - groovedPipeTapering - thickness)/2 + snapXOffset,0,0]) {
							circle(d=thickness);
						}
					}
				}
			}
		}
		union() {
			cylinder(d=diameter, h=totalGrooveHeight+1);
			translate([0,0,-groovedPipeTapering/2]) {
				cylinder(d1 = diameter - groovedPipeTapering, d2 = diameter, h = groovedPipeTapering/2); // this is a small mistake, as the wall thickness is a bit below thickness. However, it seems acceptable, as in a 3d print each layer has the correct thickness
			}
			translate([0,0,-(groovedPipeTapering/2 + connectorHeight + 1)]) {
				cylinder(d = diameter - groovedPipeTapering, h = connectorHeight + 2);
			}
		}
		translate([-(threadGrooveWidth + threadGrooveOffset)/2,-totalDiameter / 2 -1,-(groovedPipeTapering/2 + connectorHeight + 1)]) {
			cube([threadGrooveWidth + threadGrooveOffset, totalDiameter + 2, totalGrooveHeight + groovedPipeTapering/2 + connectorHeight - thickness + 1]);
		}
	}
}

module handle(handleDiameter, handleHeight, thickness, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, diameter, connectorHeight, connectorOffset, handleSnapShare, handleSnapClearance) {
	connectorInnerDiameter = diameter - groovedPipeTapering;
	connectorOuterDiameter = connectorInnerDiameter + 2*thickness;

	snapXOffset = snapXOffset(connectorOffset, handleSnapShare);
	snapZOffset = snapZOffset(thickness/2, connectorOffset/2-snapXOffset, handleSnapClearance/2);

	translate([0,0,-(groovedPipeTapering/2 + handleHeight)]) {
		difference() {
			cylinder(d = handleDiameter, h = handleHeight);
			translate([0,0, handleHeight - connectorHeight]) {
				difference() {
					cylinder(d = connectorOuterDiameter+connectorOffset, h = connectorHeight + 1);
					cylinder(d = connectorInnerDiameter-connectorOffset, h = connectorHeight + 2);
					translate([-(threadGrooveWidth + threadGrooveOffset)/2 + connectorOffset, -(connectorOuterDiameter + connectorOffset + 2)/2,-1]) {
						cube([threadGrooveWidth + threadGrooveOffset - 2*connectorOffset,connectorOuterDiameter + connectorOffset+ 2,connectorHeight + 2]);
					}
					translate([0,0,connectorHeight/2 + snapZOffset]) {
						rotate_extrude() {
							translate([(connectorOuterDiameter + connectorOffset + thickness)/2 - snapXOffset,0,0]) {
								circle(d=thickness);
							}
						}
					}
				}
			}
		}
	}
}

module outerPipe(diameter, height, thickness, pitch, threadHorizontalSize, verticalOffset, groovedPipeTapering, capThreadHeight, capPitch, capThreadSize, capThreadStarts, debug = false) {
	threadDiameter = threadDiameter(diameter, thickness, verticalOffset, threadHorizontalSize);
	twistpadThickness = pitch;

	totalGrooveHeight = height + thickness + twistpadThickness;
	totalDiameter = outerPipeDiameter(diameter, thickness, verticalOffset, threadHorizontalSize);

	outerThreadDiameter = totalDiameter + capThreadSize;

	union() {
		difference() {
			union() {
				cylinder(d=totalDiameter, h=totalGrooveHeight);
				translate([0,0,totalGrooveHeight-capThreadHeight-thickness]) {
					metric_thread(diameter = outerThreadDiameter, pitch = capPitch, thread_size = capThreadSize, length = capThreadHeight, internal=false, n_starts=capThreadStarts, square=false, leadin=2, groove=true, test=debug);
				}
			}
			metric_thread(diameter = threadDiameter, pitch = pitch, thread_size = threadHorizontalSize, length = totalGrooveHeight, internal=true, n_starts=2, square=false, leadin=2, test=debug);
		}
		translate([0,0,-groovedPipeTapering/2]) {
			difference() {
				cylinder(d1 = totalDiameter - groovedPipeTapering, d2 = totalDiameter, h = groovedPipeTapering/2);
				cylinder(d1 = threadDiameter - groovedPipeTapering, d2 = threadDiameter, h = groovedPipeTapering/2); // this is a small mistake, as the wall thickness is a bit below thickness. However, it seems acceptable, as in a 3d print each layer has the correct thickness
				}
		}
	}
}

module cap(diameter, thickness, capPitch, capThreadOffset, capThreadSize, capThreadStarts, capHeight, verticalOffset, threadHorizontalSize, debug = debug) {
	outerPipeDiameter = outerPipeDiameter(diameter, thickness, verticalOffset, threadHorizontalSize);
	capThreadDiameter = outerPipeDiameter + 2*capThreadOffset;
	outerDiameter = outerPipeDiameter + 2*(capThreadSize+thickness);

	difference() {
		cylinder(d=outerDiameter, h=capThreadHeight + 2*thickness);
		metric_thread(diameter = capThreadDiameter, pitch = capPitch, thread_size = capThreadSize, length = capThreadHeight+thickness, internal=true, n_starts=capThreadStarts, square=false, leadin = 2, groove=true, test=debug);
	}
}

module mold1(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = debug) {
	difference() {
		mold(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = debug);
		moldSeparator(diameter, height, thickness, moldHandleWidth, moldHandleThickness, pitch, threadHorizontalSize);
	}
}

module mold2(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = debug) {
	intersection() {
		mold(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = debug);
		moldSeparator(diameter, height, thickness, moldHandleWidth, moldHandleThickness, pitch, threadHorizontalSize);
	}
}

module moldSeparator(diameter, height, thickness, moldHandleWidth, moldHandleThickness, pitch, threadHorizontalSize) {
	outerDiameter = diameter + 2*thickness + threadHorizontalSize + 2*max(thickness, threadHorizontalSize);
	separatorHeight = height + thickness + moldHandleThickness + thickness + pitch;
	
	difference() {
		union() {
			translate([0,0,-1]) {
				cylinder(d=outerDiameter + 2*thickness + moldHandleThickness+2, h=separatorHeight+2);
			}
			translate([-((outerDiameter + 2*thickness + moldHandleThickness)/2+2),-(outerDiameter/2 + moldHandleWidth + 4),-4]) {
				cube([outerDiameter + 2*thickness + moldHandleThickness + 4,outerDiameter/2 + moldHandleWidth + 4 - thickness,separatorHeight+8]);
			}
		}
		translate([-((outerDiameter + 2*thickness + moldHandleThickness)/2+2),thickness,-2]) {
			cube([outerDiameter + 2*thickness + moldHandleThickness + 4,outerDiameter/2 + moldHandleWidth + 4,separatorHeight+4]);
		}
		difference() {
			translate([0,0,-3]) {
				cylinder(d=outerDiameter-2*thickness,h=separatorHeight+6);
			}
			translate([-((outerDiameter + 2*thickness + moldHandleThickness)/2+2),-(outerDiameter/2 + moldHandleWidth + 4),-4]) {
				cube([outerDiameter + 2*thickness + moldHandleThickness + 4,outerDiameter/2 + moldHandleWidth + 4 - thickness,separatorHeight+8]);
			}
		}
	}
}

module mold(diameter, height, thickness, pitch, threadHorizontalSize, threadGrooveWidth, verticalOffset, threadOffset, moldThreadHeight, moldHandleWidth, moldHandleThickness, debug = false) {
	outerDiameter = diameter + 2*thickness + threadHorizontalSize + 2*max(thickness, threadHorizontalSize);
	totalHeight = height + thickness + pitch;

	difference() {
		union() {
			cylinder(d=outerDiameter, h=totalHeight);
			translate([0,0,totalHeight]) {
				cylinder(d1=outerDiameter, d2=outerDiameter + 2*thickness, h=thickness);
			}
			translate([0,0,totalHeight + thickness + moldHandleThickness/2]) {
				rcube([outerDiameter + 2*thickness + moldHandleThickness, outerDiameter + 2*moldHandleWidth, moldHandleThickness], radius = moldHandleThickness/2, center=true, debug=debug);
			}
			translate([0,0,totalHeight - moldThreadHeight]) {
				metric_thread(diameter = outerDiameter + threadHorizontalSize, pitch = pitch, thread_size = threadHorizontalSize, length = moldThreadHeight, n_starts = 2, internal = false, square = false, leadin = 2, leadfac = 0, test = debug);
			}
		}
		translate([0,0,-1]) {
			cylinder(d=diameter, h=totalHeight+2);
		}
		translate([0,0,totalHeight]) {
			cylinder(d1=diameter, d2=diameter + 2*thickness + 2*moldHandleThickness + 2, h=thickness + moldHandleThickness + 1);
		}
		twistpad(diameter, thickness, pitch, threadHorizontalSize, threadGrooveWidth, 0, verticalOffset, threadOffset, debug = true);
	}
}

module moldHolder(diameter, height, thickness, pitch, threadHorizontalSize, verticalOffset, threadOffset, moldThreadHeight, debug = debug) {
	outerDiameter = diameter + 4*thickness + 2*threadHorizontalSize + 2*max(thickness, threadHorizontalSize) + 2*verticalOffset + 2*threadOffset ;
	innerDiameter = diameter + 2*thickness + threadHorizontalSize + 2*max(thickness, threadHorizontalSize) + 2*verticalOffset;
	totalHeight = height + thickness + pitch;

	difference() {
		translate([0,0,-thickness]) {
			cylinder(d=outerDiameter, h=totalHeight + thickness);
		}
		cylinder(d=innerDiameter, h=totalHeight-5);
		translate([0,0,totalHeight - moldThreadHeight-thickness]) {
			metric_thread(diameter = innerDiameter + threadHorizontalSize + 2*threadOffset, pitch = pitch, thread_size = threadHorizontalSize, length = moldThreadHeight + thickness, n_starts = 2, internal = true, square = false, leadin = 2, leadfac = 0, test = debug);
		}
	}
}

function threadDiameter(diameter, thickness, verticalOffset, pitch, threadOffset = 0) = diameter + 2*(thickness + verticalOffset - threadOffset) + pitch;
function outerPipeDiameter(diameter, thickness, verticalOffset, pitch) = threadDiameter(diameter, thickness, verticalOffset, pitch) + 2* thickness;

function threadAngle(grooveWidth, diameter) = acos((2*pow(diameter/2,2)-pow(grooveWidth,2))/(2*pow(diameter/2,2)));
function leadinFac(grooveWidth, diameter, share) = threadAngle(grooveWidth, diameter)/180*share;

function snapXOffset(connectorOffset, handleSnapShare) = connectorOffset/2*(handleSnapShare);
function snapZOffset(radius, xPos, handleSnapClearance) = pow(radius,2) > pow(xPos,2) ? sqrt(pow(radius,2) - pow(xPos,2)) + handleSnapClearance : handleSnapClearance;
