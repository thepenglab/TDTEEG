function varargout = tdtEEGgui(varargin)
% TDTEEGGUI MATLAB code for tdtEEGgui.fig
%      TDTEEGGUI, by itself, creates a new TDTEEGGUI or raises the existing
%      singleton*.
%
%      H = TDTEEGGUI returns the handle to a new TDTEEGGUI or the handle to
%      the existing singleton*.
%
%      TDTEEGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TDTEEGGUI.M with the given input arguments.
%
%      TDTEEGGUI('Property','Value',...) creates a new TDTEEGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tdtEEGgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tdtEEGgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tdtEEGgui

% Last Modified by GUIDE v2.5 23-May-2022 13:11:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tdtEEGgui_OpeningFcn, ...
                   'gui_OutputFcn',  @tdtEEGgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tdtEEGgui is made visible.
function tdtEEGgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tdtEEGgui (see VARARGIN)

% Choose default command line output for tdtEEGgui
handles.output = hObject;

% add my init
%init once
handles=initOnce(handles);
%init data
initData();

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tdtEEGgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%init only once
function handles=initOnce(handles)
versionName='TDT-EEGgui Offline, 2020-03-05YP';
setappdata(0,'versionName',versionName);
set(handles.text_versionName,'String',versionName);
eegCh=3;
setappdata(0,'eegCh',eegCh);
emgCh=4;
setappdata(0,'emgCh',emgCh);
setappdata(0,'M2_flag',0);
setappdata(0,'photCh',1);   %0=no photometry data; 1=data
setappdata(0,'stiCh',0);    %0=no stimulation, 1=data (epocs)
set(handles.checkbox_file_csc3,'value',1);
set(handles.checkbox_file_csc4,'value',1);
set(handles.checkbox_file_phot,'value',1);
set(handles.checkbox_file_sti,'value',0);
set(handles.text_file_folderName,'String',[]);
%parameters
procWindow=[0,60];                  %unit=sec
setappdata(0,'procWindow',procWindow);   
binTime=5;                          %unit=min
setappdata(0,'binTime',binTime);    
stepTime=2;                         %unit=min
setappdata(0,'stepTime',stepTime);  
photBinTime=1;
setappdata(0,'photBinTime',photBinTime);       %unit=sec, for smoothing of photometric signals
set(handles.edit_photBinTime,'String',photBinTime);
setappdata(0,'photTag',{'465A','405A'});                 %name to read photometry data
setappdata(0,'figWindow',[0,60]);   %unit=min, for figure-result
th=[0.3,1,0.5];
setappdata(0,'th',th);         %threshold for state-detection
setappdata(0,'stateTag',1);
setappdata(0,'autoSaveTag',0);
setappdata(0,'emgAmpDispFlag',1);       %1=show EMG amplitude, 0=show raw
setappdata(0,'stateMergeTag',0);
setappdata(0,'seizureTag',0);
seizureSTD=3;
setappdata(0,'seizureSTD',seizureSTD);
set(handles.edit_function_seizureSTD,'String',seizureSTD);
parforTag=0;
setappdata(0,'parforTag',parforTag);
filterEEG=[0.5,50];
setappdata(0,'filterEEG',filterEEG);
filterEMG=[3,300];
setappdata(0,'filterEMG',filterEMG);
filterNotch=1;
setappdata(0,'filterNotch',filterNotch);
set(handles.checkbox_filter_notch,'Value',filterNotch);
set(handles.edit_filter_eeg1,'String',filterEEG(1));
set(handles.edit_filter_eeg2,'String',filterEEG(2));
set(handles.edit_filter_emg1,'String',filterEMG(1));
set(handles.edit_filter_emg2,'String',filterEMG(2));
%figure handles
setappdata(0,'figRawData',[]);
setappdata(0,'figResult',[]);
setappdata(0,'figTh',[]);
setappdata(0,'figInfoPanel',[]);
setappdata(0,'mscoreSelect',0);     %selected brain states for manual-scoring, 0/1/2=w/nrem/rem, -1=unknown
%figure display
setappdata(0,'specClim',2);
%load trainedNet if exist (default-file=eegNet.dat)
defaultNet='eegNet.mat';
if ~isempty(dir(defaultNet))
    setappdata(0,'trainedNet_File',defaultNet);
    setappdata(0,'cnnFlag',1);
    set(handles.text_function_trainedNet,'String',['TrainedNet:',defaultNet]);
    set(handles.checkbox_function_cnn,'value',1);
else
    setappdata(0,'cnnFlag',0);
    set(handles.checkbox_function_cnn,'value',0);
end
set(handles.pushbutton_mscore_save,'enable','on');
setappdata(0,'PathName',[]);
info=struct('amplifier','','totalMin',0,'samplingRate',0,'stimuli','N/A',...
    'eventStr',[],'FileInfo',[],'eegCh',eegCh,'emgCh',emgCh,'procWindow',procWindow,...
    'parforTag',parforTag,'seizureSTD',seizureSTD,'segments',[],...
    'binTime',binTime,'stepTime',stepTime,'photBinTime',photBinTime,...
    'filterEEG',filterEEG,'filterEMG',filterEMG,'filterNotch',filterNotch);
setappdata(0,'info',info);

%init the data
function initData()
setappdata(0,'FileName',[]);
setappdata(0,'eegData',[]);
setappdata(0,'emgData',[]);
setappdata(0,'photData',[]);
setappdata(0,'specDat',[]);
setappdata(0,'emgAmpDat',[]);
setappdata(0,'state',[]);           %for one segment, 0/1/2/3
setappdata(0,'state_Sleep',[]);     %only for sleep, 0/1/2
setappdata(0,'state_Seizure',[]);   %only for seizuer 0/1
setappdata(0,'allState',[]);        %for all segments
setappdata(0,'sleepData',[]);       %summary of sleep analysis
setappdata(0,'szEvents',[]);
setappdata(0,'stiTm',[]);
setappdata(0,'laserEvent',[]);
setappdata(0,'segMergeFlag',0);
info=getappdata(0,'info');
info.totalMin=0;
info.samplingRate=0;
info.stimuli='N/A';
setappdata(0,'info',info);


