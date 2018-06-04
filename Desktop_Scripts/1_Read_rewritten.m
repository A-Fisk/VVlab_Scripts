%%% Attempting to re-write Read_EEG_EMG_Resample_24 hours script so I am
%%% certain I understand it. 
%%% Input - directory containing TDT tanks
%%% Output - output Signals for each animal, day, channel separately 
 
%Step one, importing all the files 

import_directory = dir('C:\LL\')