function dat=loadTdtEEG(blkPath,event,channel,TmArray,name)
if blkPath>0
%     filesep_loc=strfind(blkPath,filesep);
%     filePath=blkPath(1:filesep_loc(end-1)-1);
%     tankPath=blkPath(1:filesep_loc(end)-1);
    tmp=regexp(blkPath, filesep, 'split');
    tank=tmp{end-1};
    blk=tmp{end};
    fileName=[tank '_' blk '.tev'];
    filePath = [blkPath filesep fileName];
    
    disp(' ')
    disp(datetime)
    %disp(['Open tank: ',tank,'    blk: ', blk])
    buffer_Idx=['blk', strrep(blk,'-','_'), event, num2str(channel),num2str(TmArray(1)),num2str(TmArray(2))];
    setappdata(0,'buffer_Idx',buffer_Idx);
    dat=getappdata(0,buffer_Idx);
    dat=[];
    if isempty(dat)
        disp('Loading data from files...')
       
        %heads = TDTbin2mat(blkPath, 'HEADERS', 1);
        Raw=TDTbin2mat(blkPath,'T1',TmArray(1),'T2',TmArray(2),'TYPE', {'streams'}, 'STORE', event, 'CHANNEL', channel);
        dat.data=Raw.streams.(event).data;
        %clip EEG noise if needed
%         clipTh=1000;
%         if contains(name,'EMG')
%             dat.data(abs(dat.data)>clipTh)=0;
%         end
        dat.fs=Raw.streams.(event).fs;
        if TmArray(1)==0 && TmArray(2)==0
            dat.tm=linspace(0,length(dat.data)/dat.fs,length(dat.data));
        else
            dat.tm=linspace(Raw.time_ranges(1),Raw.time_ranges(2),length(dat.data));
        end
        dat.name=[fileName, '  ',name,'  ',num2str(channel)]; 
        dat.info=Raw.info;
        dat.specDat=getSpectral(dat.data,dat.fs);
        %setappdata(0,buffer_Idx,dat)
        
    else
        disp('Loading data from buffer...')
    end
    %disp([name, num2str(channel),' data loaded.'])
else
    disp('Folder is not selected yet')
    dat=[];
end
