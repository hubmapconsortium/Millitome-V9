// Millitome Generator V15
//  developer: Peter Kienle, CNS
//  developer  version test

// V15  2023-3-2
//  2023-3-2    add support for generic() coming in through MTD-Generic; fixed bisection box
//  2023-2-17   adjust letter & number columns
//  2023-2-17   add "no cut" when "1" slot is requested; updated calculated dimension l240
//  2023-2-16   modified organscale to use percentages 1-nnn
//  2023-2-2    uniform variable names
//  2022-9-12   lateralityID, mode 9 for bypass, mode 3 for bottom-only
//  2022-9-22   moved to active github
//  2022-10-25  added organ bisection
//  2022-10-26  added block full bisection

// dimensions are in mm
//
// in 3D editor usually X & Z represent the plane, Y is height ==> OpenScad reverses Y<==>Z!!
//
// ymin => height below center plane
// ymax => height above center plane
// yreal => total height of organ (abs(ymin+ymax))
//
//
// display and rendering system defaults - don't change
$fa = 1;
$fs = 0.4;

//================================================================
// exposed variables-------use to select
//
// change values here for single run from Openscad
// or run from terminal using command line; variables can be overrides using -D <property>=n
//  - genderID      0=female, 1=male
//  - organID       0=kidney_l, 1=kidney_r, 2=spleen, 3=pancreas, 4=banana, 5=g_pancreas
//  - lateralityID  0=bottom, 1=top
//  - typeID        0=fixed block size, 1=user block size, 2=user block count

//  - blocksize     5-30

//  - blocksize_x   5-30
//  - blocksize_y   5-30

//  - blocks_x      1-50
//  - blocks_y      1-50

//  - organscale    25-150

//  - asset_typeID  // 0=physical MT, 1=virtual block array, 2=virtual block/organ cut, 3=virtual organ model

//  - output_flag   0=ECHO everything, 1=ECHO insert line only, 2=ECHO col/row insert ONLY
//================================================================
//------when running from MT-Customizer or MT-Master these variables must be disabled, otherwise they will override variables from master script!!
/*
genderID        = 0;    // 0=female, 1=male, needs to be integer selector
organID         = 4;    // index for list lookup
lateralityID    = 0;    // 0=bottom, 1=top, 2=bypass MT creation                       

typeID          = 0;    // 0=fixed block size, 1=user block size, 2=user block count

blocksize       = 20 ;  // used for type 0, uniform x/y block size for cubes

blocksize_x     = 10;   // used for type 1, different x/y block size
blocksize_y     = 20;

blocks_x        = 7;    // used for type 2, number of blocks along x, used for calculated blocksize
blocks_y        = 14;   // number of blocks along y

organscale      = 100; 

asset_typeID    = 0;    // 0=physical MT, 1=virtual block array, 2=virtual block/organ cut, 3=virtual organ model, 4=blockfull_bisection, 5=organ bisection

output_flag     = 0;    // 0 = ECHO everything, 1 = ECHO insert line only, 2 = ECHO col/row insert ONLY
*/

//================================================================
// Object Generation Area
//  uncomment function(s) to be executed when running program
//================================================================

// asset_typeID = 0 - physical millitome
if (asset_typeID == 0) {
    if (lateralityID == 0) complete_bottom();       // complete bottom half
    if (lateralityID == 1) complete_top();          // complete top half
    if (lateralityID == 2) complete_bottom_noID();  // complete bottom half without layer ID
}

// asset_typeID = 1 - virtual block array
if (asset_typeID == 1) {
    if (lateralityID == 0 || lateralityID == 2) blockbottom_array();          // blocks, no ID labels are produced, bottom
    if (lateralityID == 1) blocktop_array();             // same for top  
}

// asset_typeID = 2 - virtual block/organ cut
if (asset_typeID == 2) {
    if (lateralityID == 0 || lateralityID == 2) blockbottom_cutout();         // blocks overlapping with the organ, bottom
    if (lateralityID == 1) blocktop_cutout();            // same for top
}

// asset_typeID = 3 - virtual unaltered organ model
if (asset_typeID == 3) {
    organ();
}


