//
// Blinder Copyright Chris Palmer 2018
// nop.head@gmail.com
// hydraraptor.blogspot.com
// GPL3, see COPYING
//

//!
//! Tasmota roller blind open / close mechanism
//!
$pp1_colour = grey(95);
$pp2_colour = grey(95);
$vitamin_fa = 2;
$vitamin_fs = 0.1;
include <NopSCADlib/core.scad>
include <global.scad>

use <pulley.scad>
use <NopSCADlib/utils/maths.scad>
use <NopSCADlib/utils/thread.scad>
use <NopSCADlib/utils/sector.scad>
use <NopSCADlib/utils/round.scad>
use <NopSCADlib/vitamins/insert.scad>
use <NopSCADlib/vitamins/pcb.scad>
use <NopSCADlib/vitamins/led.scad>
use <NopSCADlib/vitamins/button.scad>

include <NopSCADlib/vitamins/ball_bearings.scad>
include <NopSCADlib/vitamins/microswitches.scad>
use <pcb.scad>

switch_pos = 0; //[-1: 1]
shaft_rot = 0; // [0: 360]
show_motor = true;
show_cover = true;
show_top = true;
show_base = true;
show_pcb = true;
show_bracket = true;
motor_alpha = 1; // [0: 0.1: 1]
ymax = 1; // [-1 : 0.1 : 1]
/*[Hidden]*/

use <NopSCADlib/vitamins/rod.scad>
wall = 1.75;
side_wall = 2;

bearing = BB686;

top_clearance = max(-gm_motor_pos(motor).y + gm_motor_d(motor) / 2, gm_shaft_offset(motor).y + gm_box_width(motor) / 2) + 1;
bot_clearance = 1;
bearing_wall = wall;
axle_d = 5.98;
studding_d = 8;
nut = M8_nut;
washer = M6_washer;
microswitch = small_microswitch;
switch_size = microswitch_size(microswitch);
switch_extent = -microswitch_lower_extent(microswitch);

lever = [18 - switch_size.x / 2, 3.6, 0.5];
pivot = [-switch_size.x / 2 + 1.25, switch_size.y / 2 - 1];
op = 9.5 - switch_size.y / 2;

turns = 13;
travel = turns * metric_coarse_pitch(studding_d);
slide_slot = 8;
studding_length = ceil(switch_extent + op + nut_thickness(nut) + travel + slide_slot / 2 + op  - switch_size.y / 2);
pcb = Blinder_pcb();
pcb_cutout = 10;
pcb_z = 2;
pcb_size = pcb_size(pcb);
pcb_screw = alternate_screw(hs_cs_cap, pcb_screw(pcb));

front_t = 4;
pcb_back_from_motor = 4;
switch_back = front_t + 1 + studding_length + switch_size.y / 2 + switch_extent;
switch_top = pulley_d() / 2 + bot_clearance + switch_size.z / 2;

front_height = bot_clearance + 1.5 * pulley_d() + top_clearance;

base_length = max(front_t + gm_depth(motor) + pcb_back_from_motor, (switch_top > front_height - pcb_size.y) ? switch_back + pcb_size.x - pcb_cutout : 0);
supported_length = studding_length + 2 * bb_width(bearing);
base_width = max(gm_box(motor).x + 4, (6.75 * sqrt(gm_motor_d(motor) / 27.5) + pcb_z - gm_motor_pos(motor).x + gm_motor_d(motor) / 2 + gm_box(motor).x / 2 + 2));
base  = [base_length, base_width, 4, 1];

front = [front_t, base.y, front_height, base[3]];

shaft_pos = gm_shaft_pos(motor);

motor_pos  = [base.x / 2 - front.x, -base.y / 2 + 2 + gm_box(motor).x / 2, front.z + gm_shaft_offset(motor).y - top_clearance];
pulley_pos = motor_pos + [shaft_pos.z + shaft_l - max(shaft_l2, pulley_h()), -shaft_pos.x, -shaft_pos.y];
idler_pos  = pulley_pos - [0, 0, pulley_d()];
pcb_pos = [-base.x / 2 + pcb_size.x / 2,
           front.y / 2 - pcb_z,
           front.z - pcb_size.y / 2];

bearing_pos = idler_pos - [bb_width(bearing) /2 + spring_washer_thickness(washer), 0, 0];


studding_pos = bearing_pos - [bb_width(bearing) / 2, 0, 0];
axle_pos = studding_pos + [ceil(bb_width(bearing) + spring_washer_thickness(washer) + pulley_h()), 0, 0];