% --- Executes on button press in pushbutton_file_folder.
function pushbutton_file_folder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName = getappdata(0,'PathName');
PathName = uigetdir(PathName);
if PathName~=0
    %check if the folder has ncs+nev files
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
                eventFileName=fullfile(PathName,FileName);
            end
        end
    end
    if tevTag && tsqTag
        %clear all previous data
        initData();        
        set(handles.text_file_folderName,'String',PathName);
        setappdata(0,'PathName',PathName);
        info=getappdata(0,'info');
        info.amplifier='TDT';
        note=loadTdtEvents(PathName,'Note',[0,0],'');
        %update procWindow
        procWindow=getappdata(0,'procWindow');
        totalMin=floor(note.info.recDuration/60);
        if totalMin<procWindow(2)
            procWindow=[0,totalMin];
            setappdata(0,'procWindow',procWindow);
            set(handles.edit_par_startTime,'String',0);
            set(handles.edit_par_endTime,'String',totalMin);
        end
        %read event-file to get some basic information
        eventStr={};
        stiCh=getappdata(0,'stiCh');
        if stiCh>0
            laserEvent=loadTdtEvents(PathName,'lat_',[0,0],'laserEvent');
            setappdata(0,'laserEvent',laserEvent);
            if ~isempty(laserEvent)
                stiTm=laserEvent.tm;
                %stiTm(:,2)=stiTm(:,1)+laserEvent.duration;  
                stiTm(:,2)=stiTm(:,1)+30;  
                setappdata(0,'stiTm',stiTm); 
                %show info
                format shortG
                disp('-------------------------------');
                disp([num2str(length(laserEvent.tm)),' Laser stimulation (min):']);
                disp(stiTm/60);
                stistr=[num2str(length(stiTm)),' ChR2 Events(min):'];
                for i=1:length(stiTm)
                    stistr=[stistr,' ',num2str(round(stiTm(i)/60)),';'];
                    eventStr{i,1}=s2hhmmss(stiTm(i,1),0);
                    eventStr{i,2}=s2hhmmss(stiTm(i,2),0);
                    eventStr{i,3}='N/A';
                    eventStr{i,4}='ChR2 stimulation';
                end
                info.stimuli=stistr;
                info.laserEvent=laserEvent;
                info.eventStr=eventStr;
                set(handles.text_info_stimuli,'String',stistr);
            end
        end
        %set(handles.text_info_subject,'String',note.info.Subject);
        set(handles.text_info_totalMin,'String',note.info.duration);
        %set(handles.text_info_starttime,'String',note.info.Start);
        %set(handles.text_info_stoptime,'String',note.info.Stop);
        info.PathName=PathName;
        info.recDuration=note.info.recDuration;
        info.totalMin=info.recDuration/60;
        info.FileInfo=fieldnames(note.info);
        nt2=struct2cell(note.info);
        for i=1:length(info.FileInfo)
            info.FileInfo{i}=[info.FileInfo{i},' = ',nt2{i}];
        end
        setappdata(0,'info',info);
        setappdata(0,'FileName',[]);
    else
        msgbox('No tdt files in the folder! Please choose another!','warn')
    end
end


% --- Executes on button press in pushbutton_file_viewData.
function pushbutton_file_viewData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_viewData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StoreID='Raw_';         %default='Raw_', others='Wav1'
PathName = getappdata(0,'PathName');

eegCh=getappdata(0,'eegCh');   
emgCh=getappdata(0,'emgCh');   
photCh=getappdata(0,'photCh');
egNum=length(eegCh);
%mgNum=length(emgCh);

procWindow=getappdata(0,'procWindow');
if procWindow(2)>0 && procWindow(2)>procWindow(1)
	tmArray=procWindow*60;
else
	tmArray=[0,0];
end    
setappdata(0,'figWindow',procWindow);
set(handles.edit_par_timescale1,'String',procWindow(1));
set(handles.edit_par_timescale2,'String',procWindow(2));

%read eegData
%eegData=[];
for i=1:egNum
    eegData(i)=loadTdtEEG(PathName,StoreID,eegCh(i),tmArray,'EEG');
    %info=eegData(i).info;
    %eegData(i).data=eegData(i).data;% .*10^6; %unit converted from V to uV
end


%read emgData
%emgData=[];
if emgCh>0
    emgData=loadTdtEEG(PathName,StoreID,emgCh,tmArray,'EMG');%EMG channel is 4
    %emgData.data=emgData.data;% .*10^6;
end

%read photometry data 
%photData=[];
if photCh>0
    tagname=getappdata(0,'photTag');
    %tagname={'465B','405B'};
    photData(1)=loadTdtPhot(PathName,tagname{1},tmArray,'phot'); 
    photData(2)=loadTdtPhot(PathName,tagname{2},tmArray,'phot'); 
    %for RZ5P, 1 color photometry
%     photData(1)=loadTdtPhot(PathName,'465N',tmArray,'phot'); 
%     photData(2)=loadTdtPhot(PathName,'405N',tmArray,'phot'); 
    %for RZ10X, 2 color photometry
%     photData(1)=loadTdtPhot(PathName,'465A',tmArray,'phot'); 
%     photData(2)=loadTdtPhot(PathName,'405A',tmArray,'phot'); 
%     photData(1)=loadTdtPhot(PathName,'560B',tmArray,'phot'); 
%     photData(2)=loadTdtPhot(PathName,'405B',tmArray,'phot'); 
    x1=photData(1).data;
    x2=photData(2).data;
    reg = polyfit(x2,x1,1);
    disp(reg)
    if reg(1)<0
        f0=mean(x1);
    else
        f0=reg(1).*x2+reg(2);
    end    
    delF=100.*(x1-f0)./f0;
    photData(3)=photData(1);
    photData(3).data=delF;
    photData(3).name='DeltaF/F';
