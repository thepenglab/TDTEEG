function pDat=getSpec(dat,fs)
fsRange=[0 0.2];      %frequence range for slow oscillattion analysis
L=fs*1000;
nfft=2^nextpow2(L);
f=fs/2*linspace(0,1,nfft/2+1);
idx0=find(f>=fsRange(1) & f<=fsRange(2));
Y=fft(dat,nfft)/L;
pxx=abs(Y(1:nfft/2+1)).^2/fs;
pDat=struct();
pDat.p=pxx(idx0);
pDat.fsRange=fsRange;
pDat.f=linspace(fsRange(1),fsRange(2),length(idx0));