%to start time of recording from header
%format-31 datestr: yyyy-mm-dd HH:MM:SS
function startTimestr=getNLXStartTime(NlxHeader)
startTimestr=[];
%header information different for Cheetach5.6 and 5.7
%for Cheetach5.6.3, keyStr='Time Opened'
keyStr1='Time Opened';
%for Cheetach5.7.4, keyStr='TimeCreated'
keyStr2='TimeCreated';
keyIdx=[0,0];       %key line, key type         
for i=1:length(NlxHeader)
    if ~isempty(strfind(NlxHeader{i},keyStr1))
        keyIdx=[i,1];
    end
    if ~isempty(strfind(NlxHeader{i},keyStr2))
        keyIdx=[i,2];
    end
end
if keyIdx(1)>0
    idx=[];
    s1=cell2mat(NlxHeader(keyIdx(1)));
    if keyIdx(2)==1     %for Cheetach5.6.3
        idx=strfind(s1,'(m/d/y):')+8;
    elseif keyIdx(2)==2     %for Cheetach5.7.4
        idx=strfind(s1,keyStr2)+11;
    end
    
    if ~isempty(idx)
        OpenDate=s1(idx+1:idx+1+9);
        if keyIdx(2)==1
            idx2=strfind(s1,'(h:m:s.ms)')+10;
        elseif keyIdx(2)==2
            idx2=idx+10;
        end
        OpenTime=s1(idx2+1:end);
        startTimestr=datestr([OpenDate,' ',OpenTime]);
    end
    
else
    disp('No start time found, please check!')
end