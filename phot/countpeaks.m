%count peaks from photometry 
function peakTm=countpeaks(phtDat,stdn,smoothscale)
%downsample to 1Hz, original 1k 
ins=round(phtDat.fs);          %4 for 1k-sampling; 8 for 2k
dat0=downsample(phtDat.data,ins);
fs=1;
tm0=downsample(phtDat.tm,ins);
%get baseline
t0=60*fs*1;
base=smooth(dat0,t0);
%smooth data
dat1=smooth(dat0,round(fs*smoothscale));
ddat=dat1-base;
th=std(ddat)*stdn;
X1=ddat>th;
%find the fist above the threshold
%tLen=length(dat0);
%dd2=zeros(tLen,1);
% dd2(2:end)=X1(2:end)-X1(1:end-1);
% idx=find(dd2==1);
%find the real peak-point
blks=getBlocks(X1,1);
blknum=size(blks,1);
peakTm=zeros(blknum,2);
Idx=zeros(blknum,1);
for i=1:blknum
    X2=ddat(blks(i,2):blks(i,3));
    [mx,ik]=max(X2);
    Idx(i)=ik+blks(i,2)-1;
   
end
peakTm(:,1)=tm0(Idx)';
peakTm(:,2)=dat1(Idx);
%multiple local peaks, not optimal, don't use it 
% dd2(2:end)=ddat(2:end)-ddat(1:end-1);
% X2=dd2>0;
% dd3=zeros(tLen,1);
% dd3(1:end-1)=X2(2:end)-X2(1:end-1);
% idx=find(X1==1 & dd3==-1);
%peakTm=tm0(idx);
disp(['Number of peaks:',num2str(length(peakTm))]);
%%
%show
figure;
subplot(2,1,1);
plot(tm0,dat0,'k');
hold on;
plot(tm0,base,'b');
hold on;
plot(tm0,dat1,'r');
ys=dat1(Idx)+th;
hold on;
plot(peakTm,ys,'.g');
subplot(2,1,2);
plot(tm0,ddat);
line([tm0(1),tm0(end)],[1,1]*th);
hold on;
ys=ones(1,length(peakTm));
plot(peakTm,ys,'.');