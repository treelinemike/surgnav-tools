#!/usr/bin/python3
#
# Add line-starting timecode  with [00:00:00] at first line containing a >>
# works with timestampped files created in VIM 
# Manually determine the sync time, and make sure that entry in the logfile
# is the first one with >> (change >> on preceeding lines to, say, \\)
#
# in .vimrc, add:
# :inoremap <F5> <C-R>=strftime("%a, %b %d, %Y %H:%M:%S>> ")<CR>
# :nmap <F5> i<F5>
#
# consider paring this with the vim-auto-save plugin available on Vundle:
# https://vimawesome.com/plugin/vim-auto-save
#
#
# MAKE SURE THIS IS EXECUTABLE:
# in github/sugnav-tools
# chmod +x addApproxTimecode.py
#
# To use the script, call from the directory that contains the raw log file, e.g.:
# ~/github/surgnav-tools/addApproxTimecode.py --fps 29.97 20211202_log_001.txt
#

# required imports
import re
import sys
from datetime import datetime as dt
import argparse
import math

# parse command line arguments
parser = argparse.ArgumentParser(description='Add timecode to test log')
parser.add_argument('--fps',type=float,help='framerate (frames per second)')
parser.add_argument('infile',type=argparse.FileType('r'))
args = parser.parse_args()

# figure out whether 
frame_num_mode = 0
if(args.fps == None):
    frame_num_mode = 0
elif( abs(float(args.fps)-(30/1.001)) < 0.01 ):  # ~29.97 fps
    frame_num_mode = 1
elif( abs(float(args.fps)-(60/1.001)) < 0.01):   # ~59.94 fps
    frame_num_mode = 2
else:
    print("Invalid framerate, not parsing frame numbers.")

# make sure filename is valid, then construct output filename
m = re.findall('([\w\-]+)\.(\w+)',args.infile.name)
if( (len(m) != 1) or (len(m[0]) !=2) ):
    raise SystemExit('Invalid input filename!')
outputFileName = m[0][0] + '_timecode.' + m[0][1]
frameCSVFileName = m[0][0] + '_framenum.csv'

# open input and output files
fidOut  = open(outputFileName,'w')
if(frame_num_mode):
    fidCSV = open(frameCSVFileName,'w')

# storage for initial / reference / sync time
firstTime = 0;

# iterate through all lines
nextLine = args.infile.readline()
while nextLine:
    # show the line for debugging
    #print(nextLine.strip())
    
    # find the date string
    dateMatch = re.findall('([^>]+)>>\s*(.+)',nextLine)
    if( len(dateMatch) != 0 ):
        #print(dateMatch[0][0])
        
        # extract an actual date
        thisTime = dt.strptime(dateMatch[0][0],'%a, %b %d, %Y %H:%M:%S')
        if(firstTime == 0):
            firstTime = thisTime
        
        # compute timecode
        timecode = thisTime - firstTime
        
        # convert to seconds and groups of seconds
        timecode_sec = timecode.total_seconds()
        whole_mins = math.floor(timecode_sec/60)
        whole_ten_mins = math.floor(timecode_sec/(10*60))
        
        frame_num_str = ''
        if(frame_num_mode == 1):
            frame_num = 30*timecode_sec -2*(whole_mins-whole_ten_mins)
            frame_num_str = "|%d" % frame_num
        elif(frame_num_mode == 2):
            frame_num = 60*timecode_sec -4*(whole_mins-whole_ten_mins)
            frame_num_str = "|%d" % frame_num
        
        # prepend the timecode string to the line
        writeStr = '[' + str(timecode) + frame_num_str + ']' + ' ' + nextLine
        fidOut.write(writeStr)
        
        # write to CSV file
        if(frame_num_mode):
            csv_str = str(timecode) + ',' + "%d"%frame_num + ',' + dateMatch[0][1] + '\n'
            fidCSV.write(csv_str)
        
    else:
        # just echo back the line if it didn't have a time string prefix
        fidOut.write(nextLine)

    # read the next line
    nextLine = args.infile.readline()

# close input and output files        
args.infile.close()
fidOut.close()
print('Wrote ' + outputFileName)
if(frame_num_mode):
    fidCSV.close()
    print('Wrote ' + frameCSVFileName)
