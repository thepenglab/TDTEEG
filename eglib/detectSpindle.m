function state_Spindle=detectSpindle(specDat,STDth)
%state=specDat.fseiz>STDth;
[tLen,pLen]=size(specDat.p);
%state = zeros(tLen,1);
%f-band for Sleep spindle
fs1 = [10, 15];   % signal-band1:
fc1 = [4, 6];   % control-band1          
       
f=linspace(specDat.fsRange(1), specDat.fsRange(2), pLen);
idx1 = (f>=fs1(1) & f<=fs1(2));
idx2 = (f>=fc1(1) & f<=fc1(2));
pfs1 = mean(specDat.p(:,idx1),2);
pfc1 = mean(specDat.p(:,idx2),2);

pfs1=pfs1./pfc1;
th = mean(pfs1)+STDth*std(pfs1);

%con1 = pfs1./pfc1>0.2;
%if sleep already scored
%con1 = state==1;
%if not sleep not scored
con1 = specDat.delta>mean(specDat.delta);
state_Spindle =  pfs1>th & con1;

%remove events if shorter <0.5 sec
state_Spindle=smallsegRemove(state_Spindle,0.5/specDat.step,1);

%get time for each spindle-event
events=getszEvents(specDat,state_Spindle,1);
ShowSeizureTraces(events,specDat);

%%%
%fiter data: 
d=fdesign.bandpass('N,F3dB1,F3dB2',10,fs1(1),fs1(2),specDat.fs);
hd=design(d,'butter');
feeg=filter(hd,specDat.fEEG(2,:));
figure;
plot(specDat.fEEG(1,:)/60,feeg);
hold on;
plot(specDat.t/60,pfs1*100);
hold on;
plot([0,specDat.t(end)/60],[1,1]*th*100);


