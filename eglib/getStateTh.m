
%assign the states by fix-threshold catloging
function [state,dur]=getStateTh(pDat,emgAmp,th)
%th=threshold, std of [alpha,theta/alpha_ratio,emgAmp]
%assign the state(wake/NREM/REM) based on EEG+EMG;  %0=wake,1=NREM,2=REM
%first downsample EMG-data
% b=ceil(length(emgAmp)/length(pDat.delta));
% emgAmp=smooth(emgAmp,b);
% emgAmp2=resample(emgAmp,1,b);
emgAmp2=emgAmp;
pLen=length(pDat.delta);
mLen=length(emgAmp2);
if mLen>=pLen
    emgAmp2=emgAmp2(1:pLen);
    delta=pDat.delta;
    ratio=pDat.ratio;
else
    delta=pDat.delta(1:mLen);
    ratio=pDat.ratio(1:mLen);
end
%stTag = 'Manual threshold';
eegth=mean(delta)+th(1)*std(delta);
ratioth=mean(ratio)+th(2)*std(ratio);
emgth=mean(emgAmp2)+th(3)*std(emgAmp2);
%fprintf('This session is: %s\n',stTag);

con_highDelta=delta>eegth;
con_lowDelta=delta<eegth;
con_lowEMG=emgAmp2<emgth;
%NREM based on high delta-power and low EMG amplitude  
state=int8(con_highDelta & con_lowEMG);
%REM sleep
con_highRatio=ratio>ratioth;
con_rem=con_lowDelta & con_highRatio & con_lowEMG ;
idx=find(con_rem);
if ~isempty(idx)
    %fprintf('REM sleep found!\n');
    state(idx)=2;
end
%remove the small segments if shorter than 10sec
d=0*state;
d(2:end)=state(2:end)-state(1:end-1);
idx0=find(d~=0);
dd=idx0(2:end)-idx0(1:end-1);
ix=find(dd<=10);
if ~isempty(ix)
	for k=1:length(ix)
        state(idx0(ix(k)):(idx0(ix(k)+1)-1))=state(idx0(ix(k))-1);
    end
end
%calculate time for each state
idx1=find(state==0);
idx2=find(state==1);
idx3=find(state==2);
seg=(pDat.t(end)-pDat.t(1))/60;
dur=[length(idx1),length(idx2),length(idx3)]*seg/length(state);

%plot the threshold on data (for adjustment)
% figTh=getappdata(0,'figTh');
% hfig=0;
% if ~isempty(figTh)
%     if ishandle(figTh)
%         hfig=1;
%     end
% end
% if hfig
%     set(0,'currentfigure',figTh);
% else
%     figTh=figure('position',[100,0,800,1000]);
%     setappdata(0,'figTh',figTh); 
% end
% subplot(5,1,1);
% imagesc(state');
% mymap=[0.5,0.5,0.5;1,0.5,0;0.6,0.2,1];
% colormap(gca,mymap);
% set(gca,'clim',[0,2]);
% title('Brain States');
% subplot(5,1,2);
% imagesc(pDat.p');
% colormap(gca,'jet');
% set(gca,'clim',[0,2],'YDir','normal','XTick',[],'YTick',[]);
% subplot(5,1,3);
% plot(delta);
% xln=length(delta);
% line([0,1]*xln,[1,1]*mean(delta),'color',[.5,.5,.5],'linestyle',':');
% line([0,1]*xln,[1,1]*eegth,'color','r');
% title('Delta');
% set(gca,'xlim',[0,xln],'ylim',[0,2]);
% subplot(5,1,4);
% plot(ratio);
% xln=length(ratio);
% line([0,1]*xln,[1,1]*mean(ratio),'color',[.5,.5,.5],'linestyle',':');
% line([0,1]*xln,[1,1]*ratioth,'color','r');
% title('Theta/delta ratio');
% set(gca,'xlim',[0,xln]);
% subplot(5,1,5);
% plot(emgAmp2);
% xln=length(emgAmp2);
% line([0,1]*xln,[1,1]*mean(emgAmp2),'color',[.5,.5,.5],'linestyle',':');
% line([0,1]*xln,[1,1]*emgth,'color','r');
% title('EMGAmp');
% set(gca,'xlim',[0,xln]);
