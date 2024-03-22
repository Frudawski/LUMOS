function varargout = LUMOS_options(varargin)
% LUMOS_OPTIONS MATLAB code for LUMOS_options.fig
%      LUMOS_OPTIONS, by itself, creates a new LUMOS_OPTIONS or raises the existing
%      singleton*.
%
%      H = LUMOS_OPTIONS returns the handle to a new LUMOS_OPTIONS or the handle to
%      the existing singleton*.
%
%      LUMOS_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUMOS_OPTIONS.M with the given input arguments.
%
%      LUMOS_OPTIONS('Property','Value',...) creates a new LUMOS_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LUMOS_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LUMOS_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LUMOS_options

% Last Modified by GUIDE v2.5 16-Mar-2024 09:06:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LUMOS_options_OpeningFcn, ...
                   'gui_OutputFcn',  @LUMOS_options_OutputFcn, ...
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


% --- Executes just before LUMOS_options is made visible.
function LUMOS_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LUMOS_options (see VARARGIN)

% Choose default command line output for LUMOS_options
handles.output = hObject;

try
    % get LUMOS handle
    handles.Lumos = findall(0,'tag','SpecSimulation');
catch me
    catcher(me)
end

try
    settings  = getappdata(handles.Lumos,'settings');
    % objects checkbox
    hObject.Children.Children(2).Value = settings.objects;
    % mesh optimization
    hObject.Children.Children(7).Value = settings.mesh;
    % luminaire consideration
    hObject.Children.Children(6).Value = settings.luminaires;
    % subgrid max number per dimension
    hObject.Children.Children(3).String = num2str(settings.subgrid);
    % object reflecion consideration
    hObject.Children.Children(1).Value = settings.object_reflection;
catch

end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LUMOS_options wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LUMOS_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_mesh.
function checkbox_mesh_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mesh


% --- Executes on button press in checkbox_luminaires.
function checkbox_luminaires_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_luminaires (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_luminaires


% --- Executes on button press in Apply_button.
function Apply_button_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get settings
settings.objects = hObject.Parent.Children(2).Value;
settings.mesh = hObject.Parent.Children(7).Value;
settings.luminaires = hObject.Parent.Children(6).Value;
settings.subgrid = str2double(hObject.Parent.Children(3).String);
settings.object_reflection = hObject.Parent.Children(1).Value;

% save settings
setappdata(handles.Lumos,'settings',settings);

% close window
close(hObject.Parent.Parent)


% --- Executes on button press in Discard_button.
function Discard_button_Callback(hObject, eventdata, handles)
% hObject    handle to Discard_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% close window without saving
close(hObject.Parent.Parent)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_objects.
function checkbox_objects_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_objects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_objects


% --- Executes on button press in object_reflection.
function object_reflection_Callback(hObject, eventdata, handles)
% hObject    handle to object_reflection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of object_reflection


function checkbox_objects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to object_reflection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of object_reflection
