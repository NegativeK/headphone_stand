$fn = 50;
stand();

module stand() {
    width = 4;
    length = 4;
    height = 1;

    difference() {
        base_block(width, length, height);
        chamfer_pyramid(width, length, height, 0.75*height);
        post_holes(width, length, height);
    }
}

module base_block(width, length, height) {
    translate([-width/2, -length/2, 0]) {
        cube([width, length, height]);
    }
}

module chamfer_pyramid(width, length, height, rise) {
    subtract_scale = 1.2;

    cut_width = width*subtract_scale;
    cut_length = length*subtract_scale;
    cut_height = height*1;

    translate([-width/2, -cut_length/2, rise]) {
        rotate([0, -45, 0]) {
            cube([cut_width, cut_length, cut_height]);
        }
    }

    mirror([1, 0, 0]) {
        translate([-width/2, -cut_length/2, rise]) {
            rotate([0, -45, 0]) {
                cube([cut_width, cut_length, cut_height]);
            }
        }
    }

    translate([-cut_width/2, -length/2, rise]) {
        rotate([45, 0, 0]) {
            cube([cut_width, cut_length, cut_height]);
        }
    }

    mirror([0, 1, 0]) {
        translate([-cut_width/2, -length/2, rise]) {
            rotate([45, 0, 0]) {
                cube([cut_width, cut_length, cut_height]);
            }
        }
    }
}

module post_holes(width, length, height) {
    module hole() {
        // screw_head_height = 3/32;
        screw_head_height = 1/8;
        // screw_head_diameter = 0.312;
        screw_head_diameter = 0.375; // No washer..

        cylinder(h=screw_head_height, r=screw_head_diameter/2);

        // screw_dia = 0.19;
        screw_hole_dia = 7/32; // Or 1/4?
        screw_hole_height = 1/8;

        translate([0, 0, screw_head_height]) {
            cylinder(h=screw_hole_height, r=screw_hole_dia/2);
        }

        screw_stack = screw_head_height + screw_hole_height;
        post_width = 0.5;
        post_height = height - screw_stack;

        translate([0, 0, screw_stack]) {
            cylinder(h=post_height, r=post_width/2);
        }
    }

    x_y_scale = 5/16;

    for(i = [x_y_scale, -x_y_scale]) {
        translate([i*width, i*length, 0]) {
            hole();
        }
    }
}
