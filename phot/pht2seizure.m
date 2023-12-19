%align photometry signals to onset of seizure events
%read multiple mat-files 
%folder=
tWindows=[1,2]*60;        %time windows of pre- and post-SWD, unit=sec
snum=0;
%downsample photometry to 10Hz 
ptnum=ceil((tWindows(1)+tWindows(2))*1017/100);
phtTm=linspace(-tWindows(1),tWindows(2),ptnum);
phtMerge=zeros(1,ptnum);
activity=zeros(1,2);
filenameList=cell(1);

list=dir(folder);
filenum=0;
for i=1:length(list)
    fname=list(i).name;
    if contains(fname,'.mat')
        filenum=filenum+1;
        fullname=fullfile(folder,fname);
        load(fullname,'state','info','phtDat','specDat');
        %merge -1 for seizure if -1 as seizure, DONT merge if unknown
        %state(state==-1)=3;
        %generate szEvents
        blks=getBlocks(state,3);
        if ~isempty(blks)
            szEvents=blks;
            szEvents(:,2:3)=blks(:,2:3)*info.stepTime;
            szEvents(:,4)=szEvents(:,3)-szEvents(:,2);
            sznum=size(szEvents,1);
            %downsample photometry to 10Hz 
            tm=downsample(phtDat.tm,100);
            dat=downsample(phtDat.data,100);
            %bleaching issue
            dat(1:10*3)=0;
            %convert to Z-score
            dat=(dat-mean(dat))./std(dat);
            for j=1:sznum
                %if szEvents(j,2)>tWindows(1)
                snum=snum+1;
                idx=(tm>szEvents(j,2)-tWindows(1) & tm<szEvents(j,2)+tWindows(2));
                x0=dat(idx);

                if length(x0)>ptnum
                    phtMerge(snum,:)=x0(1:ptnum);
                else
                    %phtMerge(snum,1:length(x0))=x0;
                    phtMerge(snum,end-length(x0)+1:end)=x0;
                end
                idx1=(tm>szEvents(j,2)-tWindows(1) & tm<szEvents(j,2));
                activity(snum,1)=mean(dat(idx1));
                idx2=(tm>szEvents(j,2) & tm<szEvents(j,3));
                activity(snum,2)=mean(dat(idx2));
                filenameList{snum}=fname;
                %end
            end
        else
            fprintf('No seizure in: %s\r\n',fname);
        end
    end
end
fprintf('%d files loaded\r\n',filenum);
disp('Pre and Ictal Activity(Z):')
disp(activity);
%%
%show results
% a=1000*rand;
% b=1000*rand;
% w=1500;h=400;
% figure('Position',[a,b,w,h]);
figure();
%subplot(1,3,1);
imagesc(phtMerge);
colorbar;
title('photometry');
%axis off;
%------------------------------------------------------------
% a=1000*rand;
% b=1000*rand;
% figure('Position',[a,b,w,h]);
figure();
%subplot(1,3,1);
x=phtTm;
m0=mean(phtMerge);
dy=std(phtMerge)./sqrt(snum);
fill([x,fliplr(x)],[m0-dy,fliplr(m0+dy)],[.75 .75 .75],'linestyle','none');
hold on;
plot(x,m0,'r','linewidth',1);
set(gca,'xlim',[-tWindows(1),tWindows(2)]);
title('photometry');
xlabel('time(s)');
ylabel('DF/F(%)');


