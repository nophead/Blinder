//
// Blinder Copyright Chris Palmer 2023
// nop.head@gmail.com
// hydraraptor.blogspot.com
// GPL3, see COPYING
//
include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/pcbs.scad>
use <NopSCADlib/utils/rounded_polygon.scad>

Blinder = pcb("Blinder", "PCB Blinder", [42.0, 45.0, 1.6], colour = grey(90), hole_d = 3.2, holes = [[28.00096, 8.001]],
    parts_on_bom = true,
    polygon = rounded_polygon([
        [-21.0, -22.5, 0],
        [ 11.0, -22.5, 0],
        [ 13.0, -13.5,  2],
        [ 21,  -11.5,  0],
        [ 19,   20.5,  -2],
        [-19,   20.5,  -2],
    ]),

    components = [
        [21.5, 34.9625, 90, "smd_cap", CAP0805, 0.8, "100n"],
        [6.513, 14.6185, 90, "smd_cap", CAP0805, 0.8, "220n"],
        [23.15, 4.0775, -90, "smd_cap", CAP0805, 0.8, "100n"],
        [13.625, 14.47, 90, "smd_cap", CAP0805, 0.8, "15n"],
        [23.15, 9.1575, -90, "smd_cap", CAP0805, 0.8, "15n"],
        [40.0 - led_pitch(LED3mm) / 2, 40.0, 180, "led", LED3mm, "green", 2.0, 5],
        [11.72, 1.35, 180, "multiwatt11", "L6203", 3],
        [5.37, 19.55, 0, "molex_hdr", 02, undef],
        [27.0, 15.02, 180, "jst_ph", 3, false],
        [37.0, 15.0, 180, "jst_ph", 3, false],
        [18.34, 15.74, 180, "jst_ph", 2, false],
        [15.022, 30.583, 90, "smd_res", RES0805, "10K"],
        [15.0, 34.79, 90, "smd_res", RES0805, "10K"],
        [15.022, 25.757, -90, "smd_res", RES0805, "10K"],
        [12.72, 20.82, 180, "smd_res", RES0805, "10K"],
        [21.5, 20.0, 90, "smd_res", RES0805, "10K"],
        [35.0, 41.0, 90, "smd_res", RES0805, "2K2"],
        [11.339, 14.597, 90, "smd_res", RES0805, "1K"],
        [8.545, 14.581, 90, "smd_res", RES0805, "1K"],
        [28.6442, 40.9983, 0, "button", button_6mm_7, true],
        [18.45, 41.0, 0, "button", button_6mm_7, true],
        [7.91, 25.9 + pcb_length(tiny_buck) / 2 - pcb_holes(tiny_buck)[0].x, 90, "pcb", 1.2, tiny_buck],
        [36.668, 27.277, 0, "pcb", 0, ESP_12F],
    ],
    grid = [18.0, 20.82, 1, 6, silver, inch(0.1), inch(0.1)
]);

//! 1. Use a paste mask to apply solder paste to the SMD pads.
//! 1. Place the SMD parts on the solder.
//! 1. Use an oven or hotplate to reflow the solder.
//! 1. Alternatively the SMD parts and pads are big enough to hand solder.
//! 1. Hand solder the through hole connectors, switches, LED and L6203. The LED's flange should align with the board edge.
//! 1. Solder wires into the tink_buck converter, mount it on a double sided sticky pad and solder the wires to the PCB.
//! 1. Crop all the leads short on the underside of the board.
module blinder_PCB_assembly() pose(a = [55, 0, 25 + 180], exploded = true)
    assembly("blinder_PCB") {
        pcb(Blinder);
    }

if($preview)
    blinder_PCB_assembly();

function Blinder_pcb() = Blinder;
