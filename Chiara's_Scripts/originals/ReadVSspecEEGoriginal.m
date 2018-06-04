
clear all
close all

exte='.txt'
path='C:\Users\yghuang\Dropbox\scoring\Ne-EEG-EMG-130917\';
path1='C:\Users\yghuang\Dropbox\scoring\Ne-EEG-EMG-130917\';

mousenames=strvcat('Ne');
days=['130917'];

ders=strvcat('fro','occ','foc');

f=0:0.25:20;
maxep=21600;
zermat=zeros(1,maxep);

pathin=[path,'fft\']
pathout=[path1,'outputVS1\']; mkdir(pathout)

numanim=size(mousenames,1);
OOO=[];
for n=1:1
    mouse=mousenames(n,:); mouse(isspace(mouse))=[];
    for ddd=1:1
        day=days(ddd,:);
        figure
        for dr=1:3
            
            der=ders(dr,:)
            
            fname=[mouse,'-',day,'-',der]
            
            fnameFFT=[pathin,fname,exte]
           
            numline=1;
            fidfft=fopen(fnameFFT,'r');
            if fidfft<1
                OOO=[OOO; fname];
                continue;
            end;
            str=fgets(fidfft)
            while str(1:2)~='Ep'
                str=fgets(fidfft);
                numline=numline+1;
            end;
            
            fl=textread(fnameFFT,'%s%*[^\n]');
            fl1=char(fl);
            ep=find(fl1=='E');
            numrow=21600;
            numskip=ep+1;
            
            [epoch,state,dateexp,time,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,... % NO DELTA ALPHA THETA IN LINW 38 AND 42
                a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,a31,a32,a33,a34,a35,a36,a37,a38,a39,a40,a41,...
                a42,a43,a44,a45,a46,a47,a48,a49,a50,a51,a52,a53,a54,a55,a56,a57,a58,a59,a60,...
                a61,a62,a63,a64,a65,a66,a67,a68,a69,a70,a71,a72,a73,a74,a75,a76,a77,a78,a79,a80,a81]...
                = textread(fnameFFT,'%d%s%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',numrow,'headerlines',numskip);
            spectr=[a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,...
                a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,a31,a32,a33,a34,a35,a36,a37,a38,a39,a40,a41,...
                a42,a43,a44,a45,a46,a47,a48,a49,a50,a51,a52,a53,a54,a55,a56,a57,a58,a59,a60,...
                a61,a62,a63,a64,a65,a66,a67,a68,a69,a70,a71,a72,a73,a74,a75,a76,a77,a78,a79,a80,a81];
            
            clear a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20;
            clear a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37 a38 a39 a40 a41;
            clear a42 a43 a44 a45 a46 a47 a48 a49 a50 a51 a52 a53 a54 a55 a56 a57 a58 a59 a60;
            clear a61 a62 a63 a64 a65 a66 a67 a68 a69 a70 a71 a72 a73 a74 a75 a76 a77 a78 a79 a80 a81 fft;
            
            statestr=char(state);
            
            nr=find((statestr(:,1)=='N' & statestr(:,2)=='R')); r=find((statestr(:,1)=='R' & statestr(:,2)~='a'));
            w=find(statestr(:,1)=='W' & statestr(:,2)~='a');
            nr2=find((statestr(:,1)=='N' & statestr(:,2)=='a')); r3=find((statestr(:,1)=='R' & statestr(:,2)=='a'));
            w1=find(statestr(:,1)=='W' & statestr(:,2)=='a');
            mt=find(statestr(:,1)=='M' & statestr(:,2)~='a');
            ma=find(statestr(:,1)=='M' & statestr(:,2)=='a');
            iso=find(statestr(:,1)=='I' & statestr(:,2)=='S');
            
            nr(nr>maxep)=[];nr2(nr2>maxep)=[];r(r>maxep)=[];r3(r3>maxep)=[];w(w>maxep)=[];w1(w1>maxep)=[];mt(mt>maxep)=[];ma(ma>maxep)=[];
            iso(iso>maxep)=[];
            
            ww1mt=sort([w;w1;ma;mt]);wake=zermat; wake(ww1mt)=1;[bastend badur]=BriefAwakenings(wake,maxep);
            ba=zermat; for b=1:length(badur) ba(bastend(b,1):bastend(b,2))=1; end; mt=find(ba);
            [x,y]=intersect(w,mt); w(y)=[];[x1,y1]=intersect(w1,mt); w1(y1)=[]; mt=mt';
            
            fn=[mouse,'-',day,'-',der,'-VSspec'];
            eval(['save ',pathout,fn,'.mat spectr w nr r w1 nr2 r3 mt ma bastend iso -mat']);
            
            spN=mean(spectr(nr,:));
            spW=mean(spectr(w,:));
            spR=mean(spectr(r,:));
                     
            sp=[spW;spN;spR];
            %sp(:,1:2)=NaN;
            
            subplot(2,2,dr)
            
            semilogy(f,sp,'LineWidth',2)
            grid on
            legend('W','N','R')
            title (fn)
            
        end
        %       pause
        
    end
end