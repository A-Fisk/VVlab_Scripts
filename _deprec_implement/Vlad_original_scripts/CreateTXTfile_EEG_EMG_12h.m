clear all;
close all;

epochl=4;

path='G:\Sleepy6EEG-March2018\';
pathsig=[path,'OutputSignals\'];
pathoutEDF=[path,'OutputEDFs1\']; mkdir(pathoutEDF)
recorddates=strvcat('250318');%day month year
mousenames=strvcat('Me')
maxep=10800; epochl=4;

fs=256;
fsh12=fs*epochl*maxep;

numanim=1;
days=1;
ld='L';

p1=0.5; p2=100; s1=0.1; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=30; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb1,aa1]=cheby2(n,Rs,Wn);

p1=5; p2=100; s1=4; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=30; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb2,aa2]=cheby2(n,Rs,Wn);


for day=1:days
    recorddate=[recorddates(day,:),'_',ld];
    date1=[recorddate]
    
    for mouse=1:numanim
        
        mousename=mousenames(mouse,:);
        
        output=zeros(fsh12,4);
        
%         % LFPs
%         for chan=1:16
%             fnin=[mousename,'-LFP-',date1,'-ch',num2str(chan)];
%             eval(['load ',pathsig,fnin,'.mat sig -mat']);
%             if length(sig)>fsh12
%                 signal=sig(1:fsh12);
%             else
%                 signal=zeros(1,fsh12);
%                 signal(1:length(sig))=sig;
%             end
%           
%             signal=filtfilt(bb1,aa1,signal);
%             signal(abs(signal)>2000)=0;
%             
%             output(:,chan)=signal';
%             clear resampled_sig signal;
%         end
        
        % EEG <128 Hz
        for chan=1:4
            fnin=[mousename,'-EEG-',date1,'-ch',num2str(chan)];
            eval(['load ',pathsig,fnin,'.mat sig -mat']);
            if length(sig)>fsh12
                signal=sig(1:fsh12);
            else
                signal=zeros(1,fsh12);
                signal(1:length(sig))=sig;
            end
            if chan<4
                signal=filtfilt(bb1,aa1,signal);
            else
                signal=filtfilt(bb2,aa2,signal);
            end
            signal(abs(signal)>2000)=0;
            
            output(:,chan)=signal';
            clear sig signal;
        end
        
%         % AUD
%         fnout=[mousename,'-AUD256Hz-',recorddate];
%         eval(['load ',pathsig,fnout,'.mat aud -mat']);
%         
%         output(:,21)=aud';
%         
%         clear aud;
        
        fnoutTXT=[mousename,'-EEG-EMG-',date1];
        
        eval(['save ',pathoutEDF,fnoutTXT,'.txt output -ascii']);
        
    end
end
