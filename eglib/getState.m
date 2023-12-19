
%assign the states by fix-threshold catloging
function state=getState(pDat,emgAmp)
%assign the state(wake/NREM/REM) based on EEG+EMG;  %0=wake,1=NREM,2=REM
pLen=length(pDat.delta);
mLen=length(emgAmp);
if mLen>=pLen
    emgAmp=emgAmp(1:pLen);
    delta=pDat.delta;
    theta=pDat.theta;
    ratio=pDat.ratio;
else
    delta=pDat.delta(1:mLen);
    theta=pDat.theta(1:mLen);
    ratio=pDat.ratio(1:mLen);
end
%[stTag,eegth,emgth,ratioth]=getTh_rule(pDat,emgAmp);
%fprintf('This session is: %s\n',stTag);
%th=[-0.2,-0.6,-0.6,-0.6];     %defualt threshold: delta/theta/ratio/empAmp
th=[0.4,0.5,0,-0.1];     %defualt threshold: delta/theta/ratio/empAmp

deltath=mean(delta)+th(1)*std(delta);
thetath=mean(theta)+th(2)*std(theta);
ratioth=mean(ratio)+th(3)*std(ratio);
emgth=mean(emgAmp)+th(4)*std(emgAmp);

con_lowEMG=emgAmp<emgth;
% also use relative change
dmg=emgAmp*0;
dmg(2:end)=emgAmp(2:end)-emgAmp(1:end-1);
con_lowEMG2=dmg<0.5;
con_lowEMG=con_lowEMG&con_lowEMG2;

%part1---NREM 
%NREM based on high delta-power and low EMG amplitude  
con_highDelta=delta>deltath;
con_lowratio=ratio<ratioth;
state=int8(con_highDelta & con_lowEMG);
%default: 20/20, use 5/10 for fragmented 
state=fillGap(state,20/pDat.step,0);
state=fillGap(state,20/pDat.step,1);
return;

%part2---REM sleep
con_lowDelta=delta<deltath*1.1;
con_highTheta=theta>thetath;
con_highRatio=ratio>ratioth;
con_rem=con_lowDelta & con_highTheta & con_highRatio & con_lowEMG ;
idx=find(con_rem);
if ~isempty(idx)
    state2=fillGap(con_rem,30/pDat.step,0);
    state2=fillGap(state2,30/pDat.step,1);
    state(state2==1)=2;
end


