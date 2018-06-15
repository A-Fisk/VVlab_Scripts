
clear all
close all
path='D:\LL\';

mousenames=strvcat('LL7');
days=['09';'10';'11';'23';'24';'25';'26'];
ders=strvcat('fro','occ','foc');
dername=strvcat('frontal','occipital','fronto-occipital')
numdays=size(days,1);

f=0:0.25:20;
maxep=21600;
zermat=zeros(1,maxep);
x=1:1:maxep; x=x./900;

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
    
    NT=[NT sum(N)./900];
    RT=[RT sum(R)./900];
    
end

subplot(1,2,1)
bar(NT)
set(gca,'XTickLabel',days)
title('NREM sleep')
ylabel('Hours')

subplot(1,2,2)
bar(RT)
set(gca,'XTickLabel',days)
title('REM sleep')
ylabel('Hours')
