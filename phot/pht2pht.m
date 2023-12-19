% correlation betweeen 2-site photometry, ph1, ph2 
% load mat-file into workspace first

% smooth photometry data
d0 = round(phtDat.fs * specDat.step/4);
% downsampling photometry data to match EEG-power data
tfLen = length(phtDat.data);
[tpLen,pLen] = size(specDat.p);
step = round(tfLen/tpLen);
F0 = smooth(ph1.data,d0);
F1 = F0(1:step:step*tpLen);
F0 = smooth(ph2.data,d0);
F2 = F0(1:step:step*tpLen);
t1 = ph1.tm(1:step:step*tpLen)';
tCon=(t1>=0*60 & t1<=60*60);

%correct baseline for 5-HT signal if needed (baseline drifting & bleaching)
% d00 = 2*60/2;       %over 2min
% F1base=smooth(F1,d00);
% F1=F1-F1base;

% conditions 
%cond=(state>=0);      %all, default
%cond=(state==1);
rs=zeros(1,3);          %correlations between ph1&ph2, [wake,nrem,rem]

% remove very short wake periods
state1b=smallsegRemove(state,60/2,0);

x0=4;
y0=-1;
%xStr='Activity in DG';
xStr='Ach in mPFC';
%yStr='Activity in DRN';
yStr='5-HT in DG';

figure("Position",[rand*100,rand*100,1600,420]);
subplot(1,3,1);
cond=(state1b==0 & tCon);
%r=corr2(specDat.delta(cond),F1(cond));
r=corr2(F1(cond),F2(cond));
rs(1)=r;
plot(F1(cond),F2(cond),'.','MarkerSize',10);
ylabel(yStr);
xlabel(xStr);
title('Wake');
%r1=corrcoef(F1(cond),F2(cond));
text(x0,y0,['r=',num2str(r)]);
p=polyfit(F1(cond),F2(cond),1);
hold on;
xfit=-10:10;
yfit=p(1)*xfit+p(2);
plot(xfit,yfit,'-r');

subplot(1,3,2);
cond=(state==1 & tCon);
%r=corr2(specDat.delta(cond),F1(cond));
r=corr2(F1(cond),F2(cond));
rs(2)=r;
plot(F1(cond),F2(cond),'.','MarkerSize',10);
ylabel(yStr);
xlabel(xStr);
title('NREM');
%r1=corrcoef(F1(cond),F2(cond));
text(x0,y0,['r=',num2str(r)]);
p=polyfit(F1(cond),F2(cond),1);
hold on;
xfit=-10:10;
yfit=p(1)*xfit+p(2);
plot(xfit,yfit,'-r');

subplot(1,3,3);
cond=(state==2 & tCon);
r=corr2(F1(cond),F2(cond));
rs(3)=r;
plot(F1(cond),F2(cond),'.','MarkerSize',10);
ylabel(yStr);
xlabel(xStr);
%title('All');
title('REM');
%r1=corrcoef(F1(cond),F2(cond));
text(x0,y0,['r=',num2str(r)]);

disp("Correlations:");
disp(rs);

