function dat=loadTdtPhot(blkPath,event,TmArray,name)
dat=[];
if blkPath>0
    tmp=regexp(blkPath, filesep, 'split');
    tank=tmp{end-1};
    blk=tmp{end};
    fileName=[tank '_' blk '.tev'];
    filePath = [blkPath filesep fileName];
    event2=['x',event(2:end)];
    
    disp(' ')
    disp(datetime)
    %disp(['Open tank: ',tank,'    blk: ', blk])
%     buffer_Idx=['blk', strrep(blk,'-','_'), event,num2str(TmArray(1)),num2str(TmArray(2))];
%     setappdata(0,'buffer_Idx',buffer_Idx);
%     dat=getappdata(0,buffer_Idx);
    dat=[];
    if isempty(dat)
        disp('Loading data from files...')
        
        Raw=TDTbin2mat(blkPath,'T1',TmArray(1),'T2',TmArray(2),'TYPE', {'streams'}, 'STORE', event);
        if isempty(Raw.streams)
            disp('No Photometry data recorded');
        else
            dat.data=Raw.streams.(event2).data;
            dat.fs=Raw.streams.(event2).fs;
            %dat.tm=linspace(0,length(dat.data)/dat.fs,length(dat.data));
            dat.tm=linspace(Raw.time_ranges(1),Raw.time_ranges(2),length(dat.data));
            dat.name=[name,'-',event]; 
            dat.info=Raw.info;
            dat.specDat=getSpectral(dat.data,dat.fs);
            % setappdata(0,buffer_Idx,dat)
        end
    else
        disp('Loading data from buffer...')
    end
    disp([name,' data loaded.'])
else
    disp('Folder is not selected yet')
end
