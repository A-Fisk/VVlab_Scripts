
clear all
close all
path='D:\LL\';

mousenames=strvcat('LL7');
days=['09';'10';'11';'12';'23';'24';'25';'26'];
ders=strvcat('fro','occ','foc');
dername=strvcat('frontal','occipital','fronto-occipital')
numdays=size(days,1);

f=0:0.25:20;
maxep=21600;
zermat=zeros(1,maxep);
x=1:1:maxep; x=x./900;

ya=[4000 2000 3000]

pathout=[path,'outputVS\'];
pathfig=[path,'Hypno\']; mkdir(pathfig)

numanim=size(mousenames,1);
OOO=[];
for n=1:1
    mouse=mousenames(n,:); mouse(isspace(mouse))=[];
    for ddd=1:numdays
        day=['1804',days(ddd,:)];
        figure
        for dr=1:3
            
            der=ders(dr,:)
            
            fname=[mouse,'-',day,'-',der]
            
            fn=[mouse,'-',day,'-',der,'-VSspec'];
            eval(['load ',pathout,fn,'.mat spectr w nr r w1 nr2 r3 mt bastend -mat']);
            
            swa=mean(spectr(:,3:17),2);
            W=zermat; W(w)=1;
            N=zermat; N(nr)=1;
            R=zermat; R(r)=1;
            
            swaW=swa; swaW(W==0)=NaN;
            swaN=swa; swaN(N==0)=NaN;
            swaR=swa; swaR(R==0)=NaN;
            
            swa=[swaW swaN swaR];
            subplot(3,1,dr)
            plot(swa);
            axis([0 21600 0 max(max(swa))])
           % set(gca,'XTick',[0:1800:21600])
            grid on
            
            ylabel(dername(dr,:));
            if dr==3 xlabel('Hours'); end
            if dr==1 title(day); end
        end
        
%         figname=[mouse,'-',day,'-Hypno']
%         orient tall
%         saveas(gcf,[pathfig,figname],'tiff')     
%        % close all
    end
end