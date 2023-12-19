%generate new state_Seizure from szEvents
function state_Seizure=genStateSeizure(szEvents,state,info)
state_Seizure=state<0;
snum=size(szEvents,1);
for i=1:snum
    k1=floor((szEvents(i,2)-info.procWindow(1)*60)/info.stepTime);
    k2=round((szEvents(i,3)-info.procWindow(1)*60)/info.stepTime);
    state_Seizure(k1:k2)=1;
end