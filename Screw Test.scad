// M12

/* [Part] */
part = 1; // [1:Nut, 2:Bolt]

/* [Thread] */
thread = 12;
pitch = 1.75;
nStarts = 2;

/* [Nut] */
nutHex = 18;
nutHeight = 10.8;
nutOffset = 0.5;

/* [Bolt] */
screwHex = 18;
screwHeadHeight = 7.5;
screwLength = 15;

/* [Decoration] */
hexRound = 1; // [0:0.1:3]

textSize = 2.5;
textDepth = 0.5;

/* [Resolution] */
$fn = 30;
debug = true;

/* [Hidden] */

use<threads.scad>;


if (part == 1) {
	nut();
} else if (part == 2) {
	bolt();
}

module bolt() {
	textHexagon(screwHeadHeight, thread, screwHex);
	translate([0,0,screwHeadHeight]) {
//		intersection() {
			metric_thread(diameter = thread, pitch = pitch, length = screwLength, n_starts = nStarts, leadin = 1, internal = false, square = false, test = debug);
//			rotate([0,0,-45]) {
//				translate([-thread/2,-4/2,0]) {
//					cube([thread,4,screwLength]);
//				}
//			}
//		}
	}
}

module nut() {
	difference() {
		textHexagon(nutHeight, thread+nutOffset, nutHex);
		metric_thread(diameter = thread + nutOffset, pitch = pitch, length = nutHeight, n_starts = nStarts, leadin = 2, internal = true, square = false, test = debug);
	}
}

module textHexagon(height, threadSize, hex) {
	difference() {
		hexagon(height, hex);
		translate([0,-hex/2+textDepth,height/2]) {
			rotate([90,0,0]) {
				linear_extrude(textDepth*2) {
					text(str("M",threadSize), size = textSize, valign = "center", halign = "center");
				}
			}
		}
	}
}

module hexagon(height, hex) {
	hull() {
		for (i= [0:1:5]) {
			rotate([0,0,i*60]) {
				translate([ru((hex-hexRound)/2),0,hexRound/2]) {
					sphere(d = hexRound);
	//				translate([0,0,hexRound/2]) {
	//					cylinder(d = hexRound, h = nutHeight - hexRound);
	//				}
					translate([0,0,height - hexRound]) {
						sphere(d=hexRound);
					}
				}
			}
		}
	}
}

function ri(ru) = sqrt(3)/2*ru;
function ru(ri) = 2*ri/sqrt(3);
