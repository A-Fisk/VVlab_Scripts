clear all;
close all;
outp=[];nums=[];

epochl=4;
path='C:\ScheduledFeeding\';
pathsig=[path,'OutputSignals\'];
pathV=[path,'OutputSIGvar\'];mkdir(pathV)
pathF=[path,'FiguresProfiles\'];mkdir(pathF)

recorddates=strvcat('07','08','09','10','11','12','13','14','15','16');%day month year
%recorddates=strvcat('03','04','05','06','07','08','09','10','11','12','13','14','15','16','17');%day month year

mousenames=strvcat('Ha','Mi','Ne','Dr','Lu','Gi','Go');
numdays=size(recorddates,1)

yaEEG=[3*10^4 3*10^4 3*10^4 3*10^4 3*10^4 3*10^4 3*10^4];
artEEG=[800 800 700 700 800 900 1000];
artEMG=[400 400 300 400 400 300 300];
yaEMG=[3*10^4 3*10^4 3*10^4 3*10^4 1*10^4 3*10^4 3*10^4];

numanim=size(mousenames,1);
fs=256;
numm=60;
numh=24;
maxep=21600;
x1=1:maxep;x1=x1./900;
x2=1:numm*numh;x2=x2./60;
zermat=zeros(1,fs*numm*numm*numh);

zermat1=zeros(1,maxep);
zermat2=zeros(1,numh*numm);

events=strvcat('8Hz','EMG','EEG');
ch=1;

p1=0.5; p2=100; s1=0.1; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=20; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb1,aa1]=cheby2(n,Rs,Wn);

p1=5; p2=100; s1=4; s2=120;
Wp=[p1 p2]/(fs/2); Ws=[s1 s2]/(fs/2); Rp=3; Rs=20; [n, Wn]=cheb2ord(Wp,Ws,Rp,Rs);
[bb2,aa2]=cheby2(n,Rs,Wn);

for mouse=1:numanim
    
    mousename=mousenames(mouse,:);
    mousename(isspace(mousename))=[];
    
    figure
    
    for dd=1:numdays
        recorddate=[recorddates(dd,:),'0917']
        
        %EEG
        fnout=[mousename(1:2),'-',events(1,:),'-',recorddate,'-ch',num2str(ch)];
        eval(['load ',pathsig,fnout,'.mat sig -mat']);
        if length(sig)>length(zermat) sig=sig(1:length(zermat)); EEG=sig; else  EEG=zermat; EEG(1:length(sig))=sig; end
        clear sig; EEG=filtfilt(bb1,aa1,EEG); EEG=filtfilt(bb1,aa1,EEG); 
        
        EEG(find(abs(EEG)>artEEG(mouse)))=0; EEG(EEG==0)=NaN;
        EEGv=nanvar(reshape(EEG,fs*epochl,maxep)); clear EEG;
        pause
        %EEG
        fnout=[mousename(1:2),'-',events(2,:),'-',recorddate,'-ch',num2str(ch)];
        eval(['load ',pathsig,fnout,'.mat sig -mat']);
        if length(sig)>length(zermat) sig=sig(1:length(zermat)); EMG=sig; else  EMG=zermat; EMG(1:length(sig))=sig; end
        clear sig; EMG=filtfilt(bb2,aa2,EMG); EMG=filtfilt(bb2,aa2,EMG); EMG(find(abs(EMG)>artEMG(mouse)))=0; EMG(EMG==0)=NaN;
        EMGv=nanvar(reshape(EMG,fs*epochl,maxep)); clear EMG;
        
        fnout1=[mousename(1:2),'-EEGfrontal-EMGv-',recorddate];
        eval(['save ',pathV,fnout1,'.mat mousename EEGv EMGv -mat']);
        
        EEGv(EEGv>yaEEG(mouse))=NaN;
        EMGv(EMGv>yaEMG(mouse))=NaN;
        
        subplot ('position',[0.1 0.95-0.08*dd 0.8 0.07])
        plot(x1,EEGv,'LineWidth',1)
        hold on
        bar(x1,EMGv*2,'r')
        axis([0 24 0 yaEEG(mouse)])
        set(gca,'XTick',[0:4:24])
        grid on
        if dd>1
            plot([4 4],[0 yaEEG(mouse)],'-k','LineWidth',2);
            %plot([8 8],[0 yaEEG(mouse)],'-k','LineWidth',2);
        end
        if dd==1 title(mousename); end
        text(0.2,2.6*10^4,recorddate)
        if dd==numdays xlabel('Hours'); end
        % axis off
        
    end;
   
    orient tall
    figname=[mousename(1:2),'-070917-160917-EEGfProfile']
    saveas(gcf,[pathF,figname],'tiff')
    close all
    
end;