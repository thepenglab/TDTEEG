function dat=loadTdtEvents(blkPath,event,TmArray,name)
dat=[];   
fixedDur=30;
if blkPath>0
    tmp=regexp(blkPath, filesep, 'split');
    tank=tmp{end-1};
    blk=tmp{end};
    fileName=[tank '_' blk '.tev'];
    
    disp(' ')
    disp(datetime)
    try
        Raw=TDTbin2mat(blkPath,'T1',TmArray(1),'T2',TmArray(2),'TYPE', {'epocs'}, 'STORE', event);
    catch
        disp('No stimulation, check protocol!')
        return;
    end
    if isempty(Raw.epocs)
        if contains(name,'laser')
            disp('No ChR2 stimulation marked');
        end
        dat.info=Raw.info;
        if isfield(Raw.info,'duration')
            dat.info.recDuration=getRecordDuration(Raw.info.duration);
        else
            dat.info.recDuration=0;
            dat.info.duration='unknown';
        end
    else
        dat=Raw.epocs.(event);
        dat.tm=getStiTm(dat.onset);           %start time for each stimulation
        dat.name=[fileName, '  ',name]; 
        dat.info=Raw.info;
        if isfield(Raw.info,'duration')
            dat.info.recDuration=getRecordDuration(Raw.info.duration);
        else
            dat.info.recDuration=0;
            dat.info.duration='unknown';
        end
        if ~isempty(dat.tm)
            e2=min(20,length(dat.onset));
            fhz=1/mean(dat.offset(1:e2)-dat.onset(1:e2));
            if fhz<1
                % something un-ususal, use default fixed-duration
                dat.duration=fixedDur;
            else
                dat.duration=round(length(dat.onset)/length(dat.tm)/fhz);      %unit=sec
            end
        else
            dat.duration=0;
        end
        %disp([name,' data loaded.'])
    end
else
    disp('Folder is not selected yet')
end


function tm=getStiTm(laserTrain)
%laserTrain = 20Hz laser, usually 2min per stimulation, %interval>5min
if length(laserTrain)>2
    pre=laserTrain*0;
    pre(2:end)=laserTrain(1:end-1);
    dt=laserTrain-pre;
    idx=dt>=2*60;
    tm=laserTrain(idx);
else
    tm=[];
end

function dur=getRecordDuration(timstr)
%timstr='xx:xx:xx'
sLen=length(timstr);
if sLen>=8
    ss=str2double(timstr(sLen-1:sLen));
    mm=str2double(timstr(sLen-4:sLen-3));
    hh=str2double(timstr(1:sLen-6));
    dur=hh*60*60+mm*60+ss;
else
    dur=0;
end
