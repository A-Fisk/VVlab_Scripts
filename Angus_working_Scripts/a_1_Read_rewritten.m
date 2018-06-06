%%% Attempting to re-write Read_EEG_EMG_Resample_24 hours script so I am
%%% certain I understand it. 
%%% Input - directory containing TDT tanks
%%% Output - output Signals for each animal, day, channel separately 
 
%start by clearing workspace
clear all
close all

%define Constants   

%define the directory going to look for the files in 
global_directory = 'C:\LL\';

%mousename to be used for naming output files 
mousename = 'LL';

%number of animals
num_animals= 8;

%number of channels for each animals
num_channels=4;

%type of recording/output signal
recording_type = 'EEG';



%%Constants for reading from tanks

%max frequency
max_frequency=25000000; 
%max number of events to be returned
max_events_return = 1000000;
%step size for reading events in while loop
step=10000;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Step one, importing all the file names

%select the TDTtanks subdir 
tanks_dir = [global_directory, 'TDTtanks\'] ; 

%select the tank by finding EEG in the file name
tank_specific_ = ls([tanks_dir, '*EEG*']);

%create a string for the directory
tank_specific_dir = [tanks_dir, tank_specific_, '\'];

%create string with full tank path name 
current_tank_string = [tank_specific_dir];

%create as a directory object 
tank_specific_dir_obj = dir(tank_specific_dir);

%grab just the folders by removing first 2 and last one entries - program
%files 
tanks_list = tank_specific_dir_obj(3:(length(tank_specific_dir_obj)-1));



%Step two, create directory to hold outputs 
output_path = [global_directory, 'Output_1'];

%only make output if doesn't exist
if exist(output_path, 'dir') ~= 7
    mkdir(output_path);
end


%Step three, read the data from the TDT tank

%development mode
%for single day
%for single mouse

current_block_string = [tank_specific_dir, tanks_list(5).name];

% for loop to go through each block in turn - same as dd in VVscript
%looping through all the blocks in the directory 
for item_no=1%:length(tanks_list)
    
   %assigns block variable to be equal to the block name string
   block = tanks_list(item_no).name;
   
   
   %%%%%%% Development, just doing with one animal
   for mouse=1%:num_animals
       
       %create string of which part of tank to read
       %want to read 'EEG1' etc, not EEr. 
       events_to_read = [recording_type, num2str(mouse)];
       
       
       %Now to use the TDT ActiveX controls to connect to the tanks we have
       %defined and prepare to read the files 
       
       %Create activexcontrol figure (will open new window)
       TTX = actxcontrol('TTank.X');
       
       %connect to the local server on this computer 
       TTX.ConnectServer('Local', 'Me');
       
       %Open the correct tank 
       TTX.OpenTank(current_tank_string, 'R');
       
       %select the current block in this tank
       TTX.SelectBlock(block);
       
       %next set the global variable of MaxReturns to what we want 
       %given we are using ReadEventsV, which uses local variables, this
       %step is not necessary
       TTX.ResetGlobals();
       TTX.SetGlobalV('MaxReturn', max_events_return);
       
       %Now to read the events using the string we have defined earlier 
       %Read a snippet here to cache temporarily to read the sampling rate
       %in a few lines with ParseEvInfoV
       temp_read = TTX.ReadEventsV(max_events_return,... max number of events to read
                       events_to_read,... which events to read in the file
                       1,...Channel - returns only records for this channel
                       0,...Sortcode - disregards
                       0,...T1 - starts reading at start of block
                       1,...T2 - reads events until 1 - ???
                       'ALL') %Options - read all events records in range
       
        %Read the sampling rate 
        sampling_rate = TTX.ParseEvInfoV(0,...Starting index of records
                         1,...number records to be retrieved - should be same
                         9);%nItem - returns sampling rate
        
   
   
   end % end mouse loop
   
end %end tanks/days loop




