%correlation between photometry and EEG power, for sleep

%freq bands for analysis
freq=[1,4;6,9;9,15;15,30;30,50];
freqlabels={'Delta','Theta','Sigma','Beta','Gamma'};
freqnum=size(freq,1);

%downsample photometry to match specDat
[tLen,pLen]=size(specDat.p);
tm=downsample(phtDat.tm,round(specDat.step*phtDat.fs));
dat=downsample(phtDat.data,round(specDat.step*phtDat.fs));
fs=linspace(specDat.fsRange(1),specDat.fsRange(2),pLen);
phtLen=length(dat);
if phtLen>tLen
    dat=dat(1:tLen);
    tm=tm(1:tLen);
end

Rs=zeros(freqnum,3);      %correlation for delta/theta/fseiz/all in wake/NREMS/REMS
%remove noisy in the begining
th0=[mean(dat)+3*std(dat),mean(dat)-3*std(dat)];
d0=dat(1:10);
dat(d0>th0(1) | d0<th0(2))=0;

%correlation analysis

allDat2=zeros(tLen,freqnum);
for i=1:freqnum
    idx = fs>=freq(i,1) & fs<=freq(i,2);
    allDat2(:,i)=sum(specDat.p(:,idx),2);
end

% allDat2=specDat.delta;
% allDat2(:,2)=specDat.theta;
%allDat2(:,3)=specDat.fseiz;
%gamma (30-50Hz)
% allDat2(:,3)=sum(specDat.p(:,30*4+1:end),2);
% allDat2(:,4)=sum(specDat.p,2);

x0=0;y0=0.5;
labels_state={'Wake','NREM','REM'};
figure;
for i=1:3
    idx=(state==i-1);
    for j=1:freqnum

        Rs(i,j)=corr2(dat(idx),allDat2(idx,j));
        k=(i-1)*freqnum+j;
        subplot(3,freqnum,k);
        plot(dat(idx),allDat2(idx,j),'.');
        text(x0,y0,num2str(Rs(i,j)));
        str1=[labels_state{i},'-',freqlabels{j}];
        title(str1);
        set(gca,'xlim',[-4,4]);
    end
%     if j==4
%         szPht=dat(idx);
%         szEEGpower=allDat2(idx,3);
%     end
end
disp('R between photometry and power(delta/theta/Sigma/Beta/gamma/all):');
disp(Rs');

%%
% plot traces 
showWindows=[0,300]+25*60;      %unit=sec
figure;
% EEG spectrogram
subplot(freqnum+3,1,1);
imagesc(specDat.p');
set(gca,'clim',[0,2]);
colormap(gca,'jet');
set(gca,'YDir','normal');
set(gca,'xlim',0.5+showWindows/info.stepTime);
% EEG trace
subplot(freqnum+3,1,2);0
plot(specDat.fEEG(1,:),specDat.fEEG(2,:));
set(gca,'xlim',showWindows);
ylabel('EEG');
% EEG power traces
for i=1:freqnum
    subplot(freqnum+3,1,i+2);
    plot(tm,allDat2(:,i));
    set(gca,'xlim',showWindows);
    ylabel(freqlabels{i});
end
% photometry trace
subplot(freqnum+3,1,freqnum+3);
plot(tm,dat,'r');
set(gca,'xlim',showWindows);
ylabel('Ca (DF/F)');
%%
% figure;
% plot(dat,specDat.fseiz,'.');
% figure;
% plot(szPht,szEEGpower,'.');