%Script to create TXT file ready to create EDF file
%take in the newly created .mat files from each channel, day mouse
%Detrend the data, apply bandpass filter
%Save .txt file that includes all four channels in ascii

%start by closing all previous variables 
clear all;
close all;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 1 
% Define constants and inputs  

%define the directory going to look for the files in
global_directory = 'C:\LL\';

%mousename to be used for naming output files
MOUSENAME = 'LL';

%number of animals
NUM_ANIMALS= 8;

%length of epochs in seconds
EPOCH_LENGTH=4;

%sampling frequency
SAMPLING_FREQUENCY=256;

%Nyquist frequency
NYQUIST_FREQ = SAMPLING_FREQUENCY/2;

%maximum recording length in hours
longest_recording_length=28;

%calculate maximum number of epochs
MAX_EPOCHS = (longest_recording_length * 60 * (60/EPOCH_LENGTH));

%calculate the max number of individual points 
max_data_points = SAMPLING_FREQUENCY*MAX_EPOCHS*EPOCH_LENGTH;



%create the filter for EEG using a Chebyshev filter

%passband frequencies - keep all signal between these two frequencies 
high_pass_EEG = 0.5; %pass all frequencies higher than this
low_pass_EEG= 100; %pass all frequencies lower than this 
%Stopband frequences - remove all frequencies outside these two
low_stop_EEG = 0.1; %stop all frequencies lower than this
high_stop_EEG = 120; %stop all frequencies higher than this

%normalise the passband frequences
passband_corner_frequency_EEG = [high_pass_EEG low_pass_EEG]/NYQUIST_FREQ;
%normalise the stopband frequency
stopband_corner_frequency_EEG = [low_stop_EEG high_stop_EEG]/NYQUIST_FREQ;

%define the levels of attenuation
passband_attenuation_EEG = 3; %maximum permissible passband loss (dB)
stopband_attenuation_EEG = 30; %Amount of attenuation required for the stopband(dB)

%get the values to use in the filter
[polynomial_order_EEG cutoff_frequencies_EEG] = ... values we want to get 
    cheb2ord(passband_corner_frequency_EEG,...get values for Chebyshev filter passband corner
    stopband_corner_frequency_EEG,...stopband corner
    passband_attenuation_EEG,...passband attenuation
    stopband_attenuation_EEG); %stopband attenuation

%create the filter coefficients
[EEG_filter_1, EEG_filter_2] = ... return the transfer function coefficients 
    cheby2(polynomial_order_EEG,... use the calculated polynomial order
    stopband_attenuation_EEG,... level of attenuation required
    cutoff_frequencies_EEG); %stopband cutoff frequency calculated earlier


%%%%%%%%%%%%%%%
%now do the same for the EMG

%create the filter for EMG using a Chebyshev filter

%passband frequencies - keep all signal between these two frequencies 
high_pass_EMG = 5; %pass all frequencies higher than this
low_pass_EMG= 100; %pass all frequencies lower than this 
%Stopband frequences - remove all frequencies outside these two
low_stop_EMG = 4; %stop all frequencies lower than this
high_stop_EMG = 120; %stop all frequencies higher than this

%normalise the passband frequences
passband_corner_frequency_EMG = [high_pass_EMG low_pass_EMG]/NYQUIST_FREQ;
%normalise the stopband frequency
stopband_corner_frequency_EMG = [low_stop_EMG high_stop_EMG]/NYQUIST_FREQ;

%define the levels of attenuation
passband_attenuation_EMG = 3; %maximum permissible passband loss (dB)
stopband_attenuation_EMG = 20; %Amount of attenuation required for the stopband(dB)

%get the values to use in the filter
[polynomial_order_EMG cutoff_frequencies_EMG] = ... values we want to get 
    cheb2ord(passband_corner_frequency_EMG,...get values for Chebyshev filter passband corner
    stopband_corner_frequency_EMG,...stopband corner
    passband_attenuation_EMG,...passband attenuation
    stopband_attenuation_EMG); %stopband attenuation

%create the filter coefficients
[EMG_filter_1, EMG_filter_2] = ... return the transfer function coefficients 
    cheby2(polynomial_order_EMG,... use the calculated polynomial order
    stopband_attenuation_EMG,... level of attenuation required
    cutoff_frequencies_EMG); %stopband cutoff frequency calculated earlier
    
    


%input pathway - CHANGE LATER
read_directory_name = [global_directory 'Output_1_mat\'];

%read directory object
read_directory_obj = dir(read_directory_name);

%create empty array to hold the dates and mouse_names 
recording_dates = [];

%grab all the recording dates by looping through and grabbing all the
%unique values 
%loop through all the names in the directory - starting at 3 to avoid
%system files
for file=3:length(read_directory_obj)
    
    %read the part of the file that has the date in it
    temporary_date = read_directory_obj(file).name(9:14);
    
    %append into the recording_dates array
    recording_dates = [recording_dates; temporary_date];
    
end % end looping through file names 

%grab just the unique values so have all the days 
recording_dates = unique(recording_dates, 'rows');

%read how many days there are in total
number_of_days = length(recording_dates);

%create directory to save file names 
save_directory_name = [global_directory 'Output_2_TXT\'];

%if it doesn't exist already, create new output directory
if exist(save_directory_name, 'dir') ~= 7
    mkdir(save_directory_name);
end

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 2
% Read in the file 

%loop through all the days 
for day = 16:number_of_days

    %define the day to read - matrix slice
    day_to_read = recording_dates(day,:)
    
    %loop through all the animals 
    for mouse=1:NUM_ANIMALS
        
        %create string of actual name - done by just appending number onto
        %experiment 
        mouse_name = [MOUSENAME, num2str(mouse)];
        
        %preallocate an empty array for reading the output, length of
        %number of data points x number of channels
        output = zeros(max_data_points, 4);
        
        %create correct length array to put the signal into 
        single_channel_output = zeros(1, max_data_points);
        
        %loop through all the different channels 
        for channel = 1:4
            
            %define the file name
            file_name_to_read = [mouse_name,... start with which animals
                '-EEG-',...type of recording
                day_to_read,... which day we are reading
                '-ch',... channel number string
                num2str(channel)]; %add in channel number at the end
        
            %load the file as the signal variable
            signal = load([read_directory_name file_name_to_read]);%read variable in mat = default format
            
            %grab just the part we want from file read
            signal = signal.signal;
            
            %put the signal into the single channel array
            single_channel_output(1:length(signal)) = signal;
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Step 3
            % Apply the bandpass filter and remove artefacts
            
            %if it is an EEG because channel <4
            if channel < 4
                
                %apply the EEG filter using the filters defined earlier
                single_channel_output = filtfilt(EEG_filter_1,...
                    EEG_filter_2,...
                    single_channel_output);
            
            else %if the channel is an EMG channel
                
                %apply the EMG filter 
                single_channel_output = filtfilt(EMG_filter_1,...
                    EMG_filter_2,...
                    single_channel_output);
                
            end %end if channel statemnt   
            
            %remove any major artefacts of >2000
            single_channel_output(abs(single_channel_output)>2000)...
                = 0 ;
            
            %save into the output array as the channel we just read (transposed to correct shape) 
            output(:,channel) = single_channel_output';
            
            %clear the signal variable
            clear signal;
        
        end %end channel loop
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 4 
        % Save the file 
        
        
        %create string of file name to save
        save_file_name = [mouse_name,...
            '-EEG-EMG-',...
            day_to_read]
        
        %save the file in directory and file name as just defined 
        save([save_directory_name save_file_name],...
            'output',...
            '-ascii');
        
    end %end mouse loop 
        
end %end day loop




