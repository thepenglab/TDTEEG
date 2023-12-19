
function ShowRawData(dat,events)
figRawData=getappdata(0,'figRawData');
hfig=0;
fnum=length(dat);
if ~isempty(figRawData)
    if ishandle(figRawData)
        hfig=1;
    end
end
if hfig
    set(0,'currentfigure',figRawData);
    clf;
else
    hfg=figure('position',[50,0,1600,fnum*200]);
    setappdata(0,'figRawData',hfg);    
end
fhi=0.95/(fnum+0);
for i=1:fnum
    if isfield(dat(i),'inputRange')
        ymx=dat(i).inputRange;
    else
        ymx=1000;
    end
    %subplot(fnum,1,i);
    axes('position',[0.05,1-i*fhi,0.75,fhi*0.8]);
    %use notch-filter
%     d=fdesign.notch(6,60,10,dat(i).fs);
%     hd=design(d);
%     dat(i).data=filter(hd,dat(i).data);
    plot(dat(i).tm/60,dat(i).data,'k');   
    set(gca,'xlim',dat(i).tm([1,end])/60);
    if strfind(dat(i).name,'EEG')
        set(gca,'ylim',[-ymx,ymx]);
        ylabel('uV');
    elseif strfind(dat(i).name,'CSC')
        set(gca,'ylim',[-ymx,ymx]);
        ylabel('uV');
    elseif strfind(dat(i).name,'phot')
        ylabel('uV');
    elseif strfind(dat(i).name,'DeltaF')
        %set(gca,'ylim',[-20,20]);
        ylabel('DF/F');
    end
    title(dat(i).name);
    if i==fnum
        xlabel('time(min)');
    else
        set(gca,'xtick',[]);
    end
    %show spectral information for each channel
    pLen=length(dat(i).specDat.p);
    xf=linspace(dat(i).specDat.fsRange(1),dat(i).specDat.fsRange(2),pLen);
    axes('position',[0.85,1-i*fhi,0.1,fhi*0.8]);
    plot(xf,dat(i).specDat.p);
    ylabel('Power');
    if i==fnum
        xlabel('frequency(Hz)');
    else
        set(gca,'xtick',[]);
    end
end
% yaxis=[-1000,1000];
%show event marks if applied
if ~isempty(events)
    evtNum=length(events.Onset);
    for i=1:evtNum
        line([1,1]*events.Onset(i),yaxis,'LineStyle','-.','color','r');
    end
end