// asset_typeID = 4 - virtual fullblock bisection, in addition to X/Y cutting
if (asset_typeID == 4){
    blockfull_array();
}

// asset_typeID = 5 - virtual organ bisection, in addition to X/Y cutting
if (asset_typeID == 5) {
    bisection_organ();
}
    
//===display of organ percentage user setting, organ name & size, millitome dimensions in console (look for ECHO:)
// IMPORTANT: this must be activated when running from Terminal for automatic geometry/sheet creation
// output_flag parameter controls what information is shown in console
dimensions(); 

//===matching block array functions, for use in RUI selection interface or illustrations
//blockbottom_cutout();         // blocks overlapping with the organ, bottom
//blocktop_cutout();            // same for top

//blockbottom_array();          // blocks, intersecting the actual organ, no ID labels are produced, bottom
//blocktop_array();             // same for top  

//blockfull_box();              // both block 


//block_ids(start_character,start_number); // produces block array ID labels only
//block_array_with_letters();     // blocks, dissectiong the actual organ, each block has a ID label


//-----often used components, used for debugging
//insert();                       // area immediately surrounding the organ, with organ mold
//inserttop();                    // same for top
//inner_frame_with_letters();     // enclosure around insert, with column/row identifiers on each block
//innertop_frame_with_letters();  // same for top,row of letters if reverse
//outer_frame();                  // outer frame, with cutting slots, higher than inner frame (unused)

//===shows the 3d model of the used organ for reference
//organ();

//========these functions produce individual components; for documentation, etc, makes it easier to texture
//inner_frame();                  // inner frame (enclosure) around insert, no col/row IDs are produced
//innertop_frame();                 // same for top
//insert_frame();                   // mold cutout without slots
//inserttop_frame();                // same for top

//letter_array(start_character);  // produces the column IDs (letters A,B,C.....) for inner frame
//lettertop_array(start_character); // same for top
//number_array(start_number);     // produces the row IDs (numbers 1,2,3,4....) for inner frame
//numbertop_array(start_number);    // same for top
//layer_info_top();                 // produces "t" identifier in top layer
//layer_info_bottom();              // produces "b" identifier in bottom layer


//========basic components, for debugging and documentation
//column_slot_array();            // virtual blades, cutting column slots in all components which need them
//row_slot_array();               // virtual blades, cutting row slots in all components which need them  

//organ_top();                    // organ to cut the top half, extended straight on bottom, used for mold cutting  
//organ_bottom();                 // same for top

//inner_box_cut();                // makes the hole in inner_frame()
//innertop_box_cut();             // same for top
//inner_box_hollow();             // inner frame without cutting slots
//innertop_box_hollow();          // same for top
//outer_box_hollow();             // outer frame without cutting slots (unused)

//========most basic components, just boxes for various components                 
//outer_box();                    // dimensions of outer frame box (unused)
//bounding_box();                 // box enclosing the organ exactly
//insert_box();                   // rastered box for insert
//inserttop_box(); 

//insert_box_cut();               // 
//inserttop_box_cut();

//inner_box();                    // box for inner part
//innertop_box();                 // same for top

//blockbottom_box();              // dimensions of block array box (type dependent)
//blocktop_box();                 // same for top

//================================================================
// construction variables - no need for user access
//================================================================
wall_width      = 10;       // thickness for walls and bottoms - only for outer_box (default 20)
wall_height     = 20;       // height of outer box wall
bottom_height   = 5;        // was 10; bottom thickness of inner_box & insert (*2 for full MT bottom thickness)

inner_frame_block  = 10;    // was 20; inner frame block size around insert

cut_width       = 1;        // was 1; width of cutting tool
cut_depth       = 1;        // how far to cut below specimen

start_character = 65;       // is A - for column letters
start_number    = 49;       // is 0 - for row numbers

type_thickness  = 1;        // vertical thickness of letters (extrusion into +Z)

organ_folder    = "organs/";// location of organ models

