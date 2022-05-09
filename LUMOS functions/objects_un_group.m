function varargout = objects_un_group(varargin)
% OBJECTS_UN_GROUP MATLAB code for objects_un_group.fig
%      OBJECTS_UN_GROUP, by itself, creates a new OBJECTS_UN_GROUP or raises the existing
%      singleton*.
%
%      H = OBJECTS_UN_GROUP returns the handle to a new OBJECTS_UN_GROUP or the handle to
%      the existing singleton*.
%
%      OBJECTS_UN_GROUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTS_UN_GROUP.M with the given input arguments.
%
%      OBJECTS_UN_GROUP('Property','Value',...) creates a new OBJECTS_UN_GROUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before objects_un_group_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to objects_un_group_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help objects_un_group

% Last Modified by GUIDE v2.5 29-May-2020 08:39:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @objects_un_group_OpeningFcn, ...
                   'gui_OutputFcn',  @objects_un_group_OutputFcn, ...
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


% --- Executes just before objects_un_group is made visible.
function objects_un_group_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to objects_un_group (see VARARGIN)

% Choose default command line output for objects_un_group
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
    % get mode (object or luminaire)
    try
        handles.mode = varargin{3};
    catch
        handles.mode = 'object';
    end
    % get room list
    rlist = get_room_list(handles.Lumos);
    % set room popupmenu
    handles.popupmenu_room.String = rlist;
    handles.popupmenu_room.Value = handles.room_nr;
    % create object name list
    list = object_list(handles.objects);
    % set object name list
    handles.listbox_objects.String = list;
    % set list item to number 1
    handles.listbox_objects.Value = 1;
    % set edit text
    set(handles.edit_group_name,'String',handles.objects{1}.name);
    % draw selected object
    %plot_object(objs, obj, h, mode,CLR)
    plot_object(handles.objects(1),[],handles.axes_object,'3D',[0.6354 0 0.6957])
catch me
    catcher(me)
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes objects_un_group wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = objects_un_group_OutputFcn(hObject, eventdata, handles) 
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


function [list,idx] = object_list(obj)
list = [];
for n = 1:length(obj)
    list = [list; {obj{n}.name}];
end
idx = 1:length(obj);




function plot_object(objs, obj, h, mode,CLR)
%cla
% check for single or multiple object(s)
if isstruct(whos('objs'))
    objs = {objs}; % make it cell
end
if ~exist('CLR','var')
    CLR = [0.6354 0 0.6957]; % violet
end

axes(h)
hold on

try
    for os = 1:size(objs,2)
        for o = 1:size(objs{os},2)
            M = eye(3);
            % check if selected
            if ismember(o,obj)
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

xof = (max(g1(:,1))-min(g1(:,1)))/2;
yof = (max(g1(:,2))-min(g1(:,2)))/2;
%zof = (max(g1(:,3))-min(g1(:,3)))/2;

