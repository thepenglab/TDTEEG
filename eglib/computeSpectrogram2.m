function pDat=computeSpectrogram2(tm,eeg,fs,bin,step)
pDat=struct('t',[],'p',[],'theta',[],'delta',[],'ratio',[]);
fsRange=[0 50];      %frequence range for analysis, default=[0,25]
ftheta=[6,9];       %theta frequency
fdelta=[1,4];        %delta frequency
fseiz=[20,25];      %seizure frequency, both SWD and GTCS/TS
fs0=[10,12];         %control for seizure detection, ratio
t=tm(1):step:(tm(end)-step);
L=fs*3;
nfft=2^nextpow2(L);
f=fs/2*linspace(0,1,nfft/2+1);
idx0=find(f>=fsRange(1) & f<=fsRange(2));
idx1=(f>=ftheta(1) & f<=ftheta(2));
idx2=(f>=fdelta(1) & f<=fdelta(2));
idx3=(f>=fseiz(1) & f<=fseiz(2));
idx6=(f>=fs0(1) & f<=fs0(2));
tLen=length(t);
p=zeros(tLen,length(idx0));
ptheta=zeros(tLen,1);
pdelta=zeros(tLen,1);
pfseiz=zeros(tLen,1);
pfs0=zeros(tLen,1);
totalHours=(tm(end)-tm(1))/3600;
if totalHours>20
    m=round(totalHours);
else
    m=20;                   %progress bar length
end
fprintf(['Work-load:' repmat('|',1,m) '(100%%)\n']);
fprintf('Work-done:\n');
parfor i=1:tLen
    idx=(tm>=t(i)-bin/2 & tm<t(i)+bin/2);
    Y=fft(eeg(idx),nfft)/L;
    pxx=abs(Y(1:nfft/2+1)).^2/fs;
    p(i,:)=pxx(idx0);
    ptheta(i)=mean(pxx(idx1));
    pdelta(i)=mean(pxx(idx2));
    pfseiz(i)=mean(pxx(idx3));
    pfs0(i)=mean(pxx(idx6));
    if mod(i,round(tLen/m))==1
        fprintf('\b=\n');
    end
end
pDat.t=t;
%smooth image
h=fspecial('average');
pDat.p=imfilter(p,h);
pDat.f=f(idx0);
ptheta=smooth(ptheta,bin);
pdelta=smooth(pdelta,bin);
pDat.theta=ptheta;
pDat.delta=pdelta;
pDat.ratio=ptheta./pdelta;
pDat.fseiz=pfseiz;
pDat.fcontrol=pfs0;
pDat.step=step;
pDat.bin=bin;
pDat.fsRange=fsRange;
pDat.fs=fs;
pDat.clim=max(prctile(pdelta,90),prctile(ptheta,90))*3;
%pDat.clim=2;