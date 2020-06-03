/* [Part] */
Part = 1; // [1: Complete Set, 2: Twistpad, 3: Grooved Pipe, 4: Outer Pipe, 5: Handle]
Preview = 1; // [0: Off, 1: On]

/* [ Volume Settings (specify any set of two except Diameter and Area)] */
// in mm
Diameter = 25;
// in mm2
Area = 0;
// in mm
Height = 35;
// in mm3
Volume = 0;

/* [ Thread Settings] */
// in mm
Pitch = 2;
// in mm
Thread_Offset = 0.3;
// in mm
Thread_Groove_Width = 10;
// in mm
Thread_Groove_Roundness = 1;

/* [Handle Settings] */
// in mm
Connector_Height = 6;
// in mm
Handle_Height = 10;
// in mm (0 = Automatic)
Handle_Diameter = 0;

/* [Thickness, Offset and Resolution Settings] */
// in mm
Wall_Thickness = 2;
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
	Volume / height;

diameter = Diameter != 0 ?
	diameter :
	sqrt(4 * area1 / PI);

area2 = area1 != 0 ?
	area1 :
	pow(diameter, 2) * PI /4;

height = Height != 0 ?
	Height :
	Volume / area2;

// set other values
debug = Preview;
pitch = Pitch;
threadOffset = Thread_Offset;
threadGrooveWidth = Thread_Groove_Width;
threadGrooveRoundness = Thread_Groove_Roundness;
connectorHeight = Connector_Height;
handleHeight = Handle_Height;
thickness = Wall_Thickness;
groovedPipeTapering = Grooved_Pipe_Tapering;
verticalOffset = Vertical_Offset;
threadGrooveOffset = Thread_Groove_Offset;
connectorOffset = Connector_Offset;
$fn = Resolution_fn;

// this depends on some other variables so it's defined later
handleDiameter = Handle_Diameter != 0 ?
	Handle_Diameter :
	outerPipeDiameter(diameter, thickness, verticalOffset, pitch);

if (Part == 1) {
	color("darkred") {
		twistpad(diameter, thickness, pitch, threadGrooveWidth, threadGrooveRoundness, verticalOffset, threadOffset, debug = debug);
	}
	color("lightblue") {
		groovedPipe(diameter, height, thickness, pitch, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, connectorHeight);
	}
	color("lightgreen") {
		outerPipe(diameter, height, thickness, pitch, verticalOffset, groovedPipeTapering, debug = debug);
	}
	color("yellow") {
		handle(handleDiameter, handleHeight, thickness, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, diameter, connectorHeight, connectorOffset);
	}
} else if (Part == 2) {
	twistpad(diameter, thickness, pitch, threadGrooveWidth, threadGrooveRoundness, verticalOffset, threadOffset, debug = debug);
} else if (Part == 3) {
	groovedPipe(diameter, height, thickness, pitch, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, connectorHeight);
} else if (Part == 4) {
	outerPipe(diameter, height, thickness, pitch, verticalOffset, groovedPipeTapering, debug = debug);
} else if (Part == 5) {
	handle(handleDiameter, handleHeight, thickness, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, diameter, connectorHeight, connectorOffset);
}

use<threads.scad>;
use<roundcubes.scad>;

module twistpad(diameter, thickness, pitch, threadGrooveWidth, threadGrooveRoundness, verticalOffset, threadOffset, debug = false) {
	threadDiameter = threadDiameter(diameter, thickness, verticalOffset, pitch, threadOffset);
	innerDiameter = diameter - 2*verticalOffset;
	twistpadThickness = pitch;
	
	union() {
		intersection() {
			metric_thread(diameter = threadDiameter, pitch = pitch, length = twistpadThickness, n_starts = 2, internal = false, square = false, leadin = 0, leadfac = 0, test = debug);
			translate([0,0,twistpadThickness/2]) {
				rcube([threadGrooveWidth, threadDiameter, twistpadThickness], true, radius = threadGrooveRoundness, debug = debug, bf = false, tf = false, bb = false, tb = false);
			}
		}
		cylinder(d= innerDiameter, h= twistpadThickness + thickness);
	}
}

module groovedPipe(diameter, height, thickness, pitch, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, connectorHeight) {
	twistpadThickness = pitch;
	totalGrooveHeight = height + thickness + twistpadThickness;

	totalDiameter = diameter + 2*thickness;

	difference() {
		union() {
			cylinder(d=totalDiameter, h=totalGrooveHeight);
			translate([0,0,-groovedPipeTapering/2]) {
				cylinder(d1 = totalDiameter - groovedPipeTapering, d2 = totalDiameter, h = groovedPipeTapering/2);
			}
			translate([0,0,-(groovedPipeTapering/2 + connectorHeight)]) {
				cylinder(d = totalDiameter - groovedPipeTapering, h = connectorHeight);
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

module handle(handleDiameter, handleHeight, thickness, threadGrooveWidth, threadGrooveOffset, groovedPipeTapering, diameter, connectorHeight, connectorOffset) {
	connectorInnerDiameter = diameter - groovedPipeTapering;
	connectorOuterDiameter = connectorInnerDiameter + 2*thickness;

	translate([0,0,-(groovedPipeTapering/2 + handleHeight)]) {
		difference() {
			cylinder(d = handleDiameter, h = handleHeight);
			translate([0,0, handleHeight - connectorHeight]) {
				difference() {
					cylinder(d = connectorOuterDiameter+connectorOffset, h = connectorHeight + 1);
					cylinder(d = connectorInnerDiameter-connectorOffset, h = connectorHeight + 2);
					translate([-(threadGrooveWidth + threadGrooveOffset)/2, -(connectorOuterDiameter + 2)/2,-1]) {
						cube([threadGrooveWidth + threadGrooveOffset-connectorOffset,connectorOuterDiameter + 2,connectorHeight + 2]);
					}
				}
			}
		}
	}
}

module outerPipe(diameter, height, thickness, pitch, verticalOffset, groovedPipeTapering, debug = false) {
	threadDiameter = threadDiameter(diameter, thickness, verticalOffset, pitch);
	twistpadThickness = pitch;

	totalGrooveHeight = height + thickness + twistpadThickness;
	totalDiameter = outerPipeDiameter(diameter, thickness, verticalOffset, pitch);

	union() {
		difference() {
			cylinder(d=totalDiameter, h=totalGrooveHeight);
			metric_thread(diameter = threadDiameter, pitch = pitch, length = totalGrooveHeight, internal=true, n_starts=2, square=false, leadin=1, test=debug);
		}
		translate([0,0,-groovedPipeTapering/2]) {
			difference() {
				cylinder(d1 = totalDiameter - groovedPipeTapering, d2 = totalDiameter, h = groovedPipeTapering/2);
				cylinder(d1 = threadDiameter - groovedPipeTapering, d2 = threadDiameter, h = groovedPipeTapering/2); // this is a small mistake, as the wall thickness is a bit below thickness. However, it seems acceptable, as in a 3d print each layer has the correct thickness
				}
		}
	}
}

function threadDiameter(diameter, thickness, verticalOffset, pitch, threadOffset = 0) = diameter + 2*(thickness+verticalOffset - threadOffset) + pitch;
function outerPipeDiameter(diameter, thickness, verticalOffset, pitch) = threadDiameter(diameter, thickness, verticalOffset, pitch) + 2* thickness;

function threadAngle(grooveWidth, diameter) = acos((2*pow(diameter/2,2)-pow(grooveWidth,2))/(2*pow(diameter/2,2)));
function leadinFac(grooveWidth, diameter, share) = threadAngle(grooveWidth, diameter)/180*share;