C = origin;
plot3(g1(:,1)+C(1)-xof,g1(:,2)+C(2)-yof,g1(:,3)+C(3),'Color',clr)
plot3(g2(:,1)+C(1)-xof,g2(:,2)+C(2)-yof,g2(:,3)+C(3),'Color',clr)
for line = 1:size(g,1)
    plot3([g1(line,1);g2(line,1)]+C(1)-xof,...
        [g1(line,2);g2(line,2)]+C(2)-yof,...
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




% --- Executes on selection change in listbox_objects.
function listbox_objects_Callback(hObject, eventdata, handles)
% plot object(s)
nr = handles.listbox_objects.Value;
%plot_object(objs, obj, h, mode,CLR)
axes(handles.axes_object)
cla
plot_object(handles.objects(nr), [], handles.axes_object, '3D', handles.violet)
% get first object name
str = handles.objects{[nr(1)]}.name;
% update edit field
handles.edit_group_name.String = str;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function listbox_objects_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_objects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_group.
function button_group_Callback(hObject, eventdata, handles)
% get objects
objs = handles.objects;
% get selected objets
nr = handles.listbox_objects.Value;

% create new group object
newobj.type = 'group';
newobj.objects = objs(nr);
% set geometry relative to children object (function)
g = group_object_geometry(newobj);
newobj.geometry = {g};
% set coordinates and rotation
newobj.coordinates =  [0 0 0];
newobj.rotation = [0 0 0];
% set coordinates relative to parent object (function)
%newobj = group_object_coordinates(newobj);
[~,newobj] = get_sub_coordinates(newobj,'-');
% substract new object coordinates from sub-objects
%newobj = set_group_object_coord(newobj,newobj.coordinates,'-');
% set new-object name (= first sub object)
newobj.name = handles.edit_group_name.String;
% no material !
newobj.material = [];

% delete selected objects
objs(nr) = [];
% add new group object
objs{end+1} = newobj;
% update listbox
list = object_list(objs);
% update listbox
handles.listbox_objects.String = list;
% update selected item
handles.listbox_objects.Value = size(list,1);
% save new objects
handles.objects = objs;
% create object name list
list = object_list(handles.objects);
% set object name list
handles.listbox_objects.String = list;
% uodate guidata
guidata(hObject,handles)


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


function obj = ungroup_object_coordinates(obj)
for n = 1:numel(obj)
    c = obj{n}.coordinates;
    try
        for k = 1:numel(obj{n}.objects)
            obj{n}.objects{k}.coordinates = obj{n}.objects{k}.coordinates + c;
        end
    catch me
        %catcher(me)
    end
end


% --- Executes on button press in button_ungroup.
function button_ungroup_Callback(hObject, eventdata, handles)
% hObject    handle to button_ungroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
objs = handles.objects;
nr = handles.listbox_objects.Value;
%comeback('correct coordniates')
% correct object coordinates: parent -> single
objs(nr) = ungroup_object_coordinates(objs(nr));
% reorder objects
try
switch nr
    case 1
        if isequal(size(objs,2),1)
            % only one object present
            objs = objs{nr}.objects;
        else
            % more than one object present
            objs = [objs{nr}.objects objs(nr+1:end)];
        end
    case size(objs,2)
        objs = [objs(1:nr-1) objs{nr}.objects];
    otherwise
        objs = [objs(1:nr-1) objs{nr}.objects objs(nr+1:end)];
end
catch
   % no objects to ungroup 
end
% update listbox
list = object_list(objs);
% update listbox
handles.listbox_objects.String = list;
% save new objects
handles.objects = objs;
% create object name list
list = object_list(handles.objects);
% set object name list
handles.listbox_objects.String = list;
% update selected item
handles.listbox_objects.Value = nr;%size(list,1);
% update guidata
guidata(hObject,handles)
% plot current object
plot_object(handles.objects(nr),[],handles.axes_object,'3D',handles.violet)



% --- Executes during object creation, after setting all properties.
function axes_object_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_object
axis off


% --- Executes on button press in button_discard.
function button_discard_Callback(hObject, eventdata, handles)
% hObject    handle to button_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq();


% --- Executes on button press in button_apply.
function button_apply_Callback(hObject, eventdata, handles)
% get LUMOS handle
h = findall(handles.Lumos.Children,'tag','listbox');
% get LUMOS room data
r = getappdata(handles.Lumos,'room');
% change objects
switch handles.mode
    case 'object'
        r{handles.room_nr}.objects = handles.objects;
    case 'luminaire'
        r{handles.room_nr}.luminaire = handles.objects;
end
% overwerite LUMOS room data
setappdata(handles.Lumos,'room',r);
% set value of LUMOS listbox
set(h,'Value',1)
% refresh Lumos list box
update_Lumos_object(handles)
% set Lumos as active window
%figure(handles.Lumos)










function edit_group_name_Callback(hObject, eventdata, handles)
% get selected object(s)
nr = handles.listbox_objects.Value;
% set new object(s) name
for n = nr
   handles.objects{n}.name = handles.edit_group_name.String;
end
% create object name list
list = object_list(handles.objects);
% set object name list
handles.listbox_objects.String = list;
% update guidata
guidata(hObject,handles)
    
    

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


% --- Executes on selection change in popupmenu_room.
function popupmenu_room_Callback(hObject, eventdata, handles)
% room data
room = getappdata(handles.Lumos,'room');
% selected item
nr = handles.popupmenu_room.Value;
% create object name list
list = object_list(room{nr}.objects);
% set object name list
handles.listbox_objects.String = list;
% set list item to number 1
handles.listbox_objects.Value = 1;
% set edit text
set(handles.edit_group_name,'String',room{nr}.objects{1}.name);
% draw selected object
plot_object(room{nr}.objects(1),handles)
% update guidata
handles.objects = room{nr}.objects;
handles.room_nr = nr;
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function popupmenu_room_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_room (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function close_list(handles,mode)
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
    
    try
        switch mode
            case 'object'
                % list objects
                for o = 1:size(room{r}.objects,2)
                    
                    list{ind,1} = ['    ',room{r}.objects{o}.name];
                    ind = ind + 1;
                end
            case 'luminaire'
                % list luminaires
                for o = 1:size(room{r}.luminaire,2)
                    
                    list{ind,1} = ['    ',room{r}.luminaire{o}.name];
                    ind = ind + 1;
                end
        end
    catch
        
    end
end
% update listbox
set(h,'String',list)



function update_Lumos_object(handles)
% update Lumos lsitbox
close_list(handles,handles.mode)

% get Lumos handles
H = guidata(handles.Lumos);

% get listbox handle
%h = findall(handles.Lumos.Children,'tag','listbox');

m = get(H.listbox,'Value');

% get room data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');

% switch object or luminaire mode
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
        % update list, table and plots
        %nr = H.listbox.Value;
        %[~,~,list] = lum_room_nr(H, nr);
        %set(H.listbox,'String',list);
        %guidata(handles.Lumos, H)
        
        luminaire_table(handles.Lumos, [], H)
        plot_luminaire(H,[],handles.Lumos)
        
end


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



function luminaire_table(hObject,~,handles)
%comeback('observer table list')

% get table data
room = getappdata(hObject,'room');

% check if room or luminaire is selected
nr = handles.listbox.Value;
[room_nr, lum_nr, ~, type] = lum_room_nr(handles, nr, hObject);

switch type
    case 'room'
        % set table configuration
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnName',{room{handles.data.room}.name,'x','y','z','x-rot','y-rot','z-rot',})
        set(handles.topview_point_table,'ColumnEditable',[false true(1,6)])
        set(handles.topview_point_table,'ColumnFormat',{'char','char','char','char','char'})
       
        try
            for L = 1:max(size(room{handles.data.room}.luminaire))
                data{L,1} = room{handles.data.room}.luminaire{L}.name;
                data{L,2} = room{handles.data.room}.luminaire{L}.coordinates(1);
                data{L,3} = room{handles.data.room}.luminaire{L}.coordinates(2);
                data{L,4} = room{handles.data.room}.luminaire{L}.coordinates(3);
                data{L,5} = room{handles.data.room}.luminaire{L}.rotation(1);
                data{L,6} = room{handles.data.room}.luminaire{L}.rotation(2);
                data{L,7} = room{handles.data.room}.luminaire{L}.rotation(3);
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



function plot_luminaire(handles,eventdata,hObject)
room = getappdata(hObject,'room');
[room_nr, lum_nr, ~] = lum_room_nr(handles, [], hObject);
luminaire_table(hObject,eventdata,handles)
% plot luminaires and objects
axes(handles.view)
refresh_3DObjects(hObject, eventdata, handles,[],lum_nr)
try
    objs = room{handles.data.room}.luminaire;
    clr = handles.orange;
    plot_object(objs, lum_nr, handles.view, '3D',clr)
catch
end

refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
try
    objs = room{room_nr}.luminaire;
    clr = handles.orange;
    plot_object(objs, lum_nr, handles.topview, '2D',clr)
catch
end



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



function refresh_3DObjects(hObject, eventdata, handles, obj,lum,clr)

if ~exist('clr','var')
    clr = [0.6354 0 0.6957]; % violet
end
if ~exist('obj','var')
    obj = [];
end
if ~exist('lum','var')
    lum = [];
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
    objs = room{r}.objects;
    plot_object_Lumos(objs, obj, handles.view, '3D')
catch ME
    catcher(ME)
    %comeback('no objects or error')
end
% update guidata
guidata(hObject, handles)



function refresh_2D_objects(hObject, eventdata, handles, obj)
%hold on
room = getappdata(gcf,'room');
r = handles.data.room;
% get objects
try
    objs = room{r}.objects;
    if ~exist('obj','var')
        obj = [];
    end
    
    plot_object_Lumos(objs, obj, handles.topview, '2D')
catch
    cla
end
%hold off
% update guidata
guidata(hObject, handles)




function plot_object_Lumos(objs, obj, h, mode)
% check for single or multiple object(s)
if isstruct(whos('objs'))
    objs = {objs}; % make it cell 
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
            clr = [0.6354 0 0.6957]; % violet
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


% --- Executes during object creation, after setting all properties.
function button_apply_CreateFcn(hObject, eventdata, handles)
% hObject    handle to button_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