//================================================================
// organ definitions, used to create the mold
//  filename,x,y,z_min,z_max,z_real
//
// Dimensions of organs - must be as accurate as possible - but rounded up to next integer
// all other enclosure dimensions are derived from these
// measurements from "Organ Placing.c4d" xpresso
// 
//================================================================
filename    = 0;    // organ_list member offsets
dimx        = 1;
dimy        = 2;
dimz_min    = 3;    // how much below baseline
dimz_max    = 4;    // how much above baseline
dimz_real   = 5;    // full height of organ, should be (abs(z_min))+z_max (or 2*z_max)

scaling_factor  = organscale/100;

generic_list = [
    ["generic",generic_x,generic_y,-generic_z/2,generic_z/2,generic_z]
];

include <mt-organs.config>;

echo (genderID);
// populate organ dimensions from organ_lists
organ_lists = [organ_list_f,organ_list_m,generic_list];     // genderID ID selects organ_list from here
organ_list  = organ_lists[genderID];            // female, male or generic organ_list, genderID is selector
organ_properties    = organ_list[organID];      // retrieve property list for this organ, organID is selector

organ_file      = organ_properties[filename];   // retrieve properties from list entry
organ_xdim      = organ_properties[dimx] * scaling_factor;
organ_ydim      = organ_properties[dimy] * scaling_factor;

organ_zmin      = organ_properties[dimz_min] * scaling_factor;
organ_zmax      = organ_properties[dimz_max] * scaling_factor;
organ_zreal     = organ_properties[dimz_real] * scaling_factor;

//================================================================
// calculated dimensions, don't mess with these!
//================================================================

// put block sizes in x and y lists, then retrieve what we need based on type parameter as index
xlist = [blocksize,blocksize_x,(organ_xdim+cut_width)/blocks_x];
ylist = [blocksize,blocksize_y,(organ_ydim+cut_width)/blocks_y];

// fetch block sizes according to requested type ID, corrected for 0 index
block_xdim      = xlist[typeID];
block_ydim      = ylist[typeID];

echo ("block_xdim=",block_xdim," block_ydim=",block_ydim);

// insert box dim., rounded to next full blocksize, mode 1&2 only
1insert_box_xdim = (((organ_xdim-(organ_xdim % block_xdim))/block_xdim)*block_xdim)+block_xdim;  // next full blocksize
1insert_box_ydim = (((organ_ydim-(organ_ydim % block_ydim))/block_ydim)*block_ydim)+block_ydim;  // next full blocksize

// insert box dim., no-rounding, mode 3 only
3insert_box_xdim = organ_xdim;
3insert_box_ydim = organ_ydim;

//evaluate mode flag and select appropriate size
insert_box_xdim= typeID<3 ? 1insert_box_xdim:3insert_box_xdim;
insert_box_ydim= typeID<3 ? 1insert_box_ydim:3insert_box_ydim;

//calculate height of insert_box, add 2mm for cutting depth
insert_box_zdim = organ_zreal/2+bottom_height;

// inner_frame_box dim., based on insert dim., added blocksize around
inner_box_xdim  = insert_box_xdim+2*inner_frame_block;  
inner_box_ydim  = insert_box_ydim+2*inner_frame_block;
inner_box_zdim  = insert_box_zdim+bottom_height;


// outer_frame_box dim., based on inner_frame_box dim., added spill_width around
outer_box_xdim  = inner_box_xdim+2*wall_width;
outer_box_ydim  = inner_box_ydim+2*wall_width;
outer_box_zdim  = inner_box_zdim+wall_height+bottom_height;

//================================================================
// functions
//================================================================

// make complete millitomes
module complete_top() {
    inserttop(); 
    innertop_frame_with_letters();
}
   
module complete_bottom() {
    insert();
    inner_frame_with_letters();
}

module complete_bottom_noID() {
    insert();
    inner_frame_with_letters_noID();
}
    

// insert_box=====================================================
// size x/y is calculated to the next full block, aligned to origin, the mold cutout goes in here

module insert_box() {
    color("crimson")
    translate([0,-insert_box_ydim,-(insert_box_zdim)]) 
        cube([insert_box_xdim,insert_box_ydim,insert_box_zdim]);
    // -remove later
    //echo(str("insert_box: ",insert_box_xdim,",",insert_box_ydim,",",insert_box_zdim));
}

