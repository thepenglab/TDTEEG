%Analyze EEG - align to event (ChR2)
%data from TDT system
function tdtEventEEG(PathName,eegCh) 
autoSave = 1;
stateTag = 1;
info={};
%get the file lists
%segment sise for processing = [pre,total]
seg=[5,15];         %min
segLen=seg(2)*60;      %note: sec for timestamp
info.amplifier='TDT';
info.seg=seg;

tevTag=0;tsqTag=0;
list=dir(PathName);
for i=1:length(list)
	if length(list(i).name)>3
    	FileName=list(i).name;
        if strcmpi(FileName(end-3:end),'.tev')
        	tevTag=1;
        end
        if strcmpi(FileName(end-3:end),'.tsq') 
            tsqTag=1;
            %eventFileName=strcat(PathName,FileName);
        end
    end
end
if ~tevTag || ~tsqTag
    msgbox('No tdt files in the folder! Please choose another!','warn')
    return;
end


%get stimulus-events and total rec-time from event-file
laserEvent=loadTdtEvents(PathName,'lat_',[0,0],'laserEvent');
if ~isempty(laserEvent)
    stiTm=laserEvent.tm;
    stiTm(:,2)=stiTm(:,1)+laserEvent.duration; 
    pnum=length(stiTm);
    fprintf('%d Events found,total record time: %s\n',pnum,laserEvent.info.duration);
    disp(stiTm/60/60);
else
    fprintf('No Event file found, cannot process data!\n');
    return;
end
info.stiDuration=laserEvent.duration;
info.trialNum=pnum;
info.binTime=5;
info.stepTime=2;
filterEEG=[0.5,50];     %default=[0.5,50];
filterEMG=[30,300];     %default=[3,500];
info.filterEEG=filterEEG;
info.filterEMG=filterEMG;
info.filterNotch=1;

