
clear all
close all
path='K:\Oxford\';

mousenames=strvcat('Gi','Go');
days=strvcat('14','14');
ders=strvcat('fro','occ');

f=0:0.25:20;
maxep=21600;
zermat=zeros(1,maxep);
x=1:1:maxep; x=x./900;

pathout=[path,'outputVS\'];

numanim=size(mousenames,1);
OOO=[];
for n=1:2
    figure
    mouse=mousenames(n,:); mouse(isspace(mouse))=[];
    day=days(n,:);
    
    for dr=1:2
        
        der=ders(dr,:)
        
        fname=[mouse,'-',day,'-',der]
        
        fn=[mouse,'-',[day,'0917'],'-',der,'-VSspec'];
        eval(['load ',pathout,fn,'.mat spectr w nr r w1 nr2 r3 mt ma bastend -mat']);
        
        swa=mean(spectr(:,3:17),2);
        W=zermat; W(w)=1;
        N=zermat; N(nr)=1;
        R=zermat; R(r)=1;
        
        swaW=swa; swaW(W==0)=NaN;
        swaN=swa; swaN(N==0)=NaN;
        swaR=swa; swaR(R==0)=NaN;
        
        swa=[swaW swaN swaR];
        subplot(3,1,dr)
        plot(x,swa);
        %plot(swa)
        
        if dr==1 title (fn); end
        
    end
end