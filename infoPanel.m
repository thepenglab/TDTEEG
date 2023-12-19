function varargout = infoPanel(varargin)
% INFOPANEL MATLAB code for infoPanel.fig
%      INFOPANEL, by itself, creates a new INFOPANEL or raises the existing
%      singleton*.
%
%      H = INFOPANEL returns the handle to a new INFOPANEL or the handle to
%      the existing singleton*.
%
%      INFOPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INFOPANEL.M with the given input arguments.
%
%      INFOPANEL('Property','Value',...) creates a new INFOPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before infoPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to infoPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help infoPanel

% Last Modified by GUIDE v2.5 15-Jul-2020 11:10:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @infoPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @infoPanel_OutputFcn, ...
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


% --- Executes just before infoPanel is made visible.
function infoPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to infoPanel (see VARARGIN)

% Choose default command line output for infoPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes infoPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = infoPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_header.
function listbox_header_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_header (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_header contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_header


% --- Executes during object creation, after setting all properties.
function listbox_header_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_header (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
info=getappdata(0,'info');
if isstruct(info.FileInfo)
    str=struct2cell(info.FileInfo);
    fields=fieldnames(info.FileInfo);
    str=[fields,str];
    %str=namedargs2cell(info.FileInfo);      %need matlab2019b and later
else
    str=info.FileInfo;
end
set(hObject,'String',str);


function edit_totalDuration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_totalDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_totalDuration as text
%        str2double(get(hObject,'String')) returns contents of edit_totalDuration as a double


% --- Executes during object creation, after setting all properties.
function edit_totalDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_totalDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
info=getappdata(0,'info');
set(hObject,'String',info.totalMin);


function edit_samplingRate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_samplingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_samplingRate as text
%        str2double(get(hObject,'String')) returns contents of edit_samplingRate as a double


% --- Executes during object creation, after setting all properties.
function edit_samplingRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_samplingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
info=getappdata(0,'info');
set(hObject,'String',info.samplingRate);


function edit_amplifier_Callback(hObject, eventdata, handles)
% hObject    handle to edit_amplifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_amplifier as text
%        str2double(get(hObject,'String')) returns contents of edit_amplifier as a double


% --- Executes during object creation, after setting all properties.
function edit_amplifier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_amplifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
info=getappdata(0,'info');
set(hObject,'String',info.amplifier);

% --- Executes during object creation, after setting all properties.
function uitable_events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
info=getappdata(0,'info');
set(hObject,'Data',info.eventStr);
