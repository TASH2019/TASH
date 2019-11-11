#!/bin/tcsh -f

# the line above must be there at the beginning of the script! It tells the system what shell to use to execute the script.
#the -f option tells tcsh not to process the .tcshrc file when it starts up. Generally, you don't want a script to do this, so -f is recommended. Don't use it with bash or sh scripts: it means something else and isn't needed

global env
puts $env(SUBJECTS_DIR)
puts $env(outD)

set labelstyle "1"

rotate_brain_y 30
rotate_brain_x -20
redraw

set image_file "HG_rh_g1.tif"

set filestem "$env(outD)/$image_file"
set tiff "${filestem}"

save_tiff $tiff

exit




