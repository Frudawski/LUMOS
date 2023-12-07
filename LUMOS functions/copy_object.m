function varargout = copy_object(varargin)
% COPY_OBJECT MATLAB code for copy_object.fig
%      COPY_OBJECT, by itself, creates a new COPY_OBJECT or raises the existing
%      singleton*.
%
%      H = COPY_OBJECT returns the handle to a new COPY_OBJECT or the handle to
%      the existing singleton*.
%
%      COPY_OBJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COPY_OBJECT.M with the given input arguments.
%
%      COPY_OBJECT('Property','Value',...) creates a new COPY_OBJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before copy_object_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to copy_object_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help copy_object

% Last Modified by GUIDE v2.5 15-Apr-2020 14:04:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @copy_object_OpeningFcn, ...
                   'gui_OutputFcn',  @copy_object_OutputFcn, ...
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


% --- Executes just before copy_object is made visible.
function copy_object_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to copy_object (see VARARGIN)

% Choose default command line output for copy_object
handles.output = hObject;


% colors
handles.darkblue   = [     0    0.2267    0.4461];
handles.blue       = [     0    0.5267    0.6461];
handles.violet     = [0.6354         0    0.6957];
handles.red        = [1.0000         0    0.2585];
handles.orange     = [0.8594    0.5153         0];
handles.green      = [0.6354    0.7859    0.5085];
guidata(hObject,handles)

try
    % get LUMOS handle
    handles.Lumos = findall(0,'tag','SpecSimulation');
    % get object input
    try
        handles.objects = varargin{1};
    catch
        handles.objects = [];
    end
    % get room nr input
    try
        handles.room_nr = varargin{2};
    catch
        handles.room_nr = 1;
    end
    % get object nr input
    try
        handles.object_nr = varargin{3};
    catch
        handles.object_nr = 1;
    end
    try
        handles.mode = varargin{4};
    catch
        handles.mode = 'object';
    end
    % draw selected object
    plot_object(handles.objects,handles)
catch me
    catcher(me)
end
% get room data
%room = getappdata(handles.Lumos,'room');
% get room list
rlist = get_room_list(handles.Lumos);
% set room popupmenu
handles.menu_room.String = rlist;
handles.menu_room.Value = handles.room_nr;
% object list
guidata(hObject,handles)
list = object_list(handles);
% set object name list
handles.list_objects.String = list;
% set list item to number 1
handles.list_objects.Value = handles.object_nr;
% plot room
%refresh_3DObjects(hObject, eventdata, handles, handles.object_nr)
% set menu fields
handles.edit_object_name.String = handles.objects.name;
c = handles.objects.coordinates;
handles.edit_origin_x.String = num2str(c(1));
handles.edit_origin_y.String = num2str(c(2));
handles.edit_origin_z.String = num2str(c(3));
g = handles.objects.geometry{1};
handles.edit_dim_x.String = num2str(max(g(:,1)));
handles.edit_dim_y.String = num2str(max(g(:,2)));
handles.edit_dim_z.String = num2str(max(g(:,4)));

% set mouse drag option to ratate
rotate3d on

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes copy_object wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = copy_object_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function L = get_room_list(Lumos)
% get room data
room = getappdata(Lumos,'room');
L = [];
for n = 1:numel(room)
   L = [L;room{n}.name];
end




function [list,idx] = object_list(handles)
list = [];
room = getappdata(handles.Lumos,'room');
switch handles.mode
    case 'object'
        obj = room{handles.room_nr}.objects;
    case 'luminaire'
        obj = room{handles.room_nr}.luminaire;
end
for n = 1:length(obj)
    list = [list; {obj{n}.name}];
end
idx = 1:length(obj);





function [data,objs,ind,before] = get_object_data(obj,nr,data,objs,ind,before,c)
if ~exist('ind','var')
    ind = 0;
end
if ~exist('data','var')
    data = [];
end
if ~exist('objs','var')
    objs = [];
end
if ~exist('before','var')
    before = 0;
end
if ~exist('c','var')
    c = [0 0 0];
end
% recursive function call
if strcmp(obj.type,'group')
    % group
    for n = 1:numel(obj.objects)
        c = obj.coordinates;
        [data,objs,ind,before] = get_object_data(obj.objects{n},nr,data,objs,ind,before,c);
    end
else
    if nr > ind
        before = ind;
        % object coordinates and rotation
        data(:,1:3) = obj.coordinates+c;
        data(:,4:6) = obj.rotation;
        % object point selected
        objs = obj;
    end
    ind = ind + size(obj.geometry{1},1);
end




function o = make_copies(objs, handles)
% number of copies
n = str2double(handles.edit_nr_copies.String)+1;
% which object is selected?
nr = handles.list_objects.Value;
% get object data
try
    c = objs.coordinates;
catch
    c = objs{nr}.coordinates;
end
% offset
offx = str2double(handles.edit_x_offset.String);
offy = str2double(handles.edit_y_offset.String);
offz = str2double(handles.edit_z_offset.String);
% rotation
rx = str2double(handles.edit_rot_x.String);
ry = str2double(handles.edit_rot_y.String);
rz = str2double(handles.edit_rot_z.String);
r = [rx ry rz];
% make n copies
o = cell(1,n);
try
    o(1) = objs;
catch
    o{1} = objs;
end
str = handles.edit_object_name.String;
if ~isempty(handles.edit_suffix.String)
    if strcmp(handles.edit_suffix.String,'1')
        name = [str,' 1'];
    else
        name = [str,' ',handles.edit_suffix.String];
    end
else
    name = str;
end
try
    o{1}.name = name;
catch
    o.name = name;
