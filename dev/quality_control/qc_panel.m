function varargout = qc_panel(varargin)
% QC_PANEL M-file for qc_panel.fig
%      QC_PANEL, by itself, creates a new QC_PANEL or raises the existing
%      singleton*.
%
%      H = QC_PANEL returns the handle to a new QC_PANEL or the handle to
%      the existing singleton*.
%
%      QC_PANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QC_PANEL.M with the given input arguments.
%
%      QC_PANEL('Property','Value',...) creates a new QC_PANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qc_panel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qc_panel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qc_panel

% Last Modified by GUIDE v2.5 28-Sep-2009 21:32:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qc_panel_OpeningFcn, ...
                   'gui_OutputFcn',  @qc_panel_OutputFcn, ...
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


% --- Executes just before qc_panel is made visible.
function qc_panel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qc_panel (see VARARGIN)

% Choose default command line output for qc_panel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes qc_panel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = qc_panel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in file_listbox.
function file_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns file_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_listbox

% If double click
global callbackqc qcPanelHandles files sorted_names sorted_index
if strcmp(get(qcPanelHandles.figure1,'SelectionType'),'open')
    index_selected = get(qcPanelHandles.file_listbox,'Value');
    file_list = get(qcPanelHandles.file_listbox,'String');
    selection = file_list{index_selected};
    isdir_list={files.isdir};
    
    if  isdir_list{index_selected}==1 %selection is a folder
        cd (selection)
        files=dir;
        [sorted_names,sorted_index] = sortrows({files.name}');
        set(handles.file_listbox,'String',sorted_names)
        set(handles.file_listbox,'Value',1)
    else %selection is file
        eval([callbackqc '(''open'',selection)'])
    end
end

% --- Executes during object creation, after setting all properties.
function file_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global files sorted_names sorted_index
[sorted_names,sorted_index] = sortrows({files.name}');
set(hObject,'String',sorted_names)


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in conditions_pop.
function conditions_pop_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to conditions_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns conditions_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from conditions_pop
contents = get(hObject,'String');
selection=contents{get(hObject,'Value')};
pat = '\s+';
conditions=regexp(selection, pat, 'split');
eval([callbackqc '(''set_conditions'',conditions{1},conditions{3})'])




% --- Executes during object creation, after setting all properties.
function conditions_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to conditions_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rt_btn.
function rt_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to rt_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''rt'')'])



function minrt_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to minrt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minrt as text
%        str2double(get(hObject,'String')) returns contents of minrt as a double
eval([callbackqc '(''set_minrt'',str2double(get(hObject,''String'')))'])


% --- Executes during object creation, after setting all properties.
function minrt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minrt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxrt_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to maxrt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxrt as text
%        str2double(get(hObject,'String')) returns contents of maxrt as a double
eval([callbackqc '(''set_maxrt'',str2double(get(hObject,''String'')))'])

% --- Executes during object creation, after setting all properties.
function maxrt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxrt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in trimtrials_btn.
function trimtrials_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to trimtrials_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''trimtrials'')'])



function starttr_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to starttr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of starttr as text
%        str2double(get(hObject,'String')) returns contents of starttr as a double
eval([callbackqc '(''set_start'',str2double(get(hObject,''String'')))'])


% --- Executes during object creation, after setting all properties.
function starttr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in presses_btn.
function presses_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to presses_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''presses'')'])

% --- Executes on button press in threshold_btn.
function threshold_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to threshold_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''threshold'')'])

% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to refresh_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''refresh'')'])


% --- Executes on button press in write_btn.
function write_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to write_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''write'')'])


% --- Executes on button press in help_btn.
function help_btn_Callback(hObject, eventdata, handles)
global callbackqc
% hObject    handle to help_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval([callbackqc '(''help'')'])