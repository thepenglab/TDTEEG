%remove big noise
function dat=clipNoise(dat,th)
th2=mean(dat)+8*std(dat);
th=min(th,th2);
dat(dat>th)=0;