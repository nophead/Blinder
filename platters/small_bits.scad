include <NopSCADlib/core.scad>

use <../scad/blinder.scad>
use <../scad/pulley.scad>


translate([-37, 0])
    switch_slide_stl();

pulley_stl();

translate([31, 0])
    idler_stl();

translate([52, 0])
    retainer_stl();