else
    photData=[];
end

setappdata(0,'eegData',eegData);
setappdata(0,'emgData',emgData);
setappdata(0,'photData',photData);

info=getappdata(0,'info');
if ~isempty(eegData)
    fs=eegData(1).fs;
    if isfield(eegData(1).info,'duration')
        info.strDuration=eegData(1).info.duration;
    else
        info.strDuration='na';
    end
    info.samplingRate=fs;
    info.FileInfo=eegData(1).info;
else
    fs=0;
end
info.procWindow=procWindow;
if ~isempty(info.segments)
    if info.segments(end,1)~=procWindow(1)
        info.segments=[info.segments;procWindow];
    end
else
    info.segments=procWindow;
end
setappdata(0,'info',info);
set(handles.text_info_samplingRate,'String',num2str(fs));
% stiTm=getappdata(0,'stiTm');
% if isempty(stiTm)
% 	set(handles.text_info_subject,'String',eegData(1).info.Subject);
% 	set(handles.text_info_totalMin,'String',info.strDuration);
% 	set(handles.text_info_starttime,'String',eegData(1).info.Start);
%     set(handles.text_info_stoptime,'String',eegData(1).info.Stop);
% end
%plot data
ShowRawData([eegData,emgData,photData],[])


% --- Executes on button press in checkbox_file_csc1.
function checkbox_file_csc1_Callback(hObject, eventdata, handles)
eegCh=getappdata(0,'eegCh');
M2_flag=getappdata(0,'M2_flag');
csc1=1+4*M2_flag;
if get(hObject,'Value')
    if find(eegCh==csc1)
        %do nothing
    else
        eegCh(end+1)=csc1;
    end
else
    idx=find(eegCh~=csc1);
    eegCh=eegCh(idx);
end
setappdata(0,'eegCh',eegCh);  


% --- Executes on button press in checkbox_file_csc2.
function checkbox_file_csc2_Callback(hObject, eventdata, handles)
eegCh=getappdata(0,'eegCh');
M2_flag=getappdata(0,'M2_flag');
csc2=2+4*M2_flag;
if get(hObject,'Value')
    if find(eegCh==csc2)
        %do nothing
    else
        eegCh(end+1)=csc2;
    end
else
    idx=find(eegCh~=csc2);
    eegCh=eegCh(idx);
end
setappdata(0,'eegCh',eegCh);



% --- Executes on button press in checkbox_file_csc3.
function checkbox_file_csc3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_file_csc3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_file_csc3
eegCh=getappdata(0,'eegCh');
M2_flag=getappdata(0,'M2_flag');
csc3=3+4*M2_flag;
if get(hObject,'Value')
    if find(eegCh==csc3)
        %do nothing
    else
        eegCh(end+1)=csc3;
    end
else
    idx=find(eegCh~=csc3);
    eegCh=eegCh(idx);
end
setappdata(0,'eegCh',eegCh);

% --- Executes on button press in checkbox_file_csc4.
function checkbox_file_csc4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_file_csc4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_file_csc4
emgCh=getappdata(0,'emgCh');
M2_flag=getappdata(0,'M2_flag');
csc4=4+4*M2_flag;
if get(hObject,'Value')
    if find(emgCh==csc4)
        %do nothing
    else
        emgCh(end+1)=csc4;
    end
else
%     idx=find(emgCh==csc4);
%     emgCh=emgCh(idx);
    emgCh=-1;       %don't use EMG
end
setappdata(0,'emgCh',emgCh);


% --- Outputs from this function are returned to the command line.
function varargout = tdtEEGgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_par_startTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_startTime as text
%        str2double(get(hObject,'String')) returns contents of edit_par_startTime as a double
procWindow=getappdata(0,'procWindow');
procWindow(1)=str2double(get(hObject,'String'));
setappdata(0,'procWindow',procWindow);

% --- Executes during object creation, after setting all properties.
function edit_par_startTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_par_endTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_endTime as text
%        str2double(get(hObject,'String')) returns contents of edit_par_endTime as a double
procWindow=getappdata(0,'procWindow');
procWindow(2)=str2double(get(hObject,'String'));
setappdata(0,'procWindow',procWindow);

% --- Executes during object creation, after setting all properties.
function edit_par_endTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_par_nextSegment.
function pushbutton_par_nextSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_par_nextSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
procWindow=getappdata(0,'procWindow');  
procWindow=procWindow+procWindow(2)-procWindow(1);
setappdata(0,'procWindow',procWindow);
setappdata(0,'segMergeFlag',0);
set(handles.edit_par_startTime,'String',num2str(procWindow(1)));
set(handles.edit_par_endTime,'String',num2str(procWindow(2)));

% --- Executes on button press in pushbutton_par_preSegment.
function pushbutton_par_preSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_par_preSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
procWindow=getappdata(0,'procWindow');  
if procWindow(1)-(procWindow(2)-procWindow(1))>=0
    procWindow=procWindow-(procWindow(2)-procWindow(1));
    setappdata(0,'procWindow',procWindow);
    set(handles.edit_par_startTime,'String',num2str(procWindow(1)));
    set(handles.edit_par_endTime,'String',num2str(procWindow(2)));
end

