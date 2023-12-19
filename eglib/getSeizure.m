% detect seizures (type1=GTCS, type2=SWD)
function [state,events]=getSeizure(specDat,STDth)
if specDat.step<1
    state=detectSWD(specDat,STDth);
else
    state=detectGTCS(specDat,STDth);
end
%get time for each seizure-event
events=getszEvents(specDat,state,1);