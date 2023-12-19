%save sleep summary to txt-file
function saveSummary2txt(sleepData,info,fname)
if ~isempty(fname)
    fid=fopen(fname,'wt');
    fprintf(fid,'data source: %s\r\n',info.PathName);
    fprintf(fid,'total time processed: %8.1f(minutes)\r\n',sleepData.totalMinute);
    fprintf(fid,'bin and Step time: %d(sec) %d(sec)\r\n',info.binTime,info.stepTime);
    fprintf(fid,'\r\n----sleep summary---------\r\n');
    fprintf(fid,'total Wake/NREM/REM time(min): %8.1f %8.1f %8.1f\r\n',sleepData.dur);
    if ~isempty(sleepData.nremEpoch)
        fprintf(fid,'total NREM sleep epoches: %d\r\n',size(sleepData.nremEpoch,1));
        fprintf(fid,'average NREM sleep duration per epoch: %8.1f(sec)\r\n',mean(sleepData.nremEpoch(:,4)));
    end
    if ~isempty(sleepData.remEpoch)
        fprintf(fid,'total REM sleep epoches: %d\r\n',size(sleepData.remEpoch,1));
        fprintf(fid,'average REM sleep duration per epoch: %8.1f(sec)\r\n',mean(sleepData.remEpoch(:,4)));
    end
    fprintf(fid,'\r\n----NREM sleep epoches(#/startTime/endTime/duration(sec)---------\r\n');
    for i=1:size(sleepData.nremEpoch,1)
        fprintf(fid,'%d\t%d\t%d\t%d\r\n',sleepData.nremEpoch(i,:));
    end
    fprintf(fid,'\r\n----REM sleep epoches(#/startTime/endTime/duration(sec)---------\r\n');
    for i=1:size(sleepData.remEpoch,1)
        fprintf(fid,'%d\t%d\t%d\t%d\r\n',sleepData.remEpoch(i,:));
    end
    fclose(fid);
end