%%this script simply allows the user with a simple way to run the
%%MainCecilia.m and julien_test_midpoints.m scripts on a folder containing
%%one or more files of interest.  To use, simply set "current folder" to
%%the folder of interest, and modify the first line of the script to tell 
%%it which .lsm files to use 
%%eg for all .lsm files, use lsmfile = dir('*.lsm')
%%for all files that end in, say, nuc.lsm, use lsmfile = dir('*nuc.lsm')
%%then type julien_combo into the command window and it will analyze all
%%files, outputting the images and data tables for each graph, as well as
%%a file giving the red and green midpoints for all images tested.



lsmfile = dir('2*')
f = size(lsmfile)
f = f(1)
AllData = cell(f,1)
for i = 1:f
    AllData{i} = MainCecilia(lsmfile(i).name);
end

midpoints_summary