end
mode = 'self';
% TODO: switch self rotation / rotation to origin point
switch mode
    case 'self'
        for k = 2:n
            try
                o(k) = objs;
            catch
                o{k} = objs;
            end
            c = c + [offx offy offz];
            o{k}.coordinates = c;
            o{k}.rotation = o{k}.rotation+r;
            r = r + [rx ry rz];
            if ~isempty(handles.edit_suffix.String)
                if strcmp(handles.edit_suffix.String,'1')
                    name = [str,' ',num2str(k)];
                else
                    name = [str,' ',handles.edit_suffix.String];
                end
            end
            o{k}.name = name;
        end
    case 'origin'
        for k = 2:n
            o{k} = objs;
            M = rotate_object(objs,c,r);
            o{k}.coordinates = c*M;
            c = c + [offx offy offz];
            o{k}.rotation = [0 0 0];%o{k}.rotation+r;
            r = r + [rx ry rz];
            
        end
end





function rotate_object_coordinates(obj,c,rot,origin)
if ~exist('rot','var')
    rot = eye(3);
end
if ~exist('origin','var')
    origin = obj.coordinates;
end
try
    co = obj.coordinates+c-origin;
catch
    co = [0 0 0];
end
g = obj.geometry{1};
g = [g;g(1,:)];

% rotation matrix
M = deg2rad(obj.rotation);
T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
T = T(1:3,1:3);
g1 = g(:,1:3)*T(1:3,1:3);
g2 = g(:,[1 2 4])*T(1:3,1:3);

% shift coordinates according to origin matrix
%rows = [co co(3)];
%S = repmat(c,size(g,1),1);
S = repmat(co,size(g,1),1);
g1 = g1+S;
g2 = g2+S;

g1 = g1*rot;
g2 = g2*rot;

g = [g1 g2(:,end)];

C = origin;
%plot3(g1(:,1)+C(1),g1(:,2)+C(2),g1(:,3)+C(3),'Color',clr)
%plot3(g2(:,1)+C(1),g2(:,2)+C(2),g2(:,3)+C(3),'Color',clr)
%for line = 1:size(g,1)
%    plot3([g1(line,1);g2(line,1)]+C(1),...
%        [g1(line,2);g2(line,2)]+C(2),...
%        [g1(line,3);g2(line,3)]+C(3),'Color',clr)
%end
%view([315 30])
%axis equal



function plot_object(objs, handles)

% copy object
o = make_copies(objs, handles);
objs = o;

% check for single or multiple object(s)
if isstruct(whos('objs'))
    objs = {objs}; % make it cell 
end
mode = '3D';
clr = [0.6354 0 0.6957]; % violet

axes(handles.axes_preview)
axis off
cla
hold on

try
for os = 1:size(objs,2)
    for o = 1:size(objs{os},2)
        M = eye(3);

        % check for single or group object
        if strcmp(objs{os}{o}.type,'group')
             % object coordinates
             c = objs{os}{o}.coordinates;
             origin = c;
             
             % rotation matrix
             M = rotate_object(objs{os}{o});
             %M = eye(3);
             % rotation direction(s)
             d = objs{os}{o}.rotation;
             % plot object group
             plot_object_group(objs{os}{o},mode,clr,M,c,[],origin)
        else
            % plot
            origin = objs{os}{o}.coordinates;
            M = eye(3);
            if strcmp(mode,'2D')
                plot_single_object_2D(objs{os}{o},[],clr,M,origin)
            elseif strcmp(mode,'3D')
                plot_single_object_3D(objs{os}{o},[],clr,M,origin)
            end
        end
    end
end
catch ME
    catcher(ME)
   %comeback('no objects or error') 
end
% plot orogin
c = objs{1}{1}.coordinates;
plot3(c(1),c(2),c(3),'r*')
hold off



function plot_object_group(objs,mode,clr,M,co,d,origin)
if ~exist('co','var')
    co = [0 0 0];
end
if ~exist('d','var')
    d = [0 0 0];
end
% loop over group objects
for o = 1:size(objs.objects,2)
    if strcmp(objs.objects{o}.type,'group')
        % recursive function call
        c = objs.objects{o}.coordinates+co;
        
        rot = rotate_object(objs.objects{o},origin);
        M2 = M*rot;
        %M = eye(3);
        plot_object_group(objs.objects{o},mode,clr,M2,c,d,origin)
    else
        % get coordinates
        c = objs.objects{o}.coordinates;
        %rot = rotate_object(objs.objects{o},origin);
        %M = M*rot;
        %M = eye(3);
        % plot function call
        %origin = c;
        if strcmp(mode,'2D')
            plot_single_object_2D(objs.objects{o},co,clr,M,origin)
        elseif strcmp(mode,'3D')
            plot_single_object_3D(objs.objects{o},co,clr,M,origin)
        end
    end
end



function plot_single_object_3D(obj,c,clr,rot,origin)
if ~exist('rot','var')
    rot = eye(3);
end
if ~exist('origin','var')
    origin = obj.coordinates;
end
if ~exist('clr','var')
    clr = [0.6354  0  0.6957];
end
try
    co = obj.coordinates+c-origin;
catch
    co = [0 0 0];
end
g = obj.geometry{1};
g = [g;g(1,:)];

% rotation matrix
M = deg2rad(obj.rotation);
T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
T = T(1:3,1:3);
g1 = g(:,1:3)*T(1:3,1:3);
g2 = g(:,[1 2 4])*T(1:3,1:3);

% shift coordinates according to origin matrix
%rows = [co co(3)];
%S = repmat(c,size(g,1),1);
S = repmat(co,size(g,1),1);
g1 = g1+S;
g2 = g2+S;

g1 = g1*rot;
g2 = g2*rot;

C = origin;
plot3(g1(:,1)+C(1),g1(:,2)+C(2),g1(:,3)+C(3),'Color',clr)
plot3(g2(:,1)+C(1),g2(:,2)+C(2),g2(:,3)+C(3),'Color',clr)
for line = 1:size(g,1)
    plot3([g1(line,1);g2(line,1)]+C(1),...
        [g1(line,2);g2(line,2)]+C(2),...
        [g1(line,3);g2(line,3)]+C(3),'Color',clr)
end
view([315 30])
axis equal



function M = rotate_object(obj,c,d)
if ~exist('c','var')
    c = obj.coordinates;
end
if ~exist('d','var')
    d = [0 0 0];
