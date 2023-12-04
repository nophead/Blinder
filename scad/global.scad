//
// Blinder Copyright Chris Palmer 2018
// nop.head@gmail.com
// hydraraptor.blogspot.com
// GPL3, see COPYING
//
include <NopSCADlib/vitamins/gear_motors.scad>

//motor = GMAG_404327;
motor = FIT0492_A;
shaft_r = gm_shaft_r(motor);
shaft_flat_d = gm_shaft_flat_w(motor);
shaft_l = gm_shaft_length(motor);
shaft_l2 = gm_shaft_flat_l(motor);

ball_r = 4.4 / 2;
