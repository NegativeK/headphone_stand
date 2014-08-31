base();

module base() {
    width = 4;
    length = 4;
    height = 1;

    difference() {
        translate([-width/2, -length/2, 0]) {
            cube([width, length, height]);
        }

        pyramid(width, length, height, 1.2, 0.75*height);
    }
}

module pyramid(width, length, height, subtract_scale, rise) {
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