end
M = eye(3);
N = M;
% origin point
origin = c;
% loop over to be rotated axis
for n = find(obj.rotation+d ~= 0)
    u = N(n,:);
    alpha = obj.rotation(n)+d(n);
    % create rot matrix
    alph = alpha*pi/180;
    cosa = cos(alph);
    sina = sin(alph);
    vera = 1 - cosa;
    x = u(1);
    y = u(2);
    z = u(3);
    rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
        x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
        x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';
    [m,n] = size(x);
    newxyz = [x(:)-origin(1), y(:)-origin(2), z(:)-origin(3)];
    newxyz = newxyz*rot;
    newx = origin(1) + reshape(newxyz(:,1),m,n);
    newy = origin(2) + reshape(newxyz(:,2),m,n);
    newz = origin(3) + reshape(newxyz(:,3),m,n);
    % object coordinates
    M = M*rot;
end





function edit_nr_copies_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)



% --- Executes during object creation, after setting all properties.
function edit_nr_copies_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nr_copies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_object_name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_object_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_object_name as text
%        str2double(get(hObject,'String')) returns contents of edit_object_name as a double


% --- Executes during object creation, after setting all properties.
function edit_object_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_object_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_group_name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_group_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_group_name as text
%        str2double(get(hObject,'String')) returns contents of edit_group_name as a double


% --- Executes during object creation, after setting all properties.
function edit_group_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_group_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_suffix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_suffix as text
%        str2double(get(hObject,'String')) returns contents of edit_suffix as a double


% --- Executes during object creation, after setting all properties.
function edit_suffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rot_x_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)




% --- Executes during object creation, after setting all properties.
function edit_rot_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rot_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rot_y_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)





% --- Executes during object creation, after setting all properties.
function edit_rot_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rot_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rot_z_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)




% --- Executes during object creation, after setting all properties.
function edit_rot_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rot_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_x_offset_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)




% --- Executes during object creation, after setting all properties.
function edit_x_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_x_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_y_offset_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)




% --- Executes during object creation, after setting all properties.
function edit_y_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_y_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_z_offset_Callback(hObject, eventdata, handles)
plot_object(handles.objects,handles)




% --- Executes during object creation, after setting all properties.
function edit_z_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_z_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in box_group.
function box_group_Callback(hObject, eventdata, handles)
% hObject    handle to box_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_group


