clear all;
close all;

epochl=4;

path='C:\LL\';
pathsig=[path,'OutputSignals\'];
pathoutEDF=[path,'OutputEDFs\']; mkdir(pathoutEDF)
recorddates=strvcat('090418');%day month year
mousenames=strvcat('LL7')

maxep=21600; epochl=4;

fs=256;
fsh24=fs*epochl*maxep;

numanim=1;
numdays=size(recorddates,1);

p1=0.5; p2=100; s1=0.1; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=30; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb1,aa1]=cheby2(n,Rs,Wn);

p1=5; p2=100; s1=4; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=20; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb2,aa2]=cheby2(n,Rs,Wn);

for day=1:numdays
    recorddate=[recorddates(day,:)];
    date1=[recorddate]
    
    for mouse=1:1
        
        mousename=mousenames(mouse,:);
        
        output=zeros(fsh24,4);
        
        % EEG <128 Hz
        for chan=1:4
            fnin=[mousename,'-EEG-',date1,'-ch',num2str(chan)];
            eval(['load ',pathsig,fnin,'.mat sig -mat']);
            if length(sig)>fsh24
                signal=sig(1:fsh24);
            else
                signal=zeros(1,fsh24);
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
        
        fnoutTXT=[mousename,'-EEG-EMG-',date1];
        
        eval(['save ',pathoutEDF,fnoutTXT,'.txt output -ascii']);
        
    end
end
