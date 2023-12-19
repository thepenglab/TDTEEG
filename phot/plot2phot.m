% plot 2 photometry signals along with NREM 

figure;

%first mark NREMS (or others)
cls=[1,0.95,0.85];
evtnum=size(sleepData.nremEpoch,1);
ylm=[-5,5];
for i=1:evtnum
    %NREMS
    a1=sleepData.nremEpoch(i,2);
    w1=sleepData.nremEpoch(i,4);
    rectangle('Position',[a1,ylm(1),w1,ylm(2)-ylm(1)],'FaceColor',cls,'EdgeColor',cls)
end
%also label REM
cls=[1.0,0.9,0.95];
evtnum=size(sleepData.remEpoch,1);
for i=1:evtnum
    a1=sleepData.remEpoch(i,2);
    w1=sleepData.remEpoch(i,4);
    rectangle('Position',[a1,ylm(1),w1,ylm(2)-ylm(1)],'FaceColor',cls,'EdgeColor',cls)
end
hold on;
%plot 2 photometry signals
y2=smooth(ph1.data,round(info.samplingRate)*3);
plot(ph1.tm,y2,'LineWidth',2);
hold on;
plot(ph2.tm,ph2.data,'LineWidth',2);
xlabel('Time(s)');
ylabel('DF/F(%)');