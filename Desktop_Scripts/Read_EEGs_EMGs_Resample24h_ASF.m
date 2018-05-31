clear all;
close all;
%clea workspace befoer starting script 
outp=[];nums=[];

%create variable for epoch length - currently set as 4 seconds 
epochl=4;
%select the files 
%Path is the overall directory containing tank directory 
%will be used to create the output 
path='C:\LL\';
%pathtanks adds the tank directory to the path
pathtanks=[path,'TDTtanks\'];
%pathsig creates the output directory 
pathsig=[path,'OutputSignals\']; mkdir(pathsig)

%create string with name of tank in it
tank='Fisk_AS_EEG_2018_04-180407-125210';
%create list with all the recording names in the Tank
recorddates=strvcat('180409-080242',...
                    '180410-080109',...
                    '180411-080034',...
                    '180412-080013',...
                    '180413-080918',...
                    '180414-080010',...
                    '180415-080003',...
                    '180416-080015',...
                    '180417-080008',...
                    '180418-080004',...
                    '180419-080004',...
                    '180420-080006',...
                    '180421-080013',...
                    '180422-080010',...
                    '180423-080028',...
                    '180424-091853',...
                    '180425-082041',...
                    '180426-080011'...
                    )%day month year

%create string with mouse name, will be used to name file 
mousename='LL'

%number of animals and number of channels variables 
numanim=8;
numchs=[4];

%string with type of events - to be used in file name
events1234=strvcat('EEG');
num_chunks=4; % for resampling
%tail_length = ?? also for resampling but no idea what it does
tail_length=20000;
%same with visualize - assuming means not drawing figure - built into
%resampling function going to call later
visualize=0;

%for loop to run through all the files in recorddates list 
for dd=15:18
    
    %select the correct day from the list 
    recorddate=recorddates(dd,:);
    %slice the date to use in file name. 
    recd=recorddates(dd,1:6);
    
    %create block variable which is the full file name
    block=['ASF8-',recorddate];
    
    %in the specific days' file, loop through all the animals present
    for mouse=1:numanim
        
        %empty output list for ? reason? 
        outp=[];
        %string of the type of file and mouse number to call from the TDT
        % activex controls later 
        event123=[events1234,num2str(mouse)];
        
        %bunch of variables that define the data being dragged from TDT
        %max ret = max no of events to be returned - determines day length?
        %step = - step length of events to read?
        maxfreq=25000000; maxret = 1000000; maxevents = 1000000;step=10000;
        %open the TDT active control figure object 
        TTX = actxcontrol('TTank.X');
        % Then connect to a server.
        %call the functions on the control object, connecting to server
        % and opening the tank we have defined 
        invoke(TTX,'ConnectServer', 'Local', 'Me')
        invoke(TTX,'OpenTank', [pathtanks tank], 'R')
        
        % Select the block to access
        invoke(TTX,'SelectBlock', block)
        %Set the global variables to be what we defined earlier
        % maxret = maximum number of events to be returned 
        invoke(TTX, 'ResetGlobals')
        invoke(TTX, 'SetGlobalV', 'MaxReturn', maxret)
        
        %read the events from the TDT control object 
        L = invoke(TTX, 'ReadEventsV', maxret, event123, 1, 0, 0, 1, 'ALL');
        
        % grab the sampling rate from the TDT file so we can resample 
        SR = invoke(TTX, 'ParseEvInfoV', 0, 1, 9)
        
        %f1 is current sampling rate taken from file 
        f1=SR;
        %f2 is desired sampling rate we will set it to
        f2=256;
        
        %empty list to grab timestamp of each event in while loop  
        ts = [];
        
        %set counters before loop
        ii=1;
        events=1;
        while events>0     % reads events in steps % what is the end condition?
            %read the events from the specific file we have selected
            %maxevents = same as maxret = max no. of events - influence day
            %length
            %event123 - file type and mouse number to call from earlier
            %Channel = 0 returns all channels
            %SortCode =0 - disregards
            %(T1 - T2) - count events in this number step
            %All = Options string 
            events = invoke(TTX, 'ReadEventsV', maxevents, event123, 0, 0, ((ii-1)*step), (ii*step), 'ALL');
            
            if (events > 0)
                % if events were found, the timestamps are collected from
                % the start up to the number of events 
                timestamps = invoke(TTX, 'ParseEvInfoV', 0, events, 6);
                %concatenate collected timestamps to the ts list
                ts = cat(2, ts, timestamps(1,end));
            end
            %??? look at the length of timestamps list each time going over
            %the list?
            length(ts);
            %pause
            %increment step counter 
            ii=ii+1;
            %where is the change in events?!?!?!?!???
        end
        
        %grab the timestamps into new list, clear original ts list to use
        %again
        Tstamps=[0 ts]; clear ts;
        
        %set timevariables to select between 
        t1=0; t2=0;
        
        %loop through all the different data types. Since just using EEG
        %only the one type 
        for ee=1:1
            % EEGs, EMG
            %string of the event type and animal number to use for
            %selecting the block from the TDT file 
            event = [events1234(ee,:),num2str(mouse)]
            
            %grab the number of channels for this signal type from the 
            %numchs list  
            numch=numchs(ee);
            
            %loop through all the different channels 
            for chan = 1:numch
                
                %initialise variables 
                %sig is list which continuous variables will be saved into 
                sig=[];
                %simple counting variable 
                count=1;
                %loop through all the events by getting total number of
                %timestamps 
                for ii=1:length(Tstamps)
                    ii
                    %if the current loop is less than the end of the number
                    %of events, set the start and end times of this to be
                    %just the events in this time
                    if count<length(Tstamps)
                        t1=Tstamps(ii); t2 = Tstamps(ii+1)-0.0001;
                    %if at the end, then count the rest of the events 
                    else
                        t1=Tstamps(end); t2 = 0;
                    end;
                    
                    %grab the events from the file for just this chunk 
                    %set the start, end, and channels as previously defined
                    invoke(TTX, 'SetGlobalV', 'T1', t1);
                    invoke(TTX, 'SetGlobalV', 'T2', t2);
                    invoke(TTX, 'SetGlobalV', 'Channel', chan);
                    %read the events in this section
                    L = invoke(TTX, 'ReadEventsV', maxret, event, chan, 0, t1, t2, 'ALL');
                    %read the events as a continuous variable - don't quite
                    %understand how this works but it does! 
                    y = invoke(TTX,'ReadWavesV',event);
                    
                    %add in the continuous events - something to do with
                    %resampling. don't understand the ' either 
                    sig=[sig y'];
                    %increment count variable. 
                    count=count+1;
                    
                end;
                
                %change the range of the sig continous events - for
                %resampling somehow 
                sig=sig*10^6;
                
                %resample the events to 256 using other written script
                sig=resampling(sig,f1,f2,num_chunks,tail_length,visualize); clear sig_or;
                
                %define the file name using mouse name, number, event,
                %channel
                fnout=[mousename,num2str(mouse),'-',event(1:3),'-',recd,'-ch',num2str(chan)];
                
                %save the file as as a .mat file in the output directory
                %with output file name 
                eval(['save ',pathsig,fnout,'.mat sig block tank -mat']);
                
                %clear variables to re-use in loop 
                clear sig resampled_sig;
                
            end;
            
        end;
    end
end