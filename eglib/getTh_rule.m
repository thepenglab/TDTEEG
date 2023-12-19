
function [stTag,eegth,emgth,ratioth]=getTh_rule(pDat,emgAmp)
ratio=pDat.theta./pDat.delta;
em0=mean(pDat.delta);
em1=median(pDat.delta);
emx=max(pDat.delta);
emi=min(pDat.delta);
esd=std(pDat.delta);
mm0=mean(emgAmp);
mm1=median(emgAmp);
mmx=max(emgAmp);
mmi=min(emgAmp);
msd=std(emgAmp);
%default
eegth=em0;
emgth=mm0;
ratioth=mean(ratio)+std(ratio);
stTag='unknown';
%case 1: all sleep
%case 2: more sleep, less wake
%case 3: half sleep, half wake
%case 4: less sleep, more wake
%case 5: all wake
if (mmx-mm1)/msd>4 && abs(em1-em0)/esd<1 && em1>em0
	eegth=em0-esd;
	emgth=mm0+1*msd;
    ratioth=mean(ratio)+std(ratio)/3;
    stTag='all sleep';    
elseif (mmx-mm1)/msd>4 && (em1-emi)/esd>4     
    eegth=em0-0.5*esd;
    emgth=mm0+msd;  
    ratioth=mean(ratio)+std(ratio)/2;
    stTag='more sleep,less wake';   
elseif (mmx-mm1)/msd>4 && abs(em0-em1)/esd<1 && abs(mm0-mm1)/msd>1
    eegth=em0;
    emgth=mm0-0.5*msd;
    ratioth=mean(ratio)+std(ratio);
    stTag='half sleep half wake';    
elseif (emx-em1)/esd>3 && abs(mm0-mm1)/msd<1 && em1<0.5
    eegth=em0;
    %k=floor(mm0/msd);
    emgth=mm0-0.5*msd;
    ratioth=mean(ratio)+0.5*std(ratio);
    stTag='less sleep,more wake';
elseif abs(mm0-mm1)/msd<1 && abs(em1-em0)/esd<1 && em0<0.5
    eegth=em0+3*esd;
    k=floor(mm0/msd);
    emgth=mm0-k*msd;   
    ratioth=mean(ratio)+0.5*std(ratio);
    stTag='all wake';    
end


