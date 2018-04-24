clear all;
close all;
outp=[];nums=[];

epochl=4;
path='G:\Sleepy6EEG-March2018\';
pathtanks=[path];
pathsig=[path,'OutputSignals\']; mkdir(pathsig)

tank='March2018';
recorddates=strvcat('210318');%day month year

ld='D' %%% Careful, add 091117 before running for D phase
mousenames=strvcat('Oc','Qu','Ph');

numdays=1;
numanim=3;
numchs=[16 4 16];
events1234=strvcat('clf','EEG','LFP');
num_chunks=4; % for resampling
tail_length=20000;
visualize=0;

for dd=1:numdays
    recorddate=recorddates(dd,:)
    block=['Oc_Qu_Ph_',recorddate,'_',ld];
    
    for mouse=1:numanim %%%%%%%%%%%%%%%%%%%%%%%%%%
        
        outp=[];
        mousename=mousenames(mouse,:);
        event123=[events1234(1,:),num2str(mouse)];
        
        maxfreq=25000000; maxret = 1000000; maxevents = 1000000;step=10000;
        TTX = actxcontrol('TTank.X');
        % Then connect to a server.
        invoke(TTX,'ConnectServer', 'Local', 'Me')
        invoke(TTX,'OpenTank', [pathtanks tank], 'R')
        
        % Select the block to access
        invoke(TTX,'SelectBlock', block)
        invoke(TTX, 'ResetGlobals')
        invoke(TTX, 'SetGlobalV', 'MaxReturn', maxret)
        
        L = invoke(TTX, 'ReadEventsV', maxret, event123, 1, 0, 0, 1, 'ALL');
        SR = invoke(TTX, 'ParseEvInfoV', 0, 1, 9)
        
        f1=SR;
        f2=256;
        
%         ts = [];
%         
%         i=1;
%         events=1;
%         while events>0     % reads events in steps
%             events = invoke(TTX, 'ReadEventsV', maxevents, event123, 0, 0, ((i-1)*step), (i*step), 'ALL');
%             if (events > 0)
%                 % if events were found, the timestamps are collected
%                 timestamps = invoke(TTX, 'ParseEvInfoV', 0, events, 6);
%                 ts = cat(2, ts, timestamps(1,end));
%             end
%             length(ts);
%             %pause
%             i=i+1;
%         end
%         Tstamps=[0 ts]; clear ts;
        
        t1=0; t2=43200;
        
        for ee=1:3 %%%%1:3
            % clf, EEG, LFP
            event = [events1234(ee,:),num2str(mouse)];
            numch=numchs(ee);
            
            for chan = 1:numch
                sig=[];
%                 count=1;
%                 for i=1:length(Tstamps)
%                     i
%                     if count<length(Tstamps)
%                         t1=Tstamps(i); t2 = Tstamps(i+1)-0.0001;
%                     else
%                         t1=Tstamps(end); t2 = 0;
%                     end;
                    invoke(TTX, 'SetGlobalV', 'WavesMemLimit', 1024^3);
                    invoke(TTX, 'SetGlobalV', 'T1', t1);
                    invoke(TTX, 'SetGlobalV', 'T2', t2);
                    invoke(TTX, 'SetGlobalV', 'Channel', chan);
                    %L = invoke(TTX, 'ReadEventsV', maxret, event, chan, 0, t1, t2, 'ALL');
                    y = invoke(TTX,'ReadWavesV',event);
                    
                    sig=[sig y'];
%                     count=count+1;
                    
%                 end;
                
                sig=sig*10^6;
                
                sig=resampling(sig,f1,f2,num_chunks,tail_length,visualize); clear sig_or;
                
                fnout=[mousename,'-',event(1:3),'-',recorddate,'_',ld,'-ch',num2str(chan)];
                % pause
                eval(['save ',pathsig,fnout,'.mat sig block tank -mat']);
                
                clear sig resampled_sig;
                
            end;
            
        end;
    end
end