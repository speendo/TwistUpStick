use<threads.scad>;

// diameter -    outside diameter of threads in mm. Default: 8.
// pitch    -    thread axial "travel" per turn in mm.  Default: 1.
// length   -    overall axial length of thread in mm.  Default: 1.
// internal -    true = clearances for internal thread (e.g., a nut).
//               false = clearances for external thread (e.g., a bolt).
//               (Internal threads should be "cut out" from a solid using
//               difference ()).  Default: false.
// n_starts -    Number of thread starts (e.g., DNA, a "double helix," has
//               n_starts=2).  See wikipedia Screw_thread.  Default: 1.
// thread_size - (non-standard) axial width of a single thread "V" - independent
//               of pitch.  Default: same as pitch.
// groove      - (non-standard) true = subtract inverted "V" from cylinder
//                (rather thanadd protruding "V" to cylinder).  Default: false.
// square      - true = square threads (per
//               https://en.wikipedia.org/wiki/Square_thread_form).  Default:
//               false.
// rectangle   - (non-standard) "Rectangular" thread - ratio depth/(axial) width
//               Default: 0 (standard "v" thread).
// angle       - (non-standard) angle (deg) of thread side from perpendicular to
//               axis (default = standard = 30 degrees).
// taper       - diameter change per length (National Pipe Thread/ANSI B1.20.1
//               is 1" diameter per 16" length). Taper decreases from 'diameter'
//               as z increases.  Default: 0 (no taper).
// leadin      - 0 (default): no chamfer; 1: chamfer (45 degree) at max-z end;
//               2: chamfer at both ends, 3: chamfer at z=0 end.
// leadfac     - scale of leadin chamfer length (default: 1.0 = 1/2 thread).
// test        - true = do not render threads (just draw "blank" cylinder).
//               Default: false (draw threads).

debug = true;

// inner circle area in mm
diameter = 25;

// inner circle area in mm
height = 50;

// not in use yet
area = 0;

// not in use yet
volume = 0;

// wall thickness in mm
thickness = 2;

// Twistpad Height in mm
twistPadHeight = 4;

// Offset between the cylinders in mm
verticalOffset = 0.5;

// Offset between the grooved cylinder and the twistpad in mm
horizontalOffset = 1;
// Thread Pitch im mm
pitch = 4;

// Thread Groove Width in mm
threadGrooveWidth = 4;

// Thread Groove Height in mm
threadGrooveHeight = 3;

// Thread Groove Vertical Offset in mm
threadGrooveOffset = 0.5;

d = diameter;
h = height;

tp = twistPadHeight;

th = thickness;

vo = verticalOffset;
ho = horizontalOffset;

tg = threadGrooveWidth;
tgh = threadGrooveHeight;
tgo = threadGrooveOffset;

p = pitch;

//outerPipe(d, h, tp, th, ho, p, debug);
groovedPipe(d,h,tp, th, tg, tgh, tgo);
twistpad(d, th, tp, vo, ho, p, tg, debug);

module groovedPipe(d, h, tp, th, tg, tgh, tgo) {
	toH = h + 2*th + tgh + tp;

	toD = d + 2*th;

	difference() {
		cylinder(d=toD, h=toH);
		translate([0,0,-1]) {
			cylinder(d=d, h=toH+2);
		}
		translate([0,0,toH/2]) {
			cube([toD+2, tg+tgo, toH - 2*th], true);
		}
	}
}

module outerPipe(d, h, tp, th, vo, p, debug = false) {
	toH = h + 2*th + tgh + tp;

	thD = d + 2*(th+vo) + p;
	toD = thD + 2* th;

	difference() {
		cylinder(d=toD, h=toH);
		metric_thread(diameter = thD, pitch = p, length = toH, internal=true, n_starts=2, square=true);
	}
}

module twistpad(d, th, tp, vo, ho, p, tg, debug = false) {
	thD = d + 2*(th+vo) + p;
	iD = d - 2*vo;
	
	h1 = th + ho;
	h2 = tp;
	h3 = th;
	
	rotate([0,0,90]) {
		union() {
			cylinder(h = h1+h2+h3, d = iD);
			translate([0,0,h1]) {
				intersection() {
					metric_thread(diameter = thD, pitch = p, length = h2, n_starts=2, square=true);
					translate([0,0,h2/2]) {
						cube([tg, thD + 2, h2+2], true);
					}
				}
			}
		}
	}
}