% --- Executes on button press in pushbutton_function_analyse.
function pushbutton_function_analyse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_function_analyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% main part of the analysis
eegData=getappdata(0,'eegData');
emgData=getappdata(0,'emgData');
photData=getappdata(0,'photData');
% if isempty(eegData) || isempty(emgData) 
%     msgbox('NO DATA! Please open folder and load data!','warn');
%     return;
% end
info=updateInfo();
%procWindow=getappdata(0,'procWindow');
stiTm=getappdata(0,'stiTm');
stateTag=getappdata(0,'stateTag');
autoSaveTag=getappdata(0,'autoSaveTag');
%for EEG, get the Spectrum
if isempty(eegData)
    pDat=[];
else
    egDat=eegData(1);
    % calculate differential signals between two channels
    if length(eegData)==2
        egDat.data=eegData(1).data-eegData(2).data;
    end
    pDat=getEEGspec(egDat,info);
    %pDat=getEEGspec(eegData(1),info);
    pDat.clim=getappdata(0,'specClim');
end
setappdata(0,'specDat',pDat);
%fprintf('EEG processing done\n');
%for EMG, get the amplitude
if isempty(emgData)
    mDat=[];
else
    mDat=getEMGAmplitude(emgData(1),info);
    if length(mDat.Amp)<length(pDat.delta)
        mDat.Std(end+1:length(pDat.delta))=0;
        mDat.Amp(end+1:length(pDat.delta))=0;
        mDat.Tm(end+1:length(pDat.delta))=mDat.Tm(end);
    end
end
setappdata(0,'emgAmpDat',mDat);
%fprintf('EMG processing done\n');
if isempty(photData)
    df=[];
else
    df=photData(3);
    b=round(info.photBinTime*df.fs)+1;
    %b=11;
    df.data=smooth(df.data,b);             %default=11
    df.data(1:b)=0;
    df.dat0=smooth(photData(1).data,b);
    df.dat0(1:b)=0;
    df.ref=smooth(photData(2).data,b);
    df.ref(1:b)=0;
end
setappdata(0,'phtDat',df);
%asign the brain states
if stateTag
	%assign the state(wake/NREM/REM) based on EEG+EMG;  %0=wake,1=NREM,2=REM
    cnnFlag=getappdata(0,'cnnFlag');
    trainedNet_File=getappdata(0,'trainedNet_File');
    %need MATLAB2019 or higher
    if cnnFlag  
        state=CNNpredictState(pDat,mDat,trainedNet_File);
    else
        state=getState(pDat,mDat.Amp);
    end
    state_Sleep=state;
    %detect seizures if selected
    seizureTag=getappdata(0,'seizureTag');
    if seizureTag
        seizureSTD=getappdata(0,'seizureSTD');
        [state_Seizure,szEvents]=getSeizure(pDat,seizureSTD);
        state(state_Seizure)=3;
        setappdata(0,'szEvents',szEvents);
        snum=size(szEvents,1);
        fprintf('Detect %d seizure events\n',snum);
        if snum>0
            ShowSeizureTraces(szEvents,pDat);
        end
        setappdata(0,'state_Seizure',state_Seizure);
    end
    setappdata(0,'state',state);
    setappdata(0,'state_Sleep',state_Sleep);
    %merge segments
    stateMergeTag=getappdata(0,'stateMergeTag');
    if stateMergeTag
        segMergeFlag=getappdata(0,'segMergeFlag');
        allState=getappdata(0,'allState');
        if segMergeFlag==0
            allState=[allState;state];
            setappdata(0,'segMergeFlag',1);
        elseif segMergeFlag==1
            sLen=length(state);
            allState(end-sLen+1:end)=state;
        end
    else
        allState=state;
    end
    setappdata(0,'allState',allState);
else
    state=[];
end
    
%show the result(EEG-spectrogram and EMG)
if autoSaveTag
    eegCh=getappdata(0,'eegCh');
    info=getappdata(0,'info');
	%fn=['eeg',num2str(eegCh),'.tif'];
    fn=['eeg',num2str(eegCh),'_m',num2str(info.procWindow(1)),'-',num2str(info.procWindow(2)),'.png'];
	fname=fullfile(info.PathName,fn);
else
    fname=[];
end

%plot data
emgAmpDispFlag=getappdata(0,'emgAmpDispFlag');
%reset the stimili-time for current process window
if emgAmpDispFlag
    plotData2(pDat,mDat,df,state,stiTm,fname);
else
    %use the following to see EEG traces (seizures)
    plotData2b(pDat,mDat,df,state,stiTm,fname);
end

function info=updateInfo()
info=getappdata(0,'info');
binTime=getappdata(0,'binTime');
stepTime=getappdata(0,'stepTime');
photBinTime=getappdata(0,'photBinTime');
parforTag=getappdata(0,'parforTag');
filterEEG=getappdata(0,'filterEEG');
filterEMG=getappdata(0,'filterEMG');
filterNotch=getappdata(0,'filterNotch');
seizureSTD=getappdata(0,'seizureSTD');
info.binTime=binTime;
info.stepTime=stepTime;
info.photBinTime=photBinTime;
info.parforTag=parforTag;
info.filterEEG=filterEEG;
info.filterEMG=filterEMG;
info.filterNotch=filterNotch;
info.seizureSTD=seizureSTD;
setappdata(0,'info',info);

% --- Executes on button press in pushbutton_function_clear.
function pushbutton_function_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_function_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%clear data
initData();
%clear PathName and info
set(handles.text_file_folderName,'String',[]);
%info=getappdata(0,'info');
set(handles.text_info_totalMin,'String','');
set(handles.text_info_samplingRate,'String','');
set(handles.text_info_stimuli,'String','');
set(handles.text_info_subject,'String','');
set(handles.text_info_starttime,'String','');
set(handles.text_info_stoptime,'String','');
%close all figures
figRawData=getappdata(0,'figRawData');
if ~isempty(figRawData)
    delete(figRawData);
    setappdata(0,'figRawData',[]);