% --- Executes on button press in box_include.
function box_include_Callback(hObject, eventdata, handles)
% hObject    handle to box_include (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of box_include


% --- Executes on button press in button_discard.
function button_discard_Callback(hObject, eventdata, handles)
% hObject    handle to button_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq();



% --- Executes on button press in button_copy.
function button_copy_Callback(hObject, eventdata, handles)
% hObject    handle to button_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
o = make_copies(handles.objects, handles);
if handles.box_group.Value
    o = group(o,handles);
    o.coordinates = handles.objects.coordinates;
    o.rotation = handles.objects.rotation;
    if ~isempty(handles.edit_group_name.String)
        o.name = handles.edit_group_name.String;
    else
        o.name = o.objects{1}.name;
    end
else
    %for n = 1:numel(o)
       %o{n}.coordinates = o{n}.coordinates + handles.objects.coordinates;
       %o{n}.rotation = o{n}.rotation + handles.objects.rotation;
    %end
end
if isstruct(o)
    o = {o};
end
room = getappdata(handles.Lumos,'room');
switch handles.mode
    case 'object'
        obj = room{handles.room_nr}.objects;
    case 'luminaire'
        obj = room{handles.room_nr}.luminaire;
end
nr = handles.object_nr;
switch nr
    case 1
        if isequal(size(obj,2),1)
            % only one object present
            O = o;
        else
            % more than one object present
            O = [o obj(2:end)];
        end
    case size(room{handles.room_nr}.objects,2)
        O = [obj(1:end-1) o];
    otherwise
        O = [obj(1:nr-1) o obj(nr+1:end)];
end
% save objects
switch handles.mode
    case 'object'
        room{handles.room_nr}.objects = O;
    case 'luminaire'
        room{handles.room_nr}.luminaire = O;
end
setappdata(handles.Lumos,'room',room)

% object list
guidata(hObject,handles)
list = object_list(handles);
% set object name list
handles.list_objects.String = list;
% set list item to number 1
handles.list_objects.Value = handles.object_nr;
% set menu fields
handles.objects = o;
guidata(hObject,handles)
try
    handles.edit_object_name.String = handles.objects.name;
catch
    handles.edit_object_name.String = handles.objects{1}.name;
end
try
    c = handles.objects.coordinates;
catch
    c = handles.objects{1}.coordinates;
end
handles.edit_origin_x.String = num2str(c(1));
handles.edit_origin_y.String = num2str(c(2));
handles.edit_origin_z.String = num2str(c(3));
try
    g = handles.objects.geometry{1};
catch
    g = handles.objects{1}.geometry{1};
end
handles.edit_dim_x.String = num2str(max(g(:,1)));
handles.edit_dim_y.String = num2str(max(g(:,2)));
handles.edit_dim_z.String = num2str(max(g(:,4)));
% set value of LUMOS listbox
%h = findall(handles.Lumos.Children,'tag','listbox');
%set(h,'Value',1)
% refresh Lumos
update_Lumos_object(handles)
% set Lumos as active window
%figure(handles.Lumos)




function close_list(handles)
% get listbox handle
h = findall(handles.Lumos.Children,'tag','listbox');
% get LUMOS room data
room = getappdata(handles.Lumos,'room');

if size(room,1) > size(room,2)
    room = room';
end
ind = 1;
list = {};
% create room -> object list
for r = 1:size(room,2)
    
    % bold font
    list{ind,1} = ['<html><b>',room{r}.name,'</b></html>'];
    ind = ind + 1;
    switch handles.mode
        case 'object'
            try
                % list objects
                for o = 1:size(room{r}.objects,2)
                    
                    list{ind,1} = ['    ',room{r}.objects{o}.name];
                    ind = ind + 1;
                end
            catch
            end
        case 'luminaire'
            try
                % list objects
                for o = 1:size(room{r}.luminaire,2)
                    
                    list{ind,1} = ['    ',room{r}.luminaire{o}.name];
                    ind = ind + 1;
                end
            catch
            end
            
    end
end
% update listbox
set(h,'String',list)



function update_Lumos_object(handles)
% update Lumos lsitbox
close_list(handles)

% get Lumos handles
H = guidata(handles.Lumos);
m = get(H.listbox,'Value');

% get room data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');

switch handles.mode
    case 'object'
        table{1}.table_mode = 'objects';
        setappdata(handles.Lumos,'table',table)
        
        ind = 1;
        % create room -> object list
        for r = 1:max(size(room))
            % room
            list{ind,1} = r;
            list{ind,2} = [];
            ind = ind+1;
            try
                for o = 1:size(room{r}.objects,2)
                    % objects
                    list{ind,1} = r;
                    list{ind,2} = o;
                    ind = ind+1;
                end
            catch
            end
        end
        
        
        H.data.object = list{m,2};
        H.data.room = list{m,1};
        % update Lumos handles
        guidata(handles.Lumos, H)
        
        
        
        % update table
        object_table(handles.Lumos, [], H)
        H = guidata(handles.Lumos);
        
        refresh_2D(handles.Lumos,[],H)
        refresh_2D_objects(handles.Lumos,[],H,H.data.object)
        
        % highlight object selected
        if ~isempty(list{get(H.listbox,'Value'),2})
            refresh_3DObjects(handles.Lumos, [], H,H.data.object)
            axes(H.topview);
            refresh_2D_objects(handles.Lumos, [], H,H.data.object)
        else
            try
                refresh_3DObjects(handles.Lumos, [], H)
            catch me
                catcher(me)
                %view_CreateFcn(handles.Lumos, [], H)
            end
        end

    case 'luminaire'
        luminaire_table(H,[],handles.Lumos)
        refresh_2D(handles.Lumos,[],H)
        
        try
            refresh_2D_objects(handles.Lumos,[],H,H.data.object,'object')
        catch
            try
                refresh_2D_objects(handles.Lumos,[],H,H.data.object,'luminaire')
            catch
            end
        end
            
        try
            refresh_3DObjects(handles.Lumos, [], H, H.data.object, 'object')
        catch
            try
            refresh_3DObjects(handles.Lumos, [], H, H.data.object, 'luminaire')
            catch
            end
        end
        
end




function luminaire_table(handles,~,hObject)
%comeback('observer table list')

% get table data
room = getappdata(gcf,'room');

% check if room or luminaire is selected
nr = handles.listbox.Value;
[room_nr, lum_nr, ~, type] = lum_room_nr(handles, [], hObject);

switch type
    case 'room'
        % set table configuration
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'RowName','numbered')
        try
            set(handles.topview_point_table,'ColumnName',{room{handles.data.room}.name,'x','y','z','x-rot','y-rot','z-rot',})
        catch
            set(handles.topview_point_table,'ColumnName',{'room','x','y','z','x-rot','y-rot','z-rot',})
        end
        set(handles.topview_point_table,'ColumnEditable',[false true(1,6)])
        set(handles.topview_point_table,'ColumnFormat',{'char','char','char','char','char'})
       
        try
            for L = 1:max(size(room{handles.data.room}.luminaire))
                data{L,1} = room{room_nr}.luminaire{L}.name;
                data{L,2} = room{room_nr}.luminaire{L}.coordinates(1);
                data{L,3} = room{room_nr}.luminaire{L}.coordinates(2);
                data{L,4} = room{room_nr}.luminaire{L}.coordinates(3);
                data{L,5} = room{room_nr}.luminaire{L}.rotation(1);
                data{L,6} = room{room_nr}.luminaire{L}.rotation(2);
                data{L,7} = room{room_nr}.luminaire{L}.rotation(3);
            end
            % set table data
            set(handles.topview_point_table,'Data',data)
        catch
        end
    case 'luminaire'
        % set table configuration
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnName',{'model','select','spectrum','select','range',})
        set(handles.topview_point_table,'ColumnEditable',[true true false true false])
        set(handles.topview_point_table,'ColumnFormat',{'char','logical','char','logical','char'})
       
        ldt = getappdata(gcf,'ldt');
        spectra = getappdata(gcf,'spectra');
        
        try
            n = max(numel(ldt),numel(spectra));
            data = cell(n,5);
            for L = 1:numel(ldt)
                data{L,1} = ldt{L}.name;
                try
                if strcmp(room{room_nr}.luminaire{lum_nr}.ldt.name,ldt{L}.name)
                    data{L,2} = 1;
                else
                    data{L,2} = 0;
                end
                catch
                    data{L,2} = 0;
                end
            end
            for L = 1:numel(spectra)
                data{L,3} = spectra{L}.name;
                try
                if strcmp(room{room_nr}.luminaire{lum_nr}.spectrum.name,spectra{L}.name)
                    data{L,4} = 1;
                else
                    data{L,4} = 0;
                end
                catch
                    data{L,4} = 0;
                end
                data{L,5} = spectra{L}.range;

            end
            % set table data
            set(handles.topview_point_table,'Data',data)
        catch
        end
end
guidata(hObject, handles)



function [room_nr, lum_nr, list, type] = lum_room_nr(handles, nr, H)
room = getappdata(H,'room');
room_nr = 1;
try
    selected = nr;
catch
    selected = get(handles.listbox,'Value');
end
% make list
ind = 1;
list = [];
lum_nr = [];
type = 'room';
for r = 1:max(size(room))
    list{1,ind} = room{r}.name;
    if isequal(selected,ind)
        room_nr = r;
    end
    ind = ind+1;
    try
        for o=1:size(room{r}.luminaire,2)
            list{1,ind} = ['   ',room{r}.luminaire{o}.name];
            if isequal(selected,ind)
                room_nr = r;
                lum_nr = o;
                type = 'luminaire';
            end
            ind = ind+1;
        end
    catch
    end
end





function object_table(~, ~, handles)
%comeback('Object table cases creation..')

