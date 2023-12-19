function pDat=getEEGspec(dat,info)
%eegData=struct('data',[],'tm',[],'filename','','fs',[]);
eeg=double(dat.data);
%fiter data: 0.5-300Hz
d=fdesign.bandpass('N,F3dB1,F3dB2',10,info.filterEEG(1),info.filterEEG(2),dat.fs);
hd=design(d,'butter');
eeg=filter(hd,eeg);
%notch filter to remove 60Hz noise
if info.filterNotch
    d=fdesign.notch(6,60,10,dat.fs);
    hd=design(d);
    eeg=filter(hd,eeg);
end
%downsample to 256Hz, original 1k or 2k
% ins=round(dat.fs/256);          %4 for 1k-sampling; 8 for 2k
% eeg2=resample(eeg,1,ins);
%downsample 
if info.filterEEG(2)>=100
    ins=round(dat.fs/1000);
else
    ins=round(dat.fs/256);
end
eeg2=downsample(eeg,ins);
fs=(dat.fs/ins);
tm2=linspace(dat.tm(1),dat.tm(end),length(eeg2));
tic;
if isfield(info,'parforTag')
    loopTag=info.parforTag;
else
    loopTag=0;
end
if loopTag
    %use parfor
    pDat=computeSpectrogram2(tm2,eeg2,fs,info.binTime,info.stepTime);
else
    %use regular for loop
    pDat=computeSpectrogram1(tm2,eeg2,fs,info.binTime,info.stepTime);
end
toc;
%also save filtered EEG for trace-plotting
pDat.fEEG=[tm2;eeg2];