module inserttop_box() {
    color("darkred")
    translate([0,-insert_box_ydim,0]) 
        cube([insert_box_xdim,insert_box_ydim,insert_box_zdim]);
}

// cut insert_box opening into inner_box to make inner_frame
module insert_box_cut() {
    translate([0,-insert_box_ydim,-(insert_box_zdim)]) 
        cube([insert_box_xdim,insert_box_ydim,insert_box_zdim+cut_width]);   
}

module inserttop_box_cut() {
    translate([0,-insert_box_ydim,-cut_width])
        cube([insert_box_xdim,insert_box_ydim,insert_box_zdim+cut_width]);    
}



// insert_box with organ mold cutout, use top-extended organ_bottom()
module insert_frame() {
    difference() {
        insert_box();
        organ_bottom(); 
    } 
}

// insert_box with organ mold cutout, use bottom-extended organ_top()
module inserttop_frame() {
    difference() {
        inserttop_box();
        organ_top();
    } 
}



// insert_frame with cut slots and mold
module insert() {
    difference() {
        insert_frame();
        column_slot_array();
        row_slot_array();
    }  
}

module inserttop() {
    difference() {
        inserttop_frame();
        column_slot_array();
        row_slot_array();
    }  
}



// inner box======================================================
// raw frame box: rows & cols of blocks around insert_box, should contain labeling, slotted

module inner_box() {
    color("magenta")
    translate([-inner_frame_block,-(inner_box_ydim-inner_frame_block),-(inner_box_zdim)])
        cube([inner_box_xdim,inner_box_ydim,inner_box_zdim]);  
      // -remove later
    echo(str("inner_box: ",inner_box_xdim,",",inner_box_ydim,",",inner_box_zdim));  
}

module innertop_box() {
    color("darkviolet")
    translate([-inner_frame_block,-(inner_box_ydim-inner_frame_block),0])
        cube([inner_box_xdim,inner_box_ydim,inner_box_zdim]);    
}
 

// used to cut inner_box opening into outer_box to make outer_frame
module inner_box_cut() {
     translate([-inner_frame_block,-(inner_box_ydim-inner_frame_block),-(insert_box_zdim/2+blocksize)])
        cube([inner_box_xdim,inner_box_ydim,outer_box_zdim]);       
}

module innertop_box_cut() {
     translate([-inner_frame_block,-(inner_box_ydim-inner_frame_block),insert_box_zdim/2+blocksize-outer_box_zdim])
        cube([inner_box_xdim,inner_box_ydim,outer_box_zdim]);       
}


// inner_box with insert_box coutout
module inner_box_hollow() {
    difference() {
        inner_box();
        insert_box_cut();
    }
}

module innertop_box_hollow() {
    difference() {
        innertop_box();
        inserttop_box_cut();
    }
}


// inner_frame with slots
module inner_frame() {
    difference() {
        inner_box_hollow();
        column_slot_array();
        row_slot_array(); 
    }  
}

module innertop_frame() {
    difference() {
        innertop_box_hollow();
        column_slot_array();
        row_slot_array(); 
    }  
}


// inner_frame with slots and letters and layer ID
module inner_frame_with_letters() {
    inner_frame();
    letter_array(start_character);
    number_array(start_number); 
    layer_info_bottom();
}

module innertop_frame_with_letters() {
    innertop_frame();
    lettertop_array(start_character);
    numbertop_array(start_number);
    layer_info_top();
}

// inner_frame with slots and letters
module inner_frame_with_letters_noID() {
    inner_frame();
    letter_array(start_character);
    number_array(start_number); 
}


// outer box======================================================
// outer frame, thickness=spill_width, adjustable height, slotted
module outer_box() {
    color("indigo")
    translate([-(inner_frame_block+wall_width),-(outer_box_ydim-inner_frame_block-wall_width),-(outer_box_zdim)+wall_height])
        cube([outer_box_xdim,outer_box_ydim,outer_box_zdim]);    
}

