$fn = 50;
stand();

module stand() {
    width = 4;
    length = 4;
    height = 1;

    post_width = 1;
    post_scale = 5/16;

    difference() {
        base_block(width, length, height);
        // chamfer_pyramid(width, length, height, 0.75*height);
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

module post_holes(width, length, height, post_width) {
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

        translate([-post_width/2, -post_width/2, screw_stack]) {
            cube([post_width, post_width, height]);
        }
    }

    for(i = [0, 1]) {
        mirror([i, i, 0]) {
            translate([width/2 - post_width/2, length/2 - post_width/2, 0]) {
                hole();
            }
        }
    }
}

module frame(width, length, lift, post_width) {
    post_height = 10;
    rise = (post_height + lift) - post_width/2;

    module pins() {
        module pin() {
            pin_diameter = 1/4;
            pin_length = post_width;

            translate([-width/2 + post_width/4, -length/2 + post_width/4, rise]) {
                rotate([0, 45, 45]) {
                    cylinder(h = pin_length, d = pin_diameter);
                }
            }
        }

        for (i = [0, 1]) {
            mirror([i, i, 0]) {
                pin();
            }
        }
    }

    module verticals() {
        module vertical() {
            difference() {
                translate([width/2 - post_width, length/2 - post_width, lift]) {
                    cube([post_width, post_width, post_height]);
                }
                pins();
            }
        }

        for (i = [0, 180]) {
            rotate([0, 0, i]) {
                vertical();
            }
        }
    }

    module horizontal() {
        post_corners = sqrt(pow(width/2, 2) + pow(length/2, 2))*2;

        module bar() {
            bar_width = post_width*sqrt(2)/2;
            translate([-width/2, -length/2, rise + post_width/2]) {
                rotate([0, 90, 45]) {
                    difference() {
                        cylinder(h = post_corners, r = bar_width);
                        translate([0, -bar_width, 0]) {
                            cube([bar_width*2, bar_width*2, post_corners]);
                        }
                    }
                }
            }
        }

        module chamfer() {
            translate([-width/2, -width/2, rise+post_width/2]) {
                rotate([90, 0, 0]) {
                    translate([0, -post_width/4, 0]) {
                        cube([post_width*1.5, post_width*2, post_width]);
                    }
                }
            }
        }

        module chamfers() {
            chamfer();

            rotate([0, 0, 180]) {
                chamfer();
            }

            mirror([-1, -1, 0]) {
                chamfer();

                rotate([0, 0, 180]) {
                    chamfer();
                }
            }
        }

        difference() {
            bar();
            chamfers();
            verticals();
            pins();
        }
    }

    verticals();
    horizontal();
    pins();
}
