function mDat=getEMGAmplitude(dat,info)
mDat=struct('Tm',[],'Amp',[],'Std',[]);
emg=double(dat.data);
%filter data: 10-300Hz
d=fdesign.bandpass('N,F3dB1,F3dB2',10,info.filterEMG(1),info.filterEMG(2),dat.fs);
hd=design(d,'butter');
emg2=filter(hd,emg);
%notch filter to remove 60Hz noise
if info.filterNotch
    d=fdesign.notch(6,60,10,dat.fs);
    hd=design(d);
    emg2=filter(hd,emg2);
    %also remove 50Hz noise
    %d=fdesign.notch(6,50,10,dat.fs);
    %hd=design(d);
    %emg2=filter(hd,emg2);
end

%show the data: pre and filtered
%figure;subplot(2,1,1);plot(emg);subplot(2,1,2);plot(emg2);
%downsample to 1k if oversampled
if dat.fs>2000
    ins=round(dat.fs/1000);
    t=downsample(dat.tm,ins);
    emg2=downsample(emg2,ins);
    fs2=dat.fs/ins;
else
    fs2=dat.fs;
    t=dat.tm;
end

offset=0;
D1=abs(emg2)-offset;
D2=smooth(D1,floor(fs2*info.binTime/4)+1,'moving')-offset;
%down-sampling
%mDat.Amp=resample(D2,1,step*dat.fs);
step2=floor(info.stepTime*fs2);
mDat.Amp=D2(1:step2:end);
%mDat.Amp=clipNoise(mDat.Amp,150);
tLen=length(mDat.Amp);
mDat.Tm=linspace(dat.tm(1),dat.tm(end),tLen);
mDat.Std=zeros(tLen,1); 
h=waitbar(0,'processing EMG,please wait...');  
for i=1:tLen
    idx=(mDat.Tm>=(mDat.Tm(i)-1*info.binTime) & mDat.Tm<(mDat.Tm(i)+1*info.binTime));
    mDat.Std(i)=std(mDat.Amp(idx));
    waitbar(i/tLen);  
end
close(h);
mDat.step=info.stepTime;
mDat.bin=info.binTime;
%save filtered EMG for ploting 
% t=linspace(dat.tm(1),dat.tm(end),length(emg2));
mDat.fEMG=[t;emg2];