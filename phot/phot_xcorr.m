% cross correlation between ph1 and ph2 (2-site photometry)
% load mat-file into workspace first

% downsample photometry to ~10Hz
fs0=phtDat.fs;
fs1=fs0/100;
F1=downsample(ph1.data,100);
F2=downsample(ph2.data,100);
maxlags=60*10;
[c,lags]=xcorr(F1,F2,maxlags,"normalized");
figure;
x=lags/fs1;
stem(x,c);
line([0,0],[-0.5,0.3],'Color','r','LineStyle','--');
set(gca,'xlim',[-30,30]);
title('Cross correlation between DG-DRN activity');
xlabel('Time(s)');
ylabel('Correlation');