microswitch_pos = bearing_pos + [-bb_width(bearing) / 2 - switch_extent, studding_d / 2 + 1 + lever.x, 0];
microswitch2_pos = microswitch_pos  - [2 * op + nut_thickness(nut) + travel, 0, 0];

axle_length = ceil(studding_length + 2 * bb_width(bearing) + 2 * spring_washer_thickness(washer) + pulley_h() + retainer_h() + 2);
bearing2_pos = bearing_pos - [studding_length + bb_width(bearing), 0, 0];

switch_screw = find_screw(hs_cap, microswitch_hole_d(microswitch));
switch_insert = screw_insert(switch_screw);

slide_screw = M3_cap_screw;
slide_washer = screw_washer(slide_screw);
slide_insert = screw_insert(slide_screw, short = true);
channel_wall = 1.75;
channel = [slide_slot + washer_diameter(slide_washer) + 1, washer_diameter(slide_washer) + 2 * channel_wall + 1, channel_wall];

mount_screw = M3_cap_screw;
mount_insert = screw_insert(mount_screw, short = true);
mount_boss_r = insert_boss_radius(mount_insert, wall);

cover = [base.x + side_wall,
         base.y + 2 * side_wall,
         front.z + wall];

module mount_screw_positions() {
    for(side = [-1, 1])
        translate([base.x / 2 - mount_boss_r, side * (base.y / 2 - mount_boss_r)])
            vflip()
                children();

    translate([base.x / 2 - supported_length + mount_boss_r, 0])
        vflip()
            children();
}

case_screw = M3_cs_cap_screw;
case_insert = screw_insert(case_screw, short = true);
case_boss_r = insert_boss_radius(case_insert, wall);
case_boss_h = insert_hole_length(case_insert) + 1;

module case_screw_positions()
    for($y = [-1, 1], $z = [-1,1])
        translate([base.x / 2 - base[3] - case_boss_r, $y * base.y / 2, $z > 0 ? front.z - case_boss_r : base.z + insert_hole_radius(case_insert)])
            rotate([90 * $y, 0, 0])
                children();

module lever_microswitch() {
    microswitch(microswitch);

    end_pos = [lever.x, op - lever.z];
    button = microswitch_button_pos(microswitch);
    angle = atan2(end_pos.y - button.y, end_pos.x - button.x);
    length = sqrt(sqr(end_pos.y - button.y) + sqr(end_pos.x - button.x));
    dx = button.x - pivot.x - lever.z / 2;
    extension = dx / cos(angle);
    dy = extension * sin(angle);
    color(silver) {
        translate(end_pos)
            rotate(angle)
                translate([-length - extension, 0, -lever.y / 2])
                    cube([length + extension, lever.z, lever.y]);

        translate([pivot.x - lever.z / 2, pivot.y, -lever.y / 2])
            cube([lever.z, button.y - pivot.y - dy, lever.y]);

        translate([pivot.x + lever.z / 2, button.y - dy])
            linear_extrude(lever.y, center = true)
                sector(r = lever.z, start_angle = 90 + angle, end_angle = 180, $fn = fn);
    }
}

module slide_screw_pos(z = base.z)
    translate([microswitch2_pos.x + switch_size.y / 2 + channel.x / 2, microswitch2_pos.y, z])
        children();

module base_stl() {
    rib = [10 + front.x, channel_wall, front.z - base.z];

