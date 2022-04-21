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
# ~/github/surgnav-tools/addApproxTimecode.py 20211202_log_001.txt
#

# required imports
import re
import sys
from datetime import datetime as dt

# get the raw log filename - should be the only argument passed to this script
numarg = len(sys.argv)
if( numarg != 2 ):
    print('Error: specify exactly one filename to parse')
    exit()  
inputFileName = sys.argv[1]

# make sure filename is valid, then construct output filename
m = re.findall('([\w\-]+)\.(\w+)',inputFileName)
if( (len(m) != 1) or (len(m[0]) !=2) ):
    raise SystemExit('Invalid input filename!')
outputFileName = m[0][0] + '_timecode.' + m[0][1]

# open input and output files
fidIn   = open(inputFileName,'r')
fidOut  = open(outputFileName,'w')

# storage for initial / reference / sync time
firstTime = 0;

# iterate through all lines
nextLine = fidIn.readline()
while nextLine:
    # show the line for debugging
    #print(nextLine.strip())
    
    # find the date string
    dateMatch = re.findall('([^>]+)>>',nextLine)
    if( len(dateMatch) != 0 ):
        #print(dateMatch[0])
        
        # extract an actual date
        thisTime = dt.strptime(dateMatch[0],'%a, %b %d, %Y %H:%M:%S')
        if(firstTime == 0):
            firstTime = thisTime
            
        # prepend the timecode string to the line
        writeStr = '[' + str(thisTime - firstTime) + '] ' + nextLine
        fidOut.write(writeStr)
    else:
        # just echo back the line if it didn't have a time string prefix
        fidOut.write(nextLine)

    # read the next line
    nextLine = fidIn.readline()

# close input and output files        
fidIn.close()
fidOut.close()

# done
print('Wrote ' + outputFileName)