// outer_box with inner_box coutout
module outer_box_hollow() {
    difference() {
        outer_box();
        inner_box_cut();       
    } 
}

// outer_frame with slots
module outer_frame() {
    difference() {
        outer_box_hollow();
        column_slot_array();
        row_slot_array();  
    }
}


// block array=====================================================
// based on insert dimensions
module blockbottom_box() {
    color("lightgreen")
        translate([0,-insert_box_ydim,-organ_zreal/2]) 
        cube([insert_box_xdim,insert_box_ydim,organ_zreal/2]);
}

module blockbottom_array() {
    difference() {
        blockbottom_box();
        column_slot_array();
        row_slot_array();
    }
}

module blockbottom_cutout() {   
    intersection() {
        blockbottom_array();
        organ();  
  }    
}

// block_array ID letters; needed only for bottom
module block_array_with_letters() {
    blockbottom_array();
    block_ids(start_character,start_number);
}

module blocktop_box() {
    color("lightblue")
        translate([0,-insert_box_ydim,0])
        cube([insert_box_xdim,insert_box_ydim,organ_zreal/2]);
}

module blocktop_array() {
    difference() {
        blocktop_box();
        column_slot_array();
        row_slot_array();
    }
}

module blocktop_cutout() {
    intersection() {
        blocktop_array();
        organ();
    }
}


module blockfull_box()
{
    color("lightgreen")
    translate([0,-insert_box_ydim,-organ_zreal/2]) 
    cube([insert_box_xdim,insert_box_ydim,organ_zreal]);   
}

module blockfull_array()
{
    difference() {
        blockfull_box();
        column_slot_array();
        row_slot_array();
        bisection_box();
    }
}

// cut organ intro upper and lower sectors
module bisection_box() {
    color("lightgreen")
        //translate([-(block_xdim*2+wall_width),-outer_box_ydim+block_ydim,-(cut_width/2)])
        translate([-block_xdim,-outer_box_ydim+block_ydim,-(cut_width/2)])
        cube([outer_box_xdim+wall_width*2,outer_box_ydim+wall_width*2,cut_width]);
}




module bisection_organ() {
    difference() {
        organ();
        column_slot_array();
        row_slot_array();
        bisection_box();
    }

}




//organ==========================================================
// organ import, aligned to top/left origin, z aligned to bisection plane

module organ() {
    if (genderID > 1) {generic();} else {organ_sub();}
}

module organ_bottom() {
    if (genderID > 1) {generic();} else {organ_bottom_sub();}
}

module organ_top() {
    if (genderID > 1) {generic();} else {organ_top_sub();}
}


// fake organ, generic ellipsoid
module generic() {
   echo ("using generic");
    translate ([organ_xdim/2,-organ_ydim/2,0])
    scale ([organ_xdim,organ_ydim,organ_zreal])
        sphere (d = 1, $fa=1, $fs=0.1); // $fa, $fs used for better resolution
}

// imports regular organ polygon for display/rendering
module organ_sub() {
    echo ("using organic");
    scale([scaling_factor,scaling_factor,scaling_factor])
    rotate([0,0,0])
        translate([0,0,0])
          //  import(organ_file,convexity=3);
            import(str(organ_folder,organ_file),convexity=3);
}

// imports top-extended organ for mold-cutting in bottom box, name front extension
module organ_bottom_sub() {
    scale([scaling_factor,scaling_factor,scaling_factor])
    rotate([0,0,0])
        translate([0,0,0])
            import(str(organ_folder,"_b",organ_file),convexity=3);
}

// imports bottom-extended organ for mold-cutting in top box, name front extension
module organ_top_sub() {
    scale([scaling_factor,scaling_factor,scaling_factor])
    rotate([0,0,0])
        translate([0,0,0])
            import(str(organ_folder,"_t",organ_file),convexity=3);
}


// exact perimeter around the organ, based on organ dimensions
module bounding_box() {
    color("RoyalBlue")
    translate([organ_xdim/2,-organ_ydim/2,0])
        cube([organ_xdim,organ_ydim,organ_zdim],center=true);
}


