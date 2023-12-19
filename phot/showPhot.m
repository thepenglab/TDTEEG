%my own
function showPhot(filepath,tank,blk)
%%
%read
event1='465N';
event2='405N';
S1 = tdt2mat(filepath, tank, blk, event1);
S2 = tdt2mat(filepath, tank, blk, event2);
s1Len=length(S1.data);
s2Len=length(S2.data);
sLen=min(s1Len,s2Len);
offs=100;
x1=S1.data(offs:sLen,:);
x2=S2.data(offs:sLen,:);
tPhot=(S1.timestamps(offs:sLen,1)-S1.timestamps(offs))/60;      %unit=min
%%
%fit
reg = polyfit(x2,x1,1);
f0=reg(1).*x2+reg(2);
delF=100.*(x1-f0)./f0;
disp(reg);
%%
%plot 
figure;
subplot(3,1,1);
plot(tPhot,x1(:,1),'b');
ylabel('465');
set(gca,'xlim',[0,tPhot(end)]);
subplot(3,1,2);
plot(tPhot,x2(:,1),'g');
ylabel('405');
set(gca,'xlim',[0,tPhot(end)]);
subplot(3,1,3);
binWindow=floor(S1.sampling_rate*3/S1.npoints)+1;
plot(tPhot,smooth(delF(:,1),binWindow),'r');
ylabel('DelF/F(%)');
xlabel('Time(min)');
set(gca,'xlim',[0,tPhot(end)],'ylim',[-5,10]);
%%
%save delF/F as mat-data
pn2=[filepath,'\',tank,'\',blk,'\'];
fname=strcat(pn2,'photDat.mat');
%save(fname,'tPhot','delF');

