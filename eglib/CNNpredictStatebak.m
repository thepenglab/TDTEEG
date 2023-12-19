%use trained CNN to predict state
%updated 4/9/2019
function state=CNNpredictState(specDat,emgAmpDat,trainedNet_File)
unitSize=5;     %to fit unitSize in trainedNet
emgStdFlag=1;   %use std=1 or Amp=0
XData=getNetXData(specDat,emgAmpDat,unitSize,emgStdFlag);
load(trainedNet_File,'trainedNet');
if isempty(trainedNet)
    disp('no trainedNet');
    state=[];
    return;
end
[YPredicted,probs] = classify(trainedNet,XData,'ExecutionEnvironment','cpu');
s1=double(YPredicted)-1;
pTh=0.7;    %threshold for "NotSure"
idx=find(max(probs,[],2)<pTh);
%s1(idx)=-1;
s1(idx)=0;
%convert "unknown" to wake
s1(s1==3)=0;
s2=repmat(s1,1,5);
state_Predicted=reshape(s2',[],1);
if emgStdFlag
    mg=emgAmpDat.Std;
else
    mg=emgAmpDat.Amp;
end
state_Predicted=adjustUsingEMG(state_Predicted,mg);
%add missing episodes
state_Predicted=addMissing(state_Predicted,specDat,mg);
pLen=length(specDat.t);
mLen=length(emgAmpDat.Tm);
sLen=length(state_Predicted);
state=zeros(min(pLen,mLen),1);
state(1:sLen)=adjustState(state_Predicted,specDat.step);
%calculate time for each state
idx1=find(state==0);
idx2=find(state==1);
idx3=find(state==2);
seg=(specDat.t(end)-specDat.t(1))/60;         %convert to minute
dur=[length(idx1),length(idx2),length(idx3)]*seg/length(state);
fprintf('Wake/NREM/REM time(min): %5.2f %5.2f %5.2f\n',dur);


function X=getNetXData(specDat,emgAmpDat,unitSize,emgStdFlag)
factor=2.0;     %default=1.5, normal=1.2-1.8
%only use 0-25Hz spectral-info
f1=linspace(specDat.fsRange(1),specDat.fsRange(2),size(specDat.p,2));
HzSel=[0,25];
idx=(f1>=HzSel(1) & f1<=HzSel(2));
pBuffer=(specDat.p(:,idx)*factor)';
%pBuffer=(specDat.p*factor)';
%smooth spectrogram at time-dimension
%filter for smooth
h1=zeros(11);
h1(6,:)=normpdf(-5:5,0,5);            
h1=h1/sum(h1(6,:));
pBuffer=imfilter(pBuffer,h1);
[pLen,tLen]=size(pBuffer);
snum=floor(tLen/unitSize);
pBuffer=pBuffer(:,1:snum*unitSize);
%generate emg-image
mLen=10;
%mBuffer=zeros(mLen,snum*unitSize);
if emgStdFlag
    mg=emgAmpDat.Std(1:snum*unitSize);
else
    mg=emgAmpDat.Amp(1:snum*unitSize);
end
%remove unusual datapoints
mg(mg>prctile(mg,90))=prctile(mg,90);
%map emg to 1-mLen
mIdx=round((mLen-1)*(mg-min(mg))/(max(mg)-min(mg))+1);
%get reversed for factor (so small for wake)
mg2=(1+mLen./mIdx);
for j=1:snum*unitSize
	%mBuffer(mIdx(j),j)=1;
	pBuffer(:,j)=pBuffer(:,j).*mg2(j);
end
X=reshape(pBuffer,pLen+mLen*0,unitSize,1,[]);

function state=adjustUsingEMG(state,mg)
m0=mean(mg)-0.0*std(mg);
%m0_nrem=mean(mg(state==1));
sLen=length(state);
state(mg(1:sLen)>m0)=0;

function state=addMissing(state,pDat,mg)
sLen=min(length(pDat.delta),length(mg));
%add missing NREM
thd0=mean(pDat.delta(state==1));
thm0=mean(mg(state==1));
state(pDat.delta(1:sLen)>thd0 & mg(1:sLen)<thm0)=1;
%add missing REM 
thr0=mean(pDat.ratio(state==2));
state(pDat.ratio(1:sLen)>thr0 & pDat.delta(1:sLen)<thd0 & mg(1:sLen)<thm0)=2;