%process one segment at a time 
%pnum=25;
stateMap=zeros(pnum,[]);
stateDur=zeros(pnum,[]);
deltaMap=zeros(pnum,[]);            %align delta-power from each trial
emgAmpMap=zeros(pnum,[]);           %align EMG-amplitude from each trial
for i=1:pnum
    fprintf('Processing session %d now...\n',i);
    tmArray=(stiTm(i,1)-seg(1)*60)+[0,segLen];
    info.procWindow=round(tmArray/60);     %unit=minute
    
    eegData=loadTdtEEG(PathName,'Raw_',eegCh,tmArray,'EEG');
    emgData=loadTdtEEG(PathName,'Raw_',4,tmArray,'EMG');%EMG channel is 4

    %for EEG, get the Spectrum
    pDat=getEEGspec(eegData,info);
    %fprintf('EEG processing done\n');
    ln=length(pDat.delta);
    %deltaMap(i,1:ln)=clipNoise(pDat.delta,2)';
    deltaMap(i,1:ln)=pDat.delta';

    %for EMG, get the amplitude
    mDat=getEMGAmplitude(emgData,info);
    ln=length(mDat.Amp);
    emgAmpMap(i,1:ln)=mDat.Amp';
    %fprintf('EMG processing done\n');

    if stateTag
        %assign the state(wake/NREM/REM) based on EEG+EMG;  %0=wake,1=NREM,2=REM
        %state=getState(pDat,mDat.Amp);
        %assign the states using auto-clustering
        %[state,X]=getState2(pDat,mDat);
        %calculate time for each state
        state=CNNpredictState(pDat,mDat,'eegNet.mat');
        idx1=find(state==0);
        idx2=find(state==1);
        idx3=find(state==2);
        dur=[length(idx1),length(idx2),length(idx3)]*seg(2)/length(state);
        fprintf('Wake/NREM/REM time(min): %d,%d,%d\n',round(dur));
    else
        state=[];
        dur=[];
    end
    
    %show the result(EEG-spectrogram and EMG)
    if autoSave
        fn=['ChR2_EEG',num2str(eegCh),'_',num2str(i),'.tif'];
        fname=fullfile(PathName,fn);
        %also data to mat-file
        folder1=[];
        k=strfind(PathName,'\');
        if ~isempty(k)
            if k(end)==length(PathName)
                e1=k(end-1)+1;
                e2=k(end)-1;
                folder1=PathName(e1:e2);
            else
                e1=k(end)+1;
                folder1=PathName(e1:end);
            end
        end
        fn2=[folder1,'_eeg',num2str(eegCh),'_',num2str(i),'.mat'];
        fname2=fullfile(PathName,fn2);
        info.stiTm=stiTm(i,:);
        save(fname2,'pDat','mDat','state','info');
    else
        fname=[];
    end
%     stm=seg(1)*60+[0,laserEvent.duration];
%     dTm=stiTm(2:end,1)-stiTm(1:end-1,1);
%     idx=find(dTm/60<=(seg(2)-seg(1)));
%     if ~isempty(idx)
%         idx2=find(idx==i);
%         if ~isempty(idx2)
%             stm(2,:)=stm+dTm(idx(idx2(1)));
%         end
%     end
    stm=stiTm;
    plotData2(pDat,mDat,[],state,stm,fname);
    
    %save data
    stateMap(i,1:length(state))=state;
    stateDur(i,1:length(dur))=dur;
end
fprintf('Total Wake/NREM/REM time: %d(min),%d(min),%d(min)\n',round(sum(stateDur))); 
%plot aligned delta-power and EMG-Amp and brain states
fn=['ChR2_EEG',num2str(eegCh),'_result.tif'];
info.fname=fullfile(PathName,fn);

plotAlignedMaps(deltaMap,emgAmpMap,stateMap,info);
%%
% if stateTag
%     wid = 500*3;
%     subw = 0.33;
% else
%     wid = 500*2;
%     subw = 0.5;
% end
% figure('position',[0,0,wid,500]);
% for i=1:2
%     x0=(i-1)*subw+0.05;
%     if i==1
%         mapDat=deltaMap;
%         datName='delta power';
%         yName='power';
%         yMax=1;
%         cMax=1;
%     else
%         mapDat=emgAmpMap;
%         datName='EMG amplitude';
%         yName='uV';
%         cMax=50;
%         yMax=100;
%     end
%     xLen=size(mapDat,2);
%     %plot colored trials on top---------------------------
%     subplot('position',[x0,0.37,subw*0.8,0.58]);
%     imagesc(mapDat);
%     colormap('jet');
%     set(gca,'clim',[0,cMax]);      
%     %set(gca,'xtick',[]);
%     tkn=round((seg(2)/seg(1)))+1;
%     xtkName=cell(1,tkn);
%     for k=1:tkn
%         kk=-seg(1)+(k-1)*seg(1);
%         xtkName{k}=num2str(kk);
%     end
%     set(gca,'xtick',[]);
%     %xlabel(['Total time: ',num2str(seg(2)),'min']);
%     ylabel('Trials');
%     %[m,n]=size(mapDat);
%     line([1,1]*seg(1)*xLen/seg(2),[0,pnum+0.5],'color','w','LineStyle','--');
%     line([1,1]*((seg(1)+laserEvent.duration*1.0/60))*xLen/seg(2),[0,pnum+0.5],'color','w','LineStyle','--');
%     title(datName);
%     
%     m0=mean(mapDat)';
%     xLen=length(m0);
%     %plot mean trace ----------------------------------------
%     subplot('position',[x0,0.1,subw*0.8,0.25]);
%     %mark the ChR2-stimluation
%     col=[0.5,0.5,1];
%     %line([1,1]*seg(1)*xLen/seg(2),[0,yMax*1.5],'color','b','LineStyle','--');
%     %line([1,1]*((seg(1)+laserEvent.duration*1.0/60))*xLen/seg(2),[0,yMax*1.5],'color','b','LineStyle','--');
%     rectangle('Position',[seg(1)*xLen/seg(2),0,laserEvent.duration*xLen/60/seg(2),yMax*1.1],'FaceColor',col,'EdgeColor',col);
%     hold on;
%     x=(1:xLen)';
%     dy=(std(mapDat)./sqrt(1))';
%     fill([x;flipud(x)],[m0-dy;flipud(m0+dy)],[.85 .85 .85],'linestyle','none');
%     line(x,m0,'color','r','linewidth',1)
%     set(gca,'xlim',[1,xLen],'ylim',[0,yMax]);
%     set(gca,'xtick',linspace(1,xLen,tkn),'xticklabels',xtkName);
%     ylabel(yName);
%     xlabel('Time(min)');
% end
% if stateTag
%     hold all;
%     x0=2*subw+0.05;
%     %plot aligned states----------------------------------------
%     subplot('position',[x0,0.37,subw*0.8,0.58]);
%     imagesc(stateMap);
%     mymap=[0.5,0.5,0.5;1,0.5,0;0.6,0.2,1];
%     colormap(gca,mymap);
%     set(gca,'clim',[0,2]);
%     set(gca,'xtick',[]);
%     ylabel('Trials');
%     line([1,1]*seg(1)*xLen/seg(2),[0,pnum+0.5],'color','w','LineStyle','--');
%     line([1,1]*((seg(1)+laserEvent.duration*1.0/60))*xLen/seg(2),[0,pnum+0.5],'color','w','LineStyle','--');
%     title('brain states');
%     
%     subplot('position',[x0,0.1,subw*0.8,0.25]);
%     col=[0.5,0.5,1];
%     %mark the ChR2-stimluation
%     %line([1,1]*seg(1)*xLen/seg(2),[0,yMax*1.5],'color','b','LineStyle','--');
%     %line([1,1]*((seg(1)+laserEvent.duration*1.0/60))*xLen/seg(2),[0,yMax*1.5],'color','b','LineStyle','--');
%     rectangle('Position',[seg(1)*xLen/seg(2),-0.1,laserEvent.duration*xLen/60/seg(2),yMax*1.2],'FaceColor',col,'EdgeColor',col);
%     hold on;
%     m0=mean(stateMap)';
%     x=(1:xLen)';
%     %dy=(std(stateMap)./sqrt(1))';
%     %fill([x;flipud(x)],[m0-dy;flipud(m0+dy)],[.85 .85 .85],'linestyle','none');
%     line(x,m0,'color','r','linewidth',1)
%     set(gca,'ylim',[-0.1,1.1]);
%     set(gca,'xtick',linspace(1,xLen,tkn),'xticklabels',xtkName);
%     ylabel('probability of NREMS');
%     xlabel('Time(min)');
% 
% end
%save summary data
if autoSave
	fn=['ChR2_EEG',num2str(eegCh),'_result.mat'];
	fname=fullfile(PathName,fn);
    save(fname);
end
fprintf('---Data processing done---\n');




