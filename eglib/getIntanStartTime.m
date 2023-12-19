%to start time of recording from header
%format-31 datestr: yyyy-mm-dd HH:MM:SS
function startTimestr=getNLXStartTime(filename)
startTimestr=[];
fLen=length(filename);
if fLen<17
    disp('Error getting Intan start time');
    return;
end
OpenTime=[filename(end-9:end-8),':',...
    filename(end-7:end-6),':',filename(end-5:end-4)];
OpenDate=[filename(end-14:end-13),'/',...
    filename(end-12:end-11),'/20',filename(end-16:end-15)];

startTimestr=datestr([OpenDate,' ',OpenTime]);
