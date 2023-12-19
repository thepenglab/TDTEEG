%for TDT, EEG+EMG+photometry
function plotData1b(pDat,mDat,state,stiTm,fname)
%totmin=floor((mDat.Tm(end)-mDat.Tm(1))/60);
figResult=getappdata(0,'figResult');
hfig=0;
if ~isempty(figResult)
    if ishandle(figResult)
        hfig=1;
    end
end
if hfig
    set(0,'currentfigure',figResult);
else
    hi=400;
    hfg=figure('position',[10,200,1500,hi]);
    setappdata(0,'figResult',hfg);    
end
ftsize=12;
if ~isempty(fname)
    set(figResult,'Name',fname);
end
clf;

%brain states------------------------------------------------------
axes('position',[0.05,0.87,0.9,0.06]);
imagesc(state');
mymap=[0,0,0;0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;1,1,0];
colormap(gca,mymap);
set(gca,'clim',[-1,3]);
axis off;
%show EEG-spectrogram-----------------------------------------------
axes('position',[0.05,0.50,0.9,0.35]);
imagesc(pDat.p');
colormap(gca,'jet');
[wid,hei]=size(pDat.p);
fLen=pDat.fsRange(2)-pDat.fsRange(1);
cm=pDat.clim;
cm=2;
set(gca,'clim',[0,cm],'YDir','normal','XTick',[],'YTick',[]);
ylm=[0,30]*hei/fLen;
set(gca,'ylim',ylm);
% text(-0.01*wid,hei*1/fLen,'0-','fontsize',ftsize);
text(-0.0*wid,hei*11/fLen,'10-','fontsize',ftsize);
text(-0.0*wid,hei*25/fLen,'Hz','fontsize',ftsize);
%ylabel('Freq.(Hz)','fontsize',ftsize);
%show EMG------------------------------------------------------------
axes('position',[0.05,0.18,0.9,0.3]);
%tm=mDat.Tm;    dat=mDat.Amp;
tm=mDat.fEMG(1,:);dat=mDat.fEMG(2,:);
%downsample (for plotting)
tm=downsample(tm,20);
dat=downsample(dat,20);
%h0=1000;
h0=max(500,prctile(dat,90)*5);
%label the stimulation period
col=[0.5,0.5,1;1,1,0.5];
if ~isempty(stiTm)
    stinum=size(stiTm,1);
    for i=1:stinum
        rectangle('Position',[(stiTm(i,1)-0)/60,1,(stiTm(i,2)-stiTm(i,1))/60,h0-2],'FaceColor',col(1,:),'EdgeColor',col(1,:))
    end
    hold on;
end
plot(tm/60,dat,'k','linewidth',0.5);
set(gca,'xlim',[tm(1),tm(end)]/60,'fontsize',ftsize,'Box','on','linewidth',1);
set(gca,'ylim',[-h0,h0]);
% text(-0.02*totmin*a0,100,'100-','fontsize',ftsize);
% text(-0.02*totmin*a0,0,'uV','fontsize',ftsize);
ylabel('EMG(uV)');
xlabel('time(min)','fontsize',ftsize);

%auto save figure to tif-file
if ~isempty(fname)
    F=getframe(gcf);
    imwrite(F.cdata,fname);
end