// column slots============================================
// column cutting slot 
module column_slot() {  
    translate([-cut_width,-outer_box_ydim,-(organ_zreal/2+cut_depth)])
        cube([cut_width,outer_box_ydim+wall_width*2,organ_zreal+cut_depth*2]);
}
 
// column slot array
module column_slot_array() {
    if (blocks_x > 1) {
        for (dx = [0:block_xdim:insert_box_xdim]) {
            translate([dx,0,0])
                column_slot();
        }
    }
}

// row slots===============================================
// row cutting slot
module row_slot() {
    translate([-wall_width*2,0,-(organ_zreal/2+cut_depth)])
        cube([outer_box_xdim+wall_width*2,cut_width,organ_zreal+cut_depth*2]);
}

// row slot array
module row_slot_array() {
    if (blocks_y > 1) {
        for (dy = [0:-block_ydim:-insert_box_ydim]) {
            translate([0,dy,0])
                row_slot();
        }
    }
}

// block numbering & lettering=============================== 

// output one number character, position shifted, font size adjusted
module block_number(character) {
    //for character centering in x (y can stay static) 
    font_size   = block_ydim/4;
    font_width  = font_size/1.1;
    font_gap    = (inner_frame_block-font_width)/2;
    
    linear_extrude(type_thickness)
    translate([-(font_width+font_gap*1.5),-block_ydim*0.6,0])    //-inner_frame_block*0.75
    
    // interprets two-digit numbers up to 29
    if (character < start_number+9)
    {
        text(chr(character),size=font_size);
    } else {
        
        if ((character > start_number+8) && (character < start_number+19))
        {
            text(chr([49,character-10]),size=font_size);
        } else {
            text(chr([50,character-20]),size=font_size);
        }
    }  
}

// all numbers, line feed depends on block_ydim
module number_array(character) {
    if (blocks_y > 1) {
        for (dy = [0:-block_ydim:-insert_box_ydim+block_ydim]) {
            translate([0,dy,0])
            block_number(character+(-dy/block_ydim));
        }
    }
}

// all numbers, for top half, reverse side and rotate
module numbertop_array(character) {
    if (blocks_y > 1) {
        for (dy = [0:-block_ydim:-insert_box_ydim+block_ydim]) {    
            translate([block_xdim*(insert_box_xdim/block_xdim),dy,0])
            rotate([0,180,0])
            block_number(character+(-dy/block_ydim));
        }
    }
}

// output one letter character, position shifted, font size&position adjusted
module block_letter(character) {
    font_size   = block_xdim/6;
    font_gap    = (inner_frame_block-font_size)/1.5;
    
    linear_extrude(type_thickness)
    translate([block_xdim*0.3,font_gap,0])
    text(chr(character),size=font_size);
}

// all letters, col. feed depends on block_xdim================
module letter_array(character) {
    if (blocks_x > 1) {
        for (dx = [0:block_xdim:insert_box_xdim-block_xdim]) {
            translate([dx,0,0])
            block_letter(character+dx/block_xdim);        
        }
    }
}

// letters for top frame columns, reverse sequence, rotated================
module lettertop_array(character) {
    if (blocks_x > 1) {
        character = character-1;
        for (dx = [block_xdim:block_xdim:insert_box_xdim]) {
            translate([dx,0,0])
            rotate([0,180,0])
            block_letter(character+dx/block_xdim);        
        }
    }
}

// create bottom layer info text ("b") in zero corner
module layer_info_bottom() {
    font_size   = inner_frame_block*0.5;
    font_width  = font_size/1.1;
    font_gap    = (inner_frame_block-font_width)/1.5;
    
    linear_extrude(type_thickness)
    translate([-(font_width+font_gap),wall_width*0.4,0])
    text("b",size=font_size);
}

// create top layer info text ("t") in zero corner
module layer_info_top() {
    font_size   = inner_frame_block*0.5;
    font_width  = font_size/1.1;
    font_gap    = (inner_frame_block-font_width)/1.5;
    
    translate([((insert_box_xdim/block_xdim)*block_xdim)+wall_width/2,wall_width*0.4,0])
    rotate([0,180,0])
    linear_extrude(type_thickness)    
    text("t",size=font_size);
}


