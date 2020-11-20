$fn = 50;

board_width = 25;
  board_length = 110;
  board_hole_size = 2;
  
module led_board() {
  translate([0, -board_width/2])
  difference() {
    union() {
    cube([board_length, board_width, 0.78]);
    cube([board_width, board_width, 7]);
    }
    
      
    translate([35, board_width/2, -1])
    cylinder(r=board_hole_size, h=5);
    
    translate([board_length-10, board_width/2, -1])
    cylinder(r=board_hole_size, h=5);

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
  sensor_height = 10;
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


shell = 2;
case_length = chip_length + board_width;
case_width = chip_width*2;
case_height = sensor_height;
e = 0.5;

module components() {
 translate([0, 0, -case_height/2-pin_height/2])
chip();

translate([chip_length, 0, -case_height])
led_board();

translate([0, chip_width, -sensor_height])
motion_sensor();

translate([0, chip_width, -case_height/2])
rotate([90, 0, -90])
button();

translate([sensor_length/2-strip_length/2, 0])
led_strip();
}

//components();

difference () {
translate([-shell, -chip_width/2-shell, -shell-case_height])
difference() {
cube([shell*2+case_length, shell*2+case_width, shell*2+case_height]);
  translate([shell, shell, shell])
  cube([case_length, case_width, case_height]);
  
  translate([0, shell, case_height/2+shell]) {
      
    translate([-1, chip_width*3/2, 0])
    rotate([0, 90, 0])
    cylinder(d=thread_outer, h=10);
  }
}
components();
}



















