# VVlab_Scripts
Analysis Scripts for analysing EEG data 

Create_EDF directory contains matlab scripts for creating EDF files available for scoring from TDT tanks 
  Step 1 - Read TDT Tank
  Step 2 - Create TXT File
  Step 3 **NOT PRESENT** - use SikuliX script to create EDF files using Neurotraces 
  
Matlab scripts for processing the output of TDT synapse.

Pipeline

1 - Create EDFS
  
2 - First Quality Check - Plot EEG and EMG Variance 
  
3 - Score files in sleep sign 
  
4 - Output FFT labelled by sleep stage 
  
5 - Second Quality Check - Plot Delta power by sleep stage in hypnogram, double check for artefact and stage type 

6 - Further Analysis
