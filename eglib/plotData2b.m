%for TDT, EEG+EMG+photometry
function plotData2b(pDat,mDat,df,state,stiTm,fname)
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
    if isempty(df)
        hi=600;
    else
        hi=800;
    end
    hfg=figure('position',[10,200,1500,hi]);
    setappdata(0,'figResult',hfg);    
end
ftsize=12;
if ~isempty(fname)
    set(figResult,'Name',fname);
end
clf;
if isempty(df)      
    axp=[0.05,0.95,0.9,0.03;...
        0.05,0.69,0.9,0.25;...
        0.05,0.42,0.9,0.25;...
        0.05,0.15,0.9,0.25];
else
    axp=[0.05,0.97,0.9,0.02;...
        0.05,0.76,0.9,0.20;...
        0.05,0.54,0.9,0.20;...
        0.05,0.32,0.9,0.20;...
        0.05,0.10,0.9,0.20];
end
%brain states------------------------------------------------------
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
ylm=[0,30]*hei/fLen;
set(gca,'ylim',ylm);
% text(-0.01*wid,hei*1/fLen,'0-','fontsize',ftsize);
text(-0.0*wid,hei*11/fLen,'10-','fontsize',ftsize);
text(-0.0*wid,hei*25/fLen,'Hz','fontsize',ftsize);
%ylabel('Freq.(Hz)','fontsize',ftsize);
%show EEG traces------------------------------------------------------
axes('position',axp(3,:));
tm=pDat.fEEG(1,:);  dat=pDat.fEEG(2,:);
h0=max(dat)*1.2;
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
plot(tm/60,dat,'k','linewidth',0.5);
set(gca,'xlim',[tm(1),tm(end)]/60,'fontsize',ftsize,'Box','on','linewidth',1);
set(gca,'XTick',[]);
% text(-0.02*totmin*a0,100,'100-','fontsize',ftsize);
% text(-0.02*totmin*a0,0,'uV','fontsize',ftsize);
%plot photometry data -------------------------------------------
ylabel('EEG(uV)');
if ~isempty(df)
    %further smooth if not used before
%     df.data=smooth(df.data,51);
    disp('No phot-smoothing');
    %filter data
%     f=[6,10];
%     d=fdesign.bandpass('N,F3dB1,F3dB2',10,f(1),f(2),df.fs);
%     hd=design(d,'butter');
%     df.data=filter(hd,df.data);
    axes('position',axp(end-1,:));
%     yyaxis left
    plot(df.tm/60,df.data,'r','linewidth',1);
    ylabel('DF/F(%)');
    %xlabel('time(min)','fontsize',ftsize);
    y1=5*prctile(df.data,10);
    y2=10*prctile(df.data,90);    
    set(gca,'xlim',[df.tm(1),df.tm(end)]/60,'ylim',[y1,y2],'fontsize',ftsize,'Box','on','linewidth',1.0); 
    set(gca,'XTick',[]);
    grid on;
    %overlayer
%     yyaxis right
%     plot(pDat.fEEG(1,:)/60,pDat.fEEG(2,:),'k');
%     set(gca,'ylim',[-1000,1000]);
%     ylabel('EEG(uV)');
end
%show EMG------------------------------------------------------------
axes('position',axp(end,:));
%tm=mDat.Tm;    dat=mDat.Amp;
tm=mDat.fEMG(1,:);dat=mDat.fEMG(2,:);
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