% detect seizures (type1=GTCS, type2=SWD)
function [state,events]=getSeizure(specDat,STDth)
%threshold - GTCS
dat1=specDat.fseiz;
dat1b=dat1(dat1<mean(dat1)+3*std(dat1));
delta=specDat.delta;
theta=specDat.theta;
th1=mean(dat1b)+2*STDth*std(dat1b);
th1b=mean(theta)+STDth*std(theta);
th1b=max(prctile(theta,95),th1b);
state=dat1>th1 & theta>th1b;
%add TS 
dat2=dat1./delta;
dat2b=dat2(dat2<mean(dat2)+3*std(dat2));
th2=mean(dat2b)+STDth*std(dat2b);
dth3=prctile(delta,5);
fth3=prctile(dat1,90);
state2=dat2>th2 & delta<dth3 & dat1>fth3;
state=state | state2;
%merge if interval<n-sec
state=smallsegRemove(state,10/specDat.step,0);
%remove events if shorter <1-sec
state=smallsegRemove(state,3/specDat.step,1);

%get time for each seizure-event
d1 = state * 0;
d1(2:end) = state(2:end) - state(1:end-1);
idx1 = find(d1 == 1);
idx2 = find(d1 == -1);
idx0 = find(d1 ~= 0);

if isempty(idx0)
	events=[];
else
    if idx0(1) == idx2(1)
        idx1 = [1;idx1];
    end

    if idx0(end) == idx1(end)
        idx2 = [idx2; length(state)];
    end

    elen = length(idx1);
    events = zeros(elen, 4);
    events(:, 1) = 1:elen;
    events(:, 2) = specDat.t(idx1) - specDat.step;
    events(:, 3) = specDat.t(idx2) - specDat.step;
    events(:, 4) = events(:, 3) - events(:, 2);
end