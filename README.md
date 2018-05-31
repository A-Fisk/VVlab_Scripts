# VVlab_Scripts
Matlab scripts for processing the output of TDT synapse.

Input:
TDT tank recordings

Output:
EDF files - labelled by date, animal and tank
Variance profile for EEG and EMG 


Pipeline

1_Read_EEGs_EMGs 
  Function takes TDT tank, createst OuputSIG folder and saves all the channels for each animal and day separately
  
2_PlotEEGandEMGprofiles 
  Function to plot variance of EEG and EMG over 24 hours
  Gives rough indication of quality of recordings and level or artefacts
  
3_CreateTXTfile_EEG_EMG
  Function takes OutputSIG folder files and brings all channels into single file for each animal and day
  
4_ - NOT IN GITHUB FOLDER - yet - plan to upload SikuliX script for automated version 
  Neurotraces then run convert EDF to ASCII with sampling rate of 256 on each file
  This file then ready to be sleep scored
  
5_ - Sleep scoring 

6_ - Analysis -
