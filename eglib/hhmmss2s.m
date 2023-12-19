
%converter the time-format
function tim=hhmmss2s(timstr)
if length(timstr)==8
    tim=str2double(timstr(1:2))*60*60+str2double(timstr(4:5))*60+str2double(timstr(7:8));
else
    tim=0;
end