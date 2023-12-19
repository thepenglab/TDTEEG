function state=detectSWD(specDat,STDth)
%state=specDat.fseiz>STDth;
r = [0.5,0.3];
[tLen,pLen]=size(specDat.p);
%state = zeros(tLen,1);
%f-band for SWD
fs1 = [6, 9];   % signal-band1:
fs2 = [13, 16];
fc1 = [1, 4];   % control-band1          
fc2 = [10, 12];          
f=linspace(specDat.fsRange(1), specDat.fsRange(2), pLen);
idx1 = (f>=fs1(1) & f<=fs1(2));
idx2 = (f>=fs2(1) & f<=fs2(2));
idx4 = (f>=fc1(1) & f<=fc1(2));
idx5 = (f>=fc2(1) & f<=fc2(2));
pfs1 = mean(specDat.p(:,idx1),2);
pfs2 = mean(specDat.p(:,idx2),2);
pfc1 = mean(specDat.p(:,idx4),2);
pfc2 = mean(specDat.p(:,idx5),2);

con1 = pfs1./pfc1>r(1) & pfs2./pfc2>r(2);
%con1 = (pfs1>mean(pfs1) & pfs2>mean(pfs2));
dat1=specDat.fseiz;
th = mean(dat1)+STDth*std(dat1);
state =  specDat.fseiz>th & con1;

state=adjustSWD(state,specDat);