    stl("base") {
        difference() {
            union() {
                rounded_rectangle(base, base[3]);

                slide_screw_pos()
                    for(side = [-1, 1])
                        translate([channel.x / 2 - washer_radius(slide_washer), side * (channel.y + channel_wall + 0.2) / 2])
                            cube([channel.x, channel_wall, 2], center = true);

                for(side = [-1, 1])
                    translate([base.x / 2 - rib.x / 2, side * (base.y - rib.y) / 2, base.z])
                        rounded_rectangle(rib, channel_wall / 2 - eps);

                translate([base.x / 2 - front.x / 2, 0])
                    rounded_rectangle(front, front[3]);

                w = bb_diameter(bearing) + 2 * bearing_wall;
                z = bearing_pos.z - w / 2;

                translate(bearing_pos + [-bb_width(bearing) / 2 - bearing_wall, -w / 2, -bearing_pos.z])
                    cube([bearing_wall + bb_width(bearing) - 0.5, w, w + z]);

                translate(bearing2_pos + [-bb_width(bearing) / 2, -w / 2, -bearing_pos.z])
                    cube([bearing_wall + bb_width(bearing), w, w + z]);

                translate((bearing_pos + bearing2_pos) / 2 - [0, nut_flat_radius(M8_nut) + bearing_wall / 2, z / 2])
                    cube([bearing_pos.x - bearing2_pos.x,  bearing_wall, w + z], center = true);

                translate([microswitch_pos.x, microswitch_pos.y])
                    linear_extrude(microswitch_pos.z - switch_size.z / 2)
                        round(1)
                            union() {
                                square([switch_size.y, switch_size.x], center = true);

                                rotate(90)
                                    microswitch_hole_positions(microswitch)
                                        circle(insert_boss_radius(switch_insert, 1.7));
                            }
                case_screw_positions()
                    hull() {
                        h = case_boss_h;

                        cylinder(r = case_boss_r, h = h);

                        if($z > 0)
                            translate([(case_boss_r + front[3] - front.x), - (case_boss_r + h - rib.y) * $y, rib.y])
                                cube(eps);
                    }
            }


            translate(motor_pos)
                rotate([-90, 0, -90]) {
                    translate(gm_shaft_offset(motor))
                        rotate(180)
                            teardrop_plus(r = gm_boss(motor).x / 2 + 0.2, h = 100, center = true);

                    gm_screw_positions(motor)
                        rotate(180)
                            teardrop_plus(r = screw_clearance_radius(gm_screw(motor)), h = 100, center = true);
                }

            translate(bearing_pos)
                rotate([90, 0, 90])
                    translate_z(-bb_width(bearing) / 2) {
                        teardrop_plus(r = bb_diameter(bearing) / 2 , h = 100, center = false);

                        teardrop_plus(r = bb_diameter(bearing) / 2 - 1.5 , h = 100, center = true);
                    }

            translate(bearing2_pos)
                rotate([90, 0, -90])
                    translate_z(-bb_width(bearing) / 2) {
                        teardrop_plus(r = bb_diameter(bearing) / 2 , h = 100, center = false);

                        teardrop_plus(r = bb_diameter(bearing) / 2 - 1.5 , h = 100, center = true);
                    }

            translate(microswitch_pos)
                rotate(90)
                    microswitch_hole_positions(microswitch)
                        translate_z(-switch_size.z / 2)
                            insert_hole(switch_insert, 3);

            slide_screw_pos()
                insert_hole(slide_insert);

            mount_screw_positions()
                insert_hole(mount_insert);

            case_screw_positions()
                rotate(90 - 90 *$y)
                    insert_hole(case_insert, horizontal = true);

            translate([-base.x /2 + 5, base.y / 2])
                rounded_rectangle([4, 4, 10], 1, center = true);
        }
    }
}

module switch_slide_stl()
    stl("switch_slide") {
        difference() {
            union() {
                linear_extrude(microswitch_pos.z - switch_size.z / 2 - base.z)
                    round(1)
                        union() {
                            square([switch_size.y, switch_size.x], center = true);

                            rotate(-90)
                                microswitch_hole_positions(microswitch)
                                    circle(insert_boss_radius(switch_insert, 1.7));
                        }

                translate([switch_size.y / 2, -channel.y / 2])
                    cube(channel);

                for(side = [-1, 1])
                    translate([switch_size.y / 2 - 2, side * (channel.y - channel_wall) / 2 - channel_wall / 2])
                        cube([channel.x + 2, channel_wall, 3 * channel_wall]);
            }
            rotate(-90)
                microswitch_hole_positions(microswitch)
                    translate_z(microswitch_pos.z - switch_size.z / 2 - base.z)
                        insert_hole(switch_insert, 3);

            translate([switch_size.y / 2 + channel.x / 2, 0])
                slot(r = screw_radius(slide_screw), l = slide_slot, h = 10, center = true);
        }
    }

//! 1. Fit the heatfit inserts into the slide.
//! 1. Screw the microswitch to the slide using 10mm M2 cap screws spring washers and plain washers.
//! 1. Solder two wires to the outer pins.
module switch_slide_assembly()
    assembly("switch_slide") {
        stl_colour(pp1_colour) render() switch_slide_stl();

        translate_z(microswitch_pos.z - base.z) {
            rotate([0, 0, -90 ])
                explode(25)
                    lever_microswitch();

            rotate(-90)
                microswitch_hole_positions(microswitch) {
                    translate_z(-switch_size.z / 2)
                        insert(switch_insert);

                    explode(25, explode_children = true)
                        translate_z(switch_size.z / 2)
                            screw_and_washer(switch_screw, screw_length(switch_screw, switch_size.z, 2, insert = true), true);
                }
        }
    }