% selected list element
item = handles.listbox.Value;
% get LUMOS handle
Lumos = findall(0,'tag','SpecSimulation');
% get room data
room = getappdata(Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end
ind = 1;

% check category of selected item
for r = 1:size(room,2)
    if isequal(item,ind)
        object_case = 'room';
        object_room = r;
        object_nr = 0;
    end
    ind = ind + 1;
    try
        % list objects
        for o = 1:size(room{r}.objects,2)
            if isequal(item,ind)
                object_case = 'object';
                object_room = r;
                object_nr = o;
            end
            ind = ind + 1;
        end
    catch
    end
end

% objects in room or object geometry table
if handles.listbox.Max == 1 % <- messed with listbox parameter...
    try
    switch object_case
        case 'room'
            %disp(['room ' num2str(object_room)])
            ob_rows = [];
            try
                data = zeros(size(room{object_room}.objects,2),6);
                for i = 1:size(room{object_room}.objects,2)
                    obj = room{object_room}.objects{i};
                    ob_rows{i} = room{object_room}.objects{i}.name;
                    %data = group_object_table(obj);
                    %data(i,:) = get_object_data(obj,1);
                    data(i,1:3) = room{object_room}.objects{i}.coordinates;
                    data(i,4:6) = room{object_room}.objects{i}.rotation;
                end
            catch
            end
            % fill table
            set(handles.topview_point_table,'RowName',ob_rows)
            set(handles.topview_point_table,'ColumnName',{'x','y','z','rot-x','rot-y','rot-z'})
            set(handles.topview_point_table,'Data',data)
            set(handles.topview_point_table,'ColumnEditable',true(1,6))
            %try
            %    set(handles.topview_point_table,'ColumnEditable',true(i,6))
            %catch
            %end
            
        case 'object'
            
            % distinguish between single or group object
            obj = room{object_room}.objects{object_nr};
            if strcmp(obj.type,'group')
                [data,points] = group_object_table(obj);
            else
                %disp(['object ' num2str(object_nr) ' in room ' num2str(object_room)])
                ind = 1;
                for i = 1:size(obj.geometry,2)
                    % sub objects
                    for j = 1:size(room{object_room}.objects{object_nr}.geometry{i},1)
                        points{ind} = [num2str(i) 'P' num2str(j)];
                        data(ind,:) = room{object_room}.objects{object_nr}.geometry{i}(j,:);
                        ind = ind+1;
                    end
                end
            end
            set(handles.topview_point_table,'RowName',points)
            set(handles.topview_point_table,'ColumnName',{'x','y','z1','z2'})
            set(handles.topview_point_table,'Data',data)
            set(handles.topview_point_table,'ColumnEditable',true(1,4))        
    end
    catch
        set(handles.topview_point_table,'RowName','')
        set(handles.topview_point_table,'ColumnName',{'x','y','z1','z2'})
        set(handles.topview_point_table,'Data',[])
        set(handles.topview_point_table,'ColumnEditable',true(1,4))
    end
else
    set(handles.topview_point_table,'RowName','')
    set(handles.topview_point_table,'ColumnName',{'x','y','z1','z2'})
    set(handles.topview_point_table,'Data',[])
    set(handles.topview_point_table,'ColumnEditable',true(1,4))
end
%refresh_3DObjects(hObject, eventdata, handles)
%guidata(hObject,handles)






function [data,points,ind] = group_object_table(obj,data,points,ind)
if ~exist('data','var')
    data = [];
end
if ~exist('points','var')
    points = [];
end
if ~exist('ind','var')
    ind = 1;
end
if strcmp(obj.type,'group')
    for i = 1:numel(obj.objects)
        [data,points,ind] = group_object_table(obj.objects{i},data,points,ind);
    end
else
    [d,p,ind] = single_object_table_data(obj,ind);
    data = [data;d];
    points = [points p];
end



function newobj = group(objs,handles)
switch handles.mode
    case 'object'
        % create new group object
        newobj.type = 'group';
        newobj.objects = objs;
        % set geometry relative to children object (function)
        g = group_object_geometry(newobj);
        newobj.geometry = {g};
        % set coordinates and rotation
        newobj.coordinates =  [0 0 0];
        newobj.rotation = [0 0 0];
        % set coordinates relative to parent object (function)
        %newobj = group_object_coordinates(newobj);
        [~,newobj] = get_sub_coordinates(newobj,'-');
        % set new-object name (= first sub object)
        newobj.name = handles.edit_object_name.String;
        % no material !
        newobj.material = [];
    case 'luminaire'
        % create new group object
        newobj.type = 'group';
        newobj.objects = objs;
        % set geometry relative to children object (function)
        g = group_object_geometry(newobj);
        newobj.geometry = {g};
        % set coordinates and rotation
        newobj.coordinates =  [0 0 0];
        newobj.rotation = [0 0 0];
        % set coordinates relative to parent object (function)
        %newobj = group_object_coordinates(newobj);
        [~,newobj] = get_sub_coordinates(newobj,'-');
        % set new-object name (= first sub object)
        newobj.name = handles.edit_object_name.String;
        % no material !
        %newobj.material = [];
        
end


function  g = group_object_geometry(obj)
% call the recursive function
g = group_object_geom(obj,[]);
% order geometry
g = [min(g(:,1)) min(g(:,2)) min(g(:,3)) max(g(:,4));...
     max(g(:,1)) min(g(:,2)) min(g(:,3)) max(g(:,4));...
     max(g(:,1)) max(g(:,2)) min(g(:,3)) max(g(:,4));...
     min(g(:,1)) max(g(:,2)) min(g(:,3)) max(g(:,4))];

 
 
function g = group_object_geom(obj,g)
% find smallest x,y and z coordinates
% distuingish between object and group object
if strcmp(obj.type,'group')
    for n = 1:numel(obj.objects)
        % recursive function call
        g = [g; group_object_geom(obj.objects{n},g)];
    end
elseif strcmp(obj.type,'single') || strcmp(obj.type,'luminaire')
    % append coordniates
    g = [g;obj.geometry{1}];
end

 

function [c,obj] = get_sub_coordinates(obj,mode)
% get minimum coordinates
c = [];
for n = 1:numel(obj.objects)
    c = [c;obj.objects{n}.coordinates];
end
c = min(c);
obj.coordinates = c;
% add/substract new object coordinates from subobjects
switch mode
    case '-'
        for n = 1:numel(obj.objects)
            obj.objects{n}.coordinates = obj.objects{n}.coordinates-c;
        end
    case '+'
        for n = 1:numel(obj.objects)
            obj.objects{n}.coordinates = obj.objects{n}.coordinates+c;
        end
end



function edit_origin_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_origin_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_origin_x as text
%        str2double(get(hObject,'String')) returns contents of edit_origin_x as a double


% --- Executes during object creation, after setting all properties.
function edit_origin_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_origin_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_origin_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_origin_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_origin_y as text
%        str2double(get(hObject,'String')) returns contents of edit_origin_y as a double


% --- Executes during object creation, after setting all properties.
function edit_origin_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_origin_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_origin_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_origin_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_origin_z as text
%        str2double(get(hObject,'String')) returns contents of edit_origin_z as a double


% --- Executes during object creation, after setting all properties.
function edit_origin_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_origin_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dim_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dim_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dim_x as text
%        str2double(get(hObject,'String')) returns contents of edit_dim_x as a double


% --- Executes during object creation, after setting all properties.
function edit_dim_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dim_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dim_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dim_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dim_y as text
%        str2double(get(hObject,'String')) returns contents of edit_dim_y as a double


% --- Executes during object creation, after setting all properties.
function edit_dim_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dim_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_dim_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dim_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dim_z as text
%        str2double(get(hObject,'String')) returns contents of edit_dim_z as a double


% --- Executes during object creation, after setting all properties.
function edit_dim_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dim_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_nr_copies.
function edit_nr_copies_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_nr_copies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on edit_nr_copies and none of its controls.
function edit_nr_copies_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_nr_copies (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in list_objects.
function list_objects_Callback(hObject, eventdata, handles)
handles.object_nr = hObject.Value;
guidata(hObject,handles);
% room data
room = getappdata(handles.Lumos,'room');
% update selected object
switch handles.mode
    case 'object'
        handles.objects = room{handles.room_nr}.objects{handles.object_nr};
    case 'luminaire'
        handles.objects = room{handles.room_nr}.luminaire{handles.object_nr};
end
% set data
handles.edit_object_name.String = handles.objects.name;
c = handles.objects.coordinates;
handles.edit_origin_x.String = num2str(c(1));
handles.edit_origin_y.String = num2str(c(2));
handles.edit_origin_z.String = num2str(c(3));
g = handles.objects.geometry{1};
handles.edit_dim_x.String = num2str(max(g(:,1)));
handles.edit_dim_y.String = num2str(max(g(:,2)));
handles.edit_dim_z.String = num2str(max(g(:,4)));
% draw selected object
plot_object(handles.objects,handles)
% update guidata
guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function list_objects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_objects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in menu_room.
function menu_room_Callback(hObject, eventdata, handles)
handles.room_nr = hObject.Value;
guidata(hObject,handles);
list = object_list(handles);
% set object name list
handles.list_objects.String = list;
% set list item to number 1
handles.object_nr = 1;
handles.list_objects.Value = handles.object_nr;

% room data
room = getappdata(handles.Lumos,'room');
% update selected object
handles.objects = room{handles.room_nr}.objects{handles.object_nr};
% draw selected object
plot_object(handles.objects,handles)
% set data
handles.edit_object_name.String = handles.objects.name;
c = handles.objects.coordinates;
handles.edit_origin_x.String = num2str(c(1));
handles.edit_origin_y.String = num2str(c(2));
handles.edit_origin_z.String = num2str(c(3));
g = handles.objects.geometry{1};
handles.edit_dim_x.String = num2str(max(g(:,1)));
handles.edit_dim_y.String = num2str(max(g(:,2)));
handles.edit_dim_z.String = num2str(max(g(:,4)));
% update guidata
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function menu_room_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_room (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%{
function refresh_3DObjects(hObject, eventdata, handles, obj)

if ~exist('obj','var')
    obj = [];
end

axes(handles.axes_room)
cla
colorbar('off')
legend('off')


reset(handles.axes_room)
axis off
view([315 30])

% get room data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');
handles.data.walls = {};

% clear old plots
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
hold on

% get table data
try
    data = table{handles.room_nr}.room;
catch
    %data = get(handles.topview_point_table,'Data');
end
% get window data
%windata = getappdata(gcf,'room');

% plot room wireframe
plot3(data(:,1),data(:,2),data(:,3),'Color',[0.5 0.5 0.5])
hold on
plot3(data(:,1),data(:,2),zeros(size(data(:,3),1)),'Color',[0.5 0.5 0.5])
for i = 1:size(data,1)
    plot3([data(i,1);data(i,1)],[data(i,2);data(i,2)],[0;data(i,3)],'Color',[0.5 0.5 0.5])
end

% plot window frames for all walls
for wall = 1:size(room{handles.data.room}.walls,2)
    try
        for win = 1:size(room{handles.data.room}.walls{wall}.windows,2)
            winframe = room{handles.data.room}.walls{wall}.windows{win}.data;
            plot3(winframe(:,1),winframe(:,2),winframe(:,3),'Color',[0.7 0.7 0.7])
        end
    catch
    end
end
view([315 30])
hold off
axis equal
axis off
%axis on
title('objects')

r = handles.data.room;
try
    objs = room{r}.objects;
    plot_object(objs, obj, handles.view, '3D')
catch ME
    catcher(ME)
    %comeback('no objects or error')
end
% update guidata
guidata(hObject, handles)
%}


% --- Executes on button press in button_delete.
function button_delete_Callback(hObject, eventdata, handles)
obj_nr = handles.list_objects.Value;
room = getappdata(handles.Lumos,'room');
switch handles.mode
    case 'object'
        %room{handles.room_nr}.objects{obj_nr};
        % delete selected object
        room{handles.room_nr}.objects(obj_nr) = [];
        setappdata(handles.Lumos,'room',room);
        % select new object
        handles.object_nr = handles.object_nr-1;
        if handles.object_nr < 1
            handles.object_nr = 1;
        end
        try
            handles.objects = room{handles.room_nr}.objects{handles.object_nr};
        catch
            handles.objects = [];
        end
    case 'luminaire'
        % delete selected object
        room{handles.room_nr}.luminaire(obj_nr) = [];
        setappdata(handles.Lumos,'room',room);
        % select new object
        handles.object_nr = handles.object_nr-1;
        if handles.object_nr < 1
            handles.object_nr = 1;
        end
        try
            handles.objects = room{handles.room_nr}.luminaire{handles.object_nr};
        catch
            handles.objects = [];
        end
end

% update guidata
guidata(hObject,handles)
% update object list
list = object_list(handles);
% set object name list
handles.list_objects.String = list;
% set list item to number 1
handles.list_objects.Value = handles.object_nr;
% plot object
plot_object(handles.objects,handles)
% set menu fields
handles.edit_object_name.String = handles.objects.name;
c = handles.objects.coordinates;
handles.edit_origin_x.String = num2str(c(1));
handles.edit_origin_y.String = num2str(c(2));
handles.edit_origin_z.String = num2str(c(3));
g = handles.objects.geometry{1};
handles.edit_dim_x.String = num2str(max(g(:,1)));
handles.edit_dim_y.String = num2str(max(g(:,2)));
handles.edit_dim_z.String = num2str(max(g(:,4)));
guidata(hObject,handles)
% set value of LUMOS listbox
%h = findall(handles.Lumos.Children,'tag','listbox');
%set(h,'Value',1)
% refresh Lumos
update_Lumos_object(handles)



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function refresh_2D(hObject, eventdata, handles)
axes(handles.topview)
cla
% delete old plot
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
% get appdata
table = getappdata(gcf,'table');
% replot room layout
try
    plot(table{handles.data.room}.room(:,1),table{handles.data.room}.room(:,2),'Color',handles.darkblue)
catch
end
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
axis on
axis auto
a = axis;
axis([a(1)-abs(a(2)-a(1))/10 a(2)+abs(a(2)-a(1))/10 a(3)-abs(a(4)-a(3))/10 a(4)+abs(a(4)-a(3))/10]);

axis equal
%camtarget([mean([a(1) a(2)]) mean([a(3) a(4)]) 0]);
xlabel('x')
ylabel('y')
title('top view')
axis equal
% update guidata
guidata(hObject, handles)



function refresh_3DObjects(hObject, eventdata, handles, obj, mode)

if ~exist('obj','var')
    obj = [];
end

if ~exist('mode','var')
    mode = 'object';
end

axes(handles.view)
cla
colorbar('off')
legend('off')

reset(handles.view)
view([315 30])

% get room data
room = getappdata(gcf,'room');
table = getappdata(gcf,'table');
handles.data.walls = {};

% clear old plots
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
hold on

% get table data
try
    data = table{handles.data.room}.room;
catch
    data = get(handles.topview_point_table,'Data');
end
% get window data
%windata = getappdata(gcf,'room');

% plot room wireframe
plot3(data(:,1),data(:,2),data(:,3),'Color',[0.5 0.5 0.5])
hold on
plot3(data(:,1),data(:,2),zeros(size(data(:,3),1)),'Color',[0.5 0.5 0.5])
for i = 1:size(data,1)
    plot3([data(i,1);data(i,1)],[data(i,2);data(i,2)],[0;data(i,3)],'Color',[0.5 0.5 0.5])
end

% plot window frames for all walls
for wall = 1:size(room{handles.data.room}.walls,2)
    try
        for win = 1:size(room{handles.data.room}.walls{wall}.windows,2)
            winframe = room{handles.data.room}.walls{wall}.windows{win}.data;
            plot3(winframe(:,1),winframe(:,2),winframe(:,3),'Color',[0.7 0.7 0.7])
        end
    catch
    end
end
view([315 30])
hold off
axis equal
axis off
%axis on
title('objects')

r = handles.data.room;
try
    switch mode
        case 'object'
            objs = room{r}.objects;
            plot_object_Lumos(objs, obj, handles.view, '3D',mode)
        case 'luminaire'
            try
                objs = room{r}.objects;
                plot_object_Lumos(objs, obj, handles.view, '3D','object')
            catch
            end
            try
                objs = room{r}.luminaire;
                plot_object_Lumos(objs, obj, handles.view, '3D','luminaire')
            catch
            end
    end
catch ME
    catcher(ME)
    %comeback('no objects or error')
end
% update guidata
guidata(hObject, handles)



function refresh_2D_objects(hObject, eventdata, handles, obj, mode)
if ~exist('mode','var')
    mode = 'object';
end
room = getappdata(hObject,'room');
r = handles.data.room;
% get objects
try
    switch mode
        case 'object'
            objs = room{r}.objects;
        case 'luminaire'
            objs = room{r}.luminaire;
    end
          
    if ~exist('obj','var')
        obj = [];
    end
    
    plot_object_Lumos(objs, obj, handles.topview, '2D',mode)
catch
    cla
end
%hold off
% update guidata
guidata(hObject, handles)




function plot_object_Lumos(objs, obj, h, mode,clrmode)
% check for single or multiple object(s)
if isstruct(whos('objs'))
    objs = {objs}; % make it cell 
end

switch clrmode
    case 'object'
        CLR = [0.6354 0 0.6957]; % violet
    case 'luminaire'
        CLR = [0.8594 0.5153 0]; % orange
end

axes(h)
hold on

try
for os = 1:size(objs,2)
    for o = 1:size(objs{os},2)
        M = eye(3);
        % check if selected
        if o==obj
            clr = [1.0000 0 0.2585]; % red
        else
            clr = CLR;
        end
        % check for single or group object
        if strcmp(objs{os}{o}.type,'group')
             % object coordinates
             c = objs{os}{o}.coordinates;
             origin = c;
             
             % rotation matrix
             M = rotate_object(objs{os}{o});
             %M = eye(3);
             % rotation direction(s)
             d = objs{os}{o}.rotation;
             % plot object group
             plot_object_group(objs{os}{o},mode,clr,M,c,[],origin)
        else
            % plot
            origin = objs{os}{o}.coordinates;
            M = eye(3);
            if strcmp(mode,'2D')
                plot_single_object_2D(objs{os}{o},[],clr,M,origin)
            elseif strcmp(mode,'3D')
                plot_single_object_3D(objs{os}{o},[],clr,M,origin)
            end
        end
    end
end
catch ME
    catcher(ME)
   %comeback('no objects or error') 
end
hold off



function plot_object_group_Lumos(objs,mode,clr,M,co,d,origin)
if ~exist('co','var')
    co = [0 0 0];
end
if ~exist('d','var')
    d = [0 0 0];
end
% loop over group objects
for o = 1:size(objs.objects,2)
    if strcmp(objs.objects{o}.type,'group')
        % recursive function call
        c = objs.objects{o}.coordinates+co;
        
        rot = rotate_object(objs.objects{o},origin);
        M2 = M*rot;
        %M = eye(3);
        plot_object_group_Lumos(objs.objects{o},mode,clr,M2,c,d,origin)
    else
        % get coordinates
        c = objs.objects{o}.coordinates;
        %rot = rotate_object(objs.objects{o},origin);
        %M = M*rot;
        %M = eye(3);
        % plot function call
        %origin = c;
        if strcmp(mode,'2D')
            plot_single_object_2D(objs.objects{o},co,clr,M,origin)
        elseif strcmp(mode,'3D')
            plot_single_object_3D_Lumos(objs.objects{o},co,clr,M,origin)
        end
    end
end



function plot_single_object_3D_Lumos(obj,c,clr,rot,origin)
if ~exist('rot','var')
    rot = eye(3);
end
if ~exist('origin','var')
    origin = obj.coordinates;
end
if ~exist('clr','var')
    clr = [0.6354  0  0.6957];
end
try
    co = obj.coordinates+c-origin;
catch
    co = [0 0 0];
end
g = obj.geometry{1};
g = [g;g(1,:)];

% rotation matrix
M = deg2rad(obj.rotation);
T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
T = T(1:3,1:3);
g1 = g(:,1:3)*T(1:3,1:3);
g2 = g(:,[1 2 4])*T(1:3,1:3);

% shift coordinates according to origin matrix
%rows = [co co(3)];
%S = repmat(c,size(g,1),1);
S = repmat(co,size(g,1),1);
g1 = g1+S;
g2 = g2+S;

g1 = g1*rot;
g2 = g2*rot;

C = origin;
plot3(g1(:,1)+C(1),g1(:,2)+C(2),g1(:,3)+C(3),'Color',clr)
plot3(g2(:,1)+C(1),g2(:,2)+C(2),g2(:,3)+C(3),'Color',clr)
for line = 1:size(g,1)
    plot3([g1(line,1);g2(line,1)]+C(1),...
        [g1(line,2);g2(line,2)]+C(2),...
        [g1(line,3);g2(line,3)]+C(3),'Color',clr)
end
view([315 30])
axis equal



function plot_single_object_2D(obj,c,clr,rot,origin)
if ~exist('rot','var')
    rot = eye(3);
end
if ~exist('origin','var')
    origin = obj.coordinates;
end
if ~exist('clr','var')
    clr = [0.6354  0  0.6957];
end
try
    co = obj.coordinates+c-origin;
catch
    co = [0 0 0];
end

g = obj.geometry{1};
g = [g;g(1,:)];
offset = max(g)/2;
g(:,1:2) = g(:,1:2)-offset(:,1:2);
%{
% shift coordinates according to origin matrix
rows = [co co(3)];
S = repmat(rows,size(g,1),1);
g = g+S;
% rotation matrix
M = deg2rad(obj.rotation);
T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
T = T(1:3,1:3)*rot;
g1 = g(:,1:3)*T(1:3,1:3);
g2 = g(:,[1 2 4])*T(1:3,1:3);
%}

% rotation matrix
M = deg2rad(obj.rotation);
T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
T = T(1:3,1:3);
g1 = g(:,1:3)*T(1:3,1:3);
g2 = g(:,[1 2 4])*T(1:3,1:3);

% shift coordinates according to origin matrix
S = repmat(co,size(g,1),1);
g1 = g1+S;
g2 = g2+S;

% second rotation
g1 = g1*rot;
g2 = g2*rot;

% plot
C = origin;
plot(g1(:,1)+C(1),g1(:,2)+C(2),'Color',clr)
plot(g2(:,1)+C(1),g2(:,2)+C(2),'Color',clr)
for line = 1:size(g,1)
    plot([g1(line,1);g2(line,1)]+C(1),[g1(line,2);g2(line,2)]+C(2),'Color',clr)
end
axis equal



function M = rotate_object_Lumos(obj,c,d)
if ~exist('c','var')
    c = obj.coordinates;
end
if ~exist('d','var')
    d = [0 0 0];
end
M = eye(3);
N = M;
% origin point
origin = c;
% loop over to be rotated axis
for n = find(obj.rotation+d ~= 0)
    u = N(n,:);
    alpha = obj.rotation(n)+d(n);
    % create rot matrix
    alph = alpha*pi/180;
    cosa = cos(alph);
    sina = sin(alph);
    vera = 1 - cosa;
    x = u(1);
    y = u(2);
    z = u(3);
    rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
        x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
        x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';
    [m,n] = size(x);
    newxyz = [x(:)-origin(1), y(:)-origin(2), z(:)-origin(3)];
    newxyz = newxyz*rot;
    newx = origin(1) + reshape(newxyz(:,1),m,n);
    newy = origin(2) + reshape(newxyz(:,2),m,n);
    newz = origin(3) + reshape(newxyz(:,3),m,n);
    % object coordinates
    M = M*rot;
end
