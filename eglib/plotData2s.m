function plotData2(pDat,mDat,df,state,stiTm,fname)
totmin=floor((mDat.Tm(end)-mDat.Tm(1))/60);
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
    if isempty(df)
        hi=400;
    else
        hi=600;
    end
    wid=min(1500,totmin*50);
    hfg=figure('position',[10,200,wid,hi]);
    setappdata(0,'figResult',hfg);    
end
ftsize=12;
%show state-----------------------------------------------------------
clf;
if isempty(df)
    axp=[0.05,0.87,0.9,0.06;0.05,0.50,0.9,0.35;0.05,0.18,0.9,0.3];
else
    axp=[0.05,0.94,0.9,0.03;0.05,0.64,0.9,0.28;0.05,0.37,0.9,0.25];
end
axes('position',axp(1,:));
imagesc(state');
mymap=[0,0,0;0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;1,1,0];
colormap(gca,mymap);
set(gca,'clim',[-1,3]);
axis off;
%show EEG-spectrogram-----------------------------------------------
axes('position',axp(2,:));
imagesc(pDat.p');
colormap(gca,'jet');
[wid,hei]=size(pDat.p);
fLen=pDat.fsRange(2)-pDat.fsRange(1);
cm=pDat.clim;
cm=2;
set(gca,'clim',[0,cm],'YDir','normal','XTick',[],'YTick',[]);
text(-0.01*wid,hei*0/fLen,'0-','fontsize',ftsize);
text(-0.02*wid,hei*10/fLen,'10-','fontsize',ftsize);
text(-0.02*wid,hei*24/fLen,'Hz','fontsize',ftsize);
ylm=[0,25]*hei/fLen;
set(gca,'ylim',ylm);
%ylabel('EEG');
%show EMG------------------------------------------------------------
axes('position',axp(3,:));
%tm=mDat.Tm;    dat=mDat.Amp;
tm=mDat.fEMG(1,:);  dat=mDat.fEMG(2,:);
%downsample (for plotting)
tm=downsample(tm,20);
dat=downsample(dat,20);
%h0=max(200,prctile(dat,90)*3);
h0=1000;
%label the stimulation period
col=[0.5,0.5,1;1,1,0.5];
if ~isempty(stiTm)
    stinum=size(stiTm,1);
    for i=1:stinum
        rectangle('Position',[(stiTm(i,1)-0)/60,1,(stiTm(i,2)-stiTm(i,1))/60,h0-2],'FaceColor',col(1,:),'EdgeColor',col(1,:))
    end
    hold on;
end
plot(tm/60,dat,'k','linewidth',1);
set(gca,'xlim',[tm(1),tm(end)]/60,'ylim',[-h0,h0],'fontsize',ftsize,'Box','on','linewidth',1);
% text(-0.02*totmin,100,'100-','fontsize',ftsize);
% text(-0.02*totmin,0,'uV','fontsize',ftsize);
ylabel('EMG(uV)');
%ylabel('EEG(uV)');
if isempty(df)
    xlabel('time(min)','fontsize',ftsize);
else
    set(gca,'XTick',[]);
    %hold on;plot(df.tm/60,df.data*10,'r','linewidth',1);
    %plot photometry data -------------------------------------------
    axes('position',[0.05,0.1,0.9,0.25]);
%     yyaxis left
    plot(df.tm/60,df.data,'r','linewidth',1);
    ylabel('DF/F(%)');
    xlabel('time(min)','fontsize',ftsize);
    y1=5*prctile(df.data,10);
    y2=10*prctile(df.data,90);
    set(gca,'xlim',[df.tm(1),df.tm(end)]/60,'ylim',[y1,y2],'fontsize',ftsize,'Box','on','linewidth',1.5);    
    %overlayer
%     yyaxis right
%     plot(pDat.fEEG(1,:)/60,pDat.fEEG(2,:),'k');
%     set(gca,'ylim',[-1000,1000]);
%     ylabel('EEG(uV)');
end

%auto save figure to tif-file
if ~isempty(fname)
    F=getframe(gcf);
    imwrite(F.cdata,fname);
end