function varargout = modelgui_panel(varargin)
% MODELGUI_PANEL M-file for modelgui_panel.fig
%      MODELGUI_PANEL, by itself, creates a new MODELGUI_PANEL or raises the existing
%      singleton*.
%
%      H = MODELGUI_PANEL returns the handle to a new MODELGUI_PANEL or the handle to
%      the existing singleton*.
%
%      MODELGUI_PANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODELGUI_PANEL.M with the given input arguments.
%
%      MODELGUI_PANEL('Property','Value',...) creates a new MODELGUI_PANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before modelgui_panel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to modelgui_panel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help modelgui_panel

% Last Modified by GUIDE v2.5 12-Sep-2011 20:22:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @modelgui_panel_OpeningFcn, ...
                   'gui_OutputFcn',  @modelgui_panel_OutputFcn, ...
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

% --- Executes just before modelgui_panel is made visible.
function modelgui_panel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to modelgui_panel (see VARARGIN)

% Choose default command line output for modelgui_panel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% This sets up the initial plot - only do when we are invisible
% so window can get raised using modelgui_panel.
if strcmp(get(hObject,'Visible'),'off')
       plot(rand(5));
end

% UIWAIT makes modelgui_panel wait for user response (see UIRESUME)
% uiwait(handles.signalsModel);


% --- Outputs from this function are returned to the command line.
function varargout = modelgui_panel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on slider movement.
function muTargetSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to muTargetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_muTarget'',get(hObject,''Value''))'])

% --- Executes on slider movement.
function varTargetSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to varTargetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_varTarget'',get(hObject,''Value''))'])




% --- Executes on slider movement.
function muFoilSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to muFoilSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_muFoil'',get(hObject,''Value''))'])

% --- Executes on slider movement.
function varFoilSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to varFoilSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_varFoil'',get(hObject,''Value''))'])




% --- Executes on slider movement.
function baserateSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to baserateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_baserate'',get(hObject,''Value''))'])



% --- Executes on slider movement.
function hSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to hSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_h'',get(hObject,''Value''))'])

% --- Executes on slider movement.
function mSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to mSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_m'',get(hObject,''Value''))'])

% --- Executes on slider movement.
function aSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to aSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_a'',get(hObject,''Value''))'])

% --- Executes on slider movement.
function jSlider_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to jSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
eval([callback_modelgui '(''set_j'',get(hObject,''Value''))'])





function muTargetEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to muTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of muTargetEdit as a double


% --- Executes during object creation, after setting all properties.
function muTargetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function varTargetEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to varTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varTargetEdit as text
%        str2double(get(hObject,'String')) returns contents of varTargetEdit as a double


% --- Executes during object creation, after setting all properties.
function varTargetEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varTargetEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function muFoilEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to muFoilEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of muFoilEdit as text
%        str2double(get(hObject,'String')) returns contents of muFoilEdit as a double


% --- Executes during object creation, after setting all properties.
function muFoilEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muFoilEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function varFoilEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to varFoilEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of varFoilEdit as text
%        str2double(get(hObject,'String')) returns contents of varFoilEdit as a double


% --- Executes during object creation, after setting all properties.
function varFoilEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varFoilEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to hEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hEdit as text
%        str2double(get(hObject,'String')) returns contents of hEdit as a double


% --- Executes during object creation, after setting all properties.
function hEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to mEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mEdit as text
%        str2double(get(hObject,'String')) returns contents of mEdit as a double


% --- Executes during object creation, after setting all properties.
function mEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function aEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to aEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of aEdit as text
%        str2double(get(hObject,'String')) returns contents of aEdit as a double


% --- Executes during object creation, after setting all properties.
function aEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to jEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jEdit as text
%        str2double(get(hObject,'String')) returns contents of jEdit as a double


% --- Executes during object creation, after setting all properties.
function jEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baserateEdit_Callback(hObject, eventdata, handles)
global callback_modelgui
% hObject    handle to baserateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baserateEdit as text
%        str2double(get(hObject,'String')) returns contents of baserateEdit as a double


% --- Executes during object creation, after setting all properties.
function baserateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baserateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









% --- Executes during object creation, after setting all properties.
function muTargetSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muTargetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function varTargetSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varTargetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function muFoilSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to muFoilSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function varFoilSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varFoilSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function baserateSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baserateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function hSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function mSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes during object creation, after setting all properties.
function aSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function jSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object deletion, before destroying properties.
% function utilityAxis_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to utilityAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
