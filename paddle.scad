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
// General EPS (mm)
eps = 0.2; // Insets used for looser fits
// Wall thicknesses (mm)
wall_thick = 5.0;
// Chip thickness
chip_thick = 1.6;
// Button hole diameter
btn_hole_dia = 7.0;
// M3 screw clean hole diameter (mm)
m3_hole_dia = 3.3;
// M3 screw thread hole diameter (mm)
m3_thread_dia = 2.9;

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

// Use this to calibrate the M3 holes for a specific printer
module M3_test_block() {
    difference() {
        cube([35,5,10],center=false);
        union() {
            translate([5,2.5,-1]) cylinder(h=12, d=2.5);
            translate([10,2.5,-1]) cylinder(h=12, d=2.7);
            translate([15,2.5,-1]) cylinder(h=12, d=2.9);
            translate([20,2.5,-1]) cylinder(h=12, d=3.1);
            translate([25,2.5,-1]) cylinder(h=12, d=3.3);
            translate([30,2.5,-1]) cylinder(h=12, d=3.5);
        }
    }
}

module pie(t, r0, r1, a0, a1) {
    difference() {
        rotate_extrude(angle=a1-a0,start=a0) {
            square([r1,t]);
        }
        translate([0,0,-eps]) cylinder(h=t+eps*2, r=r0);
    }
}

module as5600_holes(depth, dia, off) {
    translate([off, off, 0])
        cylinder(h=depth, d=dia);
    translate([as_width-off, off, 0])
        cylinder(h=depth, d=dia);
    translate([off, as_length-off, 0])
        cylinder(h=depth, d=dia);
    translate([as_width-off, as_length-off, 0])
        cylinder(h=depth, d=dia);
}

module as5600() {
    off = 1.75 + as_hole_dia*0.5;
    difference() {
        union() {
            color("#ffffff") cube([as_width, as_length, as_thick], center=false);
            translate([as_width/2, as_length/2, as_thick])
                color("#000000") cube([5, 5, chip_thick+chip_thick], center=true);
        }
        translate([0, 0, -eps*0.5])
            as5600_holes(as_thick+eps, as_hole_dia, off);
    }
}

module as5600_cradle() {
    gap = 2 + eps;
    difference() {
        translate([-1, -1, 0]) 
            cube([as_width+gap, as_length+gap, as_thick], center=false);
        cube([as_width, as_length, as_thick+2*gap], center=false);
    }
}

module mcu_micro_pro() {
    color("#00cc00") cube([cpu_width, cpu_length, cpu_thick], center=false);
    translate([cpu_width/2, cpu_length/2 - 3, as_thick])
       rotate(a=45,[0,0,1])
          color("#000000") cube([7, 7, chip_thick+chip_thick], center=true);
}

module mcu_micro_pro_cradle() {
    gap = 2 + eps;
    difference() {
        translate([-1, -1, 0]) 
            cube([cpu_width+gap, cpu_length+gap, cpu_thick], center=false);
        cube([cpu_width, cpu_length, cpu_thick+2*gap], center=false);
    }
}

module cap_holes(depth, dia) {
    translate([bearing_dia*0.5+4, 4, 0])
        cylinder(h=depth, d=dia);
    translate([-bearing_dia*0.5-4, 4, 0])
        cylinder(h=depth, d=dia);
    translate([bearing_dia*0.5+4, -4, 0])
        cylinder(h=depth, d=dia);
    translate([-bearing_dia*0.5-4, -4, 0])
        cylinder(h=depth, d=dia);
}

module caps(block=0) {
    difference() {
        cap(block);
        translate([0, 0, -eps*0.5])
            cap_holes(cap_thick+eps, m3_hole_dia);
    }
}

module cap(block=0) {
    color("#edbd5f") {
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
}

module top() {
    offset = box_width*0.5;
    difference() {
        color("#edbd5f") union() {
            cube([box_width, box_length, wall_thick], center=false);
            translate([offset, offset, wall_thick]) 
                cylinder(h=wall_thick, d=2*core_dia);
        }
        union() {
            translate([offset, offset, -eps]) {
                cylinder(h=20, d=core_dia+eps*2);
                cylinder(h=wall_thick, d=bearing_dia+eps*2);
                translate([0, 0, -eps*0.5])
                    cap_holes(cap_thick+eps, m3_thread_dia);
            }
        } 
    }
}

module base() {
    off = 1.75 + as_hole_dia*0.5;
    difference() {
        color("#edbd5f") cube([box_width, box_length, box_depth], center=false);
        union() {
            translate([wall_thick, wall_thick, wall_thick+eps]) {
                cube([box_width-2*wall_thick, 
                      box_length-2*wall_thick, 
                      box_depth-wall_thick], center=false);
            }
            // Pushbutton hole
            translate([wall_thick*1.5, box_length-wall_thick*3, box_depth*0.5])
                rotate(-90,[0,1,0]) 
                    cylinder(h=wall_thick*2, d=btn_hole_dia);
            // USB hole
            translate([(box_width-usb_width)*0.5, -eps, wall_thick+cpu_thick]) 
                cube([usb_width,wall_thick+2*eps,usb_thick],center=false);
                    translate([0, 0, -eps*0.5])
            // as5600 mounting holes
            translate([(box_width-as_width)*0.5,box_length-1.5*as_length,0.5])
                as5600_holes(wall_thick*2, m3_thread_dia, off);
        }
    }
    translate([(box_width-as_width)*0.5,
                box_length-1.5*as_length,
                wall_thick-eps]) {
        color("#edbd5f") as5600_cradle();
    }
    translate([(box_width-cpu_width)*0.5, wall_thick ,wall_thick-eps]) {
        color("#edbd5f") mcu_micro_pro_cradle();
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
