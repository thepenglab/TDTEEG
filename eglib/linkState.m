%link state from segments
list=dir(folder);
linkedState=[];
fileNumber=0;
for i=1:length(list)
    fname=list(i).name;
    if contains(fname,'.mat')
        fullname=fullfile(folder,fname);
        load(fullname,'state','info');
        if ~isempty(state)
            fileNumber=fileNumber+1;
            slen=round(60*(info.procWindow(2)-info.procWindow(1))/info.stepTime);
            slen0=length(state);
            if slen0<slen
                state(slen0+1:slen)=state(slen0);
            end
            linkedState=[linkedState;state];
        end
    end
end
fprintf('%d total files loaded\n',fileNumber);
disp('Data loaded and linked');
%%
%resample state to match SWD-analysis (2s->0.2s, 10 times)
slen=length(linkedState);
b=10;
b2=slen*b;
state_re=reshape(repmat(linkedState,1,b)',b2,1);




