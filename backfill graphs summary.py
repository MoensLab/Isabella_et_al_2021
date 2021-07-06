#!/usr/bin/python

"""
This script is meant to take the "...table.xlsx" output excel files from my "Julien_combo" matlab script, and transform the green and red cumulative
density columns from a list with X number fo rows to a list with exactly 100 rows. It does so by removing, at regular intervals, individual data points
to get the red and green cumdens lists down to a number divisible by 100, and then averaging groups of numbers in that list to get 100 data points.  It
then writes a summary output file with these "normalized" green and red cumdens lists.  The purpose of this is to easily be able to make a graphs
represnting the average cumulative density along the A-P axis of a group of embryos.

To run: run this script, and select the target directory from the pop-up box.

"""

import math
import statistics
import os
import pandas as pd
import sys
from tkinter import filedialog

#select the source directory from a pop-up box
source = filedialog.askdirectory(initialdir = "/", title = "Select Folder")
source = source + "/"


#generate output xlsx file, write header row
green_df = pd.DataFrame()
red_df = pd.DataFrame()
greenint_df = pd.DataFrame()
redint_df = pd.DataFrame()



for filename in os.listdir(source):
    if filename.endswith(".xlsx") and "summary" not in filename:
        full_filename = source + filename
        short_filename = full_filename.replace(".xlsx", "")
        extra_short_filename = short_filename.replace(source, "")
        print(filename)

        df = pd.read_excel(full_filename)
        greenlist = df['CumDens_Green'].tolist()
        redlist = df['CumDens_Red'].tolist()
        greenintlist = df['CumInt_Green'].tolist()
        redintlist = df['CumInt_Red'].tolist()
        master_list = [greenlist, redlist, greenintlist, redintlist]
        final_list = []
        for zlist in master_list:

            #get whatever list I have down to a list whose length is a number divisible by 100 by regular removal of individual values
            length = len(zlist)
            leftover = length % 100
            if leftover != 0:
                toremove = int(length/leftover)
                x = toremove - 1
                removecount = 0
                while x < length and removecount < leftover:
                    zlist[x] = 'b'
                    x = x + toremove
                    removecount = removecount + 1
                newlist = [i for i in zlist if i != 'b']
            else:
                newlist = zlist

            #get my new, divisible by 100 list down to a list whose length is 100 by averaging (eg if the list is 800 values long, average every 8 values)
            newlen = len(newlist)
            shortlist = []
            templist_length = int(newlen/100)
            y = 0
            while y < newlen:
                templist = []
                for i in range(y, y+templist_length):
                    templist.append(newlist[i])
                shortlist.append(statistics.mean(templist))
                y = y + templist_length
            final_list.append(shortlist)
        green_df[extra_short_filename] = final_list[0]
        red_df[extra_short_filename] = final_list[1]
        greenint_df[extra_short_filename] = final_list[2]
        redint_df[extra_short_filename] = final_list[3]


green_df.to_excel(source + "CumDens_Green_summary.xlsx")
red_df.to_excel(source + "CumDens_Red_summary.xlsx")
greenint_df.to_excel(source + "CumInt_Green_summary.xlsx")
redint_df.to_excel(source + "CumInt_Red_summary.xlsx")







