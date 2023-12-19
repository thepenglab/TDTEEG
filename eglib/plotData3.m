%plot the following graphes for sRev
%state/spectrogram/EMG-amplitude/filtered-EEG/raw-EMG
function plotData3(pDat,mDat,state,stiTm,fname)
totmin=floor((mDat.Tm(end)-mDat.Tm(1))/60);
if totmin<=40
    d0=50;
    a0=1.5;
else
    d0=25;
    a0=1;
end

figResult=getappdata(0,'figResult');
hfig=0;
if ~isempty(figResult)
    if ishandle(figResult)
        hfig=1;
    end
end
if hfig
    set(0,'currentfigure',figResult);clf;
else
    hfg=figure('position',[10,200,totmin*d0,800]);
    setappdata(0,'figResult',hfg);    
end
%show state-----------------------------------------
axes('position',[0.07,0.95,0.9,0.03]);
imagesc(state');
mymap=[0,0,0;0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;1,1,0];
colormap(gca,mymap);
set(gca,'clim',[-1,3]);
axis off;
%show EEG-spectrogram-------------------------------
axes('position',[0.07,0.74,0.9,0.2]);
imagesc(pDat.p');
colormap(gca,'jet');
[wid,hei]=size(pDat.p);
fLen=pDat.fsRange(2)-pDat.fsRange(1);

if isfield(pDat,'clim')
    cmax=min(2,pDat.clim);
else
    cmax=2;
end
cmax=2;
set(gca,'clim',[0,cmax],'YDir','normal','XTick',[],'YTick',[]);
%set(gca,'YDir','normal','XTick',[],'YTick',[]);
text(-0.01*wid*a0,hei*1/fLen,'0-','fontsize',12);
text(-0.02*wid*a0,hei*11/fLen,'10-','fontsize',12);
text(-0.02*wid*a0,hei*24/fLen,'Hz','fontsize',12);
ylm=[0,25]*hei/fLen;
set(gca,'ylim',ylm);
%show filtered EEG-------------------------------------------
axes('position',[0.07,0.52,0.9,0.2]);
yegmg=1000/2;
if isfield(pDat,'fEEG')
    %label the stimulation period
    col=[0.5,0.5,1;1,1,0.5];
    if ~isempty(stiTm)
        stinum=size(stiTm,1);
        for i=1:stinum
            rectangle('Position',[(stiTm(i,1)-0)/60,-yegmg+2,(stiTm(i,2)-stiTm(i,1))/60,yegmg*2],'FaceColor',col(1,:),'EdgeColor',col(1,:))
        end
        hold on;
    end
    plot(pDat.fEEG(1,:)/60,pDat.fEEG(2,:),'k');
    text(pDat.fEEG(1,1)/60,yegmg*0.8,'EEG','fontsize',12);
    set(gca,'xlim',[pDat.fEEG(1,1),pDat.fEEG(1,end)]/60,'XTick',[],'fontsize',12,'Box','on','linewidth',1);
    set(gca,'ylim',[-yegmg,yegmg]);
    ylabel('EEG(uv)');
end
%show filtered EMG----------------------------------------------
axes('position',[0.07,0.3,0.9,0.2]);
yegmg=1000/2;
if isfield(mDat,'fEMG')
    %label the stimulation period
    col=[0.5,0.5,1;1,1,0.5];
    if ~isempty(stiTm)
        stinum=size(stiTm,1);
        for i=1:stinum
            rectangle('Position',[(stiTm(i,1)-0)/60,-yegmg+2,(stiTm(i,2)-stiTm(i,1))/60,yegmg*2],'FaceColor',col(1,:),'EdgeColor',col(1,:))
        end
        hold on;
    end
    plot(mDat.fEMG(1,:)/60,mDat.fEMG(2,:),'k');
    text(mDat.fEMG(1,1)/60,yegmg*0.8,'EMG','fontsize',12);
    set(gca,'xlim',[mDat.fEMG(1,1),mDat.fEMG(1,end)]/60,'XTick',[],'fontsize',12,'Box','on','linewidth',1);
    set(gca,'ylim',[-yegmg,yegmg]);
    ylabel('EMG(uv)');
end
%show EMG amplitude------------------------------------------
axes('position',[0.07,0.08,0.9,0.2]);
if isfield(mDat,'Amp')
    emgT=mDat.Tm;
    emgDat=mDat.Amp;
    h0=max(max(emgDat),200);
    ylm=[-10,h0];
end
%h0=100;
%label the stimulation period
col=[0.5,0.5,1;1,1,0.5];
if ~isempty(stiTm)
    stinum=size(stiTm,1);
    for i=1:stinum
        rectangle('Position',[(stiTm(i,1)-0)/60,1,(stiTm(i,2)-stiTm(i,1))/60,h0-2],'FaceColor',col(1,:),'EdgeColor',col(1,:))
    end
    hold on;
end
plot(emgT/60,emgDat,'k','linewidth',1);
text(emgT(1)/60,h0*0.8,'EMG amplitude','fontsize',12);
set(gca,'xlim',[emgT(1),emgT(end)]/60,'fontsize',12,'Box','on','linewidth',1);
set(gca,'ylim',ylm);
xlabel('time(min)','fontsize',12);
%ylabel('EMG amplitude(uv)');

%auto save figure to tif-file
if ~isempty(fname)
    F=getframe(gcf);
    imwrite(F.cdata,fname);
end