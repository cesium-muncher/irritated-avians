jank knockoff angry birds made in lua  
requires Love2d framework to run unless its already compiled  
if downloading compiled: do not remove from folder! it needs the DLLS to run  
make a shortcut or sumn idk  

######################################################

level creation guide

#################

Birds  
must be like:  
{"birds", "1", "2", "3", "4"},  
must have at least 4 bird entries due to jank code  
place "" to specify no bird  
avalible birds: "red", "yellow", "black", "j"  
j bird texture is not on github because it is actually a photo of a guy i know because funny  
j bird causes memory leak when it hits something  

#################

Pigs  
must be like:  
{"pig", x, y, size, i forgot},  
lowk iunno what the 4th value does, i just put 25  

#################

Blocks  
must be like:  
{material, x, y, sx, sy},  
materials are:  
wood, stone, terrain(unmovable), bouncy(unmovable), bouncywood  

#################

Name  
must be like:  
level_?.lua  
replace ? with level number  

#################

testing tips:
set the value of "level" in main.lua (line 45) to whatever your level number is so you immediately go to it