end
figResult=getappdata(0,'figResult');
if ~isempty(figResult)
    delete(figResult);
    setappdata(0,'figResult',[]);
end
figTh=getappdata(0,'figTh');
if ~isempty(figTh)
    delete(figTh);
    setappdata(0,'figTh',[]);
end
figTraces=getappdata(0,'figTraces');
if ~isempty(figTraces)
    delete(figTraces);
    setappdata(0,'figTraces',[]);
end
h0=getappdata(0,'figInfoPanel');
if ishandle(h0)
	delete(h0);
	setappdata(0,'figInfoPanel',[]);
end

% --- Executes on button press in checkbox_function_mergeState.
function checkbox_function_mergeState_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_mergeState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_mergeState
setappdata(0,'stateMergeTag',get(hObject,'Value'));


% --- Executes on button press in checkbox_function_emgAmp.
function checkbox_function_emgAmp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_emgAmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_emgAmp
setappdata(0,'emgAmpDispFlag',get(hObject,'Value'));


% --- Executes on button press in checkbox_function_autoSave.
function checkbox_function_autoSave_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_autoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_autoSave
setappdata(0,'autoSaveTag',get(hObject,'Value'));


function edit_par_binTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_binTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_binTime as text
%        str2double(get(hObject,'String')) returns contents of edit_par_binTime as a double
binTime=str2double(get(hObject,'String'));
setappdata(0,'binTime',binTime);
info=getappdata(0,'info');
info.binTime=binTime;
setappdata(0,'info',info);

% --- Executes during object creation, after setting all properties.
function edit_par_binTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_binTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_stepTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stepTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stepTime as text
%        str2double(get(hObject,'String')) returns contents of edit_stepTime as a double
stepTime=str2double(get(hObject,'String'));
setappdata(0,'stepTime',stepTime);
info=getappdata(0,'info');
info.stepTime=stepTime;
setappdata(0,'info',info);

% --- Executes during object creation, after setting all properties.
function edit_stepTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stepTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_mscore_mark.
function pushbutton_mscore_mark_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mscore_mark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figResult=getappdata(0,'figResult');
if ~isempty(figResult)
    %only change sleep states (not seizuers)
    state_Sleep=getappdata(0,'state_Sleep');
    set(0,'currentfigure',figResult);
    [x,y]=ginput(2);
    x1=max(min(x),1);
    x2=min(max(x),length(state_Sleep));
    y1=0;
    w=round(x2-x1);
    h=2;
    x1=round(x1);
    ROI=[x1,y1,w,h];
    mymap=[0.5,0.5,0.5;1,0.5,0;0.6,0.2,1;1,1,0;0,0,0];
    %mark the event in figResult
    mscoreSelect=getappdata(0,'mscoreSelect');
    if mscoreSelect>=0
        cl=mymap(mscoreSelect+1,:);
    else
        cl=mymap(5,:);
    end
    rectangle('position',ROI,'FaceColor',cl,'EdgeColor',cl);
    %update state based on scoring
    state_Sleep(x1:x1+w)=mscoreSelect;
    procWindow=getappdata(0,'procWindow');
    dur=getDur(state_Sleep,procWindow);
    fprintf('Wake/NREM/REM/unknown time(min): %5.2f %5.2f %5.2f %5.2f\n',dur);
    setappdata(0,'state_Sleep',state_Sleep);

    %state=getappdata(0,'state');
    state_Seizure=getappdata(0,'state_Seizure');
    state=state_Sleep;
    state(state_Seizure)=3;
    setappdata(0,'state',state);

    %update current segment
    segMergeFlag=getappdata(0,'segMergeFlag');
    allState=getappdata(0,'allState');
    if segMergeFlag
        sLen=length(state);
        allState(end-sLen+1:end)=state;
        setappdata(0,'allState',allState);
    else
        allState=state;
        setappdata(0,'allState',allState);
    end
end


function dur=getDur(state,procWindow)
%calculate time for each state
idx1=find(state==0);
idx2=find(state==1);
idx3=find(state==2);
idx4=find(state==-1);
seg=procWindow(2)-procWindow(1);
dur=[length(idx1),length(idx2),length(idx3),length(idx4)]*seg/length(state);


% --- Executes on button press in pushbutton_mscore_save.
function pushbutton_mscore_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_mscore_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%summarize the result for all segments 
PathName=getappdata(0,'PathName');
matFileName=getappdata(0,'FileName');
info=getappdata(0,'info');
info.PathName=PathName;
state=getappdata(0,'state');
state_Sleep=getappdata(0,'state_Sleep');
state_Seizure=getappdata(0,'state_Seizure');
allState=getappdata(0,'allState');
if isempty(allState)
    allState=state;
end
sleepData=profileSleep(allState,info);
%save data
specDat=getappdata(0,'specDat');
emgAmpDat=getappdata(0,'emgAmpDat');
phtDat=getappdata(0,'phtDat');
szEvents=getappdata(0,'szEvents');
tagname=getappdata(0,'photTag');
% save scoring data into mat-file 
if ~isempty(matFileName)
    % f0=[matFileName(1:end-4),'_m.mat'];
    % use date/time for modified filename
    nowstr=datestr(now,30);
    f0=[matFileName(1:end-4),'_',nowstr,'.mat'];
else
    eegCh=getappdata(0,'eegCh');
    f0=['eeg',num2str(eegCh),'_m',num2str(info.procWindow(1)),'-',num2str(info.procWindow(2)),'.mat'];
    if ~isempty(phtDat)
        f0=[f0(1:end-4),'_',tagname{1},'.mat'];
    end
end
filename=fullfile(info.PathName,f0);
%filename=f0;
save(filename,'info','specDat','emgAmpDat','state','state_Sleep','state_Seizure','sleepData','phtDat','szEvents');

