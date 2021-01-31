/********************************************************
 * Jewelry Box - vsergeev
 * https://github.com/vsergeev/3d-jewelry-box
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 01/31/2021
 *      * Initial release.
 ********************************************************/

/* [Basic] */

part = "both"; // [both, base, lid]

// in mm
box_diameter = 20;

// in mm
box_length = 40;

// text
box_text = "TEXT";

// text size
box_text_size = 9;

// text font
box_text_font = "Liberation Mono:style=Bold";

// add divider
box_divider = true;

/* [Magnet] */

// add magnet
box_magnet = true;

// in mm
box_magnet_diameter = 6;

// in mm
box_magnet_thickness = 1;

/* [Advanced] */

// percentage of diameter
box_base_width = 0.50; // [0:0.01:1]

// in mm
box_wall_thickness = 2.5;

// in mm
box_dovetail_clearance = 0.125;

// in mm
box_magnet_xy_clearance = 0.10;

// in mm
box_magnet_z_clearance = 0.30;

// in mm
box_text_depth = 1.25;

// in degrees
box_dovetail_angle = 60;

// percentage of wall thickness
box_dovetail_width = 0.55; // [0:0.01:1]

// percentage of wall thickness
box_dovetail_height = 0.50; // [0:0.01:1]

/* [Hidden] */

$fn = 100;

fudge_factor = 0.1;

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module profile_box() {
    cutoff_offset = sqrt(pow(box_diameter / 2, 2) - pow(box_base_width * box_diameter / 2, 2));

    difference() {
        circle(d=box_diameter);

        /* Trim top */
        translate([0, box_diameter / 2 + cutoff_offset, 0])
            square(box_diameter, center=true);

        /* Trim bottom */
        translate([0, - box_diameter / 2 - cutoff_offset, 0])
            square(box_diameter, center=true);
    }
}

module profile_box_lid() {
    wall_offset = box_diameter / 2 - box_wall_thickness + box_dovetail_clearance * (1 / sin(box_dovetail_angle) + 1 / tan(box_dovetail_angle));
    dovetail_width = box_dovetail_width * box_wall_thickness;
    dovetail_height = box_dovetail_height * box_wall_thickness;

    difference() {
        profile_box();

        /* Dovetail */
        polygon([[0, box_dovetail_clearance], [wall_offset + dovetail_width, box_dovetail_clearance],
                 [wall_offset + dovetail_width - dovetail_height / tan(box_dovetail_angle), -dovetail_height + box_dovetail_clearance],
                 [box_diameter, -dovetail_height + box_dovetail_clearance], [box_diameter, -box_diameter],
                 [-box_diameter, -box_diameter], [-box_diameter, -dovetail_height + box_dovetail_clearance],
                 [-(wall_offset + dovetail_width - dovetail_height / tan(box_dovetail_angle)), -dovetail_height + box_dovetail_clearance],
                 [-(wall_offset + dovetail_width), box_dovetail_clearance]]);
    }
}

module profile_box_base() {
    wall_offset = box_diameter / 2 - box_wall_thickness;
    dovetail_width = box_dovetail_width * box_wall_thickness;
    dovetail_height = box_dovetail_height * box_wall_thickness;

    difference() {
        profile_box();

        /* Dovetail */
        polygon([[0, 0], [wall_offset + dovetail_width, 0],
                 [wall_offset + dovetail_width - dovetail_height / tan(box_dovetail_angle), -dovetail_height],
                 [box_diameter, -dovetail_height], [box_diameter, box_diameter],
                 [-box_diameter, box_diameter], [-box_diameter, -dovetail_height],
                 [-(wall_offset + dovetail_width - dovetail_height / tan(box_dovetail_angle)), -dovetail_height],
                 [-(wall_offset + dovetail_width), 0]]);
    }
}

module profile_interior() {
    difference() {
        circle(d=box_diameter - 2 * box_wall_thickness);

        /* Trim top half */
        translate([0, box_diameter / 2 + fudge_factor, 0])
            square(box_diameter, center=true);
    }
}

module profile_divider() {
    difference() {
        /* Slightly oversized interior profile for clean union */
        scale([1.01, 1.01, 1])
            profile_interior();

        /* Middle slot */
        square([box_wall_thickness, box_diameter], center=true);

        /* Trim off extra from scaling */
        translate([0, box_diameter/2, 0])
            square([box_diameter, box_diameter], center=true);
    }
}

module profile_magnet() {
    cutoff_offset = sqrt(pow(box_diameter / 2, 2) - pow(box_base_width * box_diameter / 2, 2));

    translate([0, cutoff_offset / 2, 0])
        circle(d=box_magnet_diameter + box_magnet_xy_clearance);
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module box_base() {
    union() {
        difference() {
            union() {
                /* Side */
                linear_extrude(box_wall_thickness)
                    profile_box();

                /* Base with dovetails */
                translate([0, 0, box_wall_thickness])
                    linear_extrude(box_length - 2 * box_wall_thickness, convexity=2)
                        profile_box_base();
            }

            /* Interior cutout */
            translate([0, 0, box_wall_thickness])
                linear_extrude(box_length - 3 * box_wall_thickness)
                    profile_interior();

            /* Optional magnet */
            if (box_magnet)
                translate([0, 0, box_wall_thickness - box_magnet_thickness - box_magnet_z_clearance])
                    linear_extrude(box_magnet_thickness + box_magnet_z_clearance + fudge_factor)
                        profile_magnet();
        }

        /* Optional divider */
        if (box_divider)
            translate([0, 0, box_wall_thickness + (box_length - 3.5 * box_wall_thickness)/2])
                linear_extrude(box_wall_thickness / 2)
                    profile_divider();
    }
}

module box_lid() {
    cutoff_offset = sqrt(pow(box_diameter / 2, 2) - pow(box_base_width * box_diameter / 2, 2));

    difference() {
        union() {
            /* Side */
            translate([0, 0, box_length - box_wall_thickness])
                linear_extrude(box_wall_thickness)
                    profile_box();

            /* Lid with dovetails */
            translate([0, 0, box_wall_thickness])
                linear_extrude(box_length - 2 * box_wall_thickness, convexity=2)
                    profile_box_lid();
        }

        /* Text */
        translate([0, cutoff_offset - box_text_depth, box_wall_thickness + (box_length - 2 * box_wall_thickness)/2])
            rotate([90, -90, 180])
                linear_extrude(box_text_depth + fudge_factor)
                    text(box_text, font=box_text_font, size=box_text_size, halign="center", valign="center");

        /* Optional magnet */
        if (box_magnet)
            translate([0, 0, box_wall_thickness - fudge_factor])
                linear_extrude(box_magnet_thickness + box_magnet_z_clearance + fudge_factor)
                    profile_magnet();
    }
}

/******************************************************************************/
/* Top-level */
/******************************************************************************/

if (part == "both") {
    rotate([90, 0, 90])
        box_base();
    translate([box_wall_thickness, 0, 0])
        rotate([90, 0, 90])
            color(alpha=0.50)
                box_lid();
} else if (part == "base") {
    rotate([90, 0, 90])
        box_base();
} else if (part == "lid") {
    rotate([-90, 0, -90])
        box_lid();
}
