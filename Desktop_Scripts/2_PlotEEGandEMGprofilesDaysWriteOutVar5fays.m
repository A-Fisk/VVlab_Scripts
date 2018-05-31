%clear previously running processes 
clear all;
close all;
%empty variables for ? reasons 
outp=[];nums=[];

%define epoch length in seconds
epochl=4;
%define read and write directories 
path='C:\LL\';
pathsig=[path,'OutputSignals\'];
pathV=[path,'OutputSIGvar\'];mkdir(pathV)
pathF=[path,'FiguresProfiles\'];mkdir(pathF)

%list of file names to iterate through, just using days as will grab all. 
recorddates=strvcat('09',...
                    '10',...
                    '11',...
                    '12',...
                    '13',...
                    '14',...
                    '15',...
                    '16',...
                    '17',...
                    '18',...
                    '19',...
                    '20',...
                    '21',...
                    '22',...
                    '23',...
                    '24',...
                    '25',...
                    '26'...
                    );%day month year

%set the number of days to be the number of files 
numdays=size(recorddates,1)

%lists of something sizes, where absEEG > art EEG -> Nan?
%must be for artefact finding absolute values in artefacts
artEEG=[500 0 300 300 200 300 800 800 800 800 800 800 800 800];
artEMG=[100 0 800 100 150 200 400 400 400 400 400 400 400 400];

%create list with number of all EMG gains to apply 
EMGgain=[5 0 0.04 0.3 0.5 1 2 5 1 1 1 1 1 1]

%create lists with EEG and EMG artefact thresholds
%variance artefact thresholds 
yaEEG=[2*10^4 0 0.8*10^4 0.5*10^4 1*10^4 1.5*10^4 4*10^4 4*10^4 4*10^4 4*10^4 4*10^4 4*10^4 4*10^4 4*10^4];
yaEMG=[1*10^3 0 0.5*10^5 2*10^3 3.5*10^3 7*10^3 3*10^3 3*10^3 3*10^3 3*10^3 3*10^3 3*10^3 3*10^3 3*10^3];

%define a bunch of variables to use later, number of animals, sampling rate
%number of minutes, number of hours, max number of episodes
numanim=8;
fs=256;
numm=60;
numh=24;
maxep=21600;
%?creating something between 1 and number of exp - for graphing later?
x1=1:maxep;x1=x1./900;
x2=1:numm*numh;x2=x2./60;
%create list with zeros up to total length
zermat=zeros(1,fs*numm*numm*numh);

%create list with reasons?
zermat1=zeros(1,maxep);
zermat2=zeros(1,numh*numm);

%list of what kind of signal we are grabbing - only EEG for now 
events=strvcat('EEG');
%define which channels to looks at - 1-Frontal and 4-EMG 
ch1=2;
ch2=4;

%variables for ?????? plotting somehow - one for EEG
p1=0.5; p2=100; s1=0.1; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=30; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb1,aa1]=cheby2(n,Rs,Wn);

%variables for plotting EMG
p1=5; p2=100; s1=4; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=20; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb2,aa2]=cheby2(n,Rs,Wn);

%loop through all aniamls 
for mouse=6:6
    
    %define mouse name 
    mousename=['LL',num2str(mouse)];
   
    %create figure object
    figure
    
    %loop through all days available 
    for dd=1:numdays
       
        %grab which day we are going to plot 
        recorddate=['1804',recorddates(dd,:)]
        
        %EEG
        %define file name and import that file 
        fnout=[mousename,'-',events(1,:),'-',recorddate,'-ch',num2str(ch1)];
        eval(['load ',pathsig,fnout,'.mat sig -mat']);
        %if number of recordings longer than 24 hours, reduce to max number
        if length(sig)>length(zermat) 
            sig=sig(1:length(zermat));
            EEG=sig; 
        %if less than 24 hours then grab all the recordings with the tail
        %filled by zeros 
        else
            EEG=zermat;
            EEG(1:length(sig))=sig;
        end;
        clear sig;
        
        %filtering EEG by something
        EEG=filtfilt(bb1,aa1,EEG);
        
        %if the EEG is larger than the defined threshold, set to NaN
        EEG(find(abs(EEG)>artEEG(mouse)))=0;
        EEG(EEG==0)=NaN;
        
        %set EEGv variable to variance in the
        %shape of sampling rate*epochlength x max
        %episode number matrix 
        EEGv=nanvar(reshape(EEG,fs*epochl,maxep));
        %clear EEG;
        
        %EMG
        %do same things for the EMG
        %define file name and import file 
        fnout=[mousename,'-',events(1,:),'-',recorddate,'-ch',num2str(ch2)];
        eval(['load ',pathsig,fnout,'.mat sig -mat']);
        %if length of recording >24 (?) hours reduce to max numbers 
        if length(sig)>length(zermat)
            sig=sig(1:length(zermat));
            EMG=sig; 
        %if less than max length grab all recordings with zeros in the tail
        else
            EMG=zermat;
            EMG(1:length(sig))=sig;
            
        end
        clear sig;
        
        %apply filter to EMG 
        EMG=filtfilt(bb2,aa2,EMG);
        
        %threshold absolute values as artefacts to remove
        EMG(find(abs(EMG)>artEMG(mouse)))=0;
        EMG(EMG==0)=NaN;
        
        %grab variance from absolute values 
        EMGv=nanvar(reshape(EMG,fs*epochl,maxep)); %clear EMG;
        
        %set file name and save for the variance profiles 
        fnout1=[mousename,'-EEGfrontal-EMGv-',recorddate];
        eval(['save ',pathV,fnout1,'.mat mousename EEGv EMGv -mat']);
        
        
        %remove artefacts where variance above defined threshold 
        EEGv(EEGv>yaEEG(mouse))=NaN;
        EMGv(EMGv>yaEMG(mouse))=NaN;
                
        %create subplot for each day and plot variance on it of both EEG
        %and EMG 
        %subplot defines position of each new grid - this for final full
        %plot
        subplot ('position',[0.1 0.99-0.05*dd 0.8 0.045])
        %this for initial variable selection
        %   subplot ('position',[0.1 0.05 0.8 0.9])
        plot(x1,EEGv,'LineWidth',1)
        hold on
        plot(x1,EMGv*EMGgain(mouse),'-r','LineWidth',1)
        axis([0 24 0 yaEEG(mouse)])
        set(gca,'XTick',[0:4:24])
        grid on
        if dd<3
            plot([12 12],[0 yaEEG(mouse)],'-k','LineWidth',2);
            %plot([8 8],[0 yaEEG(mouse)],'-k','LineWidth',2);
        end
        if dd==1 title(mousename); end
        text(0.1,3*10^4,recorddate)
        if dd==numdays xlabel('Hours'); end
        % axis off
        
    end;
   
    orient landscape
    figname=[mousename,'-1804_LL-EEGvProfile']
    saveas(gcf,[pathF,figname],'tiff')
    saveas(gcf,[pathF,figname],'fig')
    %pause
    %close all
   
end;