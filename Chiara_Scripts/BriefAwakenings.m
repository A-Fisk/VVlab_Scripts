function [bastend badur]=BriefAwakenings(wake,maxep)

mindur=1;
maxdur=4;

wake=find(wake>0); wakep=[wake maxep]; dif=diff(wake); dif1=find(dif>1); endvs=wake(dif1);
startvs=dif1+1; startvs=[1 startvs maxep]; nepivs=diff(startvs); nepi1vs=find(nepivs>=mindur);
epidurvs=nepivs(nepi1vs); startep=wake(startvs(nepi1vs)); numvs=length(startep); startep(numvs)=[];
nepi1vs(length(nepi1vs))=[]; endep=endvs(nepi1vs); bastend=[startep' endep']; badur=endep-startep+1;
out=find(badur>maxdur); bastend(out,:)=[]; badur(out)=[]; 