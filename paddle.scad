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
// Chip thickness
chip_thick = 1.6;
// Button hole diameter
btn_hole_dia = 7.0;

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
// Thick
cpu_thick = 1.58;
// USB width
usb_width = 11;
// USB thick
usb_thick = 7;

/* [AS5600]*/
// AS5600 width
as_width = 23.28;
// AS5600 length
as_length = 22.85;
// Holes
as_hole_dia = 3.63;
// Thick
as_thick = 1.58;

/* [Core] */
// Core diameter
core_dia = 12.0;
// Bearing diameter
bearing_dia = 16;
// Axel diameter
axel_dia = 5;
// Cap thickness
cap_thick = 3;

/* [Hidden] */
$fn = quality;


module pie(t, r0, r1, a0, a1) {
    difference() {
        rotate_extrude(angle=a1-a0,start=a0) {
            square([r1,t]);
        }
        translate([0,0,-eps]) cylinder(h=t+eps*2, r=r0);
    }
}

module as5600() {
    off = 1.75 + as_hole_dia*0.5;
    difference() {
        union() {
            cube([as_width, as_length, as_thick], center=false);
            translate([as_width/2, as_length/2, as_thick])
                cube([5, 5, chip_thick+chip_thick], center=true);
        }
        union() {
            translate([off, off, -eps*0.5])
                cylinder(h=as_thick+eps, d=as_hole_dia);
            translate([as_width-off, off, -eps*0.5])
                cylinder(h=as_thick+eps, d=as_hole_dia);
            translate([off, as_length-off, -eps*0.5])
                cylinder(h=as_thick+eps, d=as_hole_dia);
            translate([as_width-off, as_length-off, -eps*0.5])
                cylinder(h=as_thick+eps, d=as_hole_dia);
        }
    }
}

module mcu_micro_pro() {
    cube([cpu_width, cpu_length, cpu_thick], center=false);
    translate([cpu_width/2, cpu_length/2 - 3, as_thick])
       rotate(a=45,[0,0,1])
          cube([7, 7, chip_thick+chip_thick], center=true);
}

module caps(block=0) {
    difference() {
        cap(block);
        union() {
            translate([bearing_dia*0.5+4, 4, -eps*0.5])
                cylinder(h=cap_thick+eps, d=screw_dia);
            translate([-bearing_dia*0.5-4, 4, -eps*0.5])
                cylinder(h=cap_thick+eps, d=screw_dia);
           translate([bearing_dia*0.5+4, -4, -eps*0.5])
                cylinder(h=cap_thick+eps, d=screw_dia);
            translate([-bearing_dia*0.5-4, -4, -eps*0.5])
                cylinder(h=cap_thick+eps, d=screw_dia);
        }
    }
}

module cap(block=0) {
    if (block) {
        union() {
            pie(cap_thick, core_dia*0.5, (bearing_dia+6)*0.5+5, 0, 180);
            translate([0,0,cap_thick-eps]) 
                pie(wall_thick, core_dia*0.5, (bearing_dia+6)*0.5, 45, 135);
        }
    } else {
        pie(cap_thick, core_dia*0.5, (bearing_dia+6)*0.5+5, 180, 360);
    }
}

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
        union() {
            translate([wall_thick, wall_thick, wall_thick+eps]) {
                cube([box_width-2*wall_thick, 
                      box_length-2*wall_thick, 
                      box_depth-wall_thick], center=false);
            }
            translate([wall_thick*1.5, box_length-wall_thick*3, box_depth*0.5])
                rotate(-90,[0,1,0]) 
                    cylinder(h=wall_thick*2, d=btn_hole_dia);
            translate([(box_width-usb_width)*0.5, -eps, wall_thick+cpu_thick]) 
                cube([usb_width,wall_thick+2*eps,usb_thick],center=false);
        }
    }
}


union() {
    top();
    translate([0,-60,0]) caps(0);
    translate([0,-50,0]) caps(1);
    translate([100,0,0]) {
        base();
        translate([(box_width-cpu_width)*0.5, wall_thick ,wall_thick]) 
            mcu_micro_pro();
        translate([(box_width-as_width)*0.5,box_length-1.5*as_length,wall_thick])
            as5600();
    }
}
