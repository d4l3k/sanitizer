$fn = 50;

board_width = 25;
  board_length = 110;
  board_hole_size = 1.5;
  board_max_height = 6.15;
  board_min_height = 1.44;
 
board_hole1_offset = 79.5;
board_hole2_offset = 5.5;
  
module led_board() {
  
  led_size = 3.58;
  
  translate([0, -board_width/2])
  difference() {
    union() {
    cube([board_length, board_width, board_min_height]);
    cube([board_width, board_width, board_max_height]);
    }
    
      
    translate([board_length-board_hole1_offset-board_hole_size, board_width/2, -1])
    cylinder(r=board_hole_size, h=5);
    
    translate([board_length-board_hole2_offset-board_hole_size, board_width/2, -1])
    cylinder(r=board_hole_size, h=5);

  }
  
  for (d = [76.95, 46.97, 16.62]) {
    translate([board_length-d, -led_size/2, board_min_height])
    cube([led_size, led_size, 1.6]);
  }
}

 strip_width = 10.1;
  strip_length = 33;
  led_size = 5;

module led_strip() {
  translate([0, -strip_width/2])
  union() {
    cube([strip_length, strip_width, 0.26]);
    
    translate([strip_length/2-led_size/2,strip_width/2-led_size/2])
    cube([led_size, led_size, 2]);
  }
}
  thread_outer = 6.8;
  thread_inner = 6.13;
  thread_length = 6.23;
  lip_outer = 9.5;
  lip_length = 2;
  barrel_diameter = 7.37;
  barrel_length = 12.5;
  stem_diameter=4.5;
  stem_length = 2.2;
  button_diameter=6;
  button_length = 3.7;

module button() {
  translate([0, 0, -barrel_length-lip_length]) {
  cylinder(d=barrel_diameter, h=barrel_length);
  translate([0,0,barrel_length])
  cylinder(d=lip_outer, h=lip_length);
  translate([0,0,barrel_length+lip_length])
  cylinder(d=thread_outer, h=thread_length);
  translate([0,0,barrel_length+lip_length+thread_length])
  cylinder(d=stem_diameter, h=stem_length);
    translate([0,0,barrel_length+lip_length+thread_length+stem_length])
  cylinder(d=button_diameter, h=button_length);
  }

}

  sensor_length = 32.57;
  sensor_width = 24.26;
  sensor_height = 11;
  cap_size = 23.25;
  cap_base = 3.4;
  
module motion_sensor() {

  translate([0, -sensor_width/2])
    
  union() {
    cube([sensor_length, sensor_width, sensor_height]);
    
    translate([sensor_length/2-cap_size/2, sensor_width/2-cap_size/2, sensor_height])
    union() {
    cube([cap_size, cap_size, cap_base]);
      translate([cap_size/2, cap_size/2, cap_base])
      sphere(cap_size/2);
    }
  }
}
chip_hole_radius = 2.9/2;

module chip_hole() {
  cylinder(r=chip_hole_radius, h=5);
}

chip_width = 25.63;
chip_length = 48.42;
chip_height = 1.63;
port_width = 11.5;
port_height = 6.78;
port_length = 24.40;

pin_width = 2.57;
pin_length = 36.16;
pin_height = 8.31;

chip_hole_offset_x = 0.8;
chip_hole_offset_y = 1.06;


module chip() {
  
  translate([0, -chip_width/2])
  union() {
  
  translate([0, chip_width/2+(port_width-port_height)/2, 6.14-port_height])
  rotate([90, 0, 270])
  union() {
    cube([port_width-port_height, port_height, port_length]);
    translate([0, port_height/2])
    union() {
      cylinder(d=port_height, h=port_length);

      translate([port_width-port_height, 0])
      cylinder(d=port_height, h=port_length);
    }
  }
  
  difference() {
    cube([chip_length, chip_width, chip_height]);
    
    translate([chip_hole_radius+chip_hole_offset_x, chip_hole_radius+chip_hole_offset_y,-1])
    chip_hole();
    translate([chip_hole_radius+chip_hole_offset_x, chip_width-chip_hole_offset_y-chip_hole_radius,-1])
    chip_hole();
    
    translate([chip_length-chip_hole_radius-chip_hole_offset_x, chip_hole_radius+chip_hole_offset_y,-1])
    chip_hole();
    translate([chip_length-chip_hole_radius-chip_hole_offset_x, chip_width-chip_hole_offset_y-chip_hole_radius,-1])
    chip_hole();
  }

  
  translate([chip_length/2-pin_length/2, 0, -pin_height])
  union() {
    cube([pin_length, pin_width, pin_height]);
    translate([0, chip_width-pin_width])
      cube([pin_length, pin_width, pin_height]);
  }
  }
}
  small_chip_width = 25.8;
  small_chip_length = 34.21;
  small_chip_height = 4.28; // includes boards
  small_board_height = 1.16;




module small_chip() {
  board_width = small_chip_width;
    board_length = small_chip_length;
  board_height = small_board_height;

  cube([board_length, board_width, board_height]);
  
  subboard_width = 16;
  subboard_length = 24.16;
  translate([board_length-subboard_length, (board_width-subboard_width)/2, board_height])
  cube([24.16, 16, 0.8]);
  
