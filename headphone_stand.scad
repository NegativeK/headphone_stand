$fn = 50;
stand();

module stand() {
    width = 4;
    length = 4;
    height = 1;

    post_width = 0.5;
    post_scale = 5/16;

    difference() {
        base_block(width, length, height);
        chamfer_pyramid(width, length, height, 0.75*height);
        post_holes(width, length, height, post_width, post_scale);
    }

    // We need to get the lift (1/4) out of post_holes properly.
    frame(width, length, 1/4, post_width, post_scale);
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

    module chamfer_cutter() {
        translate([-width/2, -cut_length/2, rise]) {
            rotate([0, -45, 0]) {
                cube([cut_width, cut_length, cut_height]);
            }
        }
    }

    for(i = [0:3]) {
        rotate([0, 0, 90*i]) {
            chamfer_cutter();
        }
    }
}

module post_holes(width, length, height, post_width, x_y_scale) {
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
        post_height = height - screw_stack;

        translate([0, 0, screw_stack]) {
            cylinder(h=post_height, r=post_width/2);
        }
    }

    for(i = [x_y_scale, -x_y_scale]) {
        translate([i*width, i*length, 0]) {
            hole();
        }
    }
}

module frame(width, length, lift, post_width, x_y_scale) {
    post_height = 10;

    module vertical() {
        translate([x_y_scale*width, x_y_scale*length, lift]) {
            cylinder(h = post_height, r = post_width/2);
        }
    }

    module verticals() {
        for (i = [0, 180]) {
            rotate([0, 0, i]) {
                vertical();
            }
        }
    }

    module horizontal() {
        rise = (post_height + lift) - post_width/2;
        scaled_width = width*x_y_scale;
        scaled_length = length*x_y_scale;

        post_separation = sqrt(pow(scaled_width, 2) + pow(scaled_length, 2))*2;

        translate([-width*x_y_scale, -length*x_y_scale, rise]) {
            rotate([0, 90, 45]) {
                cylinder(h = post_separation, r = post_width/2);
            }
        }
    }

    verticals();

    difference() {
        horizontal();
        verticals();
    }
}