fprintf('data saved in %s\n',filename);
% save summary into txt-file
%f1=['eeg',num2str(eegCh),'_sleep_summary.txt'];
%fname=fullfile(info.PathName,f1);
txtfname=[filename(1:end-4),'_sleep_summary.txt'];
saveSummary2txt(sleepData,info,txtfname);
% save figure 
autoSaveTag=getappdata(0,'autoSaveTag');
if autoSaveTag
%     eegCh=getappdata(0,'eegCh');
% 	fn=['eeg',num2str(eegCh),'_m',num2str(info.procWindow(1)),'-',num2str(info.procWindow(2)),'.png'];
% 	fname=fullfile(info.PathName,fn);
    figfname=[filename(1:end-4),'.png'];
    figResult=getappdata(0,'figResult');
    if ishandle(figResult)
        set(0,'currentfigure',figResult);
        F=getframe(gcf);
        imwrite(F.cdata,figfname);
    end
end


% --- Executes on button press in checkbox_function_mscore.
function checkbox_function_mscore_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_mscore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_mscore
pDat2=getappdata(0,'specDat');
mDat=getappdata(0,'emgAmpDat');
phtDat=getappdata(0,'phtDat');
state=getappdata(0,'state');
if get(hObject,'Value')
    set(handles.pushbutton_mscore_mark,'enable','on');
    %set(handles.pushbutton_mscore_save,'enable','on');
    %re-plot EEG spectrogram for sleep scoring if needed
    info=getappdata(0,'info');
    if info.binTime<5
        %h=fspecial('average');
        step=1+5/info.stepTime;
        h=ones(step,1)/step;
        pDat2.p=imfilter(pDat2.p,h);
        %plotData(pDat2,mDat,state,[],[]);
        plotData2(pDat2,mDat,phtDat,state,[],[]);
    end
else
    set(handles.pushbutton_mscore_mark,'enable','off');
    %set(handles.pushbutton_mscore_save,'enable','off');
    %plotData(pDat2,mDat,state,[],[]);
    plotData2(pDat2,mDat,phtDat,state,[],[]);
end


% --- Executes when selected object is changed in uibuttongroup_states.
function uibuttongroup_states_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_states 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(hObject,'Tag')
    case 'radiobutton_wake'
        val=0;
    case 'radiobutton_nrem'
        val=1;
    case 'radiobutton_rem'
        val=2;
    case 'radiobutton_unknown'
        val=-1;
    case 'radiobutton_stateX'
        val=3;
end
setappdata(0,'mscoreSelect',val);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
buffer_Idx=getappdata(0,'buffer_Idx');
if isstr(buffer_Idx)
    buffer=getappdata(0,buffer_Idx);
    if ~isempty(buffer)
        rmappdata(0,buffer_Idx);
        disp(['Buffer:', buffer_Idx, 'is cleared.'])
    end
    rmappdata(0,'buffer_Idx');
    clear('buffer');
end
delete(hObject);


% --- Executes on button press in checkbox_file_phot.
function checkbox_file_phot_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_file_phot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_file_phot
if get(hObject,'Value')
    setappdata(0,'photCh',1);   %0=no photometry data; 1=data
else
    setappdata(0,'photCh',0); 
end


