function pDat=getPhtspec(phtDat)
pDat=struct('t',[],'p',[]);
fsRange=[0 0.1];      %frequence range for slow oscillattion analysis

%downsample to 1Hz, original 1k 
ins=round(phtDat.fs);          %4 for 1k-sampling; 8 for 2k
dat=downsample(phtDat.data,ins);
fs=1;
tm=downsample(phtDat.tm,ins);

step=2;
%bin=60*step;
bin=60*2;

t=tm(1):step:(tm(end)-step*0);
L=fs*2000;
nfft=2^nextpow2(L);
f=fs/2*linspace(0,1,nfft/2+1);
idx0=find(f>=fsRange(1) & f<=fsRange(2));
tLen=length(t);
p=zeros(tLen,length(idx0));
for i=1:tLen
    idx=(tm>=t(i)-bin/2 & tm<t(i)+bin/2);
    Y=fft(dat(idx),nfft)/L;
    pxx=abs(Y(1:nfft/2+1)).^2/fs;
    p(i,:)=pxx(idx0);
end

pDat.t=t;
%smooth image
% h=fspecial('average');
% pDat.p=imfilter(p,h);
pDat.p=p;
pDat.f=linspace(fsRange(1),fsRange(2),length(idx0));

pDat.step=step;
pDat.bin=bin;
pDat.fsRange=fsRange;
pDat.fs=fs;




