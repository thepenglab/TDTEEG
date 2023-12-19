%to analyze oscillation in photometry
%add peak-counting 2023-01-26 YP
%load mat-file into workspace first
function phtOsc2023(phtDat,specDat,state,sleepData)
%generate spectrogram for photometry (f/min)
capStr={'all states','wake','NREM sleep','REM sleep'};
%%
idx0=find(phtDat.tm<3);
phtDat.data(idx0)=0;
%oscillation analysis: frequency 
pDat=getPhtspec(phtDat);

%%
shortNREMdur=60;        %unit=s
figure;
for i=1:4
    subplot(2,2,i);
    if i==1
        plot(pDat.f*60,mean(pDat.p,1));
    else
        idx=state==i-2;
        if ~isempty(find(idx))
            %remove short NREM episode
            if i==3
                s2=state*0;
                blk=getBlocks(state,1);
                ki=find(blk(:,4)>shortNREMdur/2);
                %ki=find(blk(:,4)>shortNREMdur/2 & blk(:,2)<140*60/2);
                for j=1:length(ki)
                    s2(blk(ki(j),2):blk(ki(j),3))=1;
                end
                idx=idx & s2;
            end
            plot(pDat.f*60,mean(pDat.p(idx,:),1));
        end
    end
    title(capStr{i});
    ylabel('power');
    xlabel('frequency (/min)');
end
%%
%oscillation analysis: peak frequency 
offsetHz=0.7;
idx=state==1;
p0=mean(pDat.p(idx,:),1);
idx=find(pDat.f>offsetHz/60);
[pk,k]=max(p0(idx));
pkHz=pDat.f(k+idx(1)-1)*60;
fprintf('peak frequency (per min) in NREMS is: %f\r',pkHz);
%%
%count peaks 
peaks=zeros(3,3);       %total/per-Min/per-episode
peakTm=countpeaks(phtDat,1,5);
%convert to index of state
stIdx=round(peakTm(:,1)/specDat.step);
stIdx=stIdx(stIdx<=length(state));
peakState=state(stIdx);
for i=0:2
    idx=find(peakState==i);
    peaks(1,i+1)=length(idx);
    peaks(2,i+1)=peaks(1,i+1)/sleepData.dur(i+1);
