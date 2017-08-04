function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to Run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 08-Sep-2010 16:04:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
initialize_gui(hObject, handles);
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1}=handles.value.output;
varargout{2}=handles.value.beta;
varargout{3}=handles.value.patchradius;
varargout{4}=handles.value.searchradius;
varargout{5}=handles.value.suffixstring;
varargout{6}=handles.value.background;
delete(hObject)

% --- Executes on button press in background.
function background_Callback(hObject, eventdata, handles)
% hObject    handle to background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
if (get(hObject,'Value') == get(hObject,'Max'))
   % Checkbox is checked-take approriate action
   background = 1;
else
   % Checkbox is not checked-take approriate action
   background = 0;
end
handles.value.background = background;
guidata(hObject,handles)


function beta_Callback(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta as text
%        str2double(get(hObject,'String')) returns contents of beta as a
%        double
beta = str2double(get(hObject, 'String'));
if isnan(beta) | (beta < 0)
    set(hObject, 'String',0.1);
    errordlg('Input must be a positive number','Error');
end
handles.value.beta = beta;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function patchradius_Callback(hObject, eventdata, handles)
% hObject    handle to patchradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of patchradius as text
%        str2double(get(hObject,'String')) returns contents of patchradius as a
%        double
patchradius = str2double(get(hObject, 'String'));
if isnan(patchradius) | (patchradius < 0)
    set(hObject, 'String', 2);
    errordlg('Input must be a positive interger','Error');
end
handles.value.patchradius = floor(patchradius);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function patchradius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function searchradius_Callback(hObject, eventdata, handles)
% hObject    handle to searchradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of searchradius as text
%        str2double(get(hObject,'String')) returns contents of searchradius as a
%        double
searchradius = str2double(get(hObject, 'String'));
if isnan(searchradius) | (searchradius < 0)
    set(hObject, 'String', 3);
    errordlg('Input must be a positive interger','Error');
end
handles.value.searchradius = floor(searchradius);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function searchradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to searchradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.value.output=1;
guidata(hObject, handles);
uiresume(handles.figure1) 


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.value.output=0;
guidata(hObject, handles);
uiresume(handles.figure1) 


function suffixstring_Callback(hObject, eventdata, handles)
% hObject    handle to suffixstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of  suffixstring as text
%        str2double(get(hObject,'String')) returns contents of  suffixstring as a
%        double
suffixstring = get(hObject, 'String');
if isnan(suffixstring)
    set(hObject, 'String', '_denoised');
    errordlg('Input must be a string','Error');
end
handles.value.suffixstring = suffixstring;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function suffixstring_CreateFcn(hObject, eventdata, handles)
% hObject    handle to suffixstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initialize_gui(fig_handle, handles)

handles.value.beta = 0.1;
handles.value.patchradius = 2;
handles.value.searchradius = 3;
handles.value.suffixstring ='_denoised';
handles.value.background = 1.0;

set(handles.beta, 'String', handles.value.beta);
set(handles.patchradius,  'String', handles.value.patchradius);
set(handles.searchradius, 'String', handles.value.searchradius);
set(handles.suffixstring, 'String', handles.value.suffixstring);
set(handles.background, 'Value', handles.value.background);

guidata(handles.figure1, handles);
