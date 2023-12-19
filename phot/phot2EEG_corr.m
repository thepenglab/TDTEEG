% correlation betweeen photometry and EEG-power
% load mat-file into workspace first

% smooth photometry data
d0 = round(phtDat.fs * specDat.step/4);
F0 = smooth(phtDat.data,d0);
% downsampling photometry data to match EEG-power data
tfLen = length(phtDat.data);
[tpLen,pLen] = size(specDat.p);
step = round(tfLen/tpLen);
F1 = F0(1:step:step*tpLen);
% calculate power at higher-frequencies 
fs1 = [0,25];
f=linspace(specDat.fsRange(1), specDat.fsRange(2), pLen);
idx1 = (f>=fs1(1) & f<=fs1(2));
pfs1 = mean(specDat.p(:,idx1),2);

% conditions 
cond=(state>=0);      %all, default
cond=(state==1);
dth=mean(specDat.delta(state==1));
%cond=cond & (specDat.delta<dth);

x0=0.1;
y0=1;
figure;
subplot(1,3,1);
r=corr2(specDat.delta(cond),F1(cond));
plot(specDat.delta(cond),F1(cond),'.');
ylabel('photometry');
xlabel('delta power');
r1=corrcoef(specDat.delta(cond),F1(cond));
text(x0,y0,['r=',num2str(r1(1,2))]);

subplot(1,3,2);
plot(specDat.theta(cond),F1(cond),'.');
ylabel('photometry');
xlabel('theta power');
r2=corrcoef(specDat.theta(cond),F1(cond));
text(x0,y0,['r=',num2str(r2(1,2))]);
subplot(1,3,3);
r=corr2(pfs1(cond),F1(cond));
plot(pfs1(cond),F1(cond),'.');
ylabel('photometry');
xlabel('power of frequencies(10-25)');
r3=corrcoef(pfs1(cond),F1(cond));
text(x0,y0,['r=',num2str(r3(1,2))]);