end
%peaks per episode
peaks(3,1)=peakPerEpisode(sleepData.wakeEpoch,peakTm);
peaks(3,2)=peakPerEpisode(sleepData.nremEpoch,peakTm);
peaks(3,3)=peakPerEpisode(sleepData.remEpoch,peakTm);
disp('Cycle number/number per-min/number per-episode in wake/NREM/REM:');
disp(peaks);
%disp([peakTm,double(peakState)]);
%%
%plot
figure;
axes('position',[0.1,0.96,0.8,0.03]);
imagesc(state');
mymap=[0,0,0;0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;1,1,0];
colormap(gca,mymap);
set(gca,'clim',[-1,3]);
axis off;
axes('position',[0.1,0.7,0.8,0.25]);
imagesc(specDat.p');
set(gca,'clim',[0,2]);
colormap(gca,'jet');
set(gca,'YDir','normal');
set(gca,'ylim',[0,100.5]);
axes('position',[0.1,0.4,0.8,0.25]);
plot(phtDat.tm,phtDat.data)
hold on;
a=std(phtDat.data)/4;
plot(peakTm(:,1),peakTm(:,2)+a,'.r');
set(gca,'xlim',[phtDat.tm(1),phtDat.tm(end)]);
axes('position',[0.1,0.1,0.8,0.25]);
imagesc(pDat.p');
set(gca,'clim',[0,0.0005]);
colormap(gca,'jet');
set(gca,'YDir','normal');
pLen=size(pDat.p,2);
d=6;d2=pDat.fsRange(2)*60/d;
for i=1:d
    ystr{i}=num2str(d2*i);
    ytk(i)=pLen/d*i;
end
set(gca,'ytick',ytk,'yticklabel',ystr);
%%
%oscillation analysis: amplitude
amp=[0,0,0];        %for wake,NREMS,REMS
areas=[0,0,0];      %response under the curve, per 1-min window
pw=[0,0,0];         %relative power of phtOsc in 1-2cycle
pwRange=[1,2]+0;   %f-range (cycle/min) for osc-quantification
ampBouts=cell(3,1);
areaBouts=cell(3,1);
baseBouts=cell(3,1);
durBouts=cell(3,1);     %duration/length of a bout (unit=sec)
nremCycles=zeros(1,2);      %[cycle-number,duration]
%downsample photometry to 0.5Hz to match specDat
tm=downsample(phtDat.tm,round(specDat.step*phtDat.fs));
dat=downsample(phtDat.data,round(specDat.step*phtDat.fs));
len1=length(dat);
len2=length(state);
if len1<len2
    dat(len1+1:len2)=zeros(len2-len1,1);
end
fs=0.5;
s1=std(dat);
for i=1:3
    blk=getBlocks(state,i-1);
    if ~isempty(blk)
        idx=blk(:,4)>10;
%         if i==2
%             idx=blk(:,4)>10 & blk(:,2)<140*60/2;
%         end
        blk=blk(idx,:);
        blknum=size(blk,1);
        y=zeros(blknum,2);
        b0=zeros(blknum,1);
        for j=1:blknum
            dat2=dat(blk(j,2):blk(j,3));
            %y(j)=range(dat2);
            %y(j)=prctile(dat2,75)-prctile(dat2,25);
            b0(j)=prctile(dat2,5);
            %b0(j)=min(dat2);
            if i==3
                b0(j)=mean(baseBouts{1});
                %b0(j)=-0.62;
                y(j,1)=max(dat2)-b0(j);
            else
                y(j,1)=max(dat2)-b0(j);
            end
            y(j,2)=30*sum(dat2-b0(j))/blk(j,4);
        end
        ampBouts{i}=y(:,1);
        areaBouts{i}=y(:,2);
        amp(i)=mean(y(:,1));
        areas(i)=mean(y(:,2));
        baseBouts{i}=b0;
        durBouts{i}=blk(:,4)*specDat.step;
    end
    fIdx=(pDat.f*60>=pwRange(1) & pDat.f*60<=pwRange(2));
    tIdx=(state==i-1);
    p0=sum(mean(pDat.p(tIdx,:)));
    pw(i)=sum(mean(pDat.p(tIdx,fIdx)))/p0;
end
disp('averaged duration of wake/NREMS/REMS:');
disp([mean(durBouts{1}),mean(durBouts{2}),mean(durBouts{3})]);
disp('oscillation amplitudes/areas/power for wake/NREMS/REMS:');
disp([amp;areas;pw]);
%%
%correlation analysis
%correlation between EEG ppower and neural activity in wake/NREMS/REMS
%EEG power: delta/theta/sigma/gamma/all 
Rs=zeros(3,5);     
%remove noisy in the begining
th0=[mean(dat)+3*std(dat),mean(dat)-3*std(dat)];
d0=dat(1:10);
dat(d0>th0(1) | d0<th0(2))=0;

%correlation analysis
egRanges=[0,4;6,9;9,15;30,50;0,50];
[tLen,pLen]=size(specDat.p);
fs=linspace(specDat.fsRange(1),specDat.fsRange(2),pLen);
allDat2=zeros(tLen,5);
for i=1:5
    idx = fs>=egRanges(i,1) & fs<=egRanges(i,2);
    allDat2(:,i)=sum(specDat.p(:,idx),2);
end
% allDat2=specDat.delta;
% allDat2(:,2)=specDat.theta;
% allDat2(:,3)=sum(specDat.p(:,100:end),2);
% allDat2(:,4)=sum(specDat.p,2);
for i=1:3
    idx=(state==i-1);
    for j=1:5
        Rs(i,j)=corr2(dat(idx),allDat2(idx,j));
    end
end
disp('R between photometry and power(delta/theta/sigma/gamma/all):');
disp(Rs);
%%
%plot
%dat2=specDat.theta;
dat2=specDat.delta;
%dat2=sum(specDat.p,2);
%dat2=sum(specDat.p(:,120:end),2);
%ystr='theta power';
ystr='delta power';
%ystr='EEG power';

figure;
xlm=[-3.0,3.0];
ylm=[0,50];
for i=1:4
    subplot(2,2,i);
    if i==1
        idx=state>=0;
    else
        idx=(state==i-2);
    end
    plot(dat(idx),dat2(idx),'.');
    title(capStr(i));
    ylabel(ystr);
    xlabel('photometry (dF/F %)');
    set(gca,'xlim',xlm);
    %set(gca,'ylim',ylm);
    r=corr2(dat(idx),dat2(idx));
    ym=mean(dat2(idx));
    text(xlm(1)+0.5,ym*1.2,['R=',num2str(r,3)]);
end



