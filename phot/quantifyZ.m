% quantify ca2+ signal (photometry)

%pre-analysis, down-sample to 10Hz
tm0=downsample(phtDat.tm,100);
dat0=downsample(phtDat.data,100);
fs0=phtDat.fs/100;

tm0=tm0-tm0(1);
%dat0(1:round(fs0*0.1))=0;

%resample state to match photometry-data
state_long=0*dat0;
for i=1:length(state)
    idx=(tm0>=(i-1)*info.stepTime & tm0<i*info.stepTime);
    state_long(idx)=state(i);
end

% set the time window for processing
tWindow=[1,240*60]+0*60;
idx=tm0>=tWindow(1) & tm0<=tWindow(2);
tm0=tm0(idx);
dat0=dat0(idx);
state_long=state_long(idx);
tLen=length(dat0);

% convert unknown to seizure
%state_long(state_long==-1)=3;

%%
%convert to Z-score
m0=mean(dat0);
s0=std(dat0);
Zdat=(dat0-m0)./s0;

%%
%find the baseline
smTim=60*5;       %half smoothing window (sec)
b=round(smTim*fs0);
b0=round(60*fs0/2);
zbase=smooth(Zdat,b0);
base=0*Zdat;
for i=1:tLen
    k1=max(1,i-b);
    k2=min(tLen,i+b);
    base(i)=min(zbase(k1:k2));
end
base=smooth(base,b);
% k=0;x=0;tx=0;
% for i=b:b:tLen-b
%     k=k+1;
%     x(k)=quantile(Zdat(i-b+1:i+b),0.1);
%     tx(k)=tm0(i);
% end
% c=polyfit(tx,x,1);
% yb=c(1)*tx+c(2);
% base=smooth(Zdat,b);       %for response-detection

fixedBase=quantile(Zdat,0.1);

responseDat=zeros(3,5);     %row=wake/nrems/rems; col=[mean,std,sum,dur,total/min]
%actDat=Zdat-base;
actDat=Zdat-fixedBase;
for i=0:3
    %idx0=(state_long==i & actDat>0);
    idx0=(state_long==i);
    responseDat(i+1,1)=mean(actDat(idx0));
    responseDat(i+1,2)=std(actDat(idx0));
    responseDat(i+1,3)=sum(actDat(idx0));
    idx1=(state==i);
    dur0=length(find(idx1))/length(idx1)*sleepData.totalMinute;
    responseDat(i+1,4)=dur0;
    responseDat(i+1,5)=responseDat(i+1,3)/dur0/60;
end
disp('row=wake/nrems/rems; col=[mean,std,sum,dur,total/min]');
disp(responseDat');
%%
figure;
%show state
axes('position',[0.05,0.87,0.9,0.06]);
imagesc(state');
mymap=[0,0,0;0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;1,1,0];
colormap(gca,mymap);
set(gca,'clim',[-1,3]);
axis off;
axes('position',[0.05,0.1,0.9,0.75]);
plot(tm0,Zdat,'k');
hold on;
plot(tm0,base,'b');
plot([tm0(1),tm0(end)],[1,1]*fixedBase,'--g')
%plot(tx,yb,'g');
set(gca,'xlim',[tm0(1),tm0(end)]);
xlabel('time(s)');
ylabel('DF/F(Z-score)');
