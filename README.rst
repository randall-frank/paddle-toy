PaddleToy
=========

|MIT| |openscad| |drawio|

.. |MIT| image:: https://img.shields.io/badge/License-MIT-yellow.svg
   :target: https://opensource.org/licenses/MIT

.. |openscad| image:: https://img.shields.io/badge/OpenSCAD-57A143.svg
    :target: https://github.com/openscad/openscad/

.. |drawio| image:: https://img.shields.io/badge/draw.io-DC6803.svg
    :target: https://www.drawio.com/


Overview
--------
This is a very simple project to create a dual "paddle" controller.  The basic
design is to use a pair of hall effects sensors attached to a 'paddle' dial and
a pair of push buttons to recreate the classic paddle controllers common in the
1980's on Apple II, Atari 2600 and other early home computers.  

This is an extremely simple design.  Connect the inputs to an Arduino Micro Pro
micro-controller and set the micro-controller to emulate a USB joystick.  The 
cases are 3D printed. Standard RC wheels can be used as the dials.
 
Tools used in this project:

- draw.io used to create images/diagrams
- Arduino IDE used to compile the source and program the micro-controller
- OpenSCAD used to create the STL files for 3D printing
- Logarithm, exponential, square root, power

Design
------
Rough device design:

.. raw:: html

   <p align="center">
     <img src="drawing.svg" style="width:600px; height:auto;">
   </p>


STL model (OpenSCAD):

.. raw:: html

   <p align="center">
      <a href="https://www.viewstl.com/embed/viewer/v2/?url=https%3A%2F%2Fraw.githubusercontent.com%2Frandall-frank%2Fpaddle-toy%2Frefs%2Fheads%2Fmain%2Fpaddletoy.stl" target="_blank" rel="noopener noreferrer">
         <img src="stl.png" style="width:600px; height:auto;">
      </a>
   </p>


Circuit:

.. raw:: html

   <p align="center">
     <img src="circuit.png" style="width:600px; height:auto;">
   </p>

Partlist
~~~~~~~~
- Arduino Micro Pro - 16Mhz ATmega32u4 
- AS5600 Magnetic Encoder
- Pushbutton - panel mount, momentary contact, normally open
- Screws: 8 M2.5, 1 M3.5
- Bearing: 16mm O.D., 5mm I.D.
- Axel: 5mm dia, 15mm long
- PLA filament
- Wire

.. note::
    The AS5600 needs to be in analog mode.  In some cases, the resistor R4 (near the GP0 pin) 
    needs to be removed.  With the resistor in place, the output on GP0 is PWM.  With it 
    removed, the output is an analog signal from [GND, VCC].


Things To Do
~~~~~~~~~~~~
- Write the joystick emulation code
- Write the OpenSCAD code for the Design
- Add a 'zeroing' mode that sets where 'zero' is for rotation


License
-------
`PaddleToy` is licensed under the MIT license.