bracket_screw = No8_screw;
bracket_washer = screw_washer(bracket_screw);
bracket_length = supported_length + max(shaft_l + gm_boss(motor).z - front.x - gm_screw_boss(motor)[1], axle_pos.x - base.x / 2) + 1;
bracket_thickness = 5;
bracket_slot = 8;

module bracket_screw_positions() {
    for(side = [-1, 1])
        translate([bracket_thickness + bracket_slot / 2 + washer_radius(bracket_washer), side * (base.y / 4 + bracket_thickness / 2)])
            children();

        translate([bracket_length - washer_radius(bracket_washer) - bracket_slot / 2, 0])
            children();
}

module bracket_stl()
    stl("bracket") {
        length = bracket_length;
        height = length;
        thickness = bracket_thickness;
        rad = 10;

        slot = bracket_slot;

        linear_extrude(thickness)
            difference() {
                hull() {
                    translate([0, - base.y / 2])
                        square([thickness + slot + screw_clearance_radius(bracket_screw) + washer_radius(bracket_washer), base.y]);

                    translate([length - rad, 0])
                        circle(rad);
                }
                bracket_screw_positions()
                    slot(screw_clearance_radius(bracket_screw), slot, 0);
            }

        difference() {
            rotate([180, -90, 0]) {
                linear_extrude(thickness)
                    difference() {
                        x = length - supported_length + base.x / 2;
                        hull() {
                            translate([0, - base.y / 2])
                                square([eps, base.y]);

                            translate([x, 0])
                                rotate(180)
                                    mount_screw_positions()
                                        circle(mount_boss_r);
                        }
                        translate([x, 0])
                            rotate(180)
                                mount_screw_positions()
                                    rotate(90)
                                        teardrop_plus(r = screw_clearance_radius(mount_screw));


                    }

            }
        }
        hull() {
            translate([bracket_length - slot - washer_diameter(bracket_washer), 0, thickness])
                cube([eps, thickness, eps], center = true);

            translate([thickness, 0, bracket_length - mount_boss_r - washer_radius(screw_washer(mount_screw)) - 1])
                cube([eps, thickness, eps], center = true);

            translate([thickness, 0, thickness])
                cube([eps, thickness, eps], center = true);
        }
    }

module dimv(p1, p2, z, max = inf, offset = 1) { //! Draw a vertical dimension showing the x,y distance between two points
    for(p = [p1, p2])
        translate(p + [0, 0, offset])
            cylinder(r = 0.1, h = z - p.z - offset);

    mid = (p1 + p2) / 2;
    d = norm(vec2(p1 - p2));
    text = str(d, "mm");
    tw = d - 2;
    if(max < tw)
        for(side = [-1, 1])
            translate([mid.x, mid.y, 0] + [side * d / 2, 0, z - max / len(text) / 1.75])
                rotate([0, -side * 90, 0])
                    cylinder(r = 0.1, h = (d - max) / 2 - 1);

    translate([mid.x, mid.y, z])
        rotate([90, 0, 0])
            resize([min(tw, max), 0], auto = true)
                linear_extrude(0.1)
                    text(text, halign = "center", valign = "top");
}

//! * Turn down the ends of the studding to 5.96mm to fit through the bearings.
module rod_assembly()
    assembly("rod", big = true) {
        if(exploded())
            color("black") {
                h = 15;
                p0 = axle_pos + [0, 0, axle_d / 2];
                p1 = studding_pos + [0, 0, studding_d / 2];
                p2 = studding_pos + [-studding_length, 0, studding_d / 2];
                p3 = axle_pos + [-axle_length, 0, axle_d / 2];

                max = p2.x - p3.x - 2;
                dimv(p0, p1, axle_pos.z + h, max);
                dimv(p1, p2, axle_pos.z + h, max);
                dimv(p2, p3, axle_pos.z + h, max);
                dimv(p0, p3, axle_pos.z + 2 * h, 2 * max);
            }

        translate(axle_pos)
            rotate([0, -90, 0])
                not_on_bom()
                    rod(axle_d, axle_length, center = false);

        translate(studding_pos)
            rotate([0, -90, 0])
                let($show_threads = true)
                    not_on_bom()
                        studding(studding_d, studding_length, false);
        hidden()
            studding(studding_d, axle_length, false);
    }

module cover_stl() {
    size = cover;

