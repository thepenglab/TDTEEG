%calculate delta density of NREM sleep (ratio of delta to the whole power)
%%
list=dir(folder);
list = list(~[list.isdir]);
[~,idx] = sort([list.datenum]);
list = list(idx);

fsRange=[0 50];  
deltaRange=[1,4];
thetaRange=[6,9];
gammaRange=[25,45];
f=linspace(fsRange(1),fsRange(2),fsRange(2)*4+1);
fLen=fsRange(2)*4+1;
didx=find(f>=deltaRange(1) & f<=deltaRange(2));
tidx=find(f>=thetaRange(1) & f<=thetaRange(2));
gidx=find(f>=gammaRange(1) & f<=gammaRange(2));

fileNumber=0;
deltaDensity=[];
thetaDensity=[];
gammaDensity=[];
wakepower=[];
nrempower=[];
rempower=[];
for i=1:length(list)
    fname=list(i).name;
    if contains(fname,'.mat')
        subfname=fullfile(folder,fname);
        load(subfname,'specDat','state');
        idx=state==1;
        fileNumber=fileNumber+1;
        dd0=sum(specDat.p(:,didx),2)./sum(specDat.p(:,1:fLen),2);
        deltaDensity(fileNumber)=mean(dd0(idx));
        dd1=sum(specDat.p(:,tidx),2)./sum(specDat.p(:,1:fLen),2);
        thetaDensity(fileNumber)=mean(dd1(idx));
        dd2=sum(specDat.p(:,gidx),2)./sum(specDat.p(:,1:fLen),2);
        gammaDensity(fileNumber)=mean(dd2(idx));
        idx=state==0;
        wakepower=[wakepower;specDat.p(idx,1:fLen)];
        idx=state==1;
        nrempower=[nrempower;specDat.p(idx,1:fLen)];
        idx=state==2;
        rempower=[rempower;specDat.p(idx,1:fLen)];
    end
end
disp('delta and theta density per hour in NREMS:');
disp([deltaDensity;thetaDensity;gammaDensity]');
disp('Average delta, theta, gamma density in NREM sleep:');
disp([nanmean(deltaDensity),nanmean(thetaDensity),nanmean(gammaDensity)]);


%%
figure('position',[100,400,1200,300]);
factor=mean(mean(specDat.p,1));
%factor=1;
subplot(1,3,1);
p1=mean(wakepower,1);
p2wake=log2(p1/factor);
plot(f,p2wake);
set(gca,'xlim',[0,fsRange(2)]);
title('Wake');
ylabel('Power (log2)');
xlabel('frequency (Hz)');
subplot(1,3,2);
p1=mean(nrempower,1);
p2nrem=log2(p1/factor);
plot(f,p2nrem);
set(gca,'xlim',[0,fsRange(2)]);
title('NREM sleep');
ylabel('Power (log2)');
xlabel('frequency (Hz)');
subplot(1,3,3);
p1=mean(rempower,1);
p2rem=log2(p1/factor);
plot(f,p2rem);
set(gca,'xlim',[0,fsRange(2)]);
title('REM sleep');
ylabel('Power (log2)');
xlabel('frequency (Hz)');
%%
disp('spectral information: f/wake/NREMS/REMS');
disp([f;p2wake;p2nrem;p2rem]');

