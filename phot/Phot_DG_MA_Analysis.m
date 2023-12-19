% quantify DG calcium drops during microarousal 
% clear; clc;
% load data into workspace
binTs=[60,10];  %time windows for binning

%Create threshold and plot
TH1 = mean(phtDat.data);
% yline(TH2);
TH2 = smooth(phtDat.data,phtDat.fs*binTs(1)+1);
%TH2 = max(TH1,TH2)+1/2 * std(S.phtDat.data);
TH2 = TH2 + 1/5 * std(phtDat.data);
%TH = mean(S.phtDat.data);

Data = smooth(phtDat.data,phtDat.fs*binTs(2)+1) < TH2;
dData = diff(Data);
dData(1)=1;
rise = find(dData>0)+1;
fall = find(dData<0);
Ind = zeros(length(fall),2,'uint32');           %[drop,pre-peak]
Mks = zeros(length(fall),2);            %[drop,pre-peak]
for i = 1:length(fall)
    %find the drop
    [Mks(i,1),k1] = min(phtDat.data(rise(i):fall(i)));
    Ind(i,1) = k1+rise(i);
    %find the peak before the drop
    a1=round(rise(i)-10*phtDat.fs);        %5s before rise to find pre-peak
    if a1<=0
        a1=1;
    end
    [Mks(i,2),k2] = max(phtDat.data(a1:rise(i)));
    Ind(i,2) = k2+a1;
end
%%
%plot traces
figure(1);clf;
%plot state
t_state=linspace(0,phtDat.tm(end),length(state));
plot(t_state,state);
hold on;
plot(phtDat.tm, phtDat.data,'k');
%plot(S.phtDat.tm, smooth(S.phtDat.data,1000*1+1));
%ylim([-10 10]);
hold on
plot(phtDat.tm, TH2);
hold on
plot(phtDat.tm(Ind(:,1)), Mks(:,1), 'r.', 'MarkerSize', 10)
hold on;
plot(phtDat.tm(Ind(:,2)), Mks(:,2), 'g.', 'MarkerSize', 10)
set(gca,'xlim',[phtDat.tm(1),phtDat.tm(end)]);
%%

evt = zeros(length(fall),4);     %[drop-time,drop-index,pre-state,post-state]
%Determine state of events
for i = 1:length(fall)
    evt(i,1) = phtDat.tm(Ind(i,1)); 
    k0 = round(phtDat.tm(Ind(i,1))./0.1);
    evt(i,2) = k0; 
    if k0 <= length(state)-10 && k0 > 100
        %state after event, MA if 10s before event
        kii=k0-100:k0+10;
        idx = find(state(kii)==3);
        if ~isempty(idx)
            evt(i,4) = 3;
        else
            evt(i,4) = state(k0);
        end
    end
    %state before the drop, 3s
    k0 = ceil(phtDat.tm(Ind(i,2))./0.1);
    if state(k0)==3
        evt(i,3)=1;
    else
        evt(i,3) = state(k0);
    end
end
%calculate all events
evt_state=evt(:,4);
mymap=[0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;0.25,0.75,0.45];
explode=[0,0,0,1];

% figure(4);
% Wake = sum(evt_state == 0);
% NREM = sum(evt_state == 1);
% REM = sum(evt_state == 2);
% MicroA = sum(evt_state == 3);
% X = [Wake NREM REM MicroA];
% labels = {'Wake','NREM','REM','MA'};
% pie(X,explode);
% colormap(gca,mymap);
% legend(labels,'Location','northeastoutside');
% title('% of events in each state');
% disp(X/sum(X));

%only calculate events with pre-state as NREM
k=evt(:,3)==1;
evt_state=evt(k,4);
Wake = sum(evt_state == 0);
NREM = sum(evt_state == 1);
REM = sum(evt_state == 2);
MicroA = sum(evt_state == 3);
X = [Wake NREM REM MicroA];
labels = {'Wake','NREM','REM','MA'};
figure(5);
pie(X,explode);
colormap(gca,mymap);
legend(labels,'Location','northeastoutside');
title('% of transitions from NREM');
disp('Probility in wake,NREM,MA,REM');
disp(X/sum(X));
disp('Calculated and total events:');
disp([sum(X),size(evt,1)]);



   