    boss_r = screw_clearance_radius(pcb_screw) + wall;
    module shape()
        hull() {
            square([base.x, size.y], center = true);

            for(side = [-1, 1])
                translate([-base.x / 2, side * (size.y / 2 - side_wall)])
                    circle(side_wall);
        }

    stl("cover") {
        if(show_top)
            linear_extrude(wall)
                difference() {
                    shape();

                    led = pcb_component(pcb, "led");

                    translate([pcb_pos.x - pcb_size.x / 2 + led.x, -base.y / 2 + pcb_z + pcb_size.z + led[6]])
                        poly_circle(led_hole_radius(led[4]));

                    for(i = [0, 1]) {
                        button = pcb_component(pcb, "button", i);
                        b = button[4];

                        translate([pcb_pos.x - pcb_size.x / 2 + button.x, -base.y / 2 + pcb_z + pcb_size.z + square_button_ra_z(b)])
                            poly_circle(square_button_d(b) / 2 + 0.1);
                    }
                }

        difference() {
            union() {
                linear_extrude(size.z, convexity = 5)
                    difference() {
                        shape();

                        offset(-side_wall)
                            shape();

                        square([base.x, base.y], center = true);
                    }

                rail = 1.6;
                h = 3.5;
                clearance = 0.1;
                for(y = [0, pcb_size.z + clearance + pcb_z]) {
                    translate([base.x / 2 - size.x + side_wall, -base.y / 2 - eps + y])
                        hull() {
                            cube([rail + eps, pcb_z, pcb_size.y + wall]);

                            translate([0, y ? pcb_z / 4 : 0])
                                cube([rail + eps, 0.75 * pcb_z, pcb_size.y + wall + 5]);
                        }

                    translate([base.x / 2 - size.x + side_wall + pcb_size.x - rail, -base.y / 2 + y])
                        cube([rail * 3, pcb_z, wall + h]);
                }
                translate([pcb_pos.x + pcb_size.x / 2 + clearance, -base.y / 2 - eps])
                    cube([rail * 2 - 0.2, pcb_z * 2, wall + h]);

                translate_z(size.z)
                    vflip()
                        translate(pcb_pos)
                            rotate([90, 0, 0])
                                pcb_hole_positions(pcb)
                                    vflip()
                                        hull() {
                                            cylinder(r = boss_r, h = pcb_z + eps);

                                            translate([0, -boss_r - pcb_z , pcb_z + eps])
                                                cube(eps);
                                        }

            }

            translate_z(size.z)
                vflip() {
                    case_screw_positions()
                        rotate(-90 - 90 *$y) {
                            teardrop_plus(r = screw_clearance_radius(case_screw), h = 10, center = true);

                            translate_z(-side_wall)
                                hflip()
                                    screw_tearsink(case_screw);
                        }

                    translate(pcb_pos)
                        rotate([90, 0, 0])
                            pcb_hole_positions(pcb)
                                rotate(180) {
                                    teardrop_plus(r = screw_clearance_radius(pcb_screw), h = 10, center = true);

                                    translate_z(-side_wall - pcb_z)
                                        hflip()
                                            screw_tearsink(pcb_screw);
                                }
                }

         }
    }
}

//! 1. Fit the 8 M3 inserts, 4 in the ribs, 3 in the base and 1 for the slide
//! 1. Fit two M2 inserts for the microswitch.
//! 1. Place the M8 nut in a central position and screw in the studding.
//! 1. Crush the M8 spring washers with pliers as they are used just as spacers.
//! 1. Fit the bearings and spring washers and secure in place with the pulley and retainer grub screws.
//! 1. Solder two wires to the outer pins of the microswitch and screw it in place.
//! 1. Screw the slide in place in the central position.
module base_assembly() pose([ 34.00, 0.00, 322.70 ])
assembly("base") {
    if(show_base)
        stl_colour(grey(95))
            base_stl();

    translate(bearing_pos)
        rotate([-90, 0, -90])
            explode(25, explode_children = true)
                ball_bearing(bearing)
                    explode(5, explode_children = true)
                        spring_washer(M6_washer)
                            explode(5)
                                idler_assembly();

    translate(bearing2_pos)
        rotate([90, 0, -90])
            explode(25, explode_children = true)
                ball_bearing(bearing)
                    explode(5, explode_children = true)
                        spring_washer(M6_washer)
                            rotate(shaft_rot)
                                explode(5)
                                    retainer_assembly();

    rod_assembly();

    translate([microswitch_pos.x - op, studding_pos.y, studding_pos.z])
        rotate([0, -90, 0])
            nut(M8_nut, brass = true);

    translate(microswitch_pos) {
        rotate([0, 180, 90])
            explode(-25, explode_children = true)
                lever_microswitch();

        rotate(90)
            microswitch_hole_positions(microswitch) {
                translate_z(-switch_size.z / 2)
                    insert(switch_insert);

                translate_z(switch_size.z / 2)
                    explode(20, explode_children = true)
                        screw_and_washer(switch_screw, screw_length(switch_screw, switch_size.z, 2, insert = true), true);
            }
    }

    slide_screw_pos()
        insert(slide_insert);

    slide_screw_pos(base.z + channel.z)
        explode(30, explode_children = true)
            screw_and_washer(slide_screw, screw_length(slide_screw, channel.z, 2, insert = slide_insert), true);

    translate([microswitch2_pos.x + slide_slot * switch_pos / 2, microswitch2_pos.y, base.z])
        explode(30)
            switch_slide_assembly();

    case_screw_positions()
        vflip()
            insert(case_insert);

    mount_screw_positions()
        insert(mount_insert);

}