// all IDs for block_array===================
module block_ids(character,number) {
    for (dx = [0:block_xdim:insert_box_xdim-block_xdim]) {
        translate([dx,0,0])
        
        for (dy = [0:-block_ydim:-insert_box_ydim+block_ydim]) {
            translate([0,dy,0])
            block_id(character+dx/block_xdim,number+(-dy/block_ydim));
        }
    }
}

//output one letter/number ID, position shifted, font size&position adjusted
module block_id(character,number) {  
    block_dim   = block_xdim<block_ydim ? block_xdim:block_ydim;  // use smaller dim
    font_size   = block_dim/3.6;
    font_width  = font_size/1.1;
    id_width    = font_width*2;
    font_gap    = (block_xdim-id_width)/2.5;
    
    linear_extrude(type_thickness)
    translate([font_gap,-block_ydim*0.65,0])
    
     // interprets two-digit numbers up to 29
    if (number < start_number+9)
    {
        text(chr(character,number),size=font_size);
    } else {
        
        if ((number > start_number+8) && (number < start_number+19))
        {
            text(chr([character,49,number-10]),size=font_size);
        } else {
            text(chr([character,50,number-20]),size=font_size);
        }
    }  
   
}

// console output======================
module dimensions()
{
// draws organ percentage, x and y dimensions of organ top/left
//    font_size   = block_xdim/2;
//    
//    // dim x
//    linear_extrude(type_thickness)
//        translate([-block_xdim,block_ydim*1.5,0])
//            text(str(organ_xdim),size=font_size);
//    
//    // dim y
//    linear_extrude(type_thickness)
//        translate([-block_xdim*1.5,-block_ydim,0])
//            rotate([0,0,90])
//                text(str(organ_ydim),size=font_size);
//    
//    // scaling percentage & organ file
//    linear_extrude(type_thickness)
//        translate([-block_xdim,block_ydim*2.2,0])
//            text(str(scaling_factor*100,"% ",organ_file),size=font_size*1.2);
    
    if (output_flag == 0) {
        echo(str("Organ Scale & Type: ",scaling_factor*100,"% ",organ_file));
        echo(str("Organ dimensions: X = ",organ_xdim," Y = ",organ_ydim," Z = ",organ_zreal));  
        // dimensions of inner_box() = full perimeter size of millitome
        echo(str("Millitome dimensions: X = ",inner_box_xdim," Y = ",inner_box_ydim," Z = ",inner_box_zdim+type_thickness));
        echo(str("Columns: ",insert_box_xdim/block_xdim, " Rows: ",insert_box_ydim/block_ydim));
    }
        
    // coa list IDs
    _gender         = 0;    // 0=female, 1=male, needs to be integer selector
    _organ1         = 1;    // organID
    _organ2         = 2;  
    _organ_scale    = 3;    // 0 to 2
    _laterality     = 4;    // 0=bottom, 1=top
    
    // cmd_output_array.....
    coa = [
        ["F","M"],
        ["Kidney_L","Kidney_R","Spleen","Pancreas"],
        ["Kidney left","Kidney right","Spleen","Pancreas"],
        ["Large","Medium","Small"],
        ["Bottom","Top"]
    ];
    
    // echoes all data to console
    if (output_flag == 1) {
        echo (str(
            ">>",
            coa[_gender][genderID],",",
            coa[_organ1][organID],",",
            coa[_organ2][organID],",",
            blocksize,",",
            coa[_organ_scale][organ_scaleID],",",
            coa[_laterality][lateralityID],",",        
            insert_box_xdim/block_xdim,",",
            insert_box_ydim/block_ydim,
            "<<"
            ));
    }
    
    // echoes column & block counters only like: (this is what bash script is looking for)
    // ECHO: ">col:4<col"
    // ECHO: ">row:7<row"
    if (output_flag == 2) {
        echo (str(
            ">col:",
            insert_box_xdim/block_xdim,
            "<col"
        ));
        
        echo (str(
            ">row:",
            insert_box_ydim/block_ydim,
            "<row"
        ));      
    } 
}




  