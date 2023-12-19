%temp

xlen=length(pDat.delta);

figure;
%EEG - delta
subplot(3,1,1);
plot(pDat.delta,'k','linewidth',2);
hold on;
line([0,xlen],[1,1]*em0,'color','r');
line([0,xlen],[1,1]*(em0+esd),'color','b');
%EEG - ratio
subplot(3,1,2);
plot(ratio,'k','linewidth',2);
hold on;
line([0,xlen],[1,1]*mean(ratio),'color','r');
line([0,xlen],[1,1]*(mean(ratio)+std(ratio)),'color','b');
%EMG
subplot(3,1,3);
plot(emgAmp,'k','linewidth',2);
hold on;
line([0,xlen],[1,1]*mm0,'color','r');
line([0,xlen],[1,1]*(mm0+msd),'color','b');