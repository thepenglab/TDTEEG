%plot EEG traces 
function plottraces(specDat,events,fname)
if isempty(events)
    return;
end
%pre=30;post=60;      %for GTCS, sleep, SWD
pre=5;post=10;      %for GTCS, sleep, SWD
%cl=[.85,.85,.85];
scaleFactor=10;
if pre+post>40
    wid=2000;
elseif pre+post>15
    wid=1600;
else
    wid=1200;
end
tnum=size(events,1);
hfig=figure('position',[0,0,wid,tnum*80]);
egmax=quantile(abs(specDat.fEEG(2,:)),0.9)*scaleFactor;
tm=specDat.fEEG(1,:);
for i=1:tnum
	idx=find(tm>=events(i,2)-pre & tm<=events(i,2)+post);
	hold on;
	plot(tm(idx)-tm(idx(1))-pre,specDat.fEEG(2,idx)/egmax+i-0.5,'k','linewidth',0.5);
    hold on;
    text(-pre,i,[num2str(round(events(i,2)/60)),'min']);
end
xlabel('time(sec)');
ylabel('Seizure EEG');
set(gca,'xlim',[-pre,post],'ylim',[-0.5,tnum+0.5]);
%auto save figure to tif-file
if ~isempty(fname)
    F=getframe(gcf);
    imwrite(F.cdata,fname);
    delete(hfig);
end