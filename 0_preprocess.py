# -*- coding:utf-8 -*-

# -----------------------------------------
# Updated Date: 2014/03/24
# Input: the control sam file and treatment sam file (alignment files after executing bowtie2-align)
# Output: dynamically generate (2^n + 1) sub-files sequentially
# Environemt: Linux
# Description: Due to the file size of alignment file, ranging from 1,2 GB to 15,16 GB, the normal, general personal
#              computers are hard to analyze such one big enough file. The divide-and-conquer is necessary step to 
#              solve such condition. This python code is based on Linux enviroment, also consist of '3' parts of individual
#              codes, extractLargeData.pl, getLargeData.pl, cbnCT.pl. (These three codes are necessary, can not be loss.)
#              This code would combine the control and the treatment alignment file into one for further gene level and 
#              transcript level analyses.
# -----------------------------------------

import sys
import os

if len(sys.argv) < 4:
    print "Usage: python ./0_preprocess.py <control name in .sam> <treatment name in .sam> <control_subFile_count> <treatment_subFile_count>"
    exit(0)

controlSAM = sys.argv[1]
treatmentSAM = sys.argv[2]
controlFileCount = 2**int(sys.argv[3])+1
treatmentFileCount = 2**int(sys.argv[4])+1

class divideIntoSubFiles:
    # global variables
    global controlSAM, treatmentSAM, controlFileCount, treatmentFileCount
    
    # private variables
    __subFileHeader = ""        # e.g con or tre
    __fin = 0                   # get total lines of control or treatment file
    __totalSubFiles = 0         # how many subfiles to be generated   
    __targetSAM = ""            # control.sam or treatment.sam
    __totalCountLines = 0       # the file contains how many lines
    __tmpCmd = ""               # linux command
    __eachFileLines = 0         # how many lines in the file
    __option = 0                # control or treatment condition

    # private methods
    def __getLineCount(self):
        self.__tmpCmd = "wc -l " + self.__targetSAM + " > ./tmp"
        os.system(self.__tmpCmd)
        try:
            self.__fin = open("./tmp",'r')
            self.__totalCountLines = int(self.__fin.readline().strip().split(' ')[0])
            self.__eachFileLines = self.__totalCountLines / (self.__totalSubFiles-1)
        except:
            print "Error: Temp file went error."
            exit(0)

    def __divideFiles(self):
        start = 1
        for i in range(1, self.__totalSubFiles, 1):
            self.__tmpCmd = "sed -n '" + str(start) + ","
            start = start + self.__eachFileLines - 1
            self.__tmpCmd = self.__tmpCmd + str(start) + "p' ./" + self.__targetSAM
            self.__tmpCmd = self.__tmpCmd + " > ./" + self.__subFileHeader + str(i) + ".sam"
            start = start + 1
            print self.__tmpCmd
            os.system(self.__tmpCmd)
        # the last one left
        if self.__totalCountLines >= start:
            self.__tmpCmd = "sed -n '" + str(start) + "," + str(self.__totalCountLines) + "p' ./" + self.__targetSAM
            self.__tmpCmd = self.__tmpCmd + " > ./" + self.__subFileHeader + str(self.__totalSubFiles) + ".sam"
            print self.__tmpCmd
            os.system(self.__tmpCmd)
        else:
            self.__totalSubFiles = self.__totalSubFiles - 1
            if self.__option == 0:
                # use function to change global variable
                def changeFileCount():
                    global controlFileCount
                    controlFileCount = controlFileCount - 1
                changeFileCount()
            else:
                def changeFileCount():
                    global treatmentFileCount
                    treatmentFileCount = treatmentFileCount - 1
                changeFileCount()

    # public methods
    def __init__(self, getOption, subFileName):
        self.__subFileHeader = subFileName
        if getOption == 0:          # control.sam
            self.__targetSAM = controlSAM
            self.__totalSubFiles = controlFileCount
            self.__option = 0
        elif getOption == 1:        # treatment.sam
            self.__targetSAM = treatmentSAM
            self.__totalSubFiles = treatmentFileCount
            self.__option = 1
        # count the total lines
        self.__getLineCount()
        # start to output data
        self.__divideFiles()

    def __exit__(self):
        self.__fin.close()

class extractLargeData:
    # public variables
    global controlSAM, treatmentSAM, controlFileCount, treatmentFileCount
    
    # private variables
    __tmpCmd = ""
    __subFileName = ""
    __executeCodeName = "./1_extractLargeData.pl"
    __targetSubFileName = ""
    __option = 0
    
    # public methods
    def __init__(self, getOption, getSubFileName, getTargetName):
        self.__subFileName = getSubFileName
        self.__targetSubFileName = getTargetName
        self.__option = getOption
        if(self.__option == 0):
            self.__execute(controlFileCount)
        else:
            self.__execute(treatmentFileCount)
            
    # private methods
    def __execute(self, getNum):
        self.__tmpCmd = ""
        for i in range(1,getNum + 1,1):
            self.__tmpCmd = "perl " + self.__executeCodeName + " ./" + self.__subFileName + str(i) + ".sam ./"
            self.__tmpCmd = self.__tmpCmd + self.__targetSubFileName + str(i) + ".sam"
            print self.__tmpCmd
            os.system(self.__tmpCmd)
        
class eachCombine:
    # public variables
    global controlSAM, treatmentSAM, controlFileCount, treatmentFileCount
    
    # private variables
    __tmpCmd = ""
    __subFileName = ""
    __executeCodeName = "./2_getLargeData.pl"
    __targetFileName = ""
    __countFile = 0
    
    # public methods
    def __init__(self, getCount, getSubFileName, getTargetName):
        self.__countFile = int(getCount)
        self.__subFileName = getSubFileName
        self.__targetFileName = getTargetName
        self.__execute()
            
    # private methods
    def __execute(self):
        self.__tmpCmd = "perl " + self.__executeCodeName + " " + str(self.__countFile + 1) + " ./" + self.__targetFileName + " "
        for i in range(1,self.__countFile + 1,1):
            self.__tmpCmd = self.__tmpCmd + "./" + self.__subFileName + str(i) + ".sam "
        print self.__tmpCmd
        os.system(self.__tmpCmd)

controlLines = divideIntoSubFiles(0,"con")
treatmentLines = divideIntoSubFiles(1,"tre")
controlExtract = extractLargeData(0,"con","c")
treatmentExtract = extractLargeData(1,"tre","t")
os.system("rm -f " + controlSAM + " " + treatmentSAM)
controlCombine = eachCombine(controlFileCount,'c',"control.txt")
treatmentCombine = eachCombine(treatmentFileCount,'t',"treatment.txt")
os.system("perl ./3_cbnCT.pl ./control.txt ./treatment.txt ./3_combine.txt")
