%converter the time-format
function timstr=s2hhmmss(tim,sTag)
ss=mod(tim,60);
if ~sTag
    ss=floor(ss);
end
mm=mod(floor(tim/60),60);
hh=floor(tim/60/60);
if ss<10
    s=['0',num2str(ss)];
else
    s=num2str(ss);
end
if mm<10
    m=['0',num2str(mm)];
else
    m=num2str(mm);
end
if hh<10
    h=['0',num2str(hh)];
else
    h=num2str(hh);
end
timstr=[h,':',m,':',s];
