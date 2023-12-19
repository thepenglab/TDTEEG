%show EEG traces of seizurs
function ShowSeizureTraces(szEvents,specDat)
if mean(szEvents(:,4))<5
    pre=5;post=10;      %for sleep, SWD
    scaleFactor=5*1.5;      %for SWD
else
    pre=60;post=120;      %for GTCS
    scaleFactor=10;     %for GTCS
end
%cl=[.85,.85,.85];
if pre+post>15
    wid=1600;
else
    wid=1200;
end
snum=size(szEvents,1);
if snum>15
    hei=50;
else
    hei=80;
end
tm=specDat.fEEG(1,:);
eg=specDat.fEEG(2,:);
egmax=quantile(abs(eg),0.97)*scaleFactor;

%create figure
hfig=0;
figTraces=getappdata(0,'figTraces');
if ~isempty(figTraces)
    if ishandle(figTraces)
        hfig=1;
    end
end
if hfig
    set(0,'currentfigure',figTraces);
    clf;
else
    hfg=figure('position',[100,0,wid,snum*hei],...
        'NumberTitle','off','Name','Selected EEG traces');
    setappdata(0,'figTraces',hfg);    
end

%plot traces
for i=1:snum
	idx=find(tm>=szEvents(i,2)-pre & tm<=szEvents(i,2)+post);
    %mark events
    cl=[1,0.75,0.5];
    rectangle('position',[0,i-0.9,szEvents(i,4),0.9],'FaceColor',cl,'EdgeColor',cl);
	hold on;
	plot(tm(idx)-tm(idx(1))-pre,eg(idx)/egmax+i-0.5,'k','linewidth',0.5);
    text(pre*(-0.9),i-0.7,['t0=',num2str(szEvents(i,2)/60),'(min)'],'color','b');
end
xlabel('time(sec)');
ylabel('Seizure EEG');
set(gca,'xlim',[-pre,post],'ylim',[0,snum]);
