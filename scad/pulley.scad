//
// Blinder Copyright Chris Palmer 2018
// nop.head@gmail.com
// hydraraptor.blogspot.com
// GPL3, see COPYING
//
$pp1_colour = grey(95);
$pp2_colour = grey(95);
$vitamin_fa = 2;
$vitamin_fs = 0.1;
include <NopSCADlib/core.scad>

use <NopSCADlib/vitamins/insert.scad>

include <global.scad>

cord_r = 1.3 / 2;
pitch = 6;

holes = 13;

dia = holes * pitch / PI;

wall = 1.25;
width = 2 * (wall + ball_r);

grub_screw = M3_grub_screw;
grub_screw_len = 5;
insert = screw_insert(grub_screw, short = true);
boss_h = 2 * (insert_hole_radius(insert) + wall);
boss_r = shaft_r + 2;

function pulley_d() = dia;
function pulley_h() = width + boss_h;
function pulley_w() = width;
function retainer_h() = boss_h;

module shaft_hole(flat)
    difference() {
        poly_circle(shaft_r);

        if(flat)
            translate([-shaft_r + shaft_flat_d, -shaft_r - 1])
                square([10, 2 *(shaft_r + 1)]);
    }

module pulley(flat = true) {
    difference() {
        rotate_extrude()
            difference() {
                square([dia / 2, width]);

                translate([dia/ 2, width / 2])
                    teardrop_plus(r = cord_r, h = 0);
            }

        for(i = [0 : holes - 1])
            rotate(i * 360 / holes)
                translate([dia/ 2, 0, width / 2])
                    rotate_extrude()
                        intersection() {
                            teardrop_plus(r = ball_r, h = 0);

                            translate([0, -ball_r - 1])
                                square([ball_r + 1, 2 * ball_r + 2]);
                        }
    }
    difference() {
        l = insert_length(insert) + wall;
        x = flat ? -shaft_r + shaft_flat_d : shaft_r;
        hull() {
            cylinder(r = boss_r, h = width + boss_h);

            translate([x, -boss_h / 2, width])
                cube([l, boss_h, boss_h]);

        }
        translate([x + l, 0, width + boss_h / 2])
            rotate([90, 0, 90])
                insert_hole(insert, 3, horizontal = true);
    }
}

module retainer_stl()
    stl("retainer") {
        difference() {
            l = insert_length(insert) + wall;
            x = shaft_r;
            hull() {
                cylinder(r = boss_r, h = boss_h);

                translate([x, -boss_h / 2])
                    cube([l, boss_h, boss_h]);

            }
            translate([x + l, 0, boss_h / 2])
                rotate([90, 0, 90])
                    insert_hole(insert, 3, horizontal = true);

            linear_extrude(50, center = true)
                shaft_hole(false);
        }
    }

module pulley_stl()
    stl("pulley")
        difference() {
            pulley();

            linear_extrude(50, center = true)
                shaft_hole(true);

            if(pulley_h() > shaft_l2)
                translate_z(-eps)
                    poly_cylinder(r = shaft_r, h = round_to_layer(pulley_h() - shaft_l2) + eps);
        }

module idler_stl()
    stl("idler")
        difference() {
            pulley(false);

            linear_extrude(50, center = true)
                shaft_hole(false);
        }

//! 1. Fit the heatfit insert
//! 1. Add the grub screw
module pulley_assembly()
assembly("pulley", ngb = true) {
    stl_colour(pp1_colour) pulley_stl();

    translate([-shaft_r + shaft_flat_d + insert_length(insert) + wall, 0, width + boss_h / 2])
        rotate([90, 0, 90])
            insert(insert);

    translate([-shaft_r + shaft_flat_d + grub_screw_len, 0, width + boss_h / 2])
        rotate([90, 0, 90])
            explode(15, explode_children = true)
                screw(grub_screw, grub_screw_len);
}

pulley_assembly();

//! 1. Fit the heatfit insert
//! 1. Add the grub screw
module idler_assembly()
assembly("idler", ngb = true) {
    stl_colour(pp1_colour) idler_stl();

    translate([shaft_r + insert_length(insert) + wall, 0, width + boss_h / 2])
        rotate([90, 0, 90])
            insert(insert);

    translate([shaft_r + grub_screw_len, 0, width + boss_h / 2])
        rotate([90, 0, 90])
            explode(15, explode_children = true)
                screw(grub_screw, grub_screw_len);
}

translate([0, 30])
    idler_assembly();

//! 1. Fit the heatfit insert
//! 1. Add the grub screw
module retainer_assembly()
assembly("retainer", ngb = true) {
    stl_colour(pp1_colour) retainer_stl();

    translate([shaft_r + insert_length(insert) + wall, 0, boss_h / 2])
        rotate([90, 0, 90])
            insert(insert);

    translate([shaft_r + grub_screw_len, 0, boss_h / 2])
        rotate([90, 0, 90])
            explode(15, explode_children = true)
                screw(grub_screw, grub_screw_len);
}

translate([0, -30])
    retainer_assembly();
