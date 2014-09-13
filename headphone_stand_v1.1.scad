$fn = 50;
stand();

module stand() {
    width = 4;
    length = 4;
    height = 1;

    post_width = 1;

    difference() {
        base_block(width, length, height);
        post_holes(width, length, height, post_width);
    }

    // We need to get the lift (1/4) out of post_holes properly.
    frame(width, length, 1/4, post_width);
}

module base_block(width, length, height) {
    translate([0, 0, height/2]) {
        cube([width, length, height], center=true);
    }
}

module post_holes(width, length, height, post_width) {
    module milled_hole(height, screw_stack) {
        milled_height = height - screw_stack;

        module tool_extreme(tool_diameter) {
            tool_radius = tool_diameter/2;

            difference() {
                cube([tool_radius, tool_radius, milled_height]);
                translate([tool_radius, tool_radius, 0]) {
                    cylinder(r = tool_radius, h = milled_height);
                }
            }
        }

        module x_y_z_extreme(tool_diameter) {
            intersection_for(i = [0, 1, 2]) {
                rotate(a = i*120, v = [1, 1, 1]) {
                    tool_extreme(tool_diameter);
                }
            }
        }

        difference() {
            cube([post_width, post_width, milled_height]);
            x_y_z_extreme(1/2);
        }
    }

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
            milled_hole(height, screw_stack);
        }
    }

    for(i = [0, 1]) {
        mirror([i, i, 0]) {
            translate([width/2 - post_width/2, length/2 - post_width/2, 0]) {
            // translate([width/2 - post_width/2, length/2 - post_width/2, 0]) {
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

            translate([-width/2 + post_width/4, -length/2 + post_width/4, 0]) {
                rotate([0, 45, 45]) {
                    cylinder(h = pin_length, d = pin_diameter);
                }
            }
        }

        for (i = [0, 1]) {
            mirror([i, i, 0]) {
                # pin();
            }
        }
    }

    module verticals() {
        module mill_clearance(mill_diameter) {
            mill_radius = 1/2;

            rotate([-45, 0, -45]) {
                // Using a z-height of mill-diameter and centered lops off
                // mill_radius
                cube(
                      [mill_diameter*2, mill_diameter*2, mill_diameter]
                    , center = true
                );
            }
        }

        module vertical() {
            difference() {
                translate([width/2 - post_width, length/2 - post_width, lift]) {
                    difference() {
                        cube([post_width, post_width, post_height]);
                        mill_clearance(1/2);
                    }
                }
                translate([0, 0, rise]) {
                    pins();
                }
            }
        }

        for (i = [0, 1]) {
            rotate([0, 0, i*180]) {
                vertical();
            }
        }
    }

    module horizontal() {
        post_corners = sqrt(pow(width/2, 2) + pow(length/2, 2))*2;

        module bar() {
            bar_width = post_width*sqrt(2)/2;

            translate([0, 0, post_width/2]) {
                rotate([0, 90, 45]) {
                    difference() {
                        cylinder(h = post_corners, r = bar_width, center=true);
                        translate([bar_width, 0, 0]) {
                            cube([bar_width*2, bar_width*2, post_corners], center=true);
                        }
                    }
                }
            }
        }

        module chamfer() {
            translate([width/2, width/2, 0]) {
                rotate([90, 0, 0]) {
                    translate([0, -post_width/4, 0]) {
                        cube([post_width*1.5, post_width*2, post_width]);
                    }
                }
            }
        }

        module chamfers() {
            module chamfer_end() {
                chamfer();

                mirror([-1, 1, 0]) {
                    chamfer();
                }
            }

            chamfer_end();

            mirror([1, 1, 0]) {
                chamfer_end();
            }
        }

        difference() {
            bar();
            chamfers();
            pins();
        }
    }

    verticals();

    translate([0, 0, rise]) {
        horizontal();
        pins();
    }
}
