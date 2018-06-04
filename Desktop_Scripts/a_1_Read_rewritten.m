%%% Attempting to re-write Read_EEG_EMG_Resample_24 hours script so I am
%%% certain I understand it. 
%%% Input - directory containing TDT tanks
%%% Output - output Signals for each animal, day, channel separately 
 

%define things will be needed 

%define the directory going to look for the files in 
global_directory = 'C:\LL\' ;

%mousename to be used for naming output files 
mousename = 'LL';

%number of animals
num_animals= 8;

%number of channels for each animals
num_channels=4;

%type of recording/output signal
recording_type = 'EEG'




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Step one, importing all the file names

%select the TDTtanks subdir 
tanks_dir = [global_directory, 'TDTtanks\'] ; 

%select the tank by finding EEG in the file name
tank_specific_ = ls([tanks_dir, '*EEG*']);

%create a string for the directory
tank_specific_dir = [tanks_dir, tank_specific_, '\'];

%create as a directory object 
tank_specific_dir_obj = dir(tank_specific_dir);

%grab just the folders by removing first 2 and last one entries
tanks_list = tank_specific_dir_obj(3:(length(tank_specific_dir_obj)-1))

%Step two, create directory to hold outputs 
%make an output directory 
output_path = [global_directory, 'Output_1']; mkdir(output_path);


%Step three, read the data from the TDT tank

%development mode
%for single day
%for single mouse

current_block_string = [tank_specific_dir, tanks_list(5).name]


data=TDT2mat(current_block_string)