  chip_width = 11.88;
  chip_length = 15;
  
  translate([11.55, (board_width-chip_width)/2, 0])
  cube([chip_length, chip_width, small_chip_height]);
  
  translate([0, board_width/2+(port_width-port_height)/2, 0.84-port_height+board_height])
  rotate([90, 0, 270])
  union() {
    cube([port_width-port_height, port_height, port_length]);
    translate([0, port_height/2])
    union() {
      cylinder(d=port_height, h=port_length);

      translate([port_width-port_height, 0])
      cylinder(d=port_height, h=port_length);
    }
  }
}

e = 0.5;
case_height = sensor_height + e * 2;
shell = 2;
long_width = board_width + e*2;
long_length = board_length + small_chip_length + e*4 + shell;
box_width = small_chip_width + e*5 + sensor_width + shell* 1.5;
box_length = 40+e;
height = case_height;

led_board_offset = small_chip_length+shell + e*3;
row2 = small_chip_width + sensor_width/2 + shell + e*3;

module components() {
 translate([e, e, -small_chip_height-e])
small_chip();

translate([led_board_offset, long_width/2, -board_max_height-e])
led_board();

translate([shell+e, row2, -sensor_height-e])
motion_sensor();

translate([0, row2, -case_height/2])
rotate([90, 0, -90])
button();

translate([box_length/2-strip_length/2, box_width, -height/2])
  rotate([-90, 0, 0])
led_strip();
}


tab = 4;

module part() {

translate([0, 0, -height]) {
  difference () {
    union() {

  
  translate([small_chip_length+e*2, small_chip_width-tab+e])
  cube([shell, tab+shell, height]);
  translate([small_chip_length+e*2-tab, small_chip_width+e*2])
  cube([tab+shell, shell, height]);
  translate([0, small_chip_width+e*2])
  cube([tab, shell, height]);
  
  translate([0, small_chip_width+e*2])
  cube([shell, tab+shell, height]);
  
  translate([0, box_width-tab-shell])
  cube([shell, tab, height]);
  
  translate([sensor_length+e*2+shell, small_chip_width+e*2])
  cube([shell, tab+shell, height]);
  
  translate([sensor_length+e*2+shell, box_width-tab-shell])
  cube([shell, tab, height]);
  
  lip_height = small_chip_height-small_board_height;
  translate([0, 0, height-lip_height])
  cube([lip_height, small_chip_width, lip_height]);
  
  board_filler_height = board_max_height-board_min_height-e;
  translate([led_board_offset+board_width+e, 0, height-board_filler_height])
  cube([board_length-board_width, long_width, board_filler_height]);
  
  translate([led_board_offset+board_length-board_hole_size, board_width/2+e]) {
      for (offset = [board_hole1_offset, board_hole2_offset]) {
        translate([-offset, 0, height-board_max_height-e])
        cylinder(r=(board_hole_size-e/2), h=board_max_height+e);
      }
    }

  difference () {
    union() {
      translate([-shell, -shell, 0]) {
        cube([long_length+shell*2, long_width+shell*2, height+shell]);
        cube([box_length+shell*2, box_width+shell*2, height+shell]);
      }

      
    }


    translate([0,0, -shell]) {
      cube([long_length, long_width, height+shell]);
      cube([box_length, box_width, height+shell]);
    }

    hole_height = 2.35;
    translate([-shell*1.5, (small_chip_width-port_width*1.1)/2+e, hole_height])
    cube([shell*2, port_width*1.1, port_height*1.1]);


    led_hole_size = led_size+e;

    translate([(box_length-led_hole_size)/2, box_width-shell*0.5, (height-led_hole_size)/2])
    cube([led_hole_size, shell*2, led_hole_size]);
    
    // button hole
    translate([e, row2, case_height/2])
    rotate([90, 0, -90])
    cylinder(d=thread_outer+2*e, h=shell*2);
    
    // sensor hole
    translate([(sensor_length-cap_size)/2+shell, row2-cap_size/2-e, height-shell/2])
    cube([cap_size+2*e, cap_size+2*e, shell*2]);
  }
}

    
    // LED hole
    led_hole_height = board_max_height-board_min_height+shell+e;
    hole_top = long_width+shell*2;
    hole_bottom = board_width/2;
    hole_length = board_hole1_offset-board_hole2_offset-board_hole_size*5-hole_bottom;
    
    translate([led_board_offset +hole_bottom/2+board_length-board_hole1_offset+board_hole_size*1,long_width-hole_top+shell,height+shell-led_hole_height+e]) {
      
      translate([0, hole_top/2, 0])
      cylinder(d1=hole_bottom, d2=hole_top, h=led_hole_height);
      
      translate([hole_length, hole_top/2, 0])
      cylinder(d1=hole_bottom, d2=hole_top, h=led_hole_height);

    
      translate([0, hole_top, led_hole_height])
      rotate([90, 180, 90])
      linear_extrude(height=hole_length, $fn=1)
      polygon(points=[
        [0, 0], [hole_top, 0], 
        [hole_top-(hole_top-hole_bottom)/2,led_hole_height],
        [(hole_top-hole_bottom)/2,led_hole_height],
      ]);    
    }

}
}
}

part();
components();










