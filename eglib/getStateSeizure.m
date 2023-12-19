%generate/update state_Seizure based on szEvents
function state_Seizure=getStateSeizure(state_Seizure,szEvents)
info=getappdata(0,'info');
state_Seizure=(state_Seizure==10);      %reset to 0
for i=1:size(szEvents,1)
    k1=floor((szEvents(i,2)-info.procWindow(1)*60)/info.stepTime);
    k1=max(k1,1);
    k2=round((szEvents(i,3)-info.procWindow(1)*60)/info.stepTime);
    state_Seizure(k1:k2)=1;
end