//! 1. Introduce the motor and pulley trapping the ball chain between the pulley and the idler and then screw the motor in place.
//! 1. Solder wires to the motor.
//! 1. Crimp JST plugs to the motors and switch wires. Use the schematic to get the correct pins.
module motor_assembly()
assembly("motor") {
    base_assembly();

    translate(pulley_pos)
        rotate([-90, 0, -90])
            explode(25)
                pulley_assembly();

    translate(motor_pos)
        rotate([-90, 0, -90]) {
            screw = gm_screw(motor);

            if(show_motor)
                explode(-15)
                    gear_motor(motor, motor_alpha);

            translate_z(front.x)
                gm_screw_positions(motor)
                    screw(screw, screw_length(screw, front.x + gm_screw_depth(motor), 0));
        }
}


//! 1. Screw the bracket to the bottom of the base using 3 8mm M3 cap screws and washers.
//! 1. Screw the bracket to the wall using rawl plugs, No8 screws and M5 washers.
//! 1. Slide it down to tension the ball chain before tightening the screws.
//! 1. Connect the PCB to the switches, motor and 12V power.
//! 1. While controlling the blind with the buttons: adjust the closed position by losening the idler pulley and rotating it on the shaft.
//! 1. Then set the open position by adjustinge the sliding microswitch.
module bracket_assembly()
assembly("bracket") {
    if(show_bracket) {
        translate([bracket_length - supported_length + base.x / 2, 0])
            rotate([180, 90, 0]) {
                stl_colour(pp1_colour) bracket_stl();

                translate_z(bracket_thickness)
                    bracket_screw_positions()
                        screw_and_washer(bracket_screw, 30);
            }

        mount_screw_positions()
            translate_z(bracket_thickness)
                screw_and_washer(mount_screw, screw_length(mount_screw, bracket_thickness, 1, insert = mount_insert));
    }
    motor_assembly();
}

//! 1. Cut away the support material under the PCB spacer boss.
//! 1. Place the PCB into the large guide and level with the top of the small guide and then slide forwards.
//! 1. Secure with the screw, washer and nut.
module cover_assembly() pose(a =[149.50, 0.00, 1.20], exploded = true)
assembly("cover") {
    if(show_cover)
        translate_z(front.z + wall)
            vflip()
                stl_colour(pp1_colour)
                    clip(ymax = ymax * cover.y / 2 + eps)
                        cover_stl();

    if(show_pcb)
        translate(pcb_pos)
            rotate([90, 0, 0]) {
                let($show_plugs = true) blinder_PCB_assembly();

                pcb_hole_positions(pcb) {
                    translate_z(-pcb_z - side_wall)
                        vflip()
                            screw(pcb_screw, screw_length(pcb_screw, side_wall + pcb_z + pcb_size.z, 1, nyloc = true));

                    translate_z(pcb_size.z)
                        nut_and_washer(screw_nut(pcb_screw), true);
                }
            }
}

//! 1. Place the 12V power cable in the slot in the base.
//! 1. Place the cover assembly over the base and secure with four screws.
module main_assembly()
assembly("main") {

    cover_assembly();

    if(show_cover)
        case_screw_positions()
            vflip()
                translate_z(side_wall)
                    screw(case_screw, screw_length(case_screw, side_wall, 0, insert = case_insert));

    bracket_assembly();
}

if($preview)
    main_assembly();
else
    base_stl();
