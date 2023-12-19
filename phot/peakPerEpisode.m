function val=peakPerEpisode(epochTm,peakTm)
pepin=[];
enum=size(epochTm,1);
if enum>0
    for i=1:enum
        idx = find(peakTm>=epochTm(i,2) & peakTm<epochTm(i,3));
        pepin = [pepin,length(idx)];
    end
    %val=mean(pepin);
    val=median(pepin);
else
    val=0;
end