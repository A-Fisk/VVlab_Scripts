
clear all
close all
path='D:\LL\';

mousenames=strvcat('LL7');
days=['09';'10';'11';'23';'24';'25';'26'];
%days=['09';'10';'11'];
ders=strvcat('fro','occ','foc');
dername=strvcat('frontal','occipital','fronto-occipital')
numdays=size(days,1);

f=0:0.25:20;
maxep=21600;
zermat=zeros(1,maxep);
x=1:2:24;

dr=1;

pathout=[path,'outputVS\'];
pathfig=[path,'Hypno\']; mkdir(pathfig)

numanim=size(mousenames,1);
OOO=[];
n=1
mouse=mousenames(n,:); mouse(isspace(mouse))=[];
NT=[]; RT=[];
for ddd=1:numdays
    day=['1804',days(ddd,:)];
    der=ders(dr,:)
    
    fname=[mouse,'-',day,'-',der]
    
    fn=[mouse,'-',day,'-',der,'-VSspec'];
    eval(['load ',pathout,fn,'.mat w nr r w1 nr2 r3 mt bastend -mat']);
    
    W=zermat; W([w; w1])=1;
    N=zermat; N([nr; nr2])=1;
    R=zermat; R([r; r3])=1;
    
    nr2h=cumsum(sum(reshape(N,1800,12))./900);
    r2h=cumsum(sum(reshape(R,1800,12))./900);
    
    NT=[NT; nr2h];
    RT=[RT; r2h];
    
end

figure
plot(x,NT,'o-','LIneWidth',2)
set(gca,'XTick',[0:2:24])
title('NREM sleep')
xlabel('Time of day (hours)')
ylabel('Hours of NREM sleep')
legend(days,'Location','northeastoutside')
grid on

figure
plot(x,RT,'o-','LIneWidth',2)
set(gca,'XTick',[0:2:24])
title('REM sleep')
xlabel('Time of day (hours)')
ylabel('Hours of REM sleep')
legend(days,'Location','northeastoutside')
grid on

