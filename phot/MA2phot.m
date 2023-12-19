% PSTH of photometry using microarousals (MA)
% load data into workspace

% generate MA-events from state==3
% state is sampled 10Hz
fs=10;
blks=getBlocks(state,3);
MAEvents=blks;
MAEvents(:,2:end)=MAEvents(:,2:end)/fs;

%downsample photometry to 10Hz 
ds=round(phtDat.fs/10);
tm=downsample(phtDat.tm,ds);
tm=tm-tm(1);
dat=downsample(phtDat.data,ds);
%convert to Z
dat_m0=mean(dat);
dat_std=std(dat);
dat=(dat-dat_m0)/dat_std;
%re-do EMG-amplitude with higher resolution (10Hz)
bs=round(info.samplingRate/2);
mg1=smooth(abs(emgAmpDat.fEMG(2,:)),bs);
mgAmp=downsample(mg1,ds);
mgTm=downsample(emgAmpDat.fEMG(1,:),ds);
mgTm=mgTm-mgTm(1);

tWindows=[15,15];        %time windows of pre- and post-SWD, unit=sec
baseWindow=[-tWindows(1)+0,-5+0];
snum=size(MAEvents,1);
tnum=round(sum(tWindows)*10);
phtEventMap=zeros(snum,tnum);
phtEventTm=linspace(-tWindows(1),tWindows(2),tnum);
pnum=round(sum(tWindows)*10);
powerEventMap=zeros(snum,pnum);
powerEventTm=linspace(-tWindows(1),tWindows(2),pnum);
emgEventMap=zeros(snum,pnum);

fsDelta=[0.5,4];
pnum3=size(specDat.p,2);
fsRange=linspace(specDat.fsRange(1),specDat.fsRange(2),pnum3);
fsIdx=fsRange>=fsDelta(1) & fsRange<=fsDelta(2);

for i=1:snum
    idx=(tm>MAEvents(i,2)-tWindows(1) & tm<MAEvents(i,2)+tWindows(2));
    x0=dat(idx);
    if length(x0)>tnum
        phtEventMap(i,:)=x0(1:tnum);
    else
        phtEventMap(i,1:length(x0))=x0;
    end
    idx2=(specDat.t>=MAEvents(i,2)-tWindows(1) & specDat.t<=MAEvents(i,2)+tWindows(2));
    x0=sum(specDat.p(idx2,:),2);
    if length(x0)>pnum
        powerEventMap(i,:)=x0(1:pnum);
    else
        powerEventMap(i,1:length(x0))=x0;
    end
    idx3=(mgTm>=MAEvents(i,2)-tWindows(1) & mgTm<=MAEvents(i,2)+tWindows(2));
    x2=mgAmp(idx3);
    if length(x2)>pnum
        emgEventMap(i,:)=x2(1:pnum);
    else
        emgEventMap(i,1:length(x2))=x2;
    end
end

%%
%show results
a=200*rand;
b=200*rand;
w=1800;h=1000;
figure('Position',[a,b,w,h]);
%figure(2);clf;
subplot(2,3,1);
imagesc(phtEventMap);
colorbar;
title('photometry');
%axis off;
subplot(2,3,2);
imagesc(emgEventMap);
colorbar;
title('EMG amplitude');
%axis off;
subplot(2,3,3);
imagesc(powerEventMap);
colorbar;
title('EEG power');
%axis off;
%------------------------------------------------------------
subplot(2,3,4);
x=phtEventTm;
m0=mean(phtEventMap);
dy=std(phtEventMap)./sqrt(snum);
fill([x,fliplr(x)],[m0-dy,fliplr(m0+dy)],[.75 .75 .75],'linestyle','none');
hold on;
plot(x,m0,'r','linewidth',1);
ylm=[min(m0),max(m0)];
line([0,0],ylm,'Color',[0.5,0.5,0.5],'LineStyle','--');
set(gca,'xlim',[-tWindows(1),tWindows(2)]);
title('photometry');
xlabel('time(s)');
ylabel('Z');
%quantify latency and calcium drop to MA
%find the baseline in the pre-window
idx=phtEventTm>baseWindow(1) & phtEventTm<baseWindow(2);
base0=mean(m0(idx));
%latency from ca-base to MA-onset
th0=std(m0)/20;
idx0=phtEventTm>-tWindows(1) & phtEventTm<0;
idx1=find(abs(m0(idx0)-base0)<th0);
maLatency=abs(phtEventTm(idx1(end)));
%calcium drop 
idx2=phtEventTm>0 & phtEventTm<5;
caBottom=min(m0(idx2));
caDrop=caBottom-base0;
disp('Latency(s), MA-duration(s), calcium-drop:')
%MA duration
maDur=mean(MAEvents(:,4));
disp([maLatency,maDur,caDrop]);
%draw the baseline
line([-tWindows(1),-maLatency],[1,1]*base0,'Color','b','LineStyle','--');
subplot(2,3,5);
x=powerEventTm;
m0=mean(emgEventMap);
dy=(std(emgEventMap)./sqrt(snum));
fill([x,fliplr(x)],[m0-dy,fliplr(m0+dy)],[.75 .75 .75],'linestyle','none');
hold on;
plot(x,m0,'r','linewidth',1);
ylm=[min(m0),max(m0)];
line([0,0],ylm,'Color',[0.5,0.5,0.5],'LineStyle','--');
set(gca,'xlim',[-tWindows(1),tWindows(2)]);
title('EMG amplitude');
xlabel('time(s)');
ylabel('EMG(uV)');
subplot(2,3,6);
x=powerEventTm;
m0=mean(powerEventMap);
dy=(std(powerEventMap)./sqrt(snum));
fill([x,fliplr(x)],[m0-dy,fliplr(m0+dy)],[.75 .75 .75],'linestyle','none');
hold on;
plot(x,m0,'r','linewidth',1);
ylm=[min(m0),max(m0)];
line([0,0],ylm,'Color',[0.5,0.5,0.5],'LineStyle','--');
set(gca,'xlim',[-tWindows(1),tWindows(2)]);
title('EEG power');
xlabel('time(s)');
ylabel('EEG power');