% --- Executes on button press in checkbox_file_sti.
function checkbox_file_sti_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_file_sti (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_file_sti
if get(hObject,'Value')
    setappdata(0,'stiCh',1);   %0=no sti data; 1=data
else
    setappdata(0,'stiCh',0); 
end


% --- Executes on button press in checkbox_function_cnn.
function checkbox_function_cnn_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_cnn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_cnn
if get(hObject,'Value')
    setappdata(0,'cnnFlag',1);   
    %select trainedNet
    [file,path] = uigetfile('*.mat');
    if isequal(file,0)
        disp('please select a trainedNet file!');
    else
        filename=fullfile(path,file);
        setappdata(0,'trainedNet_File',filename);
        set(handles.text_function_trainedNet,'String',file);
    end
else
    setappdata(0,'cnnFlag',0); 
end


function edit_par_specClim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_specClim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_specClim as text
%        str2double(get(hObject,'String')) returns contents of edit_par_specClim as a double
clm=str2double(get(hObject,'String'));
if clm<=0
    disp('CLim cannot be set below 0');
    return;
end
figResult=getappdata(0,'figResult');
if ~isempty(figResult)
    if ishandle(figResult)
        set(0,'currentfigure',figResult);
        h_axes=findobj(figResult,'type','axes');
        set(h_axes(end-1),'clim',[0,clm]);
    end
end
setappdata(0,'specClim',clm);

% --- Executes during object creation, after setting all properties.
function edit_par_specClim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_specClim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_par_emgYlim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_emgYlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_emgYlim as text
%        str2double(get(hObject,'String')) returns contents of edit_par_emgYlim as a double
ylm=str2double(get(hObject,'String'));
if ylm<=0
    disp('CLim cannot be set below 0');
    return;
end
figResult=getappdata(0,'figResult');
if ~isempty(figResult)
    if ishandle(figResult)
        set(0,'currentfigure',figResult);
        h_axes=findobj(figResult,'type','axes');
        set(h_axes(1),'ylim',[0,ylm]);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_par_emgYlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_emgYlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_file_runEEG.
function pushbutton_file_runEEG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_runEEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName = getappdata(0,'PathName');
eegCh=getappdata(0,'eegCh');
autoSaveTag=getappdata(0,'autoSaveTag');
tdtRunEEG(PathName,eegCh,[],autoSaveTag);


% --- Executes on button press in pushbutton_file_matFile.
function pushbutton_file_matFile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_file_matFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PathName=getappdata(0,'PathName');
if ~isempty(PathName)
    f0=fullfile(PathName,'*.mat');
else
    f0='*.mat';
end
[FileName,PathName] = uigetfile(f0,'Select a matlab file');
fname=fullfile(PathName,FileName);
if FileName==0
    disp('No file seleted!');
    return;
else
    load(fname,'specDat','emgAmpDat','info','state',...
        'state_Sleep','state_Seizure','phtDat','szEvents','sleepData');

    if ~exist('state_Sleep','var')
        state_Sleep=state;
    end
    if ~exist('state_Seizure','var')
        state_Seizure=(state==3);
    end
    if ~exist('szEvents','var')
        szEvents=[];
    end
    if ~exist('phtDat','var')
        phtDat=[];
    end
    if ~exist('sleepData','var')
        sleepData=profileSleep(state,info);
    end

    setappdata(0,'specDat',specDat);
    setappdata(0,'emgAmpDat',emgAmpDat);
    setappdata(0,'info',info);
    setappdata(0,'state',state);
    setappdata(0,'state_Sleep',state_Sleep);
    setappdata(0,'state_Seizure',state_Seizure);
    setappdata(0,'phtDat',phtDat);
    setappdata(0,'szEvents',szEvents);
    setappdata(0,'sleepData',sleepData);
    setappdata(0,'PathName',PathName);
    setappdata(0,'FileName',FileName);
    set(handles.text_file_folderName,'String',fname);
    %procWindow2=[round(emgAmpDat.fEMG(1,1)/60),round(emgAmpDat.fEMG(1,end)/60)];
    procWindow2=info.procWindow;
    setappdata(0,'procWindow',procWindow2);   
    setappdata(0,'figWindow',procWindow2);
    set(handles.edit_par_startTime,'String',procWindow2(1));
    set(handles.edit_par_endTime,'String',procWindow2(2));
    set(handles.edit_par_timescale1,'String',procWindow2(1));
    set(handles.edit_par_timescale2,'String',procWindow2(2));
    
    %show result
    if isfield(info,'stiTm')
        st1=info.stiTm;
    elseif isfield(info,'laserEvent')
        st1=[info.laserEvent.onset,info.laserEvent.onset+30];
    else
        st1=[];
    end

    dur=getDur(state,info.procWindow);
    fprintf('Wake/NREM/REM/unknown time(min): %5.1f %5.1f %5.1f %5.1f\n',dur);
    %plot data
    emgAmpDispFlag=getappdata(0,'emgAmpDispFlag');
    %reset the stimili-time for current process window
    if emgAmpDispFlag
        plotData2(specDat,emgAmpDat,phtDat,state,st1,[]);
    else
        %use the following to see EEG and EMG traces (seizures)
        %filter EMG if needed
%         emgbands=[30,200];
%         d=fdesign.bandpass('N,F3dB1,F3dB2',10,emgbands(1),emgbands(2),info.samplingRate);
%         hd=design(d,'butter');
%         emgAmpDat.fEMG(2,:)=filter(hd,emgAmpDat.fEMG(2,:));
        plotData2b(specDat,emgAmpDat,phtDat,state,st1,[]);
        %another version of plot, state/spectrogram/EMG/phot with
        %downsampled EMG trace
        %plotData2s(specDat,emgAmpDat,phtDat,state,st1,[]);
    end

end



function edit_par_timescale1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_timescale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_timescale1 as text
%        str2double(get(hObject,'String')) returns contents of edit_par_timescale1 as a double
tm0=getappdata(0,'figWindow');
tm0(1)=str2double(get(hObject,'String'));
setappdata(0,'figWindow',tm0);
rescaleFigTime(tm0);


% --- Executes during object creation, after setting all properties.
function edit_par_timescale1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_timescale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_par_timescale2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_par_timescale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_par_timescale2 as text
%        str2double(get(hObject,'String')) returns contents of edit_par_timescale2 as a double
tm0=getappdata(0,'figWindow');
tm0(2)=str2double(get(hObject,'String'));
setappdata(0,'figWindow',tm0);
rescaleFigTime(tm0);

% --- Executes during object creation, after setting all properties.
function edit_par_timescale2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_par_timescale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_fig_reset.
function pushbutton_fig_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fig_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tm0=getappdata(0,'procWindow');   
setappdata(0,'figWindow',tm0);
rescaleFigTime(tm0);
set(handles.edit_par_timescale1,'String',tm0(1));
set(handles.edit_par_timescale2,'String',tm0(2));

% --- Executes on button press in pushbutton_fig_nextSegment.
function pushbutton_fig_nextSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fig_nextSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tm0=getappdata(0,'figWindow');
d=tm0(2)-tm0(1);
procWindow=getappdata(0,'procWindow');  
if tm0(2)+d<=procWindow(2)
    tm0=tm0+d;
    setappdata(0,'figWindow',tm0);
    rescaleFigTime(tm0);
    set(handles.edit_par_timescale1,'String',tm0(1));
    set(handles.edit_par_timescale2,'String',tm0(2));
end

% --- Executes on button press in pushbutton_fig_preSegment.
function pushbutton_fig_preSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fig_preSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tm0=getappdata(0,'figWindow');
d=tm0(2)-tm0(1);
procWindow=getappdata(0,'procWindow');  
if tm0(1)-d>=procWindow(1)
    tm0=tm0-d;
    setappdata(0,'figWindow',tm0);
    rescaleFigTime(tm0);
    set(handles.edit_par_timescale1,'String',tm0(1));
    set(handles.edit_par_timescale2,'String',tm0(2));
end

% function rescaleFigTime(xlm)
% figResult=getappdata(0,'figResult');
% procWindow=getappdata(0,'procWindow');  
% state=getappdata(0,'state');
% if ~isempty(figResult)
%     if ishandle(figResult)
%         set(0,'currentfigure',figResult);
%         h_axes=findobj(figResult,'type','axes');
%         for i=1:length(h_axes)
%             if i>=length(h_axes)-1
%                 xlm2=0.5+(xlm-procWindow(1))*length(state)/(procWindow(2)-procWindow(1));
%                 set(h_axes(i),'xlim',xlm2);
%             else
%                 set(h_axes(i),'xlim',xlm);
%             end
%         end
%     end
% end



function edit_photBinTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_photBinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_photBinTime as text
%        str2double(get(hObject,'String')) returns contents of edit_photBinTime as a double
photBinTime=str2double(get(hObject,'String'));
setappdata(0,'photBinTime',photBinTime);
info=getappdata(0,'info');
info.photBinTime=photBinTime;
setappdata(0,'info',info);

% --- Executes during object creation, after setting all properties.
function edit_photBinTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_photBinTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filter_eeg1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filter_eeg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filter_eeg1 as text
%        str2double(get(hObject,'String')) returns contents of edit_filter_eeg1 as a double
filterEEG=getappdata(0,'filterEEG');
filterEEG(1)=str2double(get(hObject,'String'));
setappdata(0,'filterEEG',filterEEG);

% --- Executes during object creation, after setting all properties.
function edit_filter_eeg1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filter_eeg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filter_eeg2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filter_eeg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filter_eeg2 as text
%        str2double(get(hObject,'String')) returns contents of edit_filter_eeg2 as a double
filterEEG=getappdata(0,'filterEEG');
filterEEG(2)=str2double(get(hObject,'String'));
setappdata(0,'filterEEG',filterEEG);

% --- Executes during object creation, after setting all properties.
function edit_filter_eeg2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filter_eeg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filter_emg1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filter_emg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filter_emg1 as text
%        str2double(get(hObject,'String')) returns contents of edit_filter_emg1 as a double
filterEMG=getappdata(0,'filterEMG');
filterEMG(1)=str2double(get(hObject,'String'));
setappdata(0,'filterEMG',filterEMG);

% --- Executes during object creation, after setting all properties.
function edit_filter_emg1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filter_emg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filter_emg2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filter_emg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filter_emg2 as text
%        str2double(get(hObject,'String')) returns contents of edit_filter_emg2 as a double
filterEMG=getappdata(0,'filterEMG');
filterEMG(2)=str2double(get(hObject,'String'));
setappdata(0,'filterEMG',filterEMG);

% --- Executes during object creation, after setting all properties.
function edit_filter_emg2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filter_emg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_filter_notch.
function checkbox_filter_notch_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_filter_notch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_filter_notch
filterNotch=get(hObject,'Value');
setappdata(0,'filterNotch',filterNotch);

% --- Executes on button press in checkbox_function_seizure.
function checkbox_function_seizure_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_seizure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_seizure
seizureTag=get(hObject,'Value');
setappdata(0,'seizureTag',seizureTag);
specDat=getappdata(0,'specDat');
if ~isempty(specDat) && seizureTag
    seizureSTD=getappdata(0,'seizureSTD');
    [state_Seizure,szEvents]=getSeizure(specDat,seizureSTD);
    %state=getappdata(0,'state');
    state_Sleep=getappdata(0,'state_Sleep');
    state=state_Sleep;
    state(state_Seizure)=3;
    setappdata(0,'state',state);
    setappdata(0,'state_Seizure',state_Seizure);
    setappdata(0,'szEvents',szEvents);
    snum=size(szEvents,1);
    fprintf('Detect %d seizure events\n',snum);
    if snum>0
        ShowSeizureTraces(szEvents,specDat);
        ShowSeizureSpectrum(state,specDat);
    end
end


function edit_function_seizureSTD_Callback(hObject, eventdata, handles)
% hObject    handle to edit_function_seizureSTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_function_seizureSTD as text
%        str2double(get(hObject,'String')) returns contents of edit_function_seizureSTD as a double
setappdata(0,'seizureSTD',str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_function_seizureSTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_function_seizureSTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_function_parforTag.
function checkbox_function_parforTag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_function_parforTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_function_parforTag
val=get(hObject,'Value');
setappdata(0,'parforTag',val);
if val
    %starting parallel pool
    poolobj=gcp('nocreate');
    if isempty(poolobj)
        parpool('local','IdleTimeout', 120);
    end
end


% --- Executes on button press in checkbox_file_M2.
function checkbox_file_M2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_file_M2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_file_M2
eegCh=getappdata(0,'eegCh');
emgCh=getappdata(0,'emgCh');
if get(hObject,'Value')
    setappdata(0,'eegCh',eegCh+4);
    setappdata(0,'emgCh',emgCh+4);
    setappdata(0,'M2_flag',1);
else
    setappdata(0,'eegCh',eegCh-4);
    setappdata(0,'emgCh',4);
    setappdata(0,'M2_flag',0);
end


% --- Executes on button press in pushbutton_infoPanel.
function pushbutton_infoPanel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_infoPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h0=infoPanel();
setappdata(0,'figInfoPanel',h0);


% --- Executes when selected object is changed in uibuttongroup_photTag.
function uibuttongroup_photTag_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_photTag 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
photTagEnd=get(handles.edit_PhotTagEnd,'String');
switch get(hObject,'Tag')
    case 'radiobutton_465'
        tagname={strcat('465',photTagEnd),strcat('405',photTagEnd)};
    case 'radiobutton_560'
        tagname={strcat('560',photTagEnd),strcat('405',photTagEnd)};
end
setappdata(0,'photTag',tagname);



function edit_PhotTagEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PhotTagEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PhotTagEnd as text
%        str2double(get(hObject,'String')) returns contents of edit_PhotTagEnd as a double
tagname=getappdata(0,'photTag');
val=get(hObject,'String');
tagname2={strcat(tagname{1}(1:3),val),strcat('405',val)};
setappdata(0,'photTag',tagname2);

% --- Executes during object creation, after setting all properties.
function edit_PhotTagEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PhotTagEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
