%filter calcium signal
%filter

d=fdesign.bandpass('N,F3dB1,F3dB2',10,info.filterEMG(1),info.filterEMG(2),dat.fs);
hd=design(d,'butter');

dat0=phtDat.data;
