%load pre-saved mat-file to draw EEG traces
function eegTraces(fname)
load(fname);
wn=[0,3601];
fs=dat(1).fs;
tm=dat(1).tm/1000000;
idx=find(tm>=wn(1) & tm<=wn(2));
tm=tm(idx)-wn(1);
eeg=dat(1).data(idx);
%filter =[1 60] w=1 for fs/2
%b= fir1(48,[0.0005,0.03]);
b= fir1(48,0.005,'high');
hd= dfilt.dffir(b);
eeg=filter(hd,eeg);
%another filter
b2= fir1(48,0.03);
hd= dfilt.dffir(b2);
eeg=filter(hd,eeg);
%show all
%ShowRawData(dat,fnum,[])

%show examples of EEG: 10sec
figure('position',[100,200,1000,300]);
axes('position',[0.05,0.5,0.9,0.4]);
t1=[0 10]+1195;
%t1=[0,10]+1340;
idx=find(tm>=t1(1) & tm<t1(2));
plot(tm(idx),eeg(idx),'k','linewidth',1);
set(gca,'ylim',[-500,500]);
axis off;
axes('position',[0.05,0.05,0.9,0.4]);
t2=[0 10]+12;
%t2=[0,10]+1665;
idx=find(tm>=t2(1) & tm<t2(2));
plot(tm(idx),eeg(idx),'k','linewidth',1);
set(gca,'ylim',[-500,500]);
axis off;
%show example of transition period (30s)
figure;
t3=[0,10]+60*2;
idx=find(tm>=t3(1) & tm<t3(2));
plot(tm(idx),eeg(idx),'k','linewidth',1);
set(gca,'ylim',[-500,500]);
%axis off;

%show raw-traces
function ShowRawData(dat,fnum,events)
hfg=figure;
set(hfg,'position',[300,150,1000,200*fnum]);
for i=1:fnum
    subplot(fnum,1,i);
    plot(dat(i).tm/60/1000000,dat(i).data,'k');   
    set(gca,'xlim',dat(i).tm([1,end])/60/1000000,'ylim',[-500,500]);
    xlabel('time(min)');
    ylabel('uV');
end
yaxis=[-1000,1000];
%show event marks if applied
if ~isempty(events)
    evtNum=length(events.Onset);
    for i=1:evtNum
        line([1,1]*events.Onset(i),yaxis,'LineStyle','-.','color','r');
    end
end