//
// Version history:
//     26 Nov 2026 1.00  - Initial release
//
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the “Software”), to deal in the Software without restriction, 
// including without limitation the rights to use, copy, modify, 
// merge, publish, distribute, sublicense, and/or sell copies of 
// the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall 
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY 
// KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE 
// AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
// OTHER DEALINGS IN THE SOFTWARE.
//

// Quality of tessellation
quality = 200; // [10:200]

/* [Common] */
// Screw diameter (mm)
screw_dia = 2.0;   
// General EPS (mm)
eps = 0.2; // Insets used for looser fits
// Wall thicknesses (mm)
wall_thick = 5.0;

/* [Holding box] */
// width (mm)
box_width = 50;
// length (mm)
box_length = 80;
// depth (mm)
box_depth = 30;

/* [MCU] */
// CPU width
cpu_width = 18;
// CPU length
cpu_length = 37;
// USB width
usb_width = 8.2;


/* [Core] */
// Core diameter
core_dia = 12.0;
// Bearing diameter
bearing_dia = 16;
// Axel diameter
axel_dia = 5;

/* [Hidden] */
$fn = quality;

module top() {
    offset = box_width*0.5;
    difference() {
        union() {
            cube([box_width, box_length, wall_thick], center=false);
            translate([offset, offset, wall_thick]) 
                cylinder(h=wall_thick, d=2*core_dia);
        }
        union() {
            translate([offset, offset, -eps]) {
                cylinder(h=20, d=core_dia+eps*2);
                cylinder(h=wall_thick, d=bearing_dia+eps*2);
            }
        } 
    }
}

module base() {
    difference() {
        cube([box_width, box_length, box_depth], center=false);
        translate([wall_thick, wall_thick, wall_thick+eps]) {
            cube([box_width-2*wall_thick, 
                  box_length-2*wall_thick, 
                  box_depth-wall_thick], center=false);
        }
    }
}


union() {
    top();
    translate([100,0,0]) base();
}