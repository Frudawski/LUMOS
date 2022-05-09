function varargout = spec_simulation(varargin)
% SPEC_SIMULATION MATLAB code for spec_simulation.fig
%      SPEC_SIMULATION, by itself, creates a new SPEC_SIMULATION or raises the existing
%      singleton*.
%
%      H = SPEC_SIMULATION returns the handle to a new SPEC_SIMULATION or the handle to
%      the existing singleton*.
%
%      SPEC_SIMULATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPEC_SIMULATION.M with the given input arguments.
%
%      SPEC_SIMULATION('Property','Value',...) creates a new SPEC_SIMULATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spec_simulation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spec_simulation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spec_simulation

% Last Modified by GUIDE v2.5 19-Feb-2021 10:19:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @spec_simulation_OpeningFcn, ...
    'gui_OutputFcn',  @spec_simulation_OutputFcn, ...
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


% --- Executes just before spec_simulation is made visible.
function spec_simulation_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spec_simulation (see VARARGIN)

% Choose default command line output for spec_simulation
handles.output = hObject;

handles.Lumos = findall(0,'tag','SpecSimulation');
set(gca,'SortMethod','depth');

% colors
handles.darkblue   = [     0    0.2267    0.4461];
handles.blue       = [     0    0.5267    0.6461];
handles.violet     = [0.6354         0    0.6957];
handles.red        = [1.0000         0    0.2585];
handles.orange     = [0.8594    0.5153         0];
handles.green      = [0.6354    0.7859    0.5085];


% standard room height
handles.data.room_standard_height = 3.2;
% draw modus indicator
handles.data.draw = 0;

% windows & walls
handles.data.walls.vertices = [];
handles.data.walls.nr = [];
handles.data.walls.window = [];

% activate draw room tool at startup
guidata(hObject, handles)
set(handles.uitoggletool10,'State','on');
handles = guidata(hObject);
handles.selected_tool = 11;

% axis at startup
handles.axis2D = [-2 10 -2 10];
handles.axis3D = [-2 10 -2 10 0 5];

% name
handles.SpecSimulation.Name = 'LUMOS - untitled.spr';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spec_simulation wait for user response (see UIRESUME)
% uiwait(handles.SpecSimulation);



% --- Outputs from this function are returned to the command line.
function varargout = spec_simulation_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function topview_CreateFcn(hObject, ~, handles)
% hObject    handle to topview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
axis equal
axis on
hold off
grid on
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
axis([-2 10 -2 10])
%zoom(handles.Lumos,'reset');
xlabel('x')
ylabel('y')
title('top view')

% Hint: place code in OpeningFcn to populate topview
guidata(hObject, handles)



% --- Executes on button press in room_tab.
function room_tab_Callback(hObject, eventdata, handles)
% hObject    handle to room_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

table = getappdata(handles.Lumos,'table');
if ~exist('handles.data.room','var')
    handles.data.room = 1;
end
table{handles.data.room}.table_mode = 'room';
% save data
setappdata(handles.Lumos,'table',table);

handles.data.room = 1;
table{1}.table_mode = 'room';
% (de)activate  tools
toggle_menu_buttons(hObject,handles,[5:8 10:11])

R = getappdata(handles.Lumos,'room');
if size(R,1) > size(R,2)
    R = R';
end
T = getappdata(handles.Lumos,'table');
T{1}.table_mode = 'room';
% make list
for l=1:size(R,2)
    list{l,1} = R{l}.name;
end
if size(R,2) > 0
    set(handles.listbox,'Value',1)
else
    set(handles.listbox,'Value',0)
end
set(handles.topview_point_table,'Data',[])
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnName',{'x','y','z'})
set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric'})
set(handles.topview_point_table,'ColumnEditable',true(1,3))
try
    set(handles.topview_point_table,'Data',T{1}.room)
    set(handles.listbox,'String',list)
catch
    set(handles.topview_point_table,'Data',[])
    set(handles.listbox,'String',{})
end

refresh_2D(hObject, eventdata, handles)
axis([-2 10 -2 10])
try
    refresh_3D(hObject, eventdata, handles)
catch
    view_CreateFcn(hObject, eventdata, handles)
end
guidata(hObject, handles)



function topview_ButtonDownFcn(hObject, eventdata, handles)
ButtonDownFcn(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles)



function view_ButtonDownFcn(hObject, eventdata, handles)
ButtonDownFcn(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles)



function get_tool(hObject, eventdata, handles)
handles = guidata(hObject);
for i = [5:8 10:11 14]
    str = ['toggled = get(handles.uitoggletool',num2str(i),',''State'');'];
    eval(str);
    if strcmp(toggled,'on')
        handles.selected_tool = i;
    end
end
guidata(hObject, handles)



% --- Executes on mouse press over axes background.
function ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to topview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% data
e = eventdata;

% check which tool is selected in toolbar
get_tool(hObject, eventdata, handles)
handles = guidata(hObject);

% draw room
if isequal(e.Source,handles.topview) && handles.selected_tool == 10
    %axes(handles.topview)
    guidata(hObject, handles)
    draw_room_layout(hObject, eventdata, handles);
    handles = guidata(hObject);
    % select wall
elseif isequal(e.Source,handles.topview) && handles.selected_tool == 11
    % outdated
end
% update guidata
guidata(hObject, handles)



function draw_room_layout(hObject, eventdata, handles)
a = axis;
if handles.data.draw == 1
    
    h = gca;
    
    % draw
    set(handles.Lumos, 'WindowButtonMotionFcn', {@draw_room_layout_mousemove, handles});
    set(handles.Lumos, 'WindowButtonDownFcn', {@draw_room_layout, handles});
    
    % room nr
    nr = handles.data.room;
    
    % points
    C = get(h, 'CurrentPoint');
    point = C(2,:);
    
    % get table data
    table = getappdata(handles.Lumos,'table');
    % get room list
    list = get(handles.listbox,'String');
    % get room data
    %room = getappdata(handles.Lumos,'room');
    
    % table data
    t = get(handles.topview_point_table,'Data');
    t(strcmp(t,'')) = [];
    
    % add room to list
    set(handles.listbox,'String',list);
    set(handles.listbox,'Value',nr);
    handles.data.room = nr;
    guidata(hObject,handles)
    
    
    %if ~isempty(children)
    %    delete(children);
    %end
    %set(gca,'XMinorGrid','on');
    %set(gca,'YMinorGrid','on');
    
    hold on
    if isempty(t)
        % remove moving marker
        %if ~isempty(children)
        %    delete(children);
        %end
        % plot first point
        x = round(point(1,1)*10)/10;
        y = round(point(1,2)*10)/10;
        z = handles.data.room_standard_height;
        % draw first marker
        plot(x,y,'x','Color',handles.red,'UserData','move');
        % draw line
        plot([x x],[y y],'-','Color',handles.darkblue,'UserData','move');
        % get grafic objects
        try
            % move current marker
            p = findobj(h,'UserData','first','-and','LineStyle','none','-and','Marker','x');
            p.XData = x(1);
            p.YData = y(1);
        catch
        end
    else
        x = [t(:,1); round(point(1,1)*10)/10];
        y = [t(:,2); round(point(1,2)*10)/10];
        z = [t(:,3); handles.data.room_standard_height];
        % plot x for point marker
        plot(x(end,1),y(end,1),'x','Color',handles.red)
        % plot line
        plot(x(end-1:end,1),y(end-1:end,1),'-','Color',handles.darkblue)
    end
    hold off
    
    % get graphic objects
    try
        % move current marker
        p = findobj(h,'UserData','move','-and','LineStyle','none','-and','Marker','x');
        p.XData = C(2,1);
        p.YData = C(2,2);
    catch
    end
    try
        % move current wall line
        p = findobj(h,'UserData','move','-and','LineStyle','-','-and','Marker','none');
        p.XData = [x(end) C(2,1)];
        p.YData = [y(end) C(2,2)];
    catch
    end
     
    a = axis;
    b = (a(2)-a(1))/100;
    c = (a(4)-a(3))/100;
    
    % close room polygon
    if abs(C(2,1) - x(1,1)) < abs(b) && abs(C(2,2) - y(1,1)) < abs(c) && size(x,1) > 2
        x = [t(:,1); t(1,1)];
        y = [t(:,2); t(1,2)];
        z = [t(:,3); handles.data.room_standard_height];
    end
    
    % add point to table
    set(handles.topview_point_table,'Data',[x y z]);
    
    % get coordinte input
    
    % refresh 3D plot
    axes(handles.view)
    guidata(hObject,handles)
    refresh_3D(hObject, eventdata, handles)
    handles = guidata(hObject);
    axes(handles.topview)
    
    a = axis;
    b = (a(2)-a(1))/100;
    c = (a(4)-a(3))/100;
    
    % close room polygon
    if abs(C(2,1) - x(1,1)) < abs(b) && abs(C(2,2) - y(1,1)) < abs(c) && size(x,1) > 2
        
        % delete graphic objects
        grob = get(gca, 'children');
        if ~isempty(grob)
            delete(grob);
        end
        set(gca,'XMinorGrid','on');
        set(gca,'YMinorGrid','on');
        set(handles.Lumos, 'WindowButtonMotionFcn', {});
        set(handles.Lumos, 'WindowButtonDownFcn', {@topview_ButtonDownFcn, handles});
        T = get(handles.topview_point_table,'Data');
        %T = T(2:end,:);
        T = order_clockwise(T);
        set(handles.topview_point_table,'Data',T);
        % create room
        handles = guidata(hObject);
        create_room(handles, T)
        %guidata(hObject,handles)
        
        set(handles.topview_point_table,'Data',T);
        handles.x(1) = plot(T(:,1),T(:,2),'-','Color',handles.darkblue);
        
        axis equal
        hold off
        grid on
        set(gca,'XMinorGrid','on');
        set(gca,'YMinorGrid','on');
        xlabel('x')
        ylabel('y')
        title('top view')
        
        % switch to wall select tool
        set(handles.uitoggletool10,'State','off')
        set(handles.uitoggletool11,'State','on')
        
        hold off
        % save room layout appdata
        room = get(handles.topview_point_table,'Data');
        %handles.data.room = room;
        table{handles.data.room}.room = room;
        table{handles.data.room}.table_mode = 'room';
        % save room table data in appdata
        setappdata(handles.Lumos,'table',table);
        refresh_3D(hObject, eventdata, handles)
        
        handles.data.draw = 0;
    end
    
else
    % get room list and number of rooms
    list = get(handles.listbox,'String');
    if isempty(get(handles.listbox,'String'))
        nr = 1;
    else
        nr = size(get(handles.listbox,'String'),1)+1;
    end
    
    % clear datapoint table
    set(handles.topview_point_table,'Data',[]);
    
    % get table data
    %table = getappdata(handles.Lumos,'table');
    % renew list
    list{nr} = ['room ',num2str(nr)];
    handles.data.room = nr;
    
    % get room data
    room = getappdata(handles.Lumos,'room');
    % set room name
    room{nr}.name = list{nr};
    % save room name
    setappdata(handles.Lumos,'room',room)
    
    % select topview axes & delete old plots
    axes(handles.topview);
    grob = get(gca, 'children');
    if ~isempty(grob)
        delete(grob);
    end
    
    % add room to list
    set(handles.listbox,'String',list);
    set(handles.listbox,'Value',nr);
    guidata(hObject,handles)
    % set mouse button functions
    set(handles.Lumos, 'WindowButtonMotionFcn', {@x_mousemove, handles});
    handles.data.draw = 1;
    set(handles.Lumos, 'WindowButtonDownFcn', {@draw_room_layout, handles});
end
axis(a)
guidata(hObject,handles)




function create_room(handles, data)
room = getappdata(handles.Lumos,'room');

%data = unique(data,'rows','stable');
%data = [data;data(1,:)];
data = order_clockwise(data);
set(handles.topview_point_table,'Data',data)

room{handles.data.room}.walls = [];

% save room
for w = 1:size(data,1)-1
    x = [data(w,1) data(w+1,1) data(w+1,1) data(w,1) data(w,1)];
    y = [data(w,2) data(w+1,2) data(w+1,2) data(w,2) data(w,2)];
    z = [0 0 data(w+1,3) data(w,3) 0];
    
    % roomdata for setappdata
    try
        dummy = handles.data.room;
    catch
        handles.data.room = 1;
    end
    room{handles.data.room}.walls{w}.vertices = [x' y' z'];
    room{handles.data.room}.walls{w}.nr = w;
    room{handles.data.room}.walls{w}.name = ['wall ',num2str(w)];
    room{handles.data.room}.walls{w}.normal = normalv([x' y' z']);
    try
        room{handles.data.room}.walls{w}.windows = room{handles.data.room}.walls{w}.windows;
    catch
        room{handles.data.room}.walls{w}.windows = [];
    end
end


%setappdata(handles.Lumos,'room',room)
c.name = 'ceiling';
ceiling = seperate_segments(data,c);
room{handles.data.room}.ceiling = ceiling;
% floor
room{handles.data.room}.floor.nr = 1;
room{handles.data.room}.floor.name = 'floor 1';
room{handles.data.room}.floor.normal = [0 0 1];
room{handles.data.room}.floor.vertices = [data(:,1:2) zeros(size(data,1),1)];
room{handles.data.room}.enable = 1;
room{handles.data.room}.density = 5;
room{handles.data.room}.reflections = 3;
room{handles.data.room}.height = 0;
room{handles.data.room}.nord_angle = 0;
room{handles.data.room}.objects = [];
room{handles.data.room}.luminaire = [];
room{handles.data.room}.measurement = [];
room{handles.data.room}.result{1} = 0;
% save room
setappdata(handles.Lumos,'room',room)




function C = order_clockwise(T)
%  References: Computational Geometry in C by O' Rourke, Thm. 1.3.3, p. 21; [Gems II] pp. 5-6:
%  "The Area of a Simple Polygon", Jon Rokne.
X2 = T(2:end-1,1);
X1 = T(1:end-2,1);
Y2 = T(2:end-1,2);
Y1 = T(1:end-2,2);
% flip coordinates
if sum((X2-X1).*(Y2+Y1))>0
    C = T;
else
    C = flipud(T);
end




function x_mousemove(hObject, eventdata, handles)
% get mouse courser

% get axes and cursor position
h = gca;
C = get (h, 'CurrentPoint');
p = allchild(h);
% plot startpoint or move starpoint
if isempty(p)
    hold on
    plot(C(2,1),C(2,2),'rx','UserData','first')
    %([C(2,1) C(2,1)],[C(2,2) C(2,2)],'-','Color',handles.darkblue,'UserData','move')
    hold off
else
    % move current marker
    p(1).XData = C(2,1);
    p(1).YData = C(2,2);
end

% updata guidata
guidata(hObject,handles)



function draw_room_layout_mousemove(hObject, eventdata, handles)

% get mouse courser
h = gca;
C = get (h, 'CurrentPoint');
T = get(handles.topview_point_table,'Data');
T(strcmp(T,'')) = [];

% close indicator
a = axis;
b = (a(2)-a(1))/100;
c = (a(4)-a(3))/100;

try
    % move current marker
    p = findobj(h,'UserData','move','-and','LineStyle','none','-and','Marker','x');
    p.XData = C(2,1);
    p.YData = C(2,2);
catch
end
try
    % move current wall line
    p = findobj(h,'UserData','move','-and','LineStyle','-','-and','Marker','none');
    p.XData = [T(end,1) C(2,1)];
    p.YData = [T(end,2) C(2,2)];
catch
end

gr_lines = findobj(h,'LineStyle','-');
%gr_markers = findobj(h,'Marker','x')
% plot: blue = normal / red = close
if abs(C(2,1) - T(1,1)) < abs(b) && abs(C(2,2) - T(1,2)) < abs(c) % close
    %gr_markers.Color = deal(handles.red);
    set(gr_lines,'Color',handles.red);
else
    %gr_markers.Color = deal(handles.darkblue);
    set(gr_lines,'Color',handles.darkblue);
end
% axis settings


% updata guidata
guidata(hObject,handles)




% --- Executes when selected cell(s) is changed in topview_point_table.
function topview_point_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to topview_point_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% check table mode
table = getappdata(handles.Lumos,'table');
% call table dependend Callback Function
try
    if strcmp(table{handles.data.room}.table_mode,'window')
        window_table_selection_callback(hObject, eventdata, handles)
    elseif strcmp(table{handles.data.room}.table_mode,'room')
        room_table_selection_callback(hObject, eventdata, handles)
    elseif strcmp(table{handles.data.room}.table_mode,'material')
        try
            selected = eventdata.Indices;
            data = get(handles.topview_point_table,'Data');
            mat = getappdata(handles.Lumos,'material');
            mw = mat{selected(1)};
            
            %
            spec_rho = mat{selected(1)}.rho;
            rho = data{selected(1),4};
            c = whos('rho','var');
            if strcmp(c.class,'char')
                rho = str2double(rho);
            end
            factor = rho/spec_rho;
            mw.data(2,:) = mw.data(2,:).*factor;
            %
            
            axes(handles.topview)
            step = mw.data(1,2)-mw.data(1,1);
            if step <= 1
                plot(mw.data(1,:),mw.data(2,:),'Color',handles.blue)
            else
                stem(mw.data(1,:),mw.data(2,:),'Color',handles.blue,'Marker','.')
            end
            grid on
            xlabel('wavelength')
            ylabel('value')
            title('spectral properties')
            a = axis;
            b = mw.data(1,1);
            c = mw.data(1,end);
            axis([b c 0 1])
            if a(4)>1
                axis([b c 0 a(4)])
            end
            legend(['\rho = ',num2str(data{selected(1),4})]);
            %plot_material(hObject,eventdata,handles, list{s,2}, list{s,1}, list{s,3},list{s,4}, m)
        catch
        end
    elseif strcmp(table{handles.data.room}.table_mode,'objects')
        object_table_selection_callback(hObject, eventdata, handles)
    elseif strcmp(table{handles.data.room}.table_mode,'luminaire')
        luminaire_table_selection_callback(hObject, eventdata, handles)
    elseif strcmp(table{handles.data.room}.table_mode,'observer')
        try
            [handles.data.room, obs_nr, ~] = observer_room_nr(handles);
            guidata(hObject,handles)
            refresh_2D(hObject,eventdata,handles)
            refresh_2D_objects(hObject,eventdata,handles)
            plot_observer(hObject, eventdata, handles, obs_nr)
            plot_area(hObject, eventdata, handles, obs_nr)
            axes(handles.view)
            %plot_3D(hObject,eventdata,handles)
            refresh_3DObjects(hObject,eventdata,handles)
            hold on
            plot_observer(hObject, eventdata, handles, obs_nr)
            plot_area(hObject, eventdata, handles, obs_nr)
        catch
        end
    end
catch me
    catcher(me)
end
% update and save guidata
handles = guidata(hObject);
guidata(hObject, handles)



function window_table_selection_callback(hObject, eventdata, handles)

% window part selection
try
    axes(handles.topview)
    hold on
    try
        delete(handles.topview_marker_highlight);
    catch
    end
    % get slected table cell
    window = eventdata.Indices(1);
    windowpart = eventdata.Indices(2);
    % get window global data
    room = getappdata(handles.Lumos,'room');
    switch handles.data.walls.nr
        case -2
            WinData = room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.data;
        case -1
            WinData = room{handles.data.room}.floor.windows{window}.data;
        otherwise
            WinData = room{handles.data.room}.walls{handles.data.walls.nr}.windows{window}.data;
    end
    x1 = WinData(1,1);
    x2 = WinData(3,1);
    y1 = WinData(1,2);
    y2 = WinData(3,2);
    z1 = WinData(1,3);
    z2 = WinData(3,3);
    % 4 edges of window
    switch handles.data.walls.nr
        case -2
            normal = room{handles.data.room}.ceiling{handles.data.ceiling}.normal;
            if normal(1) == 0 && normal(2)>0
            switch windowpart
                case 1
                    handles.topview_marker_highlight = plot3([x1 x1],[y1 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                case 2
                    handles.topview_marker_highlight = plot3([x2 x2],[y1 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                case 3
                    handles.topview_marker_highlight = plot3([x1 x2],[y1 y1],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                case 4
                    handles.topview_marker_highlight = plot3([x1 x2],[y2 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                otherwise
            end
            elseif normal(1) == 0 && normal(2)<0
            switch windowpart
                case 1
                    handles.topview_marker_highlight = plot3([x1 x1],[y1 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                case 2
                    handles.topview_marker_highlight = plot3([x2 x2],[y1 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                case 3
                    handles.topview_marker_highlight = plot3([x1 x2],[y1 y1],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                case 4
                    handles.topview_marker_highlight = plot3([x1 x2],[y2 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                otherwise
            end
            elseif normal(2) == 0 && normal(1)<0
                switch windowpart
                    case 1
                        handles.topview_marker_highlight = plot3([x1 x1],[y1 y2],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                    case 2
                        handles.topview_marker_highlight = plot3([x2 x2],[y1 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                    case 3
                        handles.topview_marker_highlight = plot3([x1 x2],[y1 y1],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                    case 4
                        handles.topview_marker_highlight = plot3([x1 x2],[y2 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                    otherwise
                end
            elseif normal(2) == 0 && normal(1)>0
                switch windowpart
                    case 1
                        handles.topview_marker_highlight = plot3([x1 x1],[y1 y2],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                    case 2
                        handles.topview_marker_highlight = plot3([x2 x2],[y1 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                    case 3
                        handles.topview_marker_highlight = plot3([x1 x2],[y1 y1],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                    case 4
                        handles.topview_marker_highlight = plot3([x1 x2],[y2 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                    otherwise
                end
            else
                switch windowpart
                    case 1
                        handles.topview_marker_highlight = plot3([x1 x1],[y1 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                    case 2
                        handles.topview_marker_highlight = plot3([x2 x2],[y1 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                    case 3
                        handles.topview_marker_highlight = plot3([x1 x2],[y1 y1],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                    case 4
                        handles.topview_marker_highlight = plot3([x1 x2],[y2 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                    otherwise
                end
            end
        case -1
            switch windowpart
                case 1
                    handles.topview_marker_highlight = plot3([x1 x1],[y1 y2],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                case 2
                    handles.topview_marker_highlight = plot3([x2 x2],[y1 y2],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                case 3
                    handles.topview_marker_highlight = plot3([x1 x2],[y1 y1],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                case 4
                    handles.topview_marker_highlight = plot3([x1 x2],[y2 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                otherwise
            end
        otherwise
            switch windowpart
                case 1
                    handles.topview_marker_highlight = plot3([x1 x1],[y2 y2],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                case 2
                    handles.topview_marker_highlight = plot3([x2 x2],[y1 y1],[z1 z2],'-','Color',handles.red,'Linewidth',2);
                case 3
                    handles.topview_marker_highlight = plot3([x1 x2],[y1 y2],[z1 z1],'-','Color',handles.red,'Linewidth',2);
                case 4
                    handles.topview_marker_highlight = plot3([x1 x2],[y1 y2],[z2 z2],'-','Color',handles.red,'Linewidth',2);
                otherwise
            end
    end
    
catch me
    catcher(me)
end

% update guidata
guidata(hObject, handles)


function room_table_selection_callback(hObject, eventdata, handles)
% topview selected point marker
try
    table = getappdata(handles.Lumos,'table');
    axes(handles.topview)
    refresh_2D(hObject, eventdata, handles)
    hold on
    try
        delete(handles.topview_marker_highlight);
    catch
    end
    point = eventdata.Indices(1);
    data = table{handles.data.room}.room;
    handles.topview_marker_highlight = plot([data(point,1) data(point,1)],[data(point,2) data(point,2)],'-o','Color',handles.red);
    
catch
end

% 3D view selected point marker
try
    axes(handles.view)
    hold on
    try
        delete(handles.view_marker_highlight);
    catch
    end
    point = eventdata.Indices(1);
    data = get(handles.topview_point_table,'Data');
    handles.view_marker_highlight = plot3([data(point,1) data(point,1)],[data(point,2) data(point,2)],[data(point,3) 0],'-o','Color',handles.red);
catch
end
guidata(hObject,handles)



function luminaire_table_selection_callback(hObject, eventdata, handles)
% get room data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');
% get listbox data
nr = handles.listbox.Value;
[room_nr, ~, ~, type] = lum_room_nr(handles, nr);

lum_nr = handles.listbox.Value;

% check cases: room or luminaire selected
switch type
    case 'room'
        % plot objects and luminaires 3D
        axes(handles.view)
        refresh_3DObjects(hObject, eventdata, handles,[])
        clr = handles.orange;
        try
            objs = room{room_nr}.luminaire;
            plot_object(objs, lum_nr, handles.view, '3D',clr)
        catch
        end

        % plot objects and luminaires 2D
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            plot_object(objs, lum_nr, handles.topview, '2D',clr)
        catch
        end
    case 'luminaire'
        ldt = getappdata(handles.Lumos,'ldt');
        spectra = getappdata(handles.Lumos,'spectra');
        if ~isempty(eventdata.Indices)
            switch eventdata.Indices(2)
                case 1
                    % plot ldc
                    data = get(handles.topview_point_table,'Data');
                    factor = data{eventdata.Indices(1),5};
                    ldc = ldt{eventdata.Indices(1)};
                    if isa(factor,'double')
                        ldc.I = ldc.I.*factor;
                    elseif ischar(factor)
                        ldc.I = ldc.I.*str2double(factor);
                    elseif isa(factor,'string')
                        ldc.I = ldc.I.*str2double(factor);
                    end
                    % hack around polarplot deleting axes handle
                    h = figure('Visible','off');
                    h.Position = handles.topview.Position;
                    plot2dldt(ldc);
                    set(h,'Position', [10 10 520 520]);
                    set(h,'PaperUnits','inches','PaperPosition',[0 0 10 10],'Papersize',[10 10])
                    im = getframe(h);
                    im = im.cdata;
                    close(h)
                    axes(handles.topview)
                    imshow(im)
                case 3
                    % plot spectrum
                    axes(handles.topview)
                    plotspec(spectra{eventdata.Indices(1)}.data(1,:),spectra{eventdata.Indices(1)}.data(2,:)./max(spectra{eventdata.Indices(1)}.data(2,:)));
                    %comeback('check factor for spec')
                    ylabel('relative spectral power distribution')
            end
        end
end




function object_table_selection_callback(hObject, eventdata, handles)

% get room data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');


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
    % object
    
    % object part
end

% room case
item = get(handles.listbox,'Value');

if isempty(list{item,2})
    
    try
        room = getappdata(handles.Lumos,'room');
        axes(handles.topview)
        refresh_2D(hObject, eventdata, handles)
        hold on
        refresh_2D_objects(hObject, eventdata, handles)
        try
            delete(handles.topview_marker_highlight);
        catch
        end
        %point = eventdata.Indices(1);
        obj = room{handles.data.room}.objects{eventdata.Indices(1)};
        p = eventdata.Indices(1);
        data = get_object_data(obj,1);
        if eventdata.Indices(2) >= 1 && eventdata.Indices(2) <= 3
            hold on
            handles.topview_marker_highlight = plot([data(1) data(1)],[data(2) data(2)],'-o','Color',handles.red);
        elseif eventdata.Indices(2) == 4
            hold on
            handles.topview_marker_highlight = plot([data(1) data(1)+1],[data(2) data(2)],'->','Color',handles.red);
        elseif eventdata.Indices(2) == 5
            hold on
            handles.topview_marker_highlight = plot([data(1) data(1)],[data(2) data(2)+1],'-^','Color',handles.red);
        elseif eventdata.Indices(2) == 6
            hold on
            handles.topview_marker_highlight = plot(data(1),data(2),'-x','Color',handles.red);
        end
        
    catch
    end
    
    % 3D view selected point marker
    try
        axes(handles.view)
        hold on
        try
            delete(handles.view_marker_highlight);
        catch
        end
        obj = room{handles.data.room}.objects{eventdata.Indices(1)};
        p = eventdata.Indices(1);
        data = get_object_data(obj,1);
        if eventdata.Indices(2) >= 1 && eventdata.Indices(2) <= 3
            hold on
            handles.view_marker_highlight = plot3([data(1) data(1)],[data(2) data(2)],[data(3) data(3)],'-o','Color',handles.red);
        elseif eventdata.Indices(2) == 4
            hold on
            handles.topview_marker_highlight = plot3([data(1) data(1)+1],[data(2) data(2)],[data(3) data(3)],'-*','Color',handles.red);
        elseif eventdata.Indices(2) == 5
            hold on
            handles.topview_marker_highlight = plot3([data(1) data(1)],[data(2) data(2)+1],[data(3) data(3)],'-*','Color',handles.red);
        elseif eventdata.Indices(2) == 6
            hold on
            handles.topview_marker_highlight = plot3([data(1) data(1)],[data(2) data(2)],[data(3) data(3)+1],'-*','Color',handles.red);
        end
    catch
    end
    guidata(hObject,handles)
    
    
    % object case
else
    % room and object number
    r = list{item,1};
    obj_nr = list{item,2};
    % object
    obj = room{handles.data.room}.objects{obj_nr};
    % check for single or group object
    if strcmp(obj.type,'group')
        try
            p = eventdata.Indices(1);
        catch
            return
        end
        [data,objs,~,before] = get_object_data(obj,p);
        p = p-before;
        objs.coordinates = data(:,1:3)+obj.coordinates;
        g = objs.geometry{1};
        g = [g;g(1,:)];
        offset = max(g)/2;
        g(:,1:2) = g(:,1:2)-offset(:,1:2);
    
        c = objs.coordinates;
        M = deg2rad(objs.rotation);
        T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
        g1 = g(:,1:3)*T(1:3,1:3);
        g2 = g(:,[1 2 4])*T(1:3,1:3);
        
    elseif strcmp(obj.type,'single')
        % object coordinates and rotation
        data(:,1:3) = obj.coordinates;
        data(:,4:6) = obj.rotation;
        % object point selected
        objs = room{r}.objects{obj_nr};
        g = objs.geometry{1};
        g = [g;g(1,:)];
        offset = max(g)/2;
        g(:,1:2) = g(:,1:2)-offset(:,1:2);
        
        c = objs.coordinates;
        M = deg2rad(objs.rotation);
        T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
        g1 = g(:,1:3)*T(1:3,1:3);
        g2 = g(:,[1 2 4])*T(1:3,1:3);
        try
            p = eventdata.Indices(1);
        catch
            return
        end
    end
    
    
    % 3D point highlight
    axes(handles.view)
    hold on
    try
        delete(handles.view_marker_highlight);
    catch
    end
    hold on
    handles.view_marker_highlight(1) = plot3([g1(p,1) g2(p,1)]+c(1),[g1(p,2) g2(p,2)]+c(2),[g1(p,3) g2(p,3)]+c(3),'Color',handles.red,'Linewidth',2);
    handles.view_marker_highlight(2) = plot3([g1(p,1) g1(p,1)]+c(1),[g1(p,2) g1(p,2)]+c(2),[g1(p,3) g1(p,3)]+c(3),'Color',handles.red,'Marker','o');
    handles.view_marker_highlight(3) = plot3([g2(p,1) g2(p,1)]+c(1),[g2(p,2) g2(p,2)]+c(2),[g2(p,3) g2(p,3)]+c(3),'Color',handles.red,'Marker','o');
    
    hold off
    
    % 2D point highlight
    axes(handles.topview)
    hold on
    try
        delete(handles.marker_highlight);
    catch
    end
    hold on
    
    handles.marker_highlight(2) = plot([g1(p,1) g1(p,1)]+c(1),[g1(p,2) g1(p,2)]+c(2),'Color',handles.red,'Marker','o');
    hold off
    
end
% end of function
guidata(hObject,handles)



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



% --- Executes when entered data in editable cell(s) in topview_point_table.
function topview_point_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to topview_point_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

table = getappdata(handles.Lumos,'table');
%setappdata(handles.Lumos,'result',[]);

% call table dependend Callback Function
if strcmp(table{handles.data.room}.table_mode,'window')
    window_table_edit(hObject, eventdata, handles)
elseif strcmp(table{handles.data.room}.table_mode,'room')
    room_table_edit(hObject, eventdata, handles)
elseif strcmp(table{handles.data.room}.table_mode,'material')
    material_table_edit(hObject, eventdata, handles)
elseif strcmp(table{handles.data.room}.table_mode,'simulation')
    simulation_table_edit(hObject, eventdata, handles)
elseif strcmp(table{handles.data.room}.table_mode,'observer')
    observer_table_edit(hObject, eventdata, handles)
elseif strcmp(table{handles.data.room}.table_mode,'objects')
    objects_table_edit(hObject, eventdata, handles)
elseif strcmp(table{handles.data.room}.table_mode,'luminaire')
    luminaire_table_edit(hObject, eventdata, handles)
    plot_luminaire(handles,eventdata,hObject)
end

% update and save guidata
handles = guidata(hObject);
guidata(hObject, handles)


function simulation_table_edit(hObject, eventdata, handles)

clnformat = {'numeric','numeric','numeric','numeric','numeric'};
set(handles.topview_point_table,'ColumnFormat',clnformat)

room = getappdata(handles.Lumos,'room');
%sky = getappdata(handles.Lumos,'sky');
data = get(handles.topview_point_table,'Data');

% room edit

r = eventdata.Indices(1);
c = eventdata.Indices(2);

switch c
    case 1
        room{r}.density = data{r,c};
        room{r}.result = [];
    case 2
        room{r}.reflections = data{r,c};
        room{r}.result = [];
    case 3
        room{r}.nord_angle = data{r,c};
        room{r}.result = [];
    case 4
        room{r}.height = data{r,c};
        room{r}.result = [];
    case 5
        room{r}.enable = data{r,c};
    otherwise
end


% update simulation listbox
guidata(hObject, handles)
simulation_listbox(hObject, eventdata, handles)
handles = guidata(hObject);

% save room data
setappdata(handles.Lumos,'room',room');
guidata(hObject, handles)
simulation_table(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles)



function material_table_edit(hObject, eventdata, handles)

selected = eventdata.Indices;
data = get(handles.topview_point_table,'Data');

for i = 1:size(data,1)
    if i == selected(1) && data{i,2} == true
        data{i,2} = true;
    else
        data{i,2} = false;
    end
end
% check selected / unselected
c = 0;

for  i = 1:size(data,1)
    c = c+data{i,2};
end
set(handles.topview_point_table,'Data',data)

% get data
mat = getappdata(handles.Lumos,'material');
room = getappdata(handles.Lumos,'room');

ind = 1;
% create room -> wall -> window list
for r = 1:size(room,2)
    % room
    list{ind,1} = -3;
    list{ind,2} = r;
    list{ind,3} = 0;
    list{ind,4} = 0;
    ind = ind+1;
    % environment ground
    list{ind,1} = -4;
    list{ind,2} = r;
    list{ind,3} = 0;
    list{ind,4} = 0;
    ind = ind + 1;
    % floor
    list{ind,1} = -1;%'    floor';
    list{ind,2} = r;
    list{ind,3} = 0;
    list{ind,4} = 0;
    ind = ind + 1;
    try
        for win = 1:size(room{r}.floor.windows,2)
            list{ind,1} = -1;%['        window ',num2str(win)];
            list{ind,2} = r;
            list{ind,3} = win;
            list{ind,4} = 0;
            ind = ind + 1;
        end
    catch
    end
    for w = 1:size(room{r}.walls,2)
        list{ind,1} = w;%['    wall ',num2str(w)];
        list{ind,2} = r;
        list{ind,3} = 0;
        list{ind,4} = 0;
        ind = ind + 1;
        try
            for win = 1:size(room{r}.walls{w}.windows,2)
                list{ind,1} = w;%['        window ',num2str(win)];
                list{ind,2} = r;
                list{ind,3} = win;
                list{ind,4} = 0;
                ind = ind + 1;
            end
        catch
        end
    end
    for c = 1:size(room{r}.ceiling,2)
        list{ind,1} = -2;%'    ceiling';
        list{ind,2} = r;
        list{ind,3} = 0;
        list{ind,4} = c;
        ind = ind + 1;
        try
            for win = 1:size(room{r}.ceiling{c}.windows,2)
                list{ind,1} = -2;%['        window ',num2str(win)];
                list{ind,2} = r;
                list{ind,3} = win;
                list{ind,4} = c;
                ind = ind + 1;
            end
        catch
        end
    end
    % objects
    for o = 1:size(room{r}.objects,2)
        list{ind,1} = -5;
        list{ind,2} = r;
        list{ind,3} = o;
        list{ind,4} = 0;
        ind = ind + 1;
    end
end

s = get(handles.listbox,'Value');

% one or more material(s) in list?
try
    data = mat{selected(1)}.data;
    name = mat{selected(1)}.name{:};
    rho  = mat{selected(1)}.rho;
catch
    data = mat{1}.data;
    name = mat{1}.name{:};
    rho  = mat{1}.rho;
end
if c == 0
    data = [];
    name = 'none';
end

% de/acitvate
if selected(2) == 2
    if ~handles.topview_point_table.Data{selected(1),selected(2)}
        data = [];
        name = 'none';
        rho = [];
    else
        rho = ciespec2Y(data(1,:),data(2,:).*ciespec(data(1,:),'A'))/ciespec2Y(data(1,:),ciespec(data(1,:),'A'));
    end
end

% rho
if selected(2) == 4
    % adjust material to rho value
    if isempty(data)
        data = mat{selected(1)}.data;
    end
    T = handles.topview_point_table.Data;
    %comeback('SET RHO')
    %spec_rho = ciespec2Y(data(1,:),data(2,:),1)/100;
    %spec_rho = mean(data(2,:));
    spec_rho = ciespec2Y(data(1,:),data(2,:).*ciespec(data(1,:),'A'))/ciespec2Y(data(1,:),ciespec(data(1,:),'A'));
    
    rho = T{selected(1),4};
    c = whos('rho','var');
    if strcmp(c.class,'char')
        rho = str2double(rho);
    end
    factor = rho/spec_rho;
    data(2,:) = data(2,:).*factor;

    % selected material
    nr = selected(1);
    % update rho
    mat{nr}.rho = rho;
    % update spectral data
    mat{nr}.data = data;
    % update color and cellfield html text (contains color)
    rhoD65 = ciespec2Y(data(1,:),data(2,:).*ciespec(data(1,:),'D65'))/ciespec2Y(data(1,:),ciespec(data(1,:),'D65'));
    srgb = spec2srgb(mat{nr}.data(1,:),mat{nr}.data(2,:).*ciespec(mat{nr}.data(1,:),'D65'),'obj','D65');
    srgb = (srgb./max(srgb).*rhoD65).^(1/2.2);
    mat{nr}.color = srgb;
    if(sum(mat{nr}.color))< 1
        mat{nr}.cellfield = ['<html><table bgcolor=rgb(',num2str(round(255.*mat{nr}.color(1))),',',num2str(round(255.*mat{nr}.color(2))),',',num2str(round(255.*mat{nr}.color(3))),')><TR><TD><font color="#FFFFFF">',mat{nr}.name{1},'</TD></TR> </table>'];
    else
        mat{nr}.cellfield = ['<html><table bgcolor=rgb(',num2str(round(255.*mat{nr}.color(1))),',',num2str(round(255.*mat{nr}.color(2))),',',num2str(round(255.*mat{nr}.color(3))),')><TR><TD>',mat{nr}.name{1},'</TD></TR> </table>'];
    end
    setappdata(handles.Lumos,'material',mat);
end

    
%  assign material
r = list{s,2};
w = list{s,1};
win = list{s,3};
c = list{s,4};
% no window
if win == 0
    % floor
    if list{s,1} == -1
        room{r}.floor.material.name = name;
        room{r}.floor.material.data = data;
        room{r}.floor.material.rho = rho;
        % environment ground
    elseif list{s,1} == -4
        room{r}.environment_ground.material.name = name;
        room{r}.environment_ground.material.data = data;
        room{r}.environment_ground.material.rho = rho;
        % ceiling
    elseif list{s,1} == -2%size(room{r}.walls,2)+1
        for c = 1:size(room{r}.ceiling,2)
            room{r}.ceiling{c}.material.name = name;
            room{r}.ceiling{c}.material.data = data;
            room{r}.ceiling{c}.material.rho = rho;
        end
        % certain wall
    elseif list{s,1} > 0 && list{s,1} <= size(room{r}.walls,2)
        room{r}.walls{w}.material.name = name;
        room{r}.walls{w}.material.data = data;
        room{r}.walls{w}.material.rho = rho;
        % whole room
    elseif list{s,1} == -3
        room{r}.floor.material.name = name;
        room{r}.floor.material.data = data;
        room{r}.floor.material.rho = rho;
        for c = 1:size(room{r}.ceiling,2)
            room{r}.ceiling{c}.material.name = name;
            room{r}.ceiling{c}.material.data = data;
            room{r}.ceiling{c}.material.rho = rho;
        end
        % wall loop
        for wall = 1:size(room{r}.walls,2)
            room{r}.walls{wall}.material.name = name;
            room{r}.walls{wall}.material.data = data;
            room{r}.walls{wall}.material.rho = rho;
        end
    end
    % window
else
    % object case
    if isequal(w,-5)
        room{r}.objects{win}.material.name = name;
        room{r}.objects{win}.material.data = data;
        room{r}.objects{win}.material.rho = rho;
    else % none object case
        switch w
            case -2
                room{r}.ceiling{c}.windows{win}.material.name = name;
                room{r}.ceiling{c}.windows{win}.material.data = data;
                room{r}.ceiling{c}.windows{win}.material.rho = rho;
                %room{r}.objects{win}.material.glazing = handles.topview_point_table.Data{selcted(1),5};
            case -1
                room{r}.floor.windows{win}.material.name = name;
                room{r}.floor.windows{win}.material.data = data;
                room{r}.floor.windows{win}.material.rho = rho;
            otherwise
                room{r}.walls{w}.windows{win}.material.name = name;
                room{r}.walls{w}.windows{win}.material.data = data;
                room{r}.walls{w}.windows{win}.material.rho = rho;
        end
    end
end
setappdata(handles.Lumos,'room',room);
guidata(hObject, handles)
material_listbox(hObject,eventdata,handles)
material_table(hObject,eventdata,handles,[])
if ~isempty(rho)
    handles.topview_point_table.Data{selected(1),4} = rho;
end
handles = guidata(hObject);

m.data = data;
plot_material(hObject,eventdata,handles, list{s,2}, list{s,1}, list{s,3},list{s,4}, m)




function window_table_edit(hObject, eventdata, handles)

% delete highlight marker
try
    delete(handles.topview_marker_highlight);
catch
end

window = eventdata.Indices(1);
windowpart = eventdata.Indices(2);
% load appdata
table = getappdata(handles.Lumos,'table');
room  = getappdata(handles.Lumos, 'room');
% get changed entry in table
new = get(handles.topview_point_table,'Data');

% get wall number
wall = handles.data.walls.nr;
% get plotted window handle

switch wall
    case -2
        h = room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.handle;
        delete(h)
        h = room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.handle3D;
        delete(h)
        
        %data = room{handles.data.room}.ceiling{handles.data.ceiling}.vertices;
        windata = room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.data;
        
        %comeback('window changing...')
        old = eventdata.PreviousData;
        olddata = new;
        olddata(window,windowpart) = old;
        newwindata = windata;
        normal = room{handles.data.room}.ceiling{handles.data.ceiling}.normal;
        switch windowpart
            case 1
                if normal(2) == 0 && normal(1) > 0
                    newwindata([1 2 5],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                    newwindata([1 2 5],3) = interp1([olddata(window,1) olddata(window,2)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                elseif normal(2) == 0 && normal(1) < 0
                    newwindata([1 2 5],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                    newwindata([1 2 5],3) = interp1([olddata(window,1) olddata(window,2)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                elseif normal(1) == 0 && normal(2) > 0
                    newwindata([1 4 5],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                elseif normal(1) == 0 && normal(2) < 0
                    newwindata([1 4 5],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                else
                    %newwindata([1 4 5],1) = new(window,windowpart);
                    newwindata([1 4 5],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                end
            case 2
                if normal(2) == 0 && normal(1) > 0
                    newwindata([3 4],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                    newwindata([3 4],3) = interp1([olddata(window,1) olddata(window,2)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                elseif normal(2) == 0 && normal(1) < 0
                    newwindata([3 4],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                    newwindata([3 4],3) = interp1([olddata(window,1) olddata(window,2)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                elseif normal(1) == 0 && normal(2) > 0
                    newwindata([2 3],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                elseif normal(1) == 0 && normal(2) < 0
                    newwindata([2 3],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                else
                    %newwindata([3 4],2) = new(window,windowpart);
                    newwindata([2 3],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');
                end
            case 3
                if normal(2) == 0 && normal(1) > 0
                    newwindata([1 4 5],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
                elseif normal(2) == 0 && normal(1) < 0
                    newwindata([1 4 5],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
                elseif normal(1) == 0 && normal(2) > 0
                    newwindata([1 2 5],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');
                    newwindata([1 2 5],3) = interp1([olddata(window,3) olddata(window,4)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                elseif normal(1) == 0 && normal(2) < 0
                    newwindata([1 2 5],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');
                    newwindata([1 2 5],3) = interp1([olddata(window,3) olddata(window,4)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                else
                    %newwindata([1 2 5],2) = new(window,windowpart);
                    newwindata([1 2 5],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  

                end
            case 4
                if normal(2) == 0 && normal(1) > 0
                    newwindata([2 3],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
                elseif normal(2) == 0 && normal(1) < 0
                    newwindata([2 3],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
                elseif normal(1) == 0 && normal(2) > 0
                    newwindata([3 4],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');
                    newwindata([3 4],3) = interp1([olddata(window,3) olddata(window,4)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                elseif normal(1) == 0 && normal(2) < 0
                    newwindata([3 4],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');
                    newwindata([3 4],3) = interp1([olddata(window,3) olddata(window,4)],[windata(1,3) windata(3,3)],eventdata.NewData,'linear','extrap');
                else
                    %newwindata([3 4],2) = new(window,windowpart);
                    newwindata([3 4],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
                end
        end
        x = newwindata(:,1)';
        y = newwindata(:,2)';
        z = newwindata(:,3)';
        
    case -1
        h = room{handles.data.room}.floor.windows{window}.handle;
        delete(h)
        h = room{handles.data.room}.floor.windows{window}.handle3D;
        delete(h)

        windata = room{handles.data.room}.floor.windows{window}.data;
        old = eventdata.PreviousData;
        olddata = new;
        olddata(window,windowpart) = old;
        newwindata = windata;
        switch windowpart
            case 1
                newwindata([1 4 5],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');                  
            case 2
                newwindata([2 3],1) = interp1([olddata(window,1) olddata(window,2)],[windata(1,1) windata(3,1)],eventdata.NewData,'linear','extrap');                  
            case 3
                newwindata([1 2 5],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
            case 4
                newwindata([3 4],2) = interp1([olddata(window,3) olddata(window,4)],[windata(1,2) windata(3,2)],eventdata.NewData,'linear','extrap');                  
        end
        x = newwindata(:,1)';
        y = newwindata(:,2)';
        z = newwindata(:,3)';

    otherwise
        h = room{handles.data.room}.walls{wall}.windows{window}.handle;
        delete(h)
        h = room{handles.data.room}.walls{wall}.windows{window}.handle3D;
        delete(h)
        % get global room coordinates
        xw1 = room{handles.data.room}.walls{wall}.vertices(1,1);
        xw2 = room{handles.data.room}.walls{wall}.vertices(2,1);
        yw1 = room{handles.data.room}.walls{wall}.vertices(1,2);
        yw2 = room{handles.data.room}.walls{wall}.vertices(2,2);
        % wall x,y vector
        WallVector = [xw2-xw1 yw2-yw1];
        
        data = room{handles.data.room}.walls{wall}.vertices;
        windata = room{handles.data.room}.walls{wall}.windows{window}.data;
        
        % calculate global window coordinates
        if handles.data.normal_direction == 1
            r = sqrt((xw2-xw1)^2+(yw2-yw1)^2);
            xwin1 = xw1+new(window,1)/r*WallVector(1);
            xwin2 = xw1+new(window,2)/r*WallVector(1);
            ywin1 = yw1+new(window,1)/r*WallVector(2);
            ywin2 = yw1+new(window,2)/r*WallVector(2);
        else
            r = sqrt((xw1-xw2)^2+(yw1-yw2)^2);
            xwin1 = xw2-new(window,1)/r*WallVector(1);
            xwin2 = xw2-new(window,2)/r*WallVector(1);
            ywin1 = yw2-new(window,1)/r*WallVector(2);
            ywin2 = yw2-new(window,2)/r*WallVector(2);
        end
        x = [xwin1 xwin2 xwin2 xwin1 xwin1];
        y = [ywin1 ywin2 ywin2 ywin1 ywin1];
        z = [new(window,3) new(window,3) new(window,4) new(window,4) new(window,3)];
end

% plot changed window
axes(handles.topview)
WindowHandle = fill3(x,y,z,handles.blue);
axes(handles.view)
window3D = fill3(x,y,z,handles.blue);


% save patch coordinates of window
switch wall
    case -2
        room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.data = [x' y' z'];
        % save window handles
        room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.handle = WindowHandle;
        room{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.handle3D = window3D;
        setappdata(handles.Lumos,'room',room);
        table{handles.data.room}.ceiling{handles.data.ceiling}.windows{:} = [new];
        setappdata(handles.Lumos,'table',table);
    case -1
        room{handles.data.room}.floor.windows{window}.data = [x' y' z'];
        % save window handles
        room{handles.data.room}.floor.windows{window}.handle = WindowHandle;
        room{handles.data.room}.floor.windows{window}.handle3D = window3D;
        % updata appdata
        setappdata(handles.Lumos,'room',room);
        table{handles.data.room}.floor.windows{:} = [new];
        setappdata(handles.Lumos,'table',table);
    otherwise
        room{handles.data.room}.walls{wall}.windows{window}.data = [x' y' z'];
        % save window handles
        room{handles.data.room}.walls{wall}.windows{window}.handle = WindowHandle;
        room{handles.data.room}.walls{wall}.windows{window}.handle3D = window3D;
        % updata appdata
        setappdata(handles.Lumos,'room',room);
        table{handles.data.room}.wall{wall}.windows{:} = [new];
        setappdata(handles.Lumos,'table',table);
end

%handles = guidata(hObject);
guidata(hObject, handles)


function room_table_edit(hObject, eventdata, handles)

% active point
point = eventdata.Indices(1);

% select topview axes & delete old plots
axes(handles.topview);
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
% get table data
data = get(handles.topview_point_table,'Data');
% if first or last point is edited change the other as well
if point == 1
    data(end,:) = data(1,:);
    set(handles.topview_point_table,'Data',data);
end
if point == size(data,1)
    data(1,:) = data(end,:);
    set(handles.topview_point_table,'Data',data);
end

% plot new room layout
plot(data(:,1),data(:,2),'-','Color',handles.darkblue);
% active point marker
handles.topview_marker_highlight = plot3([data(point,1) data(point,1)],[data(point,2) data(point,2)],[0 data(point,3)],'-o','Color',handles.red);

% select 3D view axes & delete old plots
axes(handles.view);
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');

handles = guidata(hObject);
create_room(handles, data);
room = getappdata(handles.Lumos,'room');
handles = guidata(hObject);


% 3D view selected point marker
try
    axes(handles.view)
    hold on
    try
        delete(handles.view_marker_highlight);
    catch
    end
    point = eventdata.Indices(1);
    data = get(handles.topview_point_table,'Data');
    handles.view_marker_highlight = plot3([data(point,1) data(point,1)],[data(point,2) data(point,2)],[data(point,3) 0],'-o','Color',hanldes.red);
catch
end

% remove old windows
%room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');
table{handles.data.room}.room = [];
if point > 1
    room{handles.data.room}.walls{point-1}.windows    = [];
    table{handles.data.room}.wall{point-1}.windows{1} = [];
    room{handles.data.room}.walls{point}.windows    = [];
    table{handles.data.room}.wall{point}.windows{1} = [];
elseif point == 1
    room{handles.data.room}.walls{point}.windows    = [];
    table{handles.data.room}.wall{point}.windows{1} = [];
    room{handles.data.room}.walls{end}.windows    = [];
    table{handles.data.room}.wall{end}.windows{1} = [];
end
table{handles.data.room}.room = get(handles.topview_point_table,'Data');
guidata(hObject, handles)

point = eventdata.Indices(1);
data = get(handles.topview_point_table,'Data');
handles.topview_marker_highlight = plot([data(point,1) data(point,1)],[data(point,2) data(point,2)],'-o','Color',handles.red);
axes(handles.topview)

handles = guidata(hObject);
guidata(hObject, handles)
% updata appdata
setappdata(handles.Lumos,'table',table);
setappdata(handles.Lumos,'room',room);
refresh_2D(hObject, eventdata, handles)
refresh_3D(hObject, eventdata, handles)



function refresh_3D(hObject, eventdata, handles)
% turn warning fr delaunay of
id = 'MATLAB:delaunay:DupPtsDelaunayWarnId';
warning('off',id)

axes(handles.view)
cla
reset(handles.view)
colorbar('off')
legend('off')

% get room data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');
handles.data.walls = [];

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
room = getappdata(handles.Lumos,'room');

% plot walls
for w = 1:size(data,1)-1
    x = [data(w,1) data(w+1,1) data(w+1,1) data(w,1) data(w,1)];
    y = [data(w,2) data(w+1,2) data(w+1,2) data(w,2) data(w,2)];
    z = [0 0 data(w+1,3) data(w,3) 0];
    p = fill3(x,y,z,[0.75 0.75 0.75]);
    
    % define wall specific properties - will be given to ButtonDownFcn
    handles.data.walls.window = [];
    handles.data.walls.vertices = p.Vertices;
    handles.data.walls.nr = w;
    set(p,'HitTest','on','PickableParts','all','ButtonDownFcn',{@select_wall, handles, w,[]})
    % roomdata for setappdata
    try
        dummy = handles.data.room;
    catch
        handles.data.room = 1;
    end
    room{handles.data.room}.walls{w}.vertices = p.Vertices;
    room{handles.data.room}.walls{w}.nr = w;
    handles.data.ceiling = [];
    room{handles.data.room}.walls{w}.name = ['wall ',num2str(w)];
    % plot windows from saved data
    try
        for j = 1:size(room{handles.data.room}.walls{w}.windows,2)
            wi = room{handles.data.room}.walls{w}.windows{j}.data;
            f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.blue);
            set(f,'HitTest','on','PickableParts','none');%,'ButtonDownFcn',{@select_wall, handles})
            room{handles.data.room}.walls{w}.windows{j}.data = [wi(:,1) wi(:,2) wi(:,3)];
            % window handles
            room{handles.data.room}.walls{w}.windows{j}.handle3D = f;
        end
        % save updated room data
        setappdata(handles.Lumos,'room',room);
    catch me
        %catcher(me)
    end
    
end

try
    % plot ceiling
    for c = 1:numel(room{handles.data.room}.ceiling)
        data = room{handles.data.room}.ceiling{c}.vertices;
        handles.data.walls.window = [];
        handles.data.walls.vertices = data;
        handles.data.walls.nr = -2;
        handles.data.ceiling = c;
        room{handles.data.room}.walls{w}.name = ['ceiling ',num2str(c)];
        p = fill3(data(:,1),data(:,2),data(:,3),[0.75 0.75 0.75],'EdgeColor','none');
                    
        % define wall specific properties - will be given to ButtonDownFcn
        handles.data.walls.window = [];
        handles.data.walls.vertices = p.Vertices;
        handles.data.walls.nr = w;
        

        set(p,'HitTest','on','PickableParts','all','ButtonDownFcn',{@select_wall, handles,-2,c})
        %set(p,'HitTest','on','PickableParts','all','ButtonDownFcn',{@select_wall, handles, w})
        % roomdata for setappdata
        try
            dummy = handles.data.room;
        catch
            handles.data.room = 1;
        end
        
        
        room{handles.data.room}.ceiling{c}.vertices = p.Vertices;
        room{handles.data.room}.ceiling{c}.nr = w;
        % plot windows from saved data
        try
            for j = 1:size(room{handles.data.room}.ceiling{c}.windows,2)
                wi = room{handles.data.room}.ceiling{c}.windows{j}.data;
                f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.blue);
                set(f,'HitTest','on','PickableParts','none');%,'ButtonDownFcn',{@select_wall, handles})
                room{handles.data.room}.ceiling{c}.windows{j}.data = [wi(:,1) wi(:,2) wi(:,3)];
                % window handles
                room{handles.data.room}.ceiling{c}.windows{j}.handle3D = f;
            end
            % save updated room data
            setappdata(handles.Lumos,'room',room);
        catch me
            %catcher(me)
        end

    end
catch me

end

% plot floor
f = fill3(data(:,1),data(:,2),zeros(size(data(:,3))),[0.75 0.75 0.75]);
set(f,'HitTest','on','PickableParts','all','ButtonDownFcn',{@select_wall, handles,-1,[]})
handles.data.ceiling = [];
handles.data.walls.nr = 0;
try
    for j = 1:size(room{handles.data.room}.floor.windows,2)
        wi = room{handles.data.room}.floor.windows{j}.data;
        f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.blue);
        set(f,'HitTest','on','PickableParts','none');%,'ButtonDownFcn',{@select_wall, handles})
        room{handles.data.room}.floor.windows{j}.data = [wi(:,1) wi(:,2) wi(:,3)];
        % window handles
        room{handles.data.room}.floor.windows{j}.handle3D = f;
    end
    % save updated room data
    setappdata(handles.Lumos,'room',room);
catch me

end

handles.data.floor{handles.data.room}.vertices = f.Vertices;


hold off
axis equal
axis off
%axis on
%title('view')
% update guidata
view([315 30])
% turn warning fr delaunay of
id = 'MATLAB:delaunay:DupPtsDelaunayWarnId';
warning('off',id)
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
    data = table{handles.data.room}.room;
catch
    data = get(handles.topview_point_table,'Data');
end
% get window data
%windata = getappdata(handles.Lumos,'room');

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
%title('objects')

r = handles.data.room;
try
    objs = room{r}.objects;
    plot_object(objs, obj, handles.view, '3D', clr)
catch ME
    %catcher(ME)
    %comeback('no objects or error')
end

% update guidata
guidata(hObject, handles)



function select_wall(hObject,eventdata,handles,w,c)

% check for walls selection tool
get_tool(hObject, eventdata, handles)
handles = guidata(hObject);
handles.data.ceiling = c;
% if not walls election tool active return
if handles.selected_tool == 11
    try
        add_windows(hObject,eventdata,handles,w,c)
        handles = guidata(hObject);
    catch
    end
elseif handles.selected_tool == 14
    add_material(hObject,eventdata,handles,w)
    handles = guidata(hObject);
else
    guidata(hObject,handles)
    return
end
guidata(hObject, handles)



function plot_material(~,~,handles, r, w, win, cnum, m, f)

axes(handles.topview)
hold off
room = getappdata(handles.Lumos,'room');

if ~exist('f','var')
   f = 1; 
end

try
    step = m.data(1,2)-m.data(1,1);
    if ~isempty(m.data) && (win == 0 || w == -3)
        if step <= 1
            plot(m.data(1,:),m.data(2,:),'Color',handles.blue)
        else
            stem(m.data(1,:),m.data(2,:),'Color',handles.blue,'Marker','.')
        end
        grid on
        xlabel('wavelength in nm')
        ylabel('spectral reflection value')
        title('spectral material properties')
        a = axis;
        b = m.data(1,1);
        c = m.data(1,end);
        axis([b c 0 1])
        %rho = round(ciespec2Y(m.data(1,:),m.data(2,:),1)/100,2);
        rho = ciespec2Y(m.data(1,:),m.data(2,:).*ciespec(m.data(1,:),'A'))/ciespec2Y(m.data(1,:),ciespec(m.data(1,:),'A'));
    
        legend(['\rho = ',num2str(rho)]);
    else
        plot(0,0)
        axis off
        text(0,0,'no material data','HorizontalAlignment','center')
        title('')
    end
catch
    plot(0,0)
    axis off
    text(0,0,'no material data','HorizontalAlignment','center')
    title('')
end

if win ~= 0
    try
        mw = m;
        step = mw.data(1,2)-mw.data(1,1);
        if step <= 1
            plot(mw.data(1,:),mw.data(2,:),'Color',handles.blue)
        else
            stem(mw.data(1,:),mw.data(2,:),'Color',handles.blue,'Marker','.')
        end
        grid on
        xlabel('wavelength')
        ylabel('transmission value')
        title('spectral transmission properties')
        a = axis;
        b = mw.data(1,1);
        c = mw.data(1,end);
        axis([b c 0 1])
    catch
        plot(0,0)
        axis off
        text(0,0,'no material data','HorizontalAlignment','center')
        title('')
    end
    a = axis;
end



function add_windows(hObject,eventdata,handles,w,c)

% get room (including walls and windows) and table data
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');
% change table columns
set(handles.topview_point_table,'Data',[])
set(handles.topview_point_table,'ColumnName',{'x1','x2','z1','z2'})
set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
set(handles.topview_point_table,'ColumnEditable',true(1,4))

handles.data.walls.nr = w;
% restore windows in table
switch w
    case -1
        try
            set(handles.topview_point_table,'Data',table{handles.data.room}.floor.windows{:})
            handles.data.ceiling = [];
        catch
        end
    case -2
        try
            set(handles.topview_point_table,'Data',table{handles.data.room}.ceiling{c}.windows{:})
            handles.data.ceiling = c;
        catch
        end
    otherwise
        try
            set(handles.topview_point_table,'Data',table{handles.data.room}.wall{w}.windows{:})
            handles.data.ceiling = [];
        catch
        end
end
guidata(hObject,handles)

% try to delete point marker
h = findobj(gca,'Type','line');
delete(h);

% reset facecolor to gray
patches = get(handles.view,'children');
windows = findobj(patches,'FaceColor',handles.blue);
for e = 1:size(patches,1)
    try
        set(patches(e),'FaceColor', [0.75 0.75 0.75]);
    catch
    end
end
% mark selected patch red in 3D view
if isequal(hObject.FaceColor,[1 0 0])
    try
        set(hObject,'FaceColor',[0.75 0.75 0.75]);
    catch
    end
else
    set(hObject,'FaceColor',handles.red)
end
set(windows,'FaceColor',handles.blue)

data = hObject.Vertices;

% calculate normal vector
x = [min(data(:,1)) max(data(:,1))];
y = [min(data(:,2)) max(data(:,2))];
z = [min(data(:,3)) max(data(:,3))];


switch w
    case -1
        normal = room{handles.data.room}.floor.normal;
    case -2
        normal = room{handles.data.room}.ceiling{c}.normal; 
    otherwise
        type = whos('w','var');
        if strcmp(type.class,'struct')
            normal = wall_normal(room{handles.data.room},w,0.1);
        else
            normal = wall_normal(room{handles.data.room},room{handles.data.room}.walls{w},0.1);
        end
        %normal = room{handles.data.room}.walls{1};
end
handles.data.normal_direction = 1;

% select 2D view
axes(handles.topview)
% set camera to a orthogonal point of view
campos([mean(x) mean(y) mean(z)]+normal); % camera position coordinates
camtarget([mean(x) mean(y) mean(z)]); % camera target coordinates

if sum(abs(normal)) == 0
    campos([mean(x) mean(y) 1]);
end
% delete old plots
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
hold off
% plot wall in 2D view
handles.wall = patch(data(:,1),data(:,2),data(:,3),[0.75 0.75 0.75]);

guidata(hObject, handles)
set(handles.wall,'HitTest','on','PickableParts','all','ButtonDownFcn',{@add_window, handles, w,c})


% add measurement labels - textlabel(1:3)
Vector = [x(2)-x(1) y(2)-y(1)];
Vector = Vector/max(Vector);
switch w
    case -2
        %textlabel(1) = text(mean(x), mean(z), min(data(:,3))-0.5,[num2str(round((sqrt((data(2,1)-data(1,1))^2+(data(1,2)-data(2,2))^2)*100))/100),' m'],'HorizontalAlignment','Center');
    case -1
        textlabel(1) = text(mean(x), mean(z)-0.5, min(data(:,3)),[num2str(round((sqrt((data(2,1)-data(1,1))^2+(data(1,2)-data(2,2))^2)*100))/100),' m'],'HorizontalAlignment','Center');
    otherwise
        textlabel(1) = text(mean(x), mean(y), min(data(:,3))-0.5,[num2str(round((sqrt((data(2,1)-data(1,1))^2+(data(1,2)-data(2,2))^2)*100))/100),' m'],'HorizontalAlignment','Center');
end

switch w
    case -2
        if handles.data.normal_direction == 0
            %textlabel(2) = text(min(x)-0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(3,3)),' m'],'VerticalAlignment','middle');
        else
            %textlabel(2) = text(min(x)-0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(2,2)),' m'],'VerticalAlignment','middle');
        end
    case -1
        if handles.data.normal_direction == 0
            textlabel(2) = text(min(x)-0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(3,3)),' m'],'VerticalAlignment','middle');
        else
            textlabel(2) = text(min(x)-0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(1,2)),' m'],'VerticalAlignment','middle');
        end
    otherwise
        if handles.data.normal_direction == 0
            textlabel(2) = text(min(x)-0.5*Vector(1), min(y)-0.5*Vector(2), mean(z),[num2str(data(3,3)),' m'],'VerticalAlignment','middle');
        else
            textlabel(2) = text(min(x)-0.5*Vector(1), min(y)-0.5*Vector(2), mean(z),[num2str(data(4,3)),' m'],'VerticalAlignment','middle');
        end
end
try
set(textlabel(2), 'rotation', 90)
catch
end

switch w
    case -2
        if handles.data.normal_direction == 0
            %textlabel(3) = text(max(x)+0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(4,3)),' m'],'VerticalAlignment','middle');
        else
            %textlabel(3) = text(max(x)+0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(2,2)),' m'],'VerticalAlignment','middle');
        end
    case -1
        if handles.data.normal_direction == 0
            textlabel(3) = text(max(x)+0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(4,3)),' m'],'VerticalAlignment','middle');
        else
            textlabel(3) = text(max(x)+0.5*Vector(1), mean(y)*Vector(2), mean(z),[num2str(data(2,2)),' m'],'VerticalAlignment','middle');
        end
    otherwise
        if handles.data.normal_direction == 0
            textlabel(3) = text(max(x)+0.5*Vector(1), max(y)+0.5*Vector(2), mean(z),[num2str(data(4,3)),' m'],'VerticalAlignment','middle');
        else
            textlabel(3) = text(max(x)+0.5*Vector(1), max(y)+0.5*Vector(2), mean(z),[num2str(data(3,3)),' m'],'VerticalAlignment','middle');
        end
end
try
set(textlabel(3), 'rotation', 90)
catch
end

% plot existing windows
try
    switch w
        case -1
            for win = 1:size(room{handles.data.room}.floor.windows,2)
                window = patch(room{handles.data.room}.floor.windows{win}.data(:,1),room{handles.data.room}.floor.windows{win}.data(:,2),room{handles.data.room}.floor.windows{win}.data(:,3),handles.blue);
                % window handle
                room{handles.data.room}.floor.windows{win}.handle = window; 
            end
        case -2
            for win = 1:size(room{handles.data.room}.ceiling{c}.windows,2)
                window = patch(room{handles.data.room}.ceiling{c}.windows{win}.data(:,1),room{handles.data.room}.ceiling{c}.windows{win}.data(:,2),room{handles.data.room}.ceiling{c}.windows{win}.data(:,3),handles.blue);
                % window handle
                room{handles.data.room}.ceiling{c}.windows{win}.handle = window; 
            end
        otherwise
            for win = 1:size(room{handles.data.room}.walls{w}.windows,2)
                window = patch(room{handles.data.room}.walls{w}.windows{win}.data(:,1),room{handles.data.room}.walls{w}.windows{win}.data(:,2),room{handles.data.room}.walls{w}.windows{win}.data(:,3),handles.blue);
                % window handle
                room{handles.data.room}.walls{w}.windows{win}.handle = window; 
            end
    end
catch
end

axis auto
a = axis;
d = 1;
axis([x(1)-d x(2)+d y(1)-d y(2)+d z(1)-d z(2)+d])
axis off
axis equal
switch w
    case -2
        title('ceiling')
    case -1
        title('floor')
    otherwise
        title('wall')
end
% update appdata
table{handles.data.room}.table_mode = 'window';
setappdata(handles.Lumos,'table',table);
setappdata(handles.Lumos,'room',room);

guidata(hObject,handles)




function add_window(hObject, eventdata, handles, w,c)

% click -> begin add window end point in create window

point = eventdata.IntersectionPoint;
axes(handles.topview)
hold on

room = getappdata(handles.Lumos,'room');
switch w
    case -2
        normal = room{handles.data.room}.ceiling{c}.normal;
    case -1
        normal = room{handles.data.room}.floor.normal;
    otherwise
        normal = room{handles.data.room}.walls{w}.normal;
end
set (handles.Lumos, 'WindowButtonMotionFcn', {@WindowMouseMove, handles, point, w,c,normal});
set(handles.wall,'HitTest','on','PickableParts','all','ButtonDownFcn',{@create_window, handles, point, w})
handles.data.walls.nr = w;

guidata(hObject, handles)



function WindowMouseMove(hObject, eventdata, handles, point, w, c, normal)

handles.data.walls.nr = w;
% get mouse courser
coordinate = get (gca, 'CurrentPoint');
% update handles
handles = guidata(hObject);
% delete last plot
try
    delete(handles.w);
catch
end

% create rectangle
switch w
    case -2
        if normal(1) == 0
            x = [point(1) coordinate(1,1) coordinate(1,1) point(1) point(1)];
            y = [point(2) point(2) coordinate(1,2) coordinate(1,2)  point(2)];
            z = [point(3) point(3) coordinate(1,3) coordinate(1,3)  point(3)];
        elseif normal(2) == 0
            x = [point(1) point(1) coordinate(1,1) coordinate(1,1)  point(1)];
            y = [point(2) coordinate(1,2) coordinate(1,2) point(2)  point(2)];
            z = [point(3) point(3) coordinate(1,3) coordinate(1,3)  point(3)];
        else
            [x,y,z] = deal(NaN);
        end
    case -1
        x = [point(1) coordinate(1,1) coordinate(1,1) point(1) point(1)];
        y = [point(2) point(2) coordinate(1,2) coordinate(1,2)  point(2)];
        z = [point(3) point(3) coordinate(1,3) coordinate(1,3)  point(3)];
    otherwise
        x = [point(1) coordinate(1,1) coordinate(1,1) point(1) point(1)];
        y = [point(2) coordinate(1,2) coordinate(1,2) point(2) point(2)];
        z = [point(3) point(3) coordinate(1,3) coordinate(1,3) point(3)];
end
% plot window
handles.w = patch(x,y,z,handles.blue);
% set window & wall properties
set(handles.w,'HitTest','off','PickableParts','none')
set(handles.wall,'HitTest','on','PickableParts','all','ButtonDownFcn',{@create_window, handles, point, w, c})
% update guidata
guidata(hObject, handles)


% add window function - second part
function create_window(hObject, eventdata, handles, point, w, c)
%try
% deactivate mouse move Function
set (handles.Lumos, 'WindowButtonMotionFcn',{});
axes(handles.topview)
hold on
try
    delete(handles.topview_marker_highlight);
catch
end
% get room data
room = getappdata(handles.Lumos,'room');

point2 = eventdata.IntersectionPoint;
% delete old patch
delete(handles.w);
% create window rectangle
switch w
    case -2
        if room{handles.data.room}.ceiling{c}.normal(1) == 0
            x = [point(1) point2(1) point2(1) point(1) point(1)];
            y = [point(2) point(2) point2(2) point2(2) point(2)];
            z = [point(3) point(3) point2(3) point2(3) point(3)];
        elseif room{handles.data.room}.ceiling{c}.normal(2) == 0
            x = [point(1) point(1) point2(1) point2(1) point(1)];
            y = [point(2) point2(2) point2(2) point(2) point(2)];
            z = [point(3) point(3) point2(3) point2(3) point(3)];
        else
           %[x,y,z] = deal(NaN);
           set(handles.wall,'HitTest','on','PickableParts','all','ButtonDownFcn',{@add_window, handles, w, c});
           return
        end
    case -1
        x = [point(1) point2(1) point2(1) point(1) point(1)];
        y = [point(2) point(2) point2(2) point2(2) point(2)];
        z = [point(3) point(3) point2(3) point2(3) point(3)];
    otherwise
        x = [point(1) point2(1) point2(1) point(1) point(1)];
        y = [point(2) point2(2) point2(2) point(2) point(2)];
        z = [point(3) point(3) point2(3) point2(3) point(3)];
end

axes(handles.topview)

window = fill3(x,y,z,handles.blue);
axes(handles.view)
hold on
window3D = fill3(x,y,z,handles.blue);
set(handles.wall,'HitTest','on','PickableParts','all','ButtonDownFcn',{@add_window, handles, w, c});

% selected wall
wall = w;

% patch coordinats of window
switch w
    case -2
        % index of new window
        try
            ind = size(room{handles.data.room}.ceiling{c}.windows,2)+1;
        catch
            ind = 1;
        end
        room{handles.data.room}.ceiling{c}.windows{ind}.data = [x' y' z'];
        % window handles
        room{handles.data.room}.ceiling{c}.windows{ind}.handle = window;
        room{handles.data.room}.ceiling{c}.windows{ind}.handle3D = window3D;
        room{handles.data.room}.ceiling{c}.windows{ind}.material = [];
        % wall coordinates
        cor = room{handles.data.room}.ceiling{c}.vertices;

    case -1
        % index of new window
        try
            ind = size(room{handles.data.room}.floor.windows,2)+1;
        catch
            ind = 1;
        end
        room{handles.data.room}.floor.windows{ind}.data = [x' y' z'];
        % window handles
        room{handles.data.room}.floor.windows{ind}.handle = window;
        room{handles.data.room}.floor.windows{ind}.handle3D = window3D;
        room{handles.data.room}.floor.windows{ind}.material = [];
        % wall coordinates
        cor = room{handles.data.room}.floor.vertices;
    otherwise
        % index of new window
        try
            ind = size(room{handles.data.room}.walls{wall}.windows,2)+1;
        catch
            ind = 1;
        end
        room{handles.data.room}.walls{wall}.windows{ind}.data = [x' y' z'];
        % window handles
        room{handles.data.room}.walls{wall}.windows{ind}.handle = window;
        room{handles.data.room}.walls{wall}.windows{ind}.handle3D = window3D;
        room{handles.data.room}.walls{wall}.windows{ind}.material = [];
        % wall coordinates
        cor = room{handles.data.room}.walls{wall}.vertices;
end

% save updated room data
setappdata(handles.Lumos,'room',room);

% global coordinates of window
switch w
    case -2
        normal = room{handles.data.room}.ceiling{handles.data.ceiling}.normal;
        if normal(2) == 0 && normal(1) > 0
            winx1 = window.Vertices(1,1);
            winx2 = window.Vertices(3,1);
            winy1 = window.Vertices(1,3);
            winy2 = window.Vertices(3,3);
            % calculate wall coordinates of window
            wallx1 = cor(1,1);
            wally1 = cor(1,3);
            x1 = sqrt((winx1-wallx1)^2+(winy1-wally1)^2);
            x2 = sqrt((winx2-wallx1)^2+(winy2-wally1)^2);
            z1 = window.Vertices(1,2)-min(cor(:,2));
            z2 = window.Vertices(3,2)-min(cor(:,2));
        elseif normal(2) == 0 && normal(1) < 0
            winx1 = window.Vertices(1,1);
            winx2 = window.Vertices(3,1);
            winy1 = window.Vertices(1,3);
            winy2 = window.Vertices(3,3);
            % calculate wall coordinates of window
            wallx1 = cor(1,1);
            wally1 = cor(1,3);
            x1 = sqrt((winx1-wallx1)^2+(winy1-wally1)^2);
            x2 = sqrt((winx2-wallx1)^2+(winy2-wally1)^2);
            z1 = window.Vertices(1,2)-min(cor(:,2));
            z2 = window.Vertices(3,2)-min(cor(:,2));
        elseif normal(1) == 0 && normal(2) > 0
            winx1 = window.Vertices(1,2);
            winx2 = window.Vertices(3,2);
            winy1 = window.Vertices(1,3);
            winy2 = window.Vertices(3,3);
            % calculate wall coordinates of window
            wallx1 = cor(1,2);
            wally1 = cor(1,3);
            z1 = sqrt((winx1-wallx1)^2+(winy1-wally1)^2);
            z2 = sqrt((winx2-wallx1)^2+(winy2-wally1)^2);
            x1 = window.Vertices(1,1)-min(cor(:,1));
            x2 = window.Vertices(3,1)-min(cor(:,1));
        elseif normal(1) == 0 && normal(2) < 0
            winx1 = window.Vertices(1,2);
            winx2 = window.Vertices(3,2);
            winy1 = window.Vertices(1,3);
            winy2 = window.Vertices(3,3);
            % calculate wall coordinates of window
            wallx1 = cor(3,2);
            wally1 = cor(3,3);
            z1 = sqrt((winx1-wallx1)^2+(winy1-wally1)^2);
            z2 = sqrt((winx2-wallx1)^2+(winy2-wally1)^2);
            x1 = window.Vertices(1,1)-min(cor(:,1));
            x2 = window.Vertices(3,1)-min(cor(:,1));
        elseif normal(1) == 0 && normal(2) == 0
            x1 = window.Vertices(1,1)-min(cor(:,1));
            x2 = window.Vertices(3,1)-min(cor(:,1));
            z1 = window.Vertices(1,2)-min(cor(:,2));
            z2 = window.Vertices(3,2)-min(cor(:,2));
        end
        
    case -1
        x1 = window.Vertices(1,1)-min(cor(:,1));
        x2 = window.Vertices(3,1)-min(cor(:,1));
        z1 = window.Vertices(1,2)-min(cor(:,2));
        z2 = window.Vertices(3,2)-min(cor(:,2));
    otherwise
        wallx1 = cor(1,1);
        wally1 = cor(1,3);
        winx1 = window.Vertices(1,1);
        winx2 = window.Vertices(3,1);
        winy1 = window.Vertices(1,2);
        winy2 = window.Vertices(3,2);
        % calculate wall coordinates of window
        x1 = sqrt((winx1-wallx1)^2+(winy1-wally1)^2);
        x2 = sqrt((winx2-wallx1)^2+(winy2-wally1)^2);
        z1 = window.Vertices(1,3)-min(cor(:,3));
        z2 = window.Vertices(3,3)-min(cor(:,3));
end



% get table data
tabledata = get(handles.topview_point_table,'Data');

% save wall window table data
table = getappdata(handles.Lumos,'table');
switch w
    case -2
        table{handles.data.room}.ceiling{c}.windows = {[tabledata; x1 x2 z1 z2]};
        % add new window to table
        set(handles.topview_point_table,'Data',[tabledata; x1 x2  z1 z2]);
     case -1
        table{handles.data.room}.floor.windows = {[tabledata; x1 x2 min(window.Vertices(:,2)) max(window.Vertices(:,2))]};
        % add new window to table
        set(handles.topview_point_table,'Data',[tabledata; x1 x2 z1 z2]);
    otherwise
        table{handles.data.room}.wall{wall}.windows = {[tabledata; x1 x2 z1 z2]};
        % add new window to table
        set(handles.topview_point_table,'Data',[tabledata; x1 x2 z1 z2]);
end
setappdata(handles.Lumos,'table',table);

handles.data.walls.nr = w;

% update guidata
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function plot3D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate plot3D
plot3(0,0,0)
%grid on
grid minor
axis(handles.axis3D)
xlabel('x')
ylabel('y')
zlabel('z')
title('3D view')
guidata(hObject, handles)


% --- Executes on key press with focus on topview_point_table and none of its controls.
function topview_point_table_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to topview_point_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool6_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool10_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable other tools
for i=[5:8 11 14]
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end

axes(handles.topview)
a = axis;

if size(axis,2) == 6
    cla
    reset(gca)
    refresh_2D(hObject, eventdata, handles)
    a = axis;
    handles = guidata(hObject);
end
% delete old plot
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end

% change table columns
set(handles.topview_point_table,'ColumnName',{'x','y','z'})
% reset facecolor to gray in 3D view
patches = get(handles.view,'children');
windows = findobj(patches,'FaceColor',handles.blue);
for e = 1:size(patches,1)
    try
        set(patches(e),'FaceColor', [0.75 0.75 0.75]);
    catch
    end
end
set(windows,'FaceColor',handles.blue)

% activate ButtonDownFcn
guidata(hObject,handles)
set(handles.topview,'ButtonDOwnFcn',{@topview_ButtonDownFcn, handles})

% get room data
table = getappdata(handles.Lumos,'table');
try
    % if exist
    set(handles.topview_point_table,'Data',table{handles.data.room}.room)
catch
end
% change table mode
try
    table = getappdata(handles.Lumos,'table');
    table{handles.data.room}.table_mode = 'room';
    setappdata(handles.Lumos,'table',table);
catch
end
% switch tools off
rotate3d off
pan off
zoom off
axis(a);
guidata(hObject, handles)


function refresh_2D(hObject, eventdata, handles)
axes(handles.topview)
cla
% delete old plot
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
% get appdata
table = getappdata(handles.Lumos,'table');
% replot room layout
try
    plot(table{handles.data.room}.room(:,1),table{handles.data.room}.room(:,2),'Color',handles.darkblue)
catch
end
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
axis on

axis equal
%camtarget([mean([a(1) a(2)]) mean([a(3) a(4)]) 0]);
xlabel('x')
ylabel('y')
title('top view')
axis equal
% update guidata
guidata(hObject, handles)



function refresh_2D_objects(hObject, eventdata, handles, obj)
%hold on
room = getappdata(handles.Lumos,'room');
r = handles.data.room;
% get objects
try
    objs = room{r}.objects;
    if ~exist('obj','var')
        obj = [];
    end
    
    plot_object(objs, obj, handles.topview, '2D')
catch
    cla
end

%hold off
% update guidata
guidata(hObject, handles)



function plot_object(objs, obj, h, mode,CLR)
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
        
        if strcmp(mode,'2D')
            plot_single_object_2D(objs.objects{o},co,clr,M,origin)
        elseif strcmp(mode,'3D')
            plot_single_object_3D(objs.objects{o},co,clr,M,origin)
        end
    end
end



function plot_single_object_3D(obj,c,clr,rot,origin)
hold on
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

% rotation matrix
M = deg2rad(obj.rotation);
T =  makehgtform('xrotate',M(1),'yrotate',M(2),'zrotate',M(3));
T = T(1:3,1:3);

% xyz = (M*([cx' cy' cz'])')';
g1 = g(:,1:3)*T(1:3,1:3);
g2 = g(:,[1 2 4])*T(1:3,1:3);

% shift coordinates according to origin matrix
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
g(:,1:2) = g(:,1:2)+offset(:,1:2);
if strcmp(obj.type,'luminaire')
    if ~isempty(obj.ldt)
        R = rot*T;
        G = g(:,1:3)./2;
        G = G*R;
        [~,ind] = max(abs(G));
        x = G(ind(1),1);
        y = G(ind(2),2);
        h = plot3dldt(obj.ldt,'mode','norm','origin',C+co,'rotation',T);  
        set(h,'EdgeAlpha',0.15)
    end
end

%view([315 30])
axis equal



function plot_single_object_2D(obj,c,clr,rot,origin)
hold on
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
g(:,1:2) = g(:,1:2)+offset(:,1:2);
if strcmp(obj.type,'luminaire')
    if ~isempty(obj.ldt)
        R = rot*T;
        G = g(:,1:3)./2;
        G = G*R;
        [~,ind] = max(abs(G));
        x = G(ind(1),1);
        y = G(ind(2),2);
        h = plot3dldt(obj.ldt,'mode','norm','origin',C+co,'rotation',T);  
        set(h,'EdgeAlpha',0.25)
    end
end



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




% --------------------------------------------------------------------
function uitoggletool11_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool11_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=[5:8 10 14]
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end
rotate3d off
pan off
zoom off

handles = guidata(hObject);
guidata(hObject, handles)




% --------------------------------------------------------------------
function uitoggletool10_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool5_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=[6:8 10:11 14]
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool6_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=[5 7:8 10:11 14]
    
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end
guidata(hObject, handles)



function uitoggletool7_OnCallback(hObject, eventdata, handles)
guidata(hObject, handles)
% hObject    handle to uitoggletool7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --------------------------------------------------------------------
for i=[5:6 8 10:11 14]
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool8_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=[5:7 10:11 14]
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end
guidata(hObject, handles)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject,handles)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject,handles)


% --- Executes when SpecSimulation is resized.
function SpecSimulation_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to SpecSimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject,handles)


% --------------------------------------------------------------------
function topview_point_table_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to topview_point_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get table data and check correct table mode (room)

table = getappdata(handles.Lumos,'table');

if strcmp(table{handles.data.room}.table_mode,'room') == 1
    % room table -> contextmenu
    c = uicontextmenu;
    handles.topview_point_table.UIContextMenu = c;
    m1 = uimenu(c,'Label','delete point');
    m2 = uimenu(c,'Label','add point before');
    m3 = uimenu(c,'Label','add point after');
    for p = 1:size(table{handles.data.room}.room,1)
        eval(['m1',num2str(p),' = uimenu(m1,''Label'',''point ',num2str(p),''', ''Callback'',{@remove_point, handles, p});']),
        eval(['m2',num2str(p),' = uimenu(m2,''Label'',''point ',num2str(p),''', ''Callback'',{@add_point_before, handles, p});']),
        eval(['m3',num2str(p),' = uimenu(m3,''Label'',''point ',num2str(p),''', ''Callback'',{@add_point_after, handles, p});']),
    end
elseif strcmp(table{handles.data.room}.table_mode,'window') == 1
    % window table -> contextmenu
    c = uicontextmenu;
    handles.topview_point_table.UIContextMenu = c;
    m1 = uimenu(c,'Label','delete');
    try
        switch handles.data.walls.nr
            case -2
                n = size(table{handles.data.room}.ceiling{handles.data.ceiling}.windows{1},1);
            case -1
                n = size(table{handles.data.room}.floor.windows{1},1);
            otherwise
                n = size(table{handles.data.room}.wall{handles.data.walls.nr}.windows{1},1);
        end
        for w = 1:n
            eval(['m1',num2str(w),' = uimenu(m1,''Label'',''window ',num2str(w),''', ''Callback'',{@remove_window, handles, w});']),
        end
    catch
    end
elseif strcmp(table{handles.data.room}.table_mode,'material') == 1
    % material: table -> contextmenu
    material = getappdata(handles.Lumos,'material');
    c = uicontextmenu;
    handles.topview_point_table.UIContextMenu = c;
    m1 = uimenu(c,'Label','load material','Callback',{@load_material, handles});
    m2 = uimenu(c,'Label','remove material');
    for w = 1:size(material,2)
        eval(['m1',num2str(w),' = uimenu(m2,''Label'',''',material{w}.name{:},''', ''Callback'',{@remove_material, handles, w});']),
    end
elseif strcmp(table{handles.data.room}.table_mode,'luminaire') == 1
    % luminaire: table -> contextmenu
    ldt = getappdata(handles.Lumos,'ldt');
    spectra = getappdata(handles.Lumos,'spectra');
    c = uicontextmenu;
    handles.topview_point_table.UIContextMenu = c;
    m1 = uimenu(c,'Label','load ldc','Callback',{@uitoggletool29_ClickedCallback,handles});
    m2 = uimenu(c,'Label','load spectrum','Callback',{@uitoggletool28_ClickedCallback,handles});
    m3 = uimenu(c,'Label','remove ldc');
    m4 = uimenu(c,'Label','remove spectrum');
    for w = 1:size(ldt,2)
        eval(['m3',num2str(w),' = uimenu(m3,''Label'',''',ldt{w}.name,''', ''Callback'',{@remove_ldt, handles, w});']),
    end
    for w = 1:size(spectra,2)
        eval(['m4',num2str(w),' = uimenu(m4,''Label'',''',spectra{w}.name,''', ''Callback'',{@remove_spectrum, handles, w});']),
    end
elseif strcmp(table{handles.data.room}.table_mode,'sky') == 1
    c = uicontextmenu;
    handles.topview_point_table.UIContextMenu = c;
elseif strcmp(handles.tab_group.SelectedObject.String,'objects') == 1
    % get room data
    room = getappdata(handles.Lumos,'room');
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
    ind = get(handles.listbox,'Value');
    if ~isempty(list{ind,2})
        c = uicontextmenu;
        handles.topview_point_table.UIContextMenu = c;
        m1 = uimenu(c,'Label','delete');
        m2 = uimenu(c,'Label','add point before');
        m3 = uimenu(c,'Label','add point after');
        for p = 1:size(get(handles.topview_point_table,'Data'),1)
            eval(['m1',num2str(p),' = uimenu(m1,''Label'',''point ',num2str(p),''', ''Callback'',{@remove_object_point, handles, p});']),
            eval(['m2',num2str(p),' = uimenu(m2,''Label'',''point ',num2str(p),''', ''Callback'',{@add_object_point_before, handles, p});']),
            eval(['m3',num2str(p),' = uimenu(m3,''Label'',''point ',num2str(p),''', ''Callback'',{@add_object_point_after, handles, p});']),
        end
    else
        handles.topview_point_table.UIContextMenu = [];
    end
end
guidata(hObject, handles)




function remove_spectrum(hObject, eventdata, handles, nr)

spec = getappdata(handles.Lumos,'spectra');
newspec = [];
ind = 1;
matname = spec{nr}.name;
% new material list
for m = 1:size(spec,2)
    if m ~= nr
        newspec{ind} = spec{m};
        list{ind,1} = spec{m}.name{:};
        list{ind,2} = false;
        ind = ind + 1;
    end
end
% save material data
setappdata(handles.Lumos,'spectra',newspec);
luminaire_table(hObject,eventdata,handles)
plot_luminaire(handles,eventdata,hObject)




function remove_ldt(hObject, eventdata, handles, nr)

ldt = getappdata(handles.Lumos,'ldt');
newldt = [];
ind = 1;
matname = ldt{nr}.name;
% new material list
for m = 1:size(ldt,2)
    if m ~= nr
        newldt{ind} = ldt{m};
        try
            list{ind,1} = ldt{m}.name{:};
        catch
            list{ind,1} = ldt{m}.name;
        end
        list{ind,2} = false;
        ind = ind + 1;
    end
end
% save material data
setappdata(handles.Lumos,'ldt',newldt);
luminaire_table(hObject,eventdata,handles)
plot_luminaire(handles,eventdata,hObject)



function remove_material(hObject, eventdata, handles, material)

mat = getappdata(handles.Lumos,'material');
newmat = [];
ind = 1;
matname = mat{material}.name;
% new material list
for m = 1:size(mat,2)
    if m ~= material
        newmat{ind} = mat{m};
        list{ind,1} = mat{m}.cellfield;
        list{ind,2} = false;
        ind = ind + 1;
    end
end
% save material data
setappdata(handles.Lumos,'material',newmat);
% set table data
try
    handles.topview_point_table.Data = list;
catch
    handles.topview_point_table.Data = [];
end
% remove material in room data
room = getappdata(handles.Lumos,'room');
for r=1:size(room,2)
    try
        if strcmp(room{r}.floor.material.name,matname)
            room{r}.floor.material.name = 'none';
            room{r}.floor.material.data = [];
        end
    catch
    end
    try
        if strcmp(room{r}.ceiling.material.name,matname)
            room{r}.ceiling.material.name = 'none';
            room{r}.ceiling.material.data = [];
        end
    catch
    end
    for w = 1:size(room{r}.walls,2)
        try
            if strcmp(room{r}.walls{w}.material.name,matname)
                room{r}.walls{w}.material.name = 'none';
                room{r}.walls{w}.material.data = [];
            end
            for win = 1:size(room{r}.walls{w}.windows,2)
                try
                    if strcmp(room{r}.walls{w}.windows{win}.material.name,matname)
                        room{r}.walls{w}.windows{win}.material.name = 'none';
                        room{r}.walls{w}.windows{win}.material.data = [];
                    end
                catch
                end
            end
        catch
        end
    end
end
setappdata(handles.Lumos,'room',room);
guidata(hObject, handles)
material_listbox(hObject,eventdata,handles)
handles = guidata(hObject);
guidata(hObject, handles)



function remove_window(hObject, eventdata, handles, window)
% get data
R = getappdata(handles.Lumos,'room');
T = getappdata(handles.Lumos,'table');
w = handles.data.walls.nr;
% clear data & refresh plots
switch w
    case -2        
        T{handles.data.room}.ceiling{handles.data.ceiling}.windows{1}(window,:) = [];
        set(handles.topview_point_table,'Data',T{handles.data.room}.ceiling{handles.data.ceiling}.windows{1});
    case -1
        T{handles.data.room}.floor.windows{1}(window,:) = [];
        set(handles.topview_point_table,'Data',T{handles.data.room}.floor.windows{1});
    otherwise
        T{handles.data.room}.wall{w}.windows{1}(window,:) = [];
        set(handles.topview_point_table,'Data',T{handles.data.room}.wall{w}.windows{1});
end
try
    switch w
        case -2
            delete(R{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.handle3D)
        case -1
            delete(R{handles.data.room}.floor.windows{window}.handle3D)
        otherwise
            delete(R{handles.data.room}.walls{w}.windows{window}.handle3D)
    end
catch
end
try
        switch w
        case -2
            delete(R{handles.data.room}.ceiling{handles.data.ceiling}.windows{window}.handle)
        case -1
            delete(R{handles.data.room}.floor.windows{window}.handle)
        otherwise
            delete(R{handles.data.room}.walls{w}.windows{window}.handle)
        end
catch
end
ind = 1;
C=R;
switch w
    case -2
        R{handles.data.room}.ceiling{handles.data.ceiling}.windows = [];
        for k = 1:size(C{handles.data.room}.ceiling{handles.data.ceiling}.windows,2)
            if k~=window
                R{handles.data.room}.ceiling{handles.data.ceiling}.windows{ind} = C{handles.data.room}.ceiling{handles.data.ceiling}.windows{k};
                ind = ind+1;
            end
        end
    case -1
        R{handles.data.room}.floor.windows = [];
        for k = 1:size(C{handles.data.room}.floor.windows,2)
            if k~=window
                R{handles.data.room}.floor.windows{ind} = C{handles.data.room}.floor.windows{k};
                ind = ind+1;
            end
        end
    otherwise
        R{handles.data.room}.walls{w}.windows = [];
        for k = 1:size(C{handles.data.room}.walls{w}.windows,2)
            if k~=window
                R{handles.data.room}.walls{w}.windows{ind} = C{handles.data.room}.walls{w}.windows{k};
                ind = ind+1;
            end
        end
end
% save new data
setappdata(handles.Lumos,'room',R);
setappdata(handles.Lumos,'table',T);
guidata(hObject,handles)


function remove_point(hObject, eventdata, handles, point)

% get appdata
room  = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');

% clear windows
table{handles.data.room}.room(point,:) = [];
for w = 1:length(room{handles.data.room}.walls)
    room{handles.data.room}.walls{w}.windows = [];
end

% updata table data
set(handles.topview_point_table,'Data',table{handles.data.room}.room);

% update appdata
setappdata(handles.Lumos,'table',table);
setappdata(handles.Lumos,'room',room);

% update plots
refresh_2D(hObject, eventdata, handles)
refresh_3D(hObject, eventdata, handles)
handles = guidata(hObject);
% update guidata
guidata(hObject, handles)


function remove_object_point(hObject, eventdata, handles, point)

% get appdata
room  = getappdata(handles.Lumos,'room');
%table = getappdata(handles.Lumos,'table');

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
    % object
    
    % object part
end

ind = get(handles.listbox,'Value');
r = list{ind,1};
obj = list{ind,2};


g = room{r}.objects{obj}.geometry{1};
g(point,:) = [];
room{r}.objects{obj}.geometry{1} = g;

% update appdata
setappdata(handles.Lumos,'room',room);

% update plots
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
refresh_3DObjects(hObject, eventdata, handles)

object_table(hObject, eventdata, handles)

% update guidata
guidata(hObject, handles)



function add_object_point_before(hObject, eventdata, handles, point)
position = 'before';
add_object_point(hObject, eventdata, handles, point, position)
handles = guidata(hObject);
guidata(hObject, handles)



function add_object_point_after(hObject, eventdata, handles, point)
position = 'after';
add_object_point(hObject, eventdata, handles, point, position)
handles = guidata(hObject);
guidata(hObject, handles)


function add_point_before(hObject, eventdata, handles, point)
position = 'before';
add_point(hObject, eventdata, handles, point, position)
handles = guidata(hObject);
guidata(hObject, handles)



function add_point_after(hObject, eventdata, handles, point)
position = 'after';
add_point(hObject, eventdata, handles, point, position)
handles = guidata(hObject);
guidata(hObject, handles)


function add_object_point(hObject, eventdata, handles, point, position)
% get appdata
room  = getappdata(handles.Lumos,'room');
%table = getappdata(handles.Lumos,'table');

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
    % object
    
    % object part
end

ind = get(handles.listbox,'Value');
r = list{ind,1};
obj = list{ind,2};

g = room{r}.objects{obj}.geometry{1};
switch position
    case 'before'
        G = g(1:point-1,:);
        G = [G; g(point,:)+[0.1 0.1 0 0]];
        G = [G; g(point:end,:)];
    case 'after'
        G = g(1:point,:);
        G = [G; g(point+1,:)+[0.1 0.1 0 0]];
        G = [G; g(point:end,:)];
end
room{r}.objects{obj}.geometry{1} = G;

% update appdata
setappdata(handles.Lumos,'room',room);

% update plots
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
refresh_3DObjects(hObject, eventdata, handles)
% update table
object_table(hObject, eventdata, handles)

guidata(hObject, handles)



function add_point(hObject, eventdata, handles, point, position)

% get appdata
room  = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');

% clear windows
for w = 1:length(room{handles.data.room}.walls)
    room{handles.data.room}.walls{w}.windows = [];
end
% create new table with extra row
NewTable = zeros(size(table{handles.data.room}.room)+[1 0]);
if strcmp(position,'before') == 1
    NewTable(1:point,:) = table{handles.data.room}.room(1:point,:);
    NewTable(point+1:end,:) = table{handles.data.room}.room(point:end,:);
elseif strcmp(position,'after') == 1
    NewTable(1:point,:) = table{handles.data.room}.room(1:point,:);
    NewTable(point+1:end,:) = table{handles.data.room}.room(point:end,:);
end
% refresh table data
set(handles.topview_point_table,'Data',NewTable);
% update table data
table{handles.data.room}.room = NewTable;

% update appdata
setappdata(handles.Lumos,'room',room)
setappdata(handles.Lumos,'table',table)

guidata(hObject, handles)


% SAVE
% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get filename and location
[file,path] = uiputfile(['project_',date,'.spr'],'Save project...');
% if aborted
if file==0
    guidata(hObject, handles)
    return
end

% show filename in GUI
handles.SpecSimulation.Name = ['LUMOS - ',file];

% get data for saving
data.table = getappdata(handles.Lumos,'table');
data.room  = getappdata(handles.Lumos,'room');
data.sky   = getappdata(handles.Lumos,'sky');
data.material = getappdata(handles.Lumos,'material');
data.results = getappdata(handles.Lumos,'result');
data.ldt = getappdata(handles.Lumos,'ldt');
data.spectra = getappdata(handles.Lumos,'spectra');
% save data
save([path file],'data');
handles.save_file = [path file];
% updata guidata
guidata(hObject, handles)


% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    axes(handles.view)
    colorbar('off')
catch
end
% get filename and location
[file,path] = uigetfile(['project_',date,'.spr'],'Load existing project...');
% if aborted
if file==0
    guidata(hObject, handles)
    return
end

% show filename in GUI
handles.SpecSimulation.Name = ['LUMOS - ',file];

% LOAD FILE
handles.data.room = 1;
set(handles.room_tab,'Value',1);
set(handles.listbox,'Value',1);

% load
load([path file],'-mat')
% set data
setappdata(handles.Lumos,'table',data.table);
setappdata(handles.Lumos,'room',data.room);
setappdata(handles.Lumos,'sky',data.sky);
try
    setappdata(handles.Lumos,'material',data.material);
catch
    setappdata(handles.Lumos,'material',[]);
end
try
    setappdata(handles.Lumos,'ldt',data.ldt);
catch
    setappdata(handles.Lumos,'ldt',[]);
end
try
    setappdata(handles.Lumos,'spectra',data.spectra);
catch
    setappdata(handles.Lumos,'spectra',[]);
end
try
setappdata(handles.Lumos,'result',data.results);
catch
    setappdata(handles.Lumos,'result',[]);
end

for l = 1:max(size(data.room))
    list{l,1} = data.room{l}.name;
end
for s = 1:size(data.sky,2)
    handles.data.sky = 1;
end

% (de)activate  tools
toggle_menu_buttons(hObject,handles,[5:8 10:11])

handles.data.room = 1;
set(handles.listbox,'Value',1)
% refresh plots
if size(data.table,2) > 0
    set(handles.topview_point_table,'Data',data.table{1}.room);
    set(handles.listbox,'String',list)
else
    set(handles.topview_point_table,'Data',[]);
    set(handles.listbox,'String',[])
end
uitoggletool10_OnCallback(hObject, eventdata, handles)
guidata(hObject,handles);
refresh_2D(hObject, eventdata, handles)
refresh_3D(hObject, eventdata, handles)
handles = guidata(hObject);

% update guidata
guidata(hObject,handles)


% --- Executes on button press in sky_tab.
function sky_tab_Callback(hObject, eventdata, handles)
% hObject    handle to sky_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

% set table
set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'ColumnName',{'x','y','L','CCT'})
set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnEditable',false(1,4))
set(handles.listbox,'String',[]);
drawnow

table = getappdata(handles.Lumos,'table');
if ~exist('handles.data.room','var')
    handles.data.room = 1;
end
table{handles.data.room}.table_mode = 'sky';
% save data
setappdata(handles.Lumos,'table',table);

% sky list
sky = getappdata(handles.Lumos,'sky');
for l = 1:size(sky,2)
    list{l,1} = sky{l}.filename;
    handles.data.sky = 1;
end

set(handles.listbox,'Value',1);
if size(sky,2) > 0
    set(handles.listbox,'String',list);
    set(handles.topview_point_table,'Data',[sky{l}.x sky{l}.y round(sky{l}.L) round(sky{l}.CCT)]);
end

% (de)activate  tools
toggle_menu_buttons(hObject,handles,13)


% (try) plot sky
refresh_sky(hObject, eventdata, handles)
set(handles.listbox,'Value',1);

% update guidata
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function room_tab_CreateFcn(hObject, eventdata, handles)
% hObject    handle to room_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1)
guidata(hObject, handles)


function refresh_sky(hObject, eventdata, handles)

% get sky data
data = getappdata(handles.Lumos,'sky');
% plot tregenza sky - input: 1.) data 2.) color = 1 / bw = 0
if ~isempty(data)
    data = data{handles.data.sky};%.spectrum;
end

if ~isempty(data)
    
    axes(handles.topview)
    children = get(gca, 'children');
    if ~isempty(children)
        set(children,'Visible','off');
    end
    plot_tregenza_sky(data,1,'2D');
    
    axes(handles.view)
    children = get(gca, 'children');
    if ~isempty(children)
        set(children,'Visible','off');
    end
    %figure
    plot_tregenza_sky(data,1,'explosion');
    %out = plotspecrange(data.spectrum(1,:),data.spectrum(2:end,:),'y-axis','radiance L_e in W m^{-2} sr^{-1} nm^{-1}')
    
else
    
    axes(handles.topview)
    guidata(hObject,handles)
    topview_CreateFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    cla
    axis off
    title('')

    axes(handles.view)
    guidata(hObject,handles)
    topview_CreateFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    cla
    axis off
    title('')

    
end
% update guidata
guidata(hObject, handles)



% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox

try
    % room case
    if strcmp(handles.tab_group.SelectedObject.String,'room')
        
        handles.data.room = get(handles.listbox,'Value');
        guidata(hObject,handles)
        table = getappdata(handles.Lumos,'table');
        % activate draw room tool
        uitoggletool10_OnCallback(hObject, eventdata, handles)
        % refresh table data
        set(handles.topview_point_table,'Data',table{handles.data.room}.room)
        table{handles.data.room}.table_mode = 'room';
        setappdata(handles.Lumos,'table',table)
        %guidata(hObject,handles);
        % refresh plots
        refresh_3D(hObject, eventdata, handles)
        refresh_2D(hObject, eventdata, handles)
        handles = guidata(hObject);
        
        % object case
    elseif strcmp(handles.tab_group.SelectedObject.String,'objects')
        m = get(handles.listbox,'Value');
        
        % get room data
        room = getappdata(handles.Lumos,'room');
        table = getappdata(handles.Lumos,'table');
        table{handles.data.room}.table_mode = 'objects';
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
        
        handles.data.object = list{m,2};
        handles.data.room = list{m,1};
        guidata(hObject, handles)
        
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles, handles.data.object)
        
        
        % update table
        object_table(hObject, eventdata, handles)
        handles = guidata(hObject);
        
        % highlight object selected
        if ~isempty(list{get(handles.listbox,'Value'),2})
            refresh_3DObjects(hObject, eventdata, handles,handles.data.object)
            axes(handles.topview);
            refresh_2D_objects(hObject, eventdata, handles,handles.data.object)
        else
            try
                refresh_3DObjects(hObject, eventdata, handles)
            catch
                view_CreateFcn(hObject, eventdata, handles)
            end
        end
        
        % sky case
    elseif strcmp(handles.tab_group.SelectedObject.String,'sky')
        
        %comeback('sky stuff')
        sky = getappdata(handles.Lumos,'sky');
        s = get(handles.listbox,'Value');
        handles.data.sky = s;
        % update table
        set(handles.topview_point_table,'Data',[sky{s}.x  sky{s}.y  round(sky{s}.L)  round(sky{s}.CCT)]);
        % refresh_sky
        refresh_sky(hObject, eventdata, handles)
        handles = guidata(hObject);
        
        % material case
    elseif strcmp(handles.tab_group.SelectedObject.String,'material')
        
        m = get(handles.listbox,'Value');
        sel = handles.listbox.Value;
        % get room data
        room = getappdata(handles.Lumos,'room');
        table = getappdata(handles.Lumos,'table');
        
        ind = 1;
        mat = [];
        % create room -> wall list
        for r = 1:max(size(room))
            % complete room   
            if ind == sel
                try
                    mat = [];
                catch
                    mat = [];
                end
            end
            list{ind,1} = -5;
            list{ind,2} = r;
            list{ind,3} = 0;
            list{ind,4} = 0;
            ind = ind+1;
            % environment
            if ind == sel
                try
                    mat = room{r}.environment_ground;
                catch
                    mat = [];
                end
            end
            list{ind,1} = -4;
            list{ind,2} = r;
            list{ind,3} = 0;
            list{ind,4} = 0;
            ind = ind + 1;
            % floor
            if ind == sel
                try
                    mat = room{r}.floor.material;
                catch
                    mat = [];
                end
            end
            list{ind,1} = -1;%'    floor';
            list{ind,2} = r;
            list{ind,3} = 0;
            list{ind,4} = 0;
            ind = ind + 1;
            try
                % windows
                for win = 1:size(room{r}.floor.windows,2)
                    if ind == sel
                        try
                            mat = room{r}.floor.windows{win}.material;
                        catch
                            mat = [];
                        end
                    end
                    list{ind,1} = -1;%['        window ',num2str(win)];
                    list{ind,2} = r;
                    list{ind,3} = win;
                    list{ind,4} = 0;
                    ind = ind + 1;
                end
            catch
            end
            % walls
            for w = 1:size(room{r}.walls,2)
                if ind == sel
                    try
                        mat = room{r}.walls{w}.material;
                    catch
                        mat = [];
                    end
                end
                list{ind,1} = w;%['    wall ',num2str(w)];
                list{ind,2} = r;
                list{ind,3} = 0;
                list{ind,4} = 0;
                ind = ind + 1;
                try
                    % windows
                    for win = 1:size(room{r}.walls{w}.windows,2)
                        if ind == sel
                            try
                                mat = room{r}.walls{w}.windows{win}.material;
                            catch
                                mat = [];
                            end
                        end
                        list{ind,1} = w;%['        window ',num2str(win)];
                        list{ind,2} = r;
                        list{ind,3} = win;
                        list{ind,4} = 0;
                        ind = ind + 1;
                    end
                catch
                end
            end
            % ceiling
            for c = 1:size(room{r}.ceiling,2)
                if ind == sel
                    try
                        mat = room{r}.ceiling{c}.material;
                    catch
                        mat = [];
                    end
                end
                list{ind,1} = -2;
                list{ind,2} = r;
                list{ind,3} = 0;
                list{ind,4} = c;
                ind = ind + 1;
                try
                    % windows
                    for win = 1:size(room{r}.ceiling{c}.windows,2)
                        if ind == sel
                            try
                                mat = room{r}.ceiling{c}.windows{win}.material;
                            catch
                                mat = [];
                            end
                        end
                        list{ind,1} = -2;%['        window ',num2str(win)];
                        list{ind,2} = r;
                        list{ind,3} = win;
                        list{ind,4} = c;
                        ind = ind + 1;     
                    end
                catch
                end
            end
            % objects
            for o = 1:size(room{r}.objects,2)
                if ind == sel
                    try
                        mat = room{r}.objects{o}.material;
                    catch
                        mat = [];
                    end
                end
                list{ind,1} = -6;
                list{ind,2} = r;
                list{ind,3} = o;
                list{ind,4} = 0;
                ind = ind + 1;
            end
            
        end
        
        selected_wall = list{m,1};
        selected_win  = list{m,3};
        handles.data.room = list{m,2};
        guidata(hObject, handles)
        
        if w == -6
            mat = room{r}.objects{win}.material;
        end
        handles = guidata(hObject);
        guidata(hObject,handles)
        material_table(hObject,eventdata,handles,mat)
        handles = guidata(hObject);
        
        %comeback('material list update')
        % refreshplot
        if isequal(list{m,1},-6) % object case
            refresh_3DObjects(hObject, eventdata, handles, list{m,3})
            plot_material(hObject,eventdata,handles, handles.data.room, selected_wall, selected_win,[],mat)
        elseif isequal(list{m,1},-4) % envirenment
            refresh_3DObjects(hObject, eventdata, handles, list{m,3})
            plot_material(hObject,eventdata,handles, handles.data.room, selected_wall, selected_win, [], mat.material)
        else % not object case
            plot_3D(hObject, eventdata, handles, selected_wall, selected_win,list{sel,4})
            plot_material(hObject,eventdata,handles, handles.data.room, selected_wall, selected_win, list{sel,4}, mat)
        end
        table{handles.data.room}.table_mode = 'material';
        guidata(hObject, handles)
        setappdata(handles.Lumos,'table',table);
        
        % environment case
    elseif strcmp(handles.tab_group.SelectedObject.String,'environment')
        %comeback('environment listbox callback')
        
        guidata(hObject, handles)
        environment_listbox(hObject, eventdata, handles)
        guidata(hObject, guidata(hObject))
        environment_table(hObject, eventdata, handles)
        handles = guidata(hObject);
        
        % simulation case
    elseif strcmp(handles.tab_group.SelectedObject.String,'simulation')
        simulation_listbox_callback(hObject, eventdata, handles)
        handles = guidata(hObject);
        
        % observer case
    elseif strcmp(handles.tab_group.SelectedObject.String,'metrics')
        observer_listbox_callback(hObject, eventdata, handles)
        handles = guidata(hObject);
        % result case
    elseif strcmp(handles.tab_group.SelectedObject.String,'results')
        result_listbox_callback(hObject, eventdata, handles);
        handles = guidata(hObject);
        % luminaire case
    elseif strcmp(handles.tab_group.SelectedObject.String,'luminaire')
        luminaire_table(hObject,eventdata,handles)
        plot_luminaire(handles,eventdata,hObject)
        % end of cases
    end
    
catch me
    %catcher(me)
end
% save guidata
guidata(hObject,handles)



function plot_luminaire(handles,eventdata,hObject)
room = getappdata(handles.Lumos,'room');
[room_nr, lum_nr, ~] = lum_room_nr(handles);

% plot luminaires and objects
axes(handles.view)
cla reset
refresh_3DObjects(hObject, eventdata, handles,[],lum_nr)
try
    objs = room{room_nr}.luminaire;
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



function object_table(hObject, eventdata, handles)
%comeback('Object table cases creation..')

% selected list element
item = handles.listbox.Value;

% get room data
room = getappdata(handles.Lumos,'room');
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
                set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric','numeric'})
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
                set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
                set(handles.topview_point_table,'Data',data)
                set(handles.topview_point_table,'ColumnEditable',true(1,4))
        end
    catch
        set(handles.topview_point_table,'RowName','')
        set(handles.topview_point_table,'ColumnName',{'x','y','z1','z2'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'Data',[])
        set(handles.topview_point_table,'ColumnEditable',true(1,4))
    end
else
    set(handles.topview_point_table,'RowName','')
    set(handles.topview_point_table,'ColumnName',{'x','y','z1','z2'})
    set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
    set(handles.topview_point_table,'Data',[])
    set(handles.topview_point_table,'ColumnEditable',true(1,4))
end

%refresh_3DObjects(hObject, eventdata, handles)

guidata(hObject,handles)






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



function [data,points,ind] = single_object_table_data(obj,ind)
for j = 1:size(obj.geometry{1},1)
    points{j} = [num2str(ind) 'P' num2str(j)];
    data(j,:) = obj.geometry{1}(j,:);
end
ind = ind+1;



function luminaire_table_edit(hObject, eventdata,handles)

% selected list element
item = handles.listbox.Value;
% get room data
room = getappdata(handles.Lumos,'room');
% get listbox data
[room_nr, ~, ~, type] = lum_room_nr(handles, item);
lum_nr = eventdata.Indices(1);
data = get(handles.topview_point_table,'Data');

switch type
    case 'room'
        nr = eventdata.Indices(1);
        % update coordinates and rotation
        data = cell2mat(data(:,2:end));
        room{room_nr}.luminaire{nr}.coordinates = data(nr,1:3);
        room{room_nr}.luminaire{nr}.rotation = data(nr,4:6);
        setappdata(handles.Lumos,'room',room)
        
        a = room{room_nr}.luminaire{nr}.rotation;
        M1 = rotMatrixD([1 0 0],a(1));
        M2 = rotMatrixD([0 1 0],a(2));
        M3 = rotMatrixD([0 0 1],a(3));
        M = M1*M2*M3;
        try
            room{room_nr}.luminaire{nr}.normal = room{room_nr}.luminaire{nr}.normal*M;
        catch
            room{room_nr}.luminaire{nr}.normal = [0 0 -1];
        end
        % plot objects and luminaires 3D
        axes(handles.view)
        refresh_3DObjects(hObject, eventdata, handles,[])
        clr = handles.orange;
        try
            objs = room{room_nr}.luminaire;
            plot_object(objs, lum_nr, handles.view, '3D',clr)
        catch
        end
        
        % plot objects and luminaires 2D
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            plot_object(objs, lum_nr, handles.topview, '2D',clr)
        catch
        end

    case 'luminaire'

        selected = eventdata.Indices;
        data = get(handles.topview_point_table,'Data');
        
        for i = 1:size(data,1)
            if selected(2) == 2 || selected(2) == 4
                if i == selected(1) && sum(data{i,selected(2)} == true)
                    data{i,selected(2)} = true;
                else
                    data{i,selected(2)} = false;
                end
            end
        end
        % check selected / unselected
        c = 0;
        
        if selected(2)~=5
        for  i = 1:size(data,1)
            c = c+data{i,selected(2)};
        end
        end
        handles.topview_point_table.Data = data;
        % get room data
        room = getappdata(handles.Lumos,'room');

        nr = handles.listbox.Value;
        [room_nr, lum_nr] = lum_room_nr(handles, nr);
        % switch ldt or spectrum
        switch selected(2)
            case 2
                % ldt
                try
                    % selected or unselected
                    if c % something is selected
                        ldt = getappdata(handles.Lumos,'ldt');
                        room{room_nr}.luminaire{lum_nr}.ldt = ldt{selected(1)};
                        h_old = room{room_nr}.luminaire{lum_nr}.geometry{1}(1,4);
                        h = ldt{selected(1)}.info.fH/1000;
                        b = ldt{selected(1)}.info.fB/1000;
                        t = ldt{selected(1)}.info.fL/1000;
                        if b == 0
                            b = t;
                        end
                        hdiff = h-h_old;
                        room{room_nr}.luminaire{lum_nr}.coordinates(3) = room{room_nr}.luminaire{lum_nr}.coordinates(3)-hdiff;
                        room{room_nr}.luminaire{lum_nr}.geometry{1} = [0 0 0 h
                            b 0 0 h
                            b t 0 h
                            0 t 0 h];
                    else
                        room{room_nr}.luminaire{lum_nr}.ldt = [];
                        room{room_nr}.luminaire{lum_nr}.geometry{1} = [0         0         0    0.1000
                            0.1000         0         0    0.1000
                            0.1000    0.1000         0    0.1000
                            0         0.1000         0    0.1000];
                    end
                catch
                    room{room_nr}.luminaire{lum_nr}.ldt = [];
                end
                setappdata(handles.Lumos,'room',room)
            case 4
                % spectrum
                try
                    % selected or unselected
                    if c % something is selected
                        %ldt = getappdata(handles.Lumos,'ldt');
                        spec = getappdata(handles.Lumos,'spectra');
                        room{room_nr}.luminaire{lum_nr}.spectrum = spec{selected(1)};
                        room{room_nr}.luminaire{lum_nr}.lambda = spec{selected(1)}.data(1,:);                  
                    else
                        room{room_nr}.luminaire{lum_nr}.spectrum = [];
                        room{room_nr}.luminaire{lum_nr}.lambda = [];
                    end
                    
                catch
                    room{room_nr}.luminaire{lum_nr}.spectrum = [];
                    room{room_nr}.luminaire{lum_nr}.lambda = [];
                end
                setappdata(handles.Lumos,'room',room)
            case 5
                % dimming
                room{room_nr}.luminaire{lum_nr}.dimming = str2double(data(selected(1),5));
                setappdata(handles.Lumos,'room',room)
        end
        
        
end
setappdata(handles.Lumos,'room',room)

guidata(hObject,handles)





function objects_table_edit(hObject, eventdata,handles)

% selected list element
item = handles.listbox.Value;

% get room data
room = getappdata(handles.Lumos,'room');
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

data = get(handles.topview_point_table,'Data');

switch object_case
    case 'room'
        obj_nr = eventdata.Indices(1);
        % update coordinates and rotation
        room{object_room}.objects{obj_nr}.coordinates = data(obj_nr,1:3);
        room{object_room}.objects{obj_nr}.rotation = data(obj_nr,4:6);
    case 'object'
        data = get(handles.topview_point_table,'Data');
        room{object_room}.objects{object_nr}.geometry{1} = data;
end

setappdata(handles.Lumos,'room',room)

% update figures
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
refresh_3DObjects(hObject, eventdata, handles)

guidata(hObject,handles)



function simulation_listbox_callback(hObject, eventdata, handles)

room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end
sky  = getappdata(handles.Lumos,'sky');

nr = get(handles.listbox,'Value');

results = getappdata(handles.Lumos,'result');

skynum = size(sky,2);
%if skynum == 0
%    skynum = 1;
%end

ind = 0;
for r = 1:size(room,2)
    ind = ind + 1;
    
    if nr == ind
        handles.data.room = r;
        axes(handles.topview)
        
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        [~, lum_nr, ~] = lum_room_nr(handles);
        try
            objs = room{r}.luminaire;
            clr = handles.orange;
            plot_object(objs, lum_nr, handles.topview, '2D',clr)
        catch
        end
        
        axes(handles.view)
        try
            if ~isempty(results{handles.data.room}.sky{1})
                % plot results
                plotGouraud(results{handles.data.room}.sky{1},handles.view,handles.topview);
            else
                cla
                text(0.5,0.5,0.5,'no data','HorizontalAlignment','center')
                title('')
                axis off
            end
        catch
            cla
            text(0.5,0.5,0.5,'no data','HorizontalAlignment','center')
            title('')
            axis off
        end
    end

    
    for s = 1:skynum
        ind = ind + 1;
        if nr == ind
            handles.data.sky  = s;
            handles.data.room = r;
            axes(handles.topview)
            try
                plot_tregenza_sky(sky{handles.data.sky},1,'2D');
            catch
                cla
            end
            axes(handles.view)
            try
                if ~isempty(results{handles.data.room}.sky{s+1})
                    % plot results
                    plotGouraud(results{handles.data.room}.sky{s+1},handles.view,handles.topview);
                else
                    cla
                    text(0.5,0.5,0.5,'no data','HorizontalAlignment','center')
                    title('')
                    axis off
                end
            catch
                cla
                text(0.5,0.5,0.5,'no data','HorizontalAlignment','center')
                title('')
                axis off
            end
        end
    end
end

guidata(hObject, handles)


function environment_table(hObject, eventdata, handles)
comeback('environment table list')
% room data
room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end
table = getappdata(handles.Lumos,'table');
nr = get(handles.listbox,'Value');
try
    name = room{nr}.name;
    w = abs(max(table{nr}.room(:,1))-min(table{nr}.room(:,1)));
    d = abs(max(table{nr}.room(:,2))-min(table{nr}.room(:,2)));
    try
        a = room{nr}.angle;
        h = room{nr}.height_over_ground;
    catch
        a = 0;
        h = 0;
    end
    data = {h; w; d; ''; ''; a};
catch
    name = 'room';
    data = [];
end
% environment table
set(handles.topview_point_table,'Data',data);
set(handles.topview_point_table,'ColumnName',{name,})
set(handles.topview_point_table,'RowName',{'height','width','depth','direction','distance','rotation'})
set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric','numeric'})
set(handles.topview_point_table,'ColumnEditable',true(1,2))

guidata(hObject, handles)



% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','');
guidata(hObject,handles)


% --------------------------------------------------------------------
function uitoggletool13_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uitoggletool13,'State','off')

skies = getappdata(handles.Lumos,'sky');
nr = size(skies,2)+1;

% load file (spectrum)
[file, path] = uigetfile('*.txt','Load spectrum file','MultiSelect','on');
try % single file
    if file == 0
        return
    end
    filenumber = 1;
catch % multiple files
    filenumber = size(file,2);
end

for i = 1:filenumber
    % load data
    if filenumber ~= 1
        data.spectrum = importdata([path file{i}]);
    else
        data.spectrum = importdata([path file]);
    end
    
    handles.data.sky = nr;
    
    [xyz,x,y,~,Y] = ciespec2xyz(data.spectrum(1,:),data.spectrum(2:end,:));
    %lab = ciexyz2lab(xyz,'D65');
    %CLR = cielab2srgb(lab,'D65');
    CLR = xyz2srgb(xyz);
    
    skies{nr}.x = x;
    skies{nr}.y = y;
    skies{nr}.L = Y(:,2);
    ind = isnan(Y);
    skies{nr}.L(ind) = NaN;
    skies{nr}.CCT = CCT('x',x,'y',y,'warning','off');
    skies{nr}.CCT(ind) = NaN;
    skies{nr}.spectrum = data.spectrum;
    if filenumber ~= 1
        skies{nr}.filename = file{i};
    else
        skies{nr}.filename = file;
    end
    skies{nr}.RGB = CLR;
    
    nr = nr + 1;
end
% last sky
nr = nr-1;

% set table
set(handles.topview_point_table,'ColumnName',{'x','y','L','CCT'})
set(handles.topview_point_table,'ColumnEditable',false(1,4))
set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
set(handles.topview_point_table,'Data',[x y round(skies{nr}.L) round(skies{nr}.CCT)]);

table = getappdata(handles.Lumos,'table');
if ~exist('handles.data.room','var')
    handles.data.room = 1;
end
table{handles.data.room}.table_mode = 'sky';
% save data
setappdata(handles.Lumos,'table',table);
setappdata(handles.Lumos,'sky',skies)
% refresh_sky
refresh_sky(hObject, eventdata, handles)
%handles = guidata(hObject);

list = [];
for i = 1:nr
    list{i,1} = skies{i}.filename;
end

set(handles.listbox,'String',list);
% update guidata
guidata(hObject,handles)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox.
function listbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% room contextmenu
if strcmp(handles.tab_group.SelectedObject.String,'room') == 1
    % listbox contextmenu
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    m1 = uimenu(c,'Label','delete');
    m2 = uimenu(c,'Label','rename');
    m3 = uimenu(c,'Label','duplicate');
    m4 = uimenu(c,'Label','add room','Callback',{@add_room, handles});
    list = get(handles.listbox,'String');
    % build context-sub-menu
    for r = 1:size(list,1)
        eval(['m1',num2str(r),' = uimenu(m1,''Label'','' ',list{r},''', ''Callback'',{@delete_room, handles, r});']),
        eval(['m2',num2str(r),' = uimenu(m2,''Label'','' ',list{r},''', ''Callback'',{@rename_room, handles, r});']),
        eval(['m3',num2str(r),' = uimenu(m3,''Label'','' ',list{r},''', ''Callback'',{@duplicate_room, handles, r});']),
    end
    if isempty(list)
        set(m1,'enable','off')
        set(m2,'enable','off')
        set(m3,'enable','off')
    end
    
    % sky contextmenu
elseif strcmp(handles.tab_group.SelectedObject.String,'sky') == 1
    % listbox contextmenu
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    m1 = uimenu(c,'Label','remove  ');
    m2 = uimenu(c,'Label','load  ','Callback',{@uitoggletool13_OnCallback, handles});
    %m3 = uimenu(c,'Label','duplicate');
    list = get(handles.listbox,'String');
    % build context-sub-menu
    for r = 1:size(list,1)
        eval(['m1',num2str(r),' = uimenu(m1,''Label'','' ',list{r},''', ''Callback'',{@delete_sky, handles, r});']),
    end
    if isempty(list)
        set(m1,'enable','off')
    end
    % material context menu
elseif strcmp(handles.tab_group.SelectedObject.String,'material') == 1
    %comeback('material context menu')
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    
    % environment context menu
elseif strcmp(handles.tab_group.SelectedObject.String,'environment') == 1
    %comeback('material context menu')
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    
    % objects context menu
elseif strcmp(handles.tab_group.SelectedObject.String,'objects') == 1
    %comeback('material context menu')
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    handles.listbox.UIContextMenu = c;
    m1 = uimenu(c,'Label','remove object ');
    m2 = uimenu(c,'Label','add object   ');
    m3 = uimenu(c,'Label','rename object   ');
    m4 = uimenu(c,'Label','copy object   ');
    m5 = uimenu(c,'Label','un/group objects   ');
    %m6 = uimenu(c,'Label','ungroup objects   ');
    list = get(handles.listbox,'String');
    % build context-sub-menu
    room = getappdata(handles.Lumos,'room');
    for r = 1:max(size(room))
        eval(['m1',num2str(r),' = uimenu(m1,''Label'','' ',room{r}.name,''');'])
        eval(['m2',num2str(r),' = uimenu(m2,''Label'','' ',room{r}.name,''', ''Callback'',{@add_object, handles, r});'])
        eval(['m3',num2str(r),' = uimenu(m3,''Label'','' ',room{r}.name,''');'])
        eval(['m4',num2str(r),' = uimenu(m4,''Label'','' ',room{r}.name,''');'])
        eval(['m5',num2str(r),' = uimenu(m5,''Label'','' ',room{r}.name,''', ''Callback'',{@group_objects, handles, r});'])
    end
    for r = 1:max(size(room))
        for o = 1:size(room{r}.objects,2)
            try
                eval(['m1',num2str(r),num2str(o),' = uimenu(m1',num2str(r),',''Label'','' ',room{r}.objects{o}.name,''', ''Callback'',{@delete_object, handles, r, o});']),
                eval(['m3',num2str(r),num2str(o),' = uimenu(m3',num2str(r),',''Label'','' ',room{r}.objects{o}.name,''', ''Callback'',{@rename_room_object, handles, r, o});'])
                eval(['m4',num2str(r),num2str(o),' = uimenu(m4',num2str(r),',''Label'','' ',room{r}.objects{o}.name,''', ''Callback'',{@copy_room_object, handles, r, o});'])
            catch
            end
        end
    end
    if isempty(list)
        set(m1,'enable','off')
    end
    
    % observer contextmenu
elseif strcmp(handles.tab_group.SelectedObject.String,'metrics') == 1
    % listbox contextmenu
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    m1 = uimenu(c,'Label','remove  ');
    m2 = uimenu(c,'Label','add area   ');
    m3 = uimenu(c,'Label','add point   ');
    m4 = uimenu(c,'Label','rename   ');
    list = get(handles.listbox,'String');
    % build context-sub-menu
    for r = 1:size(list,1)
        eval(['m1',num2str(r),' = uimenu(m1,''Label'','' ',list{r},''', ''Callback'',{@delete_observer, handles, r});']),
        eval(['m4',num2str(r),' = uimenu(m4,''Label'','' ',list{r},''', ''Callback'',{@rename_observer, handles, r});']),
    end
    room = getappdata(handles.Lumos,'room');
    for r = 1:numel(room)
        eval(['m2',num2str(r),' = uimenu(m2,''Label'','' ',room{r}.name,''', ''Callback'',{@uitoggletool32_ClickedCallback, handles, r});']),
        eval(['m3',num2str(r),' = uimenu(m3,''Label'','' ',room{r}.name,''', ''Callback'',{@uitoggletool24_ClickedCallback, handles, r});']),
    end
    if isempty(list)
        set(m1,'enable','off')
    end
    % luminaire contextmenu
elseif strcmp(handles.tab_group.SelectedObject.String,'luminaire') == 1
    % listbox contextmenu
    c = uicontextmenu;
    handles.listbox.UIContextMenu = c;
    m1 = uimenu(c,'Label','remove  ');
    m2 = uimenu(c,'Label','add luminaire   ');
    m3 = uimenu(c,'Label','rename   ');
    list = get(handles.listbox,'String');
    % build context-sub-menu
    for r = 1:size(list,1)
        eval(['m1',num2str(r),' = uimenu(m1,''Label'','' ',list{r},''', ''Callback'',{@delete_luminaire, handles, r});']),
        eval(['m3',num2str(r),' = uimenu(m3,''Label'','' ',list{r},''', ''Callback'',{@rename_luminaire, handles, r});']),
    end
    room = getappdata(handles.Lumos,'room');
    for r = 1:numel(room)
        eval(['m2',num2str(r),' = uimenu(m2,''Label'','' ',room{r}.name,''', ''Callback'',{@uitoggletool26_ClickedCallback, handles, r});']),
    end
    if isempty(list)
        set(m1,'enable','off')
    end
end

guidata(hObject,handles)



function group_objects(hObject, eventdata, handles, r,mode)
if ~exist('mode','var')
    mode = 'object';
end
%handles.listbox.Max = 100;
room = getappdata(handles.Lumos,'room');
switch mode
    case 'object'
        o = room{r}.objects;
    case 'luminaire'
        o = room{r}.luminaire;
end
objects_un_group(o,r,mode)





function copy_room_object(hObject, eventdata, handles, r, o)
room = getappdata(handles.Lumos,'room');
obj = room{r}.objects{o};

obj.coordinates = obj.coordinates + [1 1 0];

ind = size(room{r}.objects,2);
room{r}.objects{ind+1} = obj;

setappdata(handles.Lumos,'room',room);

% update plots
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
refresh_3DObjects(hObject, eventdata, handles)

% set listbox
object_listbox(hObject, [], handles)
set(handles.listbox,'Value',1)

% table
guidata(hObject,handles)
object_table(hObject, eventdata, handles)
handles = guidata(hObject);

guidata(hObject,handles)




function add_room(hObject, eventdata, handles)
% adding a standard romm
room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');

% get room list and number of rooms
list = get(handles.listbox,'String');
if isempty(get(handles.listbox,'String'))
    nr = 1;
else
    nr = size(get(handles.listbox,'String'),1)+1;
end
handles.data.room = nr;

guidata(hObject, handles)

room_name =  ['room ',num2str(nr)];
list = [get(handles.listbox,'String');{room_name}];

set(handles.listbox,'String',list);
set(handles.listbox,'Value',nr);


z = handles.data.room_standard_height;
stdroom = [0 0 z;...
    0 6 z;...
    5 6 z;...
    5 0 z;...
    0 0 z];

set(handles.topview_point_table,'Data',stdroom);

% save room layout appdata
if isempty(table)
    table = [];
    table{1}.room = stdroom;
    table{1}.table_mode = 'room';
else
    table{handles.data.room}.room = stdroom;
    table{handles.data.room}.table_mode = 'room';
end
% save room table data in appdata
setappdata(handles.Lumos,'table',table);

% set room name
room{nr}.name = room_name;
room{nr}.height = 0;
% empty objects
room{nr}.objects = [];
% save room name
setappdata(handles.Lumos,'room',room)
% create room
create_room(handles, stdroom)

guidata(hObject, handles)
refresh_2D(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles)
refresh_3D(hObject, eventdata, handles)
handles = guidata(hObject);


guidata(hObject, handles)



function delete_sky(hObject, listbox, handles,sky)
S = getappdata(handles.Lumos,'sky');
T = getappdata(handles.Lumos,'table');
ind = 1;
NS = {};
list = {};
for i = 1:size(S,2)-1
    if i == sky
        ind = ind+1;
    end
    NS{i} = S{ind};
    list{i} = S{ind}.filename;
    ind = ind+1;
end
% save rooms
setappdata(handles.Lumos,'sky',NS);

% set listbox
handles.listbox.String = list;
nr = sky-1;
if nr == 0
    nr = 1;
end
if size(get(handles.listbox,'String'),2) > 0
    set(handles.listbox,'Value',1)
    handles.data.room = 1;
    eventdata =[];
    listbox_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
else
    set(handles.listbox,'Value',0)
end

handles.data.room = nr;
set(handles.listbox,'Value',nr)
guidata(hObject, handles)
sky_tab_Callback(hObject, 0, handles)



function delete_room(hObject, listbox, handles,room)
R = getappdata(handles.Lumos,'room');
T = getappdata(handles.Lumos,'table');
results = getappdata(handles.Lumos,'result');
try
results(room) = [];
catch
end
setappdata(handles.Lumos,'result',results)
ind = 1;
for i = 1:size(R,2)-1
    if i == room
        ind = ind+1;
    end
    NR{i} = R{ind};
    list{i} = R{ind}.name;
    NT{i} = T{ind};
    ind = ind+1;
    
end

% save rooms
try
    setappdata(handles.Lumos,'room',NR);
    setappdata(handles.Lumos,'table',NT);
catch
    setappdata(handles.Lumos,'room',[]);
    setappdata(handles.Lumos,'table',[]);
end

% set listbox
try
    handles.listbox.String = list;
catch
    list = [];
    handles.listbox.String = [];
end
nr = room-1;
if nr == 0
    nr = 1;
end
if size(get(handles.listbox,'String'),2) > 0
    set(handles.listbox,'Value',1)
    handles.data.room = 1;
    eventdata =[];
    listbox_Callback(hObject, eventdata, handles)
    handles = guidata(hObject);
else
    set(handles.listbox,'Value',0)
    axes(handles.topview)
    cla
    axes(handles.view)
    cla
end

handles.data.room = nr;
set(handles.listbox,'Value',nr)
guidata(hObject,handles)



function delete_object(hObject, listbox, handles, room, object_nr)
R = getappdata(handles.Lumos,'room');
%T = getappdata(handles.Lumos,'table');
ind = 1;
NR = R{room};
NR.objects = [];
for i = 1:size(R{room}.objects,2)-1
    if i == object_nr
        ind = ind+1;
    end
    NR.objects{i} = R{room}.objects{ind};
    ind = ind+1;
end
R{room}= NR;
% save rooms
try
    setappdata(handles.Lumos,'room',R);
    %setappdata(handles.Lumos,'table',NT);
catch
    setappdata(handles.Lumos,'room',[]);
    %setappdata(handles.Lumos,'table',[]);
end

% set listbox
object_listbox(hObject, [], handles)
set(handles.listbox,'Value',1)

% refresh plots
refresh_2D(hObject, [], handles)
refresh_2D_objects(hObject, [], handles)
refresh_3DObjects(hObject, [], handles)


% table
guidata(hObject,handles)
object_table(hObject, [], handles)
handles = guidata(hObject);

guidata(hObject,handles)


function rename_room(hObject, listbox, handles,room_nr)
eventdata=[];
room = getappdata(handles.Lumos,'room');
room{room_nr} = rename_object(room{room_nr});
setappdata(handles.Lumos,'room',room);
room_tab_Callback(hObject, eventdata, handles)
guidata(hObject,handles)



function rename_room_object(hObject, listbox, handles,room_nr, object_nr)
eventdata=[];
room = getappdata(handles.Lumos,'room');
% user inut: new name
name = inputdlg({['rename ',room{room_nr}.objects{object_nr}.name]},'');
% set new name
room{room_nr}.objects{object_nr}.name = name{1};
setappdata(handles.Lumos,'room',room);
object_listbox(hObject, eventdata, handles)
guidata(hObject,handles)


function rename(hObject, eventdata, handles, room)
list = get(handles.listbox,'String');
% get room data
R = getappdata(handles.Lumos,'room');
for l = 1:size(list,1)
    if l ~= room
        newlist{l} = list{l,:};
    else
        newlist{room} = hObject.String;
    end
end
handles.listbox.String = newlist;
% set room name
R{room}.name = hObject.String;
% save room name
setappdata(handles.Lumos,'room',R)
delete(hObject)


function duplicate_room(hObject, listbox, handles,room)

R = getappdata(handles.Lumos,'room');
T = getappdata(handles.Lumos,'table');
ind = 1;
for i = 1:size(R,2)
    NR{ind} = R{i};
    list{ind} = R{i}.name;
    NT{ind} = T{i};
    if i == room
        ind = ind+1;
        NR{ind} = R{i};
        NR{ind}.name = [NR{ind}.name ' copy'];
        list{ind} = [R{i}.name,' copy'];
        NT{ind} = T{i};
    end
    ind = ind+1;
end
% save rooms
setappdata(handles.Lumos,'room',NR);
setappdata(handles.Lumos,'table',NT);
% set listbox
handles.listbox.String = list;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function view_CreateFcn(hObject, eventdata, handles)
% hObject    handle to view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
axis on
hold off
grid on
set(gca,'XMinorGrid','on');
set(gca,'YMinorGrid','on');
axis([-2 10 -2 10 0 5])
axis off
xlabel('x')
ylabel('y')
title('view')

guidata(hObject,handles)


% --------------------------------------------------------------------
function uitoggletool14_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool14_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uitoggletool14,'State','off')
for i=[5:8 10:11]
    str = ['set(handles.uitoggletool',num2str(i),',''State'',''off'')'];
    eval(str);
end
rotate3d off
pan off
zoom off

load_material(hObject,eventdata,handles)
guidata(hObject, handles)


% --------------------------------------------------------------------
function File_menu_Callback(hObject, eventdata, handles)
% hObject    handle to File_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uipushtool2_ClickedCallback(hObject, eventdata, handles)
guidata(hObject, guidata(hObject))


% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(spec_simulation)


% --------------------------------------------------------------------
function menu_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uipushtool3_ClickedCallback(hObject, eventdata, handles)
guidata(hObject, guidata(hObject))


% --- Executes on button press in material_tab.
function material_tab_Callback(hObject, eventdata, handles)
% hObject    handle to material_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

try
    table{handles.data.room}.table_mode = 'material';
catch
end
% (de)activate  tools
toggle_menu_buttons(hObject,handles,14)

table = getappdata(handles.Lumos,'table');

handles.data.room = 1;
table{handles.data.room}.table_mode = 'material';
% save data
setappdata(handles.Lumos,'table',table);

set(handles.listbox,'Value',3);

guidata(hObject, handles)
material_listbox(hObject,eventdata,handles)
handles = guidata(hObject);
material_table(hObject,eventdata,handles,[])
handles = guidata(hObject);

% plot
%plot_material(hObject,eventdata,handles, handles.data.room, 0, 0)
listbox_Callback(hObject, eventdata, handles)
plot_3D(hObject, eventdata, handles, 0, 0)

guidata(hObject, handles)


function material_listbox(hObject,eventdata,handles)
% get room data
room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end
ind = 1;
list = {};
% create room -> wall list
for r = 1:size(room,2)
    
    % bold font
    list{ind,1} = ['<html><b>',room{r}.name,'</b></html>'];
    ind = ind + 1;
    
    % environment ground
    try
        dummy = room{1}.environment_ground;
        list{ind,1} = ['    environment ground   [',room{r}.environment_ground.material.name,']'];
    catch
        list{ind,1} = ['    environment ground   [none]'];
    end
    ind = ind + 1;
    %ind = ind + 2;
        
    % floor
    try
        dummy = room{1}.floor.material;
        list{ind,1} = ['    floor   [',room{r}.floor.material.name,']'];
    catch
        list{ind,1} = ['    floor   [none]'];
    end
    ind = ind + 1;
    
    try
        for win = 1:size(room{r}.floor.windows,2)
            try
                dummy = room{r}.floor.windows{win}.material;
                list{ind,1} = ['        window ',num2str(win),'   [',room{r}.floor.windows{win}.material.name,']'] ;
            catch
                list{ind,1} = ['        window ',num2str(win),'   [none]'] ;
            end
            ind = ind + 1;
        end
    catch
    end
    

    for w = 1:size(room{r}.walls,2)
        try
            dummy = room{r}.walls{w}.material;
            list{ind,1} = ['    wall ',num2str(w),'   [',room{r}.walls{w}.material.name,']'] ;
        catch
            list{ind,1} = ['    wall ',num2str(w),'   [none]'] ;
        end
        ind = ind + 1;
        try
            for win = 1:size(room{r}.walls{w}.windows,2)
                try
                    dummy = room{r}.walls{w}.windows{win}.material;
                    list{ind,1} = ['        window ',num2str(win),'   [',room{r}.walls{w}.windows{win}.material.name,']'] ;
                catch
                    list{ind,1} = ['        window ',num2str(win),'   [none]'] ;
                end
                ind = ind + 1;
            end
        catch
        end
    end
    try
        dummy = room{r}.ceiling{1}.material;
        list{ind,1} = ['    ceiling   [',room{r}.ceiling{1}.material.name,']'];
    catch
        list{ind,1} = '    ceiling   [none]';
    end
    ind = ind + 1;
    
    for c = 1:size(room{r}.ceiling,2)
    try
        for win = 1:size(room{r}.ceiling{c}.windows,2)
            try
                dummy = room{r}.ceiling{c}.windows{win}.material;
                list{ind,1} = ['        window ',num2str(win),'   [',room{r}.ceiling{c}.windows{win}.material.name,']'] ;
            catch
                list{ind,1} = ['        window ',num2str(win),'   [none]'] ;
            end
            ind = ind + 1;
        end
    catch
    end
    end
    
    % add objects
    for o = 1:size(room{r}.objects,2)
        %comeback('add objects to material list')
        try
            list{ind,1} = ['    ',room{r}.objects{o}.name,'   [',room{r}.objects{o}.material.name,']'];
        catch
            list{ind,1} = ['    ',room{r}.objects{o}.name,'   [none]'];
        end
        ind = ind + 1;
    end
    
end
% update listbox
set(handles.listbox,'String',list)

guidata(hObject, handles)



function material_table(hObject,eventdata,handles,mat)

% get table data
data = getappdata(handles.Lumos,'material');

list = [];

str = get(handles.listbox,'String');
nr = get(handles.listbox,'Value');

% find already chosen material and switch on in table list
if ~isempty(str)
    matname = str{nr};
    start = findstr('[',matname)+1;
    stop  = findstr(']',matname)-1;
    material = matname(start:stop);
    for i = 1:size(data,2)
        if strcmp(data{i}.name{:},material)
            list{i,2} = true;
        else
            list{i,2} = false;
        end
    end
end

try
    handles.topview_point_table.Data(:,2) = list(:,2);
catch
end

for m = 1:size(data,2)
    list{m,1} = data{m}.cellfield;
    
    list{m,3} = data{m}.range{:};
    %rho = ciespec2Y(mat.data(1,:),mat.data(2,:),1)/100;
    try
        if isequal(m,find(cell2mat(handles.topview_point_table.Data(:,2))))
            list{m,4} = mat.rho;
        else
            list{m,4} = data{m}.rho;
        end
    catch
        try
            list{m,4} = ciespec2Y(data{m}.data(1,:),data{m}.data(2,:).*ciespec(data{m}.data(1,:),'A'))/ciespec2Y(data{m}.data(1,:),ciespec(data{m}.data(1,:),'A'));
        catch
            list{m,4}= [];
        end
    end
end





% set table configuration
set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnName',{'Material','Selection','Range','rho'})
set(handles.topview_point_table,'ColumnEditable',[false true false true true])
set(handles.topview_point_table,'ColumnFormat',{'char','logical','char','char'})


% set table data
handles.topview_point_table.Data = list;
guidata(hObject, handles)




function load_material(hObject,eventdata,handles)

[file,path] = uigetfile('*.txt','Load material data...','MultiSelect','on');
try % single file
    if file == 0
        guidata(hObject,handles)
        return
    end
    
    % load material data
    filename = [path file];
    material = load(filename);
    mat = getappdata(handles.Lumos,'material');
    nr = size(mat,2)+1;
    mat{nr}.name = {file(1:end-4)};
    mat{nr}.data = material;
    mat{nr}.range = {[num2str(material(1,1)),'-',num2str(material(1,end))]};
    mat{nr}.rho = cierho(material(1,:),material(2,:));
    rhoD65 = ciespec2Y(material(1,:),material(2,:).*ciespec(material(1,:),'D65'))/ciespec2Y(material(1,:),ciespec(material(1,:),'D65'));
    srgb = spec2srgb(mat{nr}.data(1,:),mat{nr}.data(2,:).*ciespec(mat{nr}.data(1,:),'D65'),'obj','D65');
    srgb = (srgb./max(srgb).*rhoD65).^(1/2.2); % gamma factor = sqrt(1/2.2)
    mat{nr}.color = srgb;
    if(sum(mat{nr}.color))< 1
        mat{nr}.cellfield = ['<html><table bgcolor=rgb(',num2str(round(255.*mat{nr}.color(1))),',',num2str(round(255.*mat{nr}.color(2))),',',num2str(round(255.*mat{nr}.color(3))),')><TR><TD><font color="#FFFFFF">',mat{nr}.name{1},'</TD></TR> </table>'];
    else
        mat{nr}.cellfield = ['<html><table bgcolor=rgb(',num2str(round(255.*mat{nr}.color(1))),',',num2str(round(255.*mat{nr}.color(2))),',',num2str(round(255.*mat{nr}.color(3))),')><TR><TD>',mat{nr}.name{1},'</TD></TR> </table>'];
    end
    setappdata(handles.Lumos,'material',mat)
    
catch % multiple files
    mat = getappdata(handles.Lumos,'material');
    nr = size(mat,2)+1;
    for i =1:size(file,2)
        % load material data
        filename = [path file{i}];
        mat{nr}.name = {file{i}(1:end-4)};
        mat{nr}.data = load(filename);
        mat{nr}.range = {[num2str(mat{nr}.data(1,1)),'-',num2str(mat{nr}.data(1,end))]};
        material = mat{nr}.data;
        mat{nr}.rho = cierho(material(1,:),material(2,:));
        rhoD65 = ciespec2Y(material(1,:),material(2,:).*ciespec(material(1,:),'D65'))/ciespec2Y(material(1,:),ciespec(material(1,:),'D65'));
        srgb = spec2srgb(mat{nr}.data(1,:),mat{nr}.data(2,:).*ciespec(mat{nr}.data(1,:),'D65'),'obj','D65');
        srgb = (srgb./max(srgb).*rhoD65).^(1/2.2); % gamma factor = sqrt(1/2.2)
        mat{nr}.color = srgb;
        if(sum(mat{nr}.color))< 1
            mat{nr}.cellfield = ['<html><table bgcolor=rgb(',num2str(round(255.*mat{nr}.color(1))),',',num2str(round(255.*mat{nr}.color(2))),',',num2str(round(255.*mat{nr}.color(3))),')><TR><TD><font color="#FFFFFF">',mat{nr}.name{1},'</TD></TR> </table>'];
        else
            mat{nr}.cellfield = ['<html><table bgcolor=rgb(',num2str(round(255.*mat{nr}.color(1))),',',num2str(round(255.*mat{nr}.color(2))),',',num2str(round(255.*mat{nr}.color(3))),')><TR><TD>',mat{nr}.name{1},'</TD></TR> </table>'];
        end
        nr = nr + 1;
    end
    setappdata(handles.Lumos,'material',mat)
    
end
% new table list of materials
list = [];
for m = 1:size(mat,2)
    list{m,1} = mat{m}.cellfield;
    list{m,2} = false;
    list{m,3} = mat{m}.range{:};
    list{m,4} = mat{m}.rho;
end

handles.topview_point_table.Data = list;
guidata(hObject,handles)




function plot_3D(hObject, eventdata, handles, w, window, cnum)

axes(handles.view)
cla
colorbar('off')
legend('off')

reset(handles.view)
view([315 30])

%try
%    wa = w;
%    dummy = window;
%catch
%    wa = -100;
%    window = 0;
%end
% get room data
room = getappdata(handles.Lumos,'room');
%table = getappdata(handles.Lumos,'table');

% clear old plots
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end
%set(gca,'XMinorGrid','on');
%set(gca,'YMinorGrid','on');
axis off
axis equal
title('')
hold on
% get table data
try
    % plot floor
    try
        data = room{handles.data.room}.floor.vertices;
        c = patch(data(:,1),data(:,2),data(:,3),[0.75 0.75 0.75]);
        set(c,'EdgeColor','none');
        c.FaceAlpha = 0.3;
        try
            if w == -1 && window == 0
                set(c,'FaceColor',handles.red);
            end
        catch
        end
        try
            for j = 1:size(room{handles.data.room}.floor.windows,2)
                wi = room{handles.data.room}.floor.windows{j}.data;
                if w == -1 && window == j
                    f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.red);
                else                 
                    f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.blue);
                end
                f.FaceAlpha = 0.5;
            end
        catch
        end
    catch
    end
    % plot walls
    try
        for seg = 1:numel(room{handles.data.room}.walls)
            data = room{handles.data.room}.walls{seg}.vertices;
            c(seg) = patch(data(:,1),data(:,2),data(:,3),[0.75 0.75 0.75]);
            c(seg).FaceAlpha = 0.3;
            try
                if w == seg && window == 0
                    set(c(seg),'FaceColor',handles.red);
                end
            catch
            end
            try
                for j = 1:size(room{handles.data.room}.walls{seg}.windows,2)
                    wi = room{handles.data.room}.walls{seg}.windows{j}.data;
                    if w == seg && window == j
                        f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.red);
                    else
                        f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.blue);
                    end
                    f.FaceAlpha = 0.5;
                end
            catch
            end
        end
    catch
    end
    % plot ceiling
    try
        for seg = 1:numel(room{handles.data.room}.ceiling)
                data = room{handles.data.room}.ceiling{seg}.vertices;
                c(seg) = patch(data(:,1),data(:,2),data(:,3),[0.75 0.75 0.75]);
                set(c(seg),'EdgeColor','none');
                c(seg).FaceAlpha = 0.3;
                try
                    if w == -2 && window == 0 && cnum == seg
                        set(c(seg),'FaceColor',handles.red);
                    end
                catch
                end
                try
                    for j = 1:size(room{handles.data.room}.ceiling{seg}.windows,2)
                        wi = room{handles.data.room}.ceiling{seg}.windows{j}.data;
                        if w == -2 && window == j && cnum == seg
                            f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.red);
                        else
                            f = fill3(wi(:,1),wi(:,2),wi(:,3),handles.blue);
                        end
                        f.FaceAlpha = 0.5;
                    end
                catch
                end
        end
    catch
    end
    
    % plot objects
    r = handles.data.room;
    try
        objs = room{r}.objects;
        plot_object(objs, [], handles.view, '3D', [0.25 0.25 0.25])
    catch ME
        catcher(ME)
        %comeback('no objects or error')
    end


    
catch
    axes(handles.view)
    reset(handles.view)
    plot(0,0);
    axis off
    text(0,0,'no room','HorizontalAlignment','center')
end

% update guidata
guidata(hObject, handles)


% --- Executes on button press in environment_tab.
function environment_tab_Callback(hObject, eventdata, handles)
% hObject    handle to environment_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

% (de)activate  tools
for i = [10:11 13:14 17 18 19]
    str = ['toggled = set(handles.uitoggletool',num2str(i),',''Enable'',''off'');'];
    eval(str);
    if strcmp(toggled,'on')
        handles.selected_tool = i;
    end
end
for i = 15
    str = ['toggled = set(handles.uitoggletool',num2str(i),',''Enable'',''on'');'];
    eval(str);
end
set(handles.listbox,'Value',1);
handles.data.room = 1;

% plot listbox and table
guidata(hObject, handles)
environment_listbox(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject, handles)
environment_table(hObject, eventdata, handles)
handles = guidata(hObject);

guidata(hObject, handles)



function environment_listbox(hObject, eventdata, handles)
% room list
room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end
list = [];
ind = 1;
nr = get(handles.listbox,'Value');
for i = 1:size(room,2)
    list{ind,1} = room{i}.name;
    if ind == nr
        handles.data.room = i;
    end
    ind = ind + 1;
    try
        for o = 1:size(room{i}.obstacles,2)
            list{ind,1} = ['    ',room{i}.obstacles{o}.name];
            if ind == nr
                handles.data.room = i;
            end
            ind = ind + 1;
        end
    catch
    end
end
set(handles.listbox,'String',list)
guidata(hObject, handles)



% --- Executes on button press in environment_tab.
function togglebutton9_Callback(hObject, eventdata, handles)
% hObject    handle to environment_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of environment_tab


% --- Executes during object creation, after setting all properties.
function topview_point_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to topview_point_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject, 'Data',[])
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool15_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

comeback('Add obstacles')
% get room data
room = getappdata(handles.Lumos,'room');
% get room nr
nr = handles.data.room;
try
    N = size(room{nr}.obstacles,2)+1;
catch
    N = 1;
end

room{nr}.obstacles{N}.name = ['obstacle ',num2str(N)];
room{nr}.obstacles{N}.data = [0 0 0 0 0 0]';
% save room data
setappdata(handles.Lumos,'room',room);
guidata(hObject, handles)
environment_listbox(hObject, eventdata, handles)
% update guidata
guidata(hObject, guidata(hObject))


% --------------------------------------------------------------------
function uitoggletool17_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% table update to get latest changes
%simulation_table_edit(hObject, eventdata, handles)
%handles = guidata(hObject);

% get data
room = getappdata(handles.Lumos,'room');
sky  = getappdata(handles.Lumos,'sky');
% save simulation table mode
table = getappdata(handles.Lumos,'table');
table{handles.data.room}.table_mode = 'simulation';

% start simulation
tic
axes(handles.topview)
result = [];
for r = 1:numel(room)
    numsky = numel(sky);
    for s = 0:numsky
        room{r}.result{s+1} = 0;
        check_enable = room{r}.enable;
        if check_enable
            % unwrap all surfaces in room
            surfaces = unwrap_surfaces(room{r});
            % get luminaires
            try
                try
                    [luminaire_surfaces,luminaires] = get_luminaire(room{r}.luminaire);
                catch
                    [~,luminaires] = get_luminaire(room{r}.luminaire);
                end
            catch
                luminaires = [];
                luminaire_surfaces = [];
            end
            for n = 1:numel(luminaire_surfaces)
               luminaire_surfaces{n}.type = 'luminaire'; 
            end
            surfaces = [surfaces luminaire_surfaces];
            % check that materials are assigned
            mat_check = 1;
            for c = 1:numel(surfaces)
                if (isempty(surfaces{c}.material) || strcmp(surfaces{c}.material.name,'none')) && ~strcmp(surfaces{c}.type,'window')
                    mat_check = 0;
                end
            end
            if isempty(room{r}.environment_ground)
               mat_check = 0; 
            end
            if ~mat_check
                warndlg('One or more surface does not have a material assigned!','Warning');
                return
            end
            try
                measurements = room{r}.measurement;
                for m = 1:numel(measurements)
                    if strcmp(measurements{m}.type,'area')
                        points = get_points(measurements{m});
                        area = measurements{m};
                        area.grid = cell(1,size(measurements{m}.points,1));
                        for n = 1:size(points,1)
                            p.coordinates = points(n,:);
                            p.azimuth = measurements{m}.azimuth;
                            p.elevation = measurements{m}.elevation;
                            p.normal = measurements{m}.normal;
                            p.name = [measurements{m}.name,' - point ',num2str(n)];
                            p.type = 'point';
                            area.grid{n} = p;
                        end
                        measurements{m} = area;
                    end
                end
            catch
                measurements = [];
            end
            % simulation information
            ground = room{r}.environment_ground;
            try
                ground.height = room{r}.height;
            catch
                ground.height = 0;
            end
            try
                ground.lambda = ground.material.data(1,:);
            catch
                ground.lambda = 0;
            end
            try
                ground.irradiance = zeros(size(ground.material.data(1,:)));
            catch
                ground.irradiance = 0;
            end
            try
                ground.radiance = zeros(size(ground.material.data(1,:)));
            catch
                ground.radiance = 0;
            end
            information.density = room{r}.density;
            information.reflections = room{r}.reflections;
            information.nord_angle = room{r}.nord_angle;
            try
                skydata = sky{s};
            catch
                skydata = [];
            end
            % actual radiosity simulation
            if (s~= 0 || ~isempty(luminaires))
                [calculation,ground,measurements] = surfaces_radiosity_calculation(surfaces,skydata,luminaires,ground,information,measurements);
                
                % save calculation
                result{r}.sky{s+1} = calculation;
                result{r}.ground{s+1} = ground;
                result{r}.measures{s+1} = measurements;
                % mark room-sky combo as calculated
                room{r}.result{s+1} = 1;
            else
                % save calculation
                result{r}.sky{s+1} = [];
                result{r}.ground{s+1} = [];
                result{r}.measures{s+1} = [];
                % mark room-sky combo as calculated
                room{r}.result{s+1} = 0;
            end
        end
    end
end
setappdata(handles.Lumos,'result',result)
setappdata(handles.Lumos,'room',room)
t = toc;
if t>360
    t = round(t/3600,2);
    postfix = ' h';
elseif t>60
    t = round(t/60,1);
    postfix = ' m';
else
    t = round(t);
    postfix = ' s';
end
disp(['Calcualtion time: ',num2str(t),postfix])


% simulation listbox refresh
guidata(hObject, handles)
simulation_listbox(hObject, eventdata, handles)
handles = guidata(hObject);

% activate "results" tab button
set(handles.results_tab,'Enable','on')

% plot selected room from listbox
axes(handles.view)
try
    if room{handles.data.room}.result{handles.data.sky}
        % plot results
        plotGouraud(result{handles.data.room}.sky{handles.data.sky},handles.view,handles.topview);
    else
        cla
        text(0.5,0.5,0.5,'no data','HorizontalAlignment','center')
        title('')
    end
catch ERROR
    % error message output
    comeback(['Error:',10])
    catcher(ERROR)
    
    cla
    text(0.5,0.5,0.5,'no data','HorizontalAlignment','center')
    title('')
    setappdata(handles.Lumos,'table',table);
end

setappdata(handles.Lumos,'table',table);
guidata(hObject, handles)



function surfaces = unwrap_surfaces(room)
ind = 1;
win_ind = 0;
surfaces = [];
surfaces{ind}.type = 'room';
surfaces{ind}.name = 'floor';
surfaces{ind}.vertices = room.floor.vertices;
surfaces{ind}.material = room.floor.material;
%surfaces{ind}.lambda = room.floor.material.data(1,:);
surfaces{ind}.blank = [];
surfaces{ind}.normal = room.floor.normal;
surfaces{ind}.mesh = [];
idx = ind;
try
    for win = 1:numel(room.floor.windows)
        ind = ind+1;
        surfaces{ind}.type = 'window';
        win_ind = win_ind+1;
        surfaces{ind}.name = ['window ',num2str(win_ind)];
        surfaces{ind}.vertices = room.floor.windows{win}.data;
        surfaces{ind}.material = room.floor.windows{win}.material;
        surfaces{ind}.blank = [];
        surfaces{ind}.normal = room.floor.normal;
        surfaces{ind}.mesh = [];
        surfaces{ind}.lambda = [];
        surfaces{ind}.E = [];
        surfaces{ind}.L = [];
        % parent surface blank area
        surfaces{idx}.blank = [surfaces{idx}.blank surfaces(ind)];
    end
catch
end
for w = 1:numel(room.walls)
    if isequal(sum(isnan(room.walls{w}.normal)),0)
        ind = ind+1;
        surfaces{ind}.type = 'room';
        surfaces{ind}.name = ['wall ',num2str(w)];
        surfaces{ind}.vertices = room.walls{w}.vertices;
        surfaces{ind}.material = room.walls{w}.material;
        surfaces{ind}.blank = [];
        surfaces{ind}.normal = room.walls{w}.normal;
        surfaces{ind}.mesh = [];
        surfaces{ind}.lambda = [];
        surfaces{ind}.E = [];
        surfaces{ind}.L = [];
        idx = ind;
    end
    try
        for win = 1:numel(room.walls{w}.windows)
            ind = ind+1;
            surfaces{ind}.type = 'window';
            win_ind = win_ind+1;
            surfaces{ind}.name = ['window ',num2str(win_ind)];
            surfaces{ind}.vertices = room.walls{w}.windows{win}.data;
            surfaces{ind}.material = room.walls{w}.windows{win}.material;
            surfaces{ind}.blank = [];
            surfaces{ind}.normal = room.walls{w}.normal;
            surfaces{ind}.mesh = [];
            surfaces{ind}.lambda = [];
            surfaces{ind}.E = [];
            surfaces{ind}.L = [];
            % parent surface blank area
            surfaces{idx}.blank = [surfaces{idx}.blank surfaces(ind)];
        end
    catch
    end
end
for c = 1:numel(room.ceiling)
    ind = ind+1;
    surfaces{ind}.type = 'room';
    surfaces{ind}.name = ['ceiling ',num2str(c)];
    surfaces{ind}.vertices = room.ceiling{c}.vertices;
    surfaces{ind}.material = room.ceiling{c}.material;
    surfaces{ind}.blank = [];
    surfaces{ind}.normal = room.ceiling{c}.normal;
    surfaces{ind}.mesh = [];
    surfaces{ind}.lambda = [];
    surfaces{ind}.E = [];
    surfaces{ind}.L = [];
    idx = ind;
    try
        for win = 1:numel(room.ceiling{c}.windows)
            ind = ind+1;
            surfaces{ind}.type = 'window';
            win_ind = win_ind+1;
            surfaces{ind}.name = ['window ',num2str(win_ind)];
            surfaces{ind}.vertices = room.ceiling{c}.windows{win}.data;
            surfaces{ind}.material = room.ceiling{c}.windows{win}.material;
            surfaces{ind}.blank = [];
            surfaces{ind}.normal = room.ceiling{c}.normal;
            surfaces{ind}.mesh = [];
            surfaces{ind}.lambda = [];
            surfaces{ind}.E = [];
            surfaces{ind}.L = [];
            % parent surface blank area
            surfaces{idx}.blank = [surfaces{idx}.blank surfaces(ind)];
        end
    catch
    end
end
% objects
[S,O] = get_objects_surfaces(room.objects);

% check if objects intersect with surfaces
for n = 1:numel(O)
    s1 = size(O{n}.geometry{1},1);
    edges1 = zeros(3*(s1-1),3);
    edges2 = zeros(3*(s1-1),3);
    % create object x,y edges
    idx = 1;
    for e = 1:s1-1
        edges1(idx,:) = O{n}.geometry{1}(e,1:3);
        edges2(idx,:) = O{n}.geometry{1}(e+1,1:3);
        edges1(idx+1,:) = O{n}.geometry{1}(e,4:6);
        edges2(idx+1,:) = O{n}.geometry{1}(e+1,4:6);
        idx = idx+2;
    end
    % create object z edges
    for e = 1:s1-1
        edges1(idx,:) = O{n}.geometry{1}(e,1:3);
        edges2(idx,:) = O{n}.geometry{1}(e,4:6);
        idx = idx+1;
    end

    % check for surface intersections

    % loop over all room surfaces
    for m = 1:numel(surfaces)

        try

            % check if edges have intersection with surface
            r = dot(edges2-edges1,repmat(surfaces{m}.normal,size(edges1,1),1),2);
            P = dot(edges1-surfaces{m}.vertices(1,:),repmat(surfaces{m}.normal,size(edges1,1),1),2);
            a = -P./r;
            a(isinf(a)) = NaN;
            a(a>1) = NaN;
            a(a<0) = NaN;
            in = any(~isnan(a),2);
            a(isnan(a)) = 0;
            c = edges1+a.*(edges2-edges1);
            cand = c(in,:);
            idx = c_quickhull(c(in,:));
            idx = idx(1:end-1);

            % check that intersection points lie within surface polygon
            % normal vector
            normal = surfaces{m}.normal;
            % plane elevation rotation angle
            [~,elevation,~] = cart2sph(normal(1),normal(2),normal(3));
            % rotate parallel to y-z-axis
            if ~isnan(elevation) && ~isequal(elevation,0)
                % rotation matrix
                if abs(normal(3)) == 1
                    rotax = [0 1 0];
                    R1 = makehgtform('axisrotate',rotax,pi/2);
                    %R1 = rotMatrix([0 rad2deg(pi/2) 0]);
                else
                    rotax = cross(normal,[0 0 1]);
                    R1 = makehgtform('axisrotate',rotax,-elevation);
                    %R1 = rotMatrix([0 0 rad2deg(-elevation)]);

                end
            else
                R1 = eye(3);
            end
            R1 = R1(1:3,1:3);
            newnorm = surfaces{m}.normal*R1;
            [azimuth,~,~] = cart2sph(newnorm(1),newnorm(2),newnorm(3));
            if ~isequal(mod(azimuth,pi),0)
                %R2 = rotMatrix([0 0 rad2deg(azimuth)]);
                R2 = makehgtform('axisrotate',[0 0 1],-azimuth);
            else
                R2 = eye(3);
            end
            R2 = R2(1:3,1:3);
            % rearange data structure and rotate intersection plane
            rip = (R1*R2*cand(idx,:)')';
            % rotate blocking surface vertices
            polyg = (R1*R2*surfaces{m}.vertices')';
            % check if intersection point is inside surface polygon
            in = inpolygon(rip(:,2),rip(:,3),polyg(:,2),polyg(:,3));
            vertices = cand(idx,:);
            vertices(~in,:) = [];
            try
                vertices = [vertices;vertices(1,:)];
            catch
            end

            if ~isempty(vertices)
                blank.type = 'hole';
                blank.name = ['hole ',num2str(numel(surfaces{m}.blank)+1)];
                blank.vertices = vertices;
                blank.material = surfaces{m}.material;
                try
                    blank.material.data(2,:) = zeros(size(blank.material.data(2,:)));
                catch
                end
                blank.blank = [];
                blank.normal = surfaces{m}.normal;
                blank.mesh = [];
                blank.lambda = [];
                blank.E = [];
                blank.L = [];
                surfaces{m}.blank = [surfaces{m}.blank {blank}];
            end
        catch
            continue
        end
    end
end
% check if object intersect with other objects

surfaces = [surfaces S];



function [surfaces,objects] = get_luminaire(objs,M,co,d,origin,s,material,O)
if ~exist('co','var')
    co = [0 0 0];
end
if ~exist('d','var')
    d = [0 0 0];
end
if ~exist('M','var')
    M = eye(3);
end
if ~exist('s','var')
    s = [];
end
if ~exist('O','var')
    O = [];
end
% loop over group objects
for o = 1:numel(objs)
    try
        if ~exist('material','var')
            material = objs{o}.spectrum;
        end
        if ~isempty(objs{o}.spectrum)
            material = objs{o}.spectrum;
        end
    catch
        material = [];
    end
    if strcmp(objs{o}.type,'group')
        % recursive function call
        c = objs{o}.coordinates+co;
        if ~exist('origin','var')
            origin = c;
        end
        rot = rotate_object(objs{o},origin);
        M2 = M*rot;
        [s,O] = get_luminaire(objs{o}.objects,M2,c,d,origin,s,material,O);
    else
        % get coordinates
        c = objs{o}.coordinates;
        if ~exist('origin','var')
            origin = c;
        end
        [S,Ob] = get_single_luminaire(objs{o},co,M,origin,material);
        s = [s S];
        O = [O {Ob}];
    end
end
surfaces = s;
objects = O;




function [surfaces,obj] = get_single_luminaire(obj,c,rot,origin,material)
if ~exist('rot','var')
    rot = eye(3);
end
if ~exist('origin','var')
    origin = obj.coordinates;
end
    if ~exist('material','var')
        material = obj.material;
    end
try
    co = obj.coordinates+c-origin;
catch
    co = [0 0 0];
end
g = obj.geometry{1};
g = [g;g(1,:)];
offset = max(g)./2;
g(:,1) = g(:,1)-offset(:,1);
g(:,2) = g(:,2)-offset(:,2);
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

g1 = (g1*rot)+origin;
g2 = (g2*rot)+origin;

obj.geometry{1} = [g1 g2];
obj.coordinates = obj.coordinates+c;
obj.material = material;
surfaces = get_object_surfaces(g1,g2,obj);



function [surfaces,objects] = get_objects_surfaces(objs,M,co,d,origin,s,material,O)
if ~exist('co','var')
    co = [0 0 0];
end
if ~exist('d','var')
    d = [0 0 0];
end
if ~exist('M','var')
    M = eye(3);
end
if ~exist('s','var')
    s = [];
end
if ~exist('O','var')
    O = [];
end
% loop over group objects
for o = 1:numel(objs)
    if ~exist('material','var')
        material = objs{o}.material;
    end
    if ~isempty(objs{o}.material)
         material = objs{o}.material;
    end
    if strcmp(objs{o}.type,'group')
        % recursive function call
        c = objs{o}.coordinates+co;
        if ~exist('origin','var')
            origin = c;
        end
        rot = rotate_object(objs{o},origin);
        M2 = M*rot;
        s = get_objects_surfaces(objs{o}.objects,M2,c,d,origin,s,material,O);
        
    else
        % get coordinates
        c = objs{o}.coordinates;
        if ~exist('origin','var')
            origin = c;
        end
        [S,Ob] = get_single_object_surfaces(objs{o},co,M,origin,material);
        s = [s S];
        O = [O {Ob}];
    end
end
surfaces = s;
objects = O;



function [surfaces,obj] = get_single_object_surfaces(obj,c,rot,origin,material)
if ~exist('rot','var')
    rot = eye(3);
end
if ~exist('origin','var')
    origin = obj.coordinates;
end
    if ~exist('material','var')
        material = obj.material;
    end
try
    co = obj.coordinates+c-origin;
catch
    co = [0 0 0];
end
g = obj.geometry{1};
g = [g;g(1,:)];
offset = max(g)./2;
g(:,1) = g(:,1)-offset(:,1);
g(:,2) = g(:,2)-offset(:,2);
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

g1 = (g1*rot)+origin;
g2 = (g2*rot)+origin;

obj.geometry{1} = [g1 g2];
obj.coordinates = obj.coordinates+c;
obj.rotation = [0 0 0];
obj.material = material;
surfaces = get_object_surfaces(g1,g2,obj);


function object =  get_object_surfaces(data1,data2,obj)
try
    for w = 1:size(data1,1)-1
        
        x = [data1(w,1) data1(w+1,1) data2(w+1,1) data2(w,1) data1(w,1)];
        y = [data1(w,2) data1(w+1,2) data2(w+1,2) data2(w,2) data1(w,2)];
        z = [data1(w,3) data1(w+1,3) data2(w+1,3) data2(w,3) data1(w,3)];
        % crate object struct
        object{w}.type = 'object';
        object{w}.name = [obj.name,' ',num2str(w)];
        object{w}.vertices = [x' y' z'];
        object{w}.vertices = unique(object{w}.vertices,'rows','stable');
        object{w}.vertices  = [object{w}.vertices;object{w}.vertices(1,:)];
        object{w}.material = obj.material;
        %object{w}.lambda = obj.material.data(1,:);
        object{w}.normal = normalv([x' y' z']);
        object{w}.blank = [];
        object{w}.mesh = [];
        object{w}.lambda = [];
        object{w}.E = [];
        object{w}.L = [];
    end
    bottom = seperate_segments(data1,obj);
    for k = 1:numel(bottom)
        bottom{k}.type = 'object';
        bottom{k}.material = obj.material;
        %bottom{k}.normal = -bottom{k}.normal;
    end
    object = [object bottom];
    top = seperate_segments(data2,obj);
    for k = 1:numel(top)
        top{k}.type = 'object';
        top{k}.material = obj.material;
        top{k}.normal = -top{k}.normal;
    end
    object = [object top];
catch
    object = [];
end
    
    
function S = seperate_segments(data,obj)
x = data(:,1);
y = data(:,2);
% segment triangulation
ctri = delaunay(x,y);
% ensure clockwise triangles
for t = 1:size(ctri,1)
    T = data(ctri(t,:),:);
    idx = c_quickhull(T(:,1:2));
    ctri(t,:) = ctri(t,idx(1:end-1));
end


ind = 1;
% combine neighbouring segments with same normal direction
not = [];
n = 0;
vec = 1:size(ctri,1);

for seg = vec
    if ismember(seg,not)
        continue
    end
    if ~inpolygon(mean(data(ctri(seg,:),1)),mean(data(ctri(seg,:),2)),data(:,1),data(:,2))
        continue
    end
    
    % new segment
    n = n+1;
    segment{n} = data(ctri(seg,:),:);
    again = [];
    % for every patch loop over all other segments
    try
    for oseg = vec(vec~=seg)
        if ismember(oseg,not)
            continue
        end
        if inpolygon(mean(data(ctri(oseg,:),1)),mean(data(ctri(oseg,:),2)),data(:,1),data(:,2))
            % segment normals
            w.vertices = segment{n};
            ow.vertices = data(ctri(oseg,:),:);

            normal = round(normalv(w.vertices),12);
            onormal = round(normalv(ow.vertices),12);
            % compare normal vectors
            if isequal(sum(normal == onormal),3)
                
                % check matching points
                match = ismember(w.vertices,ow.vertices,'rows');
                omatch = ismember(ow.vertices,w.vertices,'rows');
                % if 2 points match, they are are neighbour patches
                if sum(match) >= 2
                    % delete other patch from list
                    not = [not oseg];
                    % index of matching points
                    a = find(match==1,2);
                    b = find(omatch==0,1);
                    
                    % add additional point to patch
                    if isequal(abs(a(2)-a(1)),1)
                        wpart1 = segment{n}(1:a(1),:);
                        wpart2 = segment{n}(a(1)+1:end,:);
                        owpart = ow.vertices(b(1),:);
                    else
                        wpart1 = segment{n}(1:end,:);
                        wpart2 = [];
                        owpart = ow.vertices(b(1),:);
                    end
                    segment{n} = [wpart1; owpart; wpart2];
                else
                    % repeat patch comparement
                    again = [again oseg];
                end
                
                % repeat loop for patch comparement
                for oseg = again
                    if ismember(oseg,not)
                        continue
                    end
                    % segment normals
                    w.vertices = segment{n};
                    ow.vertices = data(ctri(oseg,:),:);

                    normal = round(normalv(w.vertices),12);
                    onormal = round(normalv(ow.vertices),12);
                    % compare normal vectors
                    if isequal(sum(normal == onormal),3)
                        % check matching points
                        match = ismember(w.vertices,ow.vertices,'rows');
                        omatch = ismember(ow.vertices,w.vertices,'rows');
                        % if 2 points match, they are are neighbour patches
                        if sum(match) >= 2
                            % delete other patch from list
                            not = [not oseg];
                            % index of mathing points
                            a = find(match==1,2);
                            b = find(omatch==0,1);
                            
                            % add additional point to patch
                            if isequal(abs(a(2)-a(1)),1)
                                wpart1 = segment{n}(1:a(1),:);
                                wpart2 = segment{n}(a(1)+1:end,:);
                                owpart = ow.vertices(b(1),:);
                            else
                                wpart1 = segment{n}(1:end,:);
                                wpart2 = [];
                                owpart = ow.vertices(b(1),:);
                            end
                            segment{n} = [wpart1; owpart; wpart2];
                        end
                    end
                end
            end
        end
    end
    catch me
        catcher(me)
    end
    segment{n} = [segment{n};segment{n}(1,:)];
    S{n}.type = [];
    S{n}.name = [obj.name,' ',num2str(n)];
    S{n}.vertices = segment{n};
    %S{n}.nr = n;
    S{n}.material = [];
    S{n}.normal = normalv(segment{n});
    S{n}.blank = [];
    S{n}.mesh = [];
    S{n}.lambda = [];
    S{n}.E = [];
    S{n}.L = [];
end







% --- Executes on button press in simulation_tab.
function simulation_tab_Callback(hObject, eventdata, handles)
% hObject    handle to simulation_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

table = getappdata(handles.Lumos,'table');
%try
%    table{handles.data.room}.table_mode = 'simulation';
%catch
%end
% (de)activate  tools
toggle_menu_buttons(hObject,handles,17)


try
    table{handles.data.room}.table_mode = 'simulation';
catch
end
setappdata(handles.Lumos,'table',table)

guidata(hObject, handles)
simulation_table(hObject, eventdata, handles)
handles = guidata(hObject);


simulation_listbox(hObject, eventdata, handles)
handles = guidata(hObject);

%set(handles.listbox,'Value',2)
handles.data.sky = 1;
handles.data.room = 1;
simulation_listbox_callback(hObject, eventdata, handles)

guidata(hObject, handles)


function simulation_listbox(hObject, eventdata, handles)

room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end

sky = getappdata(handles.Lumos,'sky');
results = getappdata(handles.Lumos,'result');

entry = get(handles.listbox,'Value');

list = [];
ind = 1;
% loop over list entries
for r = 1:length(room)
    
    try
        if room{r}.result{1}
            % &nbsp;&nbsp;&nbsp;
            list{ind} = ['<html><b>',room{r}.name,'</b></html>'];
        else
            list{ind} = ['',room{r}.name];
        end
        
    catch
        list{ind} = ['',room{r}.name];
    end
    
    ind = ind+1;
    
    try
    for s = 1:size(sky,2)
        try
        if room{r}.result{1}
            list{ind} = ['<html><b>&nbsp;&nbsp;&nbsp;',sky{s}.filename,'</b></html>'];
        else
            list{ind} = ['   ',sky{s}.filename];
        end
        catch
             list{ind} = ['   ',sky{s}.filename];
        end

        if isequal(ind,entry)
            handles.data.room = r;
            handles.data.sky = s;
        end
        
        ind = ind+1;
        
    end
    catch
    end
    
end

if isempty(room)
    set(handles.listbox,'String',[])
    set(handles.listbox,'Value',1)
else
    set(handles.listbox,'String',list)
    set(handles.listbox,'Value',1)
end
guidata(hObject, handles)



function simulation_table(hObject, eventdata, handles)

clnformat = {'numeric','numeric','numeric','numeric','numeric'};
set(handles.topview_point_table,'ColumnFormat',clnformat)

room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end
sky  = getappdata(handles.Lumos,'sky');
list = [];
ind = 1;
dens = [];
refl = [];

for r = 1:size(room,2)
    try
        list{1,r} = room{r}.density;
    catch
        list{1,r} = 5;
    end
    try
        list{2,r} = room{r}.reflections;
    catch
        list{2,r} = 2;
    end
    try
        list{3,r} = room{r}.nord_angle;
    catch
        list{3,r} = 0;
    end
    try
        list{4,r} = room{r}.height;
    catch
        list{4,r} = 0;
    end
    try
        list{5,r} = room{r}.enable;
        if isempty(list{5,r})
            list{5,r} = 1;
        end
    catch
        list{5,r} = 0;
    end
    check = 0;

end
    
rows = [];
rows = {'dens','refl','N°','h','sim'};


columns = [];
%clnformat = [];
for r = 1:size(room,2)
    %skyfrm = repmat({'logical'},size(sky,2),1);
    columns{r} = room{r}.name;
    editable(r) = true;
end

% set table data
set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'RowName',columns)
set(handles.topview_point_table,'ColumnName',rows)

try
    list{5,:} = logical(list{5,:});
    set(handles.topview_point_table,'Data',list')
    set(handles.topview_point_table,'ColumnEditable',editable)
catch
   %list{5} = false; 
   %set(handles.topview_point_table,'Data',list')
end

clnformat = {'numeric','numeric','numeric','numeric','logical'};
set(handles.topview_point_table,'ColumnFormat',clnformat)
    
guidata(hObject, handles)


% --- Executes on button press in observer_tab.
function observer_tab_Callback(hObject, eventdata, handles)
% hObject    handle to observer_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

table = getappdata(handles.Lumos,'table');
try
    table{handles.data.room}.table_mode = 'observer';
catch
end
setappdata(handles.Lumos,'table',table)

% (de)activate  tools
toggle_menu_buttons(hObject,handles,[24 32 33 18]) % 18


handles.data.room = 1;

try
    table = getappdata(handles.Lumos,'table');
    table{handles.data.room}.table_mode = 'observer';
    setappdata(handles.Lumos,'table',table);
    % list, plot
    guidata(hObject,handles)
    observer_listbox(hObject, eventdata, handles)
    handles = guidata(hObject);
    guidata(hObject,handles)
    observer_table(hObject,eventdata,handles)
    handles = guidata(hObject);
    guidata(hObject, handles)
    axes(handles.view)
    %plot_3D(hObject, eventdata, handles, -100, 0)
    refresh_3DObjects(hObject, eventdata, handles)
    plot_observer(hObject, eventdata, handles)
    handles = guidata(hObject);
    plot_area(hObject, eventdata, handles)
    % plot observers
    axes(handles.topview)
    guidata(hObject,handles)
    refresh_2D(hObject, eventdata, handles)
    refresh_2D_objects(hObject, eventdata, handles)
    handles = guidata(hObject);
    plot_observer(hObject, eventdata, handles)
    plot_area(hObject, eventdata, handles)
catch me
    %catcher(me)
end
guidata(hObject,handles)


function observer_listbox(hObject, eventdata, handles)

% make list
[~,~, list] = observer_room_nr(handles);
set(handles.listbox,'String',list)
set(handles.listbox,'Value',1)
handles = guidata(hObject);
guidata(hObject,handles)


function observer_listbox_callback(hObject, eventdata, handles)
%comeback('listbox callback')
room = getappdata(handles.Lumos,'room');
if size(room,1) > size(room,2)
    room = room';
end

% room nr
[handles.data.room, observer_nr, ~] = observer_room_nr(handles);
observer_table(hObject,eventdata,handles,observer_nr)
% plot observers
axes(handles.view)
refresh_3DObjects(hObject, eventdata, handles)
plot_observer(hObject, eventdata, handles, observer_nr)
plot_area(hObject, eventdata, handles, observer_nr)

refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
handles = guidata(hObject);
plot_observer(hObject, eventdata, handles, observer_nr)
plot_area(hObject, eventdata, handles, observer_nr)
guidata(hObject,handles)


function plot_observer(hObject, eventdata, handles, nr, mode)

if ~exist('nr','var')
    nr = [];
end
if ~exist('mode','var')
    mode = 'all';
end

try
    hold on
    
    data = [];
    room = getappdata(handles.Lumos,'room');
    try
        for o = 1:max(size(room{handles.data.room}.measurement))
            data(o,:) = [room{handles.data.room}.measurement{o}.coordinates room{handles.data.room}.measurement{o}.azimuth room{handles.data.room}.measurement{o}.elevation];
        end
    catch
        data = [];
    end
    for p = 1:size(data,1)
        if (strcmp(room{handles.data.room}.measurement{p}.type,'point') || strcmp(room{handles.data.room}.measurement{p}.type,'DF') || strcmp(room{handles.data.room}.measurement{p}.type,'observer'))
            if strcmp(room{handles.data.room}.measurement{p}.type,'point')
                try
                    if isequal(p,nr)
                        color = handles.red;
                        line = 2;
                        mark = 15;
                    else
                        color = handles.blue;
                        line = 1;
                        mark = 10;
                    end
                catch
                    color = handles.blue;
                    line = 1;
                    mark = 10;
                end
            elseif strcmp(room{handles.data.room}.measurement{p}.type,'DF')
                try
                    if isequal(p,nr)
                        color = handles.red;
                        line = 2;
                        mark = 15;
                    else
                        color = handles.orange;
                        line = 1;
                        mark = 10;
                    end
                catch
                    color = handles.orange;
                    line = 1;
                    mark = 10;
                end
            
                elseif strcmp(room{handles.data.room}.measurement{p}.type,'observer')
                try
                    if isequal(p,nr)
                        color = handles.red;
                        line = 2;
                        mark = 15;
                    else
                        color = handles.green;
                        line = 1;
                        mark = 10;
                    end
                catch
                    color = handles.green;
                    line = 1;
                    mark = 10;
                end
            
            end
            
            if strcmp(room{handles.data.room}.measurement{p}.type,mode) || strcmp(mode,'all')
                % observer point
                plot3(data(p,1),data(p,2),data(p,3),'.','Color',color,'MarkerSize',mark)
                % viewing direction
                a1 = plot3([data(p,1) data(p,1)],[data(p,2) data(p,2)+0.5],[data(p,3) data(p,3)],'Color',color,'Linewidth',line);
                % arrow head
                a2 = plot3([data(p,1)-0.15 data(p,1) data(p,1)+0.15],[data(p,2)+0.35  data(p,2)+0.5 data(p,2)+0.35],[data(p,3) ,data(p,3) ,data(p,3)],'Color',color,'Linewidth',line);
                % rotate in viewing direction
                rotate(a1,[1 0 0],data(p,5),[data(p,1) data(p,2) data(p,3)])
                rotate(a2,[1 0 0],data(p,5),[data(p,1) data(p,2) data(p,3)])
                rotate(a1,[0 0 1],data(p,4),[data(p,1) data(p,2) data(p,3)])
                rotate(a2,[0 0 1],data(p,4),[data(p,1) data(p,2) data(p,3)])
            end
        end 
    end
    hold off
catch me
    catcher(me)
    hold off
end
guidata(hObject,handles)


function uitoggletool18_ClickedCallback(hObject, eventdata, handles, room_nr)
% hObject    handle to uitoggletool18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%comeback('add observer')
room = getappdata(handles.Lumos,'room');

% room nr
try
    R = room_nr;
catch
    R = observer_room_nr(handles);
end

% add observer
try
    nr = size(room{R}.measurement,2)+1;
    room{R}.measurement{nr}.coordinates = [0 0 0];
    room{R}.measurement{nr}.azimuth = 0;
    room{R}.measurement{nr}.elevation = 0;
    room{R}.measurement{nr}.normal = [0 1 0];
    room{R}.measurement{nr}.name = ['observer ',num2str(nr)];
    room{R}.measurement{nr}.type = 'observer';
catch
    room{R}.measurement{1}.coordinates = [0 0 0];
    room{R}.measurement{1}.azimuth = 0;
    room{R}.measurement{1}.elevation = 0;
    room{R}.measurement{1}.normal = [0 1 0];
    room{R}.measurement{1}.name = 'observer 1';
    room{R}.measurement{1}.type = 'observer';
end
% Save data
setappdata(handles.Lumos,'room',room)
guidata(hObject, handles)
% update list, table and plots
observer_listbox(hObject, eventdata, handles)
observer_table(hObject,eventdata,handles)
plot_observer(hObject, eventdata, handles)
handles = guidata(hObject);

guidata(hObject,handles)


function observer_table(hObject,eventdata,handles,nr)
%comeback('observer table list')

% get table data
room = getappdata(handles.Lumos,'room');

if exist('nr','var') && ~isempty(nr)
    mode = room{handles.data.room}.measurement{nr}.type;
else
    mode = 'point';
end

switch mode
    case 'point'
        % set table configuration
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnName',{room{handles.data.room}.name,'x','y','z','az °','el °'})
        set(handles.topview_point_table,'ColumnEditable',[true true true true true true])
        set(handles.topview_point_table,'ColumnFormat',{'char','char','char','char','char','char'})
        try
            for o = 1:max(size(room{handles.data.room}.measurement))
                data{o,1} = room{handles.data.room}.measurement{o}.name;
                data{o,2} = room{handles.data.room}.measurement{o}.coordinates(1);
                data{o,3} = room{handles.data.room}.measurement{o}.coordinates(2);
                data{o,4} = room{handles.data.room}.measurement{o}.coordinates(3);
                data{o,5} = room{handles.data.room}.measurement{o}.azimuth;
                data{o,6} = room{handles.data.room}.measurement{o}.elevation;
            end
            % set table data
            set(handles.topview_point_table,'Data',data)
        catch
        end

    case 'area'
        % set table configuration
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnName',{'name','width x','length y','points in x','points in y','DIN'})
        set(handles.topview_point_table,'ColumnEditable',[false true true true true true])
        set(handles.topview_point_table,'ColumnFormat',{'char','numeric','numeric','numeric','numeric','logical'})
        data{1,1} = room{handles.data.room}.measurement{nr}.name;
        data{1,2} = room{handles.data.room}.measurement{nr}.width;
        data{1,3} = room{handles.data.room}.measurement{nr}.length;
        data{1,4} = room{handles.data.room}.measurement{nr}.pointsx;
        data{1,5} = room{handles.data.room}.measurement{nr}.pointsy;
        data{1,6} = room{handles.data.room}.measurement{nr}.DINpoints;
        data{1,6}= logical(data{1,6});
        % set table data
        set(handles.topview_point_table,'Data',data)
end
guidata(hObject, handles)




function luminaire_table(hObject,eventdata,handles)
%comeback('observer table list')

% get table data
room = getappdata(handles.Lumos,'room');

% check if room or luminaire is selected
nr = handles.listbox.Value;
[room_nr, lum_nr, ~, type] = lum_room_nr(handles, nr);

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
        set(handles.topview_point_table,'ColumnName',{'model','select','spectrum','select','dimming',})
        set(handles.topview_point_table,'ColumnEditable',[true true false true true])
        set(handles.topview_point_table,'ColumnFormat',{'char','logical','char','logical','numeric'})
       
        ldt = getappdata(handles.Lumos,'ldt');
        spectra = getappdata(handles.Lumos,'spectra');
        
        try
            n = max(numel(ldt),numel(spectra));
            data = cell(n,5);
            for L = 1:numel(ldt)
                data{L,1} = ldt{L}.name;
                try
                if strcmp(room{room_nr}.luminaire{lum_nr}.ldt.name,ldt{L}.name)
                    data{L,2} = true;
                else
                    data{L,2} = false;
                end
                catch
                    data{L,2} = false;
                end
            end
            for L = 1:numel(spectra)
                data{L,3} = spectra{L}.name;
                try
                if strcmp(room{room_nr}.luminaire{lum_nr}.spectrum.name,spectra{L}.name)
                    data{L,4} = true;
                else
                    data{L,4} = false;
                end
                catch
                    data{L,4} = false;
                end
                %data{L,5} = spectra{L}.range;
                try
                    data{L,5} = num2str(room{room_nr}.luminaire{lum_nr}.dimming);
                catch
                    data{L,5} = 1;
                end

            end
            % set table data
            set(handles.topview_point_table,'Data',data)
        catch me
            catcher(me)
        end
end
guidata(hObject, handles)




function delete_observer(hObject,eventdata,handles, selected)

room = getappdata(handles.Lumos,'room');
% room and observer nr
[room_nr, observer_nr, ~] = observer_room_nr(handles, selected);
observer_backup = room{room_nr}.measurement;
room{room_nr}.measurement = [];
% delete observer
ind = 1;
for ob = 1:max(size(observer_backup))
    if ~isequal(ob,observer_nr)
        room{room_nr}.measurement{ind} = observer_backup{ob};
        ind = ind+1;
    end
end
% save data
setappdata(handles.Lumos,'room',room);
% uodate plots
guidata(hObject, handles)
observer_listbox(hObject, eventdata, handles)
handles = guidata(hObject);
guidata(hObject,handles)
observer_table(hObject,eventdata,handles)
refresh_3DObjects(hObject, eventdata, handles)
plot_observer(hObject, eventdata, handles)
%handles = guidata(hObject);
plot_area(hObject, eventdata, handles)
% plot observers
axes(handles.topview)
%guidata(hObject,handles)
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
%handles = guidata(hObject);
plot_observer(hObject, eventdata, handles)
plot_area(hObject, eventdata, handles)
%handles = guidata(hObject);
guidata(hObject,handles)


function rename_observer(hObject,eventdata,handles, nr)
room = getappdata(handles.Lumos,'room');
% get room nr
[room_nr, observer_nr, ~] = observer_room_nr(handles,nr);
room{room_nr}.measurement{observer_nr} = rename_object(room{room_nr}.measurement{observer_nr});
setappdata(handles.Lumos,'room',room);
guidata(hObject,handles)
observer_listbox(hObject, eventdata, handles)
observer_listbox_callback(hObject, eventdata, handles)
guidata(hObject,handles)




function delete_luminaire(hObject,eventdata,handles, selected)

room = getappdata(handles.Lumos,'room');
% room and observer nr
[room_nr, lum_nr, ~] = lum_room_nr(handles, selected);
lum_backup = room{room_nr}.luminaire;
room{room_nr}.luminaire = [];
% delete luminaire
ind = 1;
for ob = 1:max(size(lum_backup))
    if ~isequal(ob,lum_nr)
        room{room_nr}.luminaire{ind} = lum_backup{ob};
        ind = ind+1;
    end
end
% save data
setappdata(handles.Lumos,'room',room);
% update plots
guidata(hObject, handles)
handles = guidata(hObject);
%observer_listbox(hObject, eventdata, handles)
[~, ~, list] = lum_room_nr(handles, selected);
set(handles.listbox,'String',list);
set(handles.listbox,'Value',1);
handles = guidata(hObject);
guidata(hObject,handles)
luminaire_table(hObject,eventdata,handles)
plot_luminaire(handles,eventdata,hObject)
handles = guidata(hObject);
guidata(hObject,handles)


function object = rename_object(object)
% user inut: new name
name = inputdlg({['rename ',object.name]},'');
% set new name
object.name = name{1};


function observer_table_edit(hObject, eventdata, handles)
% get room nr
[room_nr, obs_nr,~] = observer_room_nr(handles);
%if isempty(obs_nr)
%    obs_nr = eventdata.Indices(1);
%end
% get room dta
room = getappdata(handles.Lumos,'room');

try
    mode = room{room_nr}.measurement{obs_nr}.type;
catch
    mode = 'point';
end

switch mode
    case 'point'
        % update observer data
        switch eventdata.Indices(2)
            case 1
                % observer name
                room{room_nr}.measurement{eventdata.Indices(1)}.name = eventdata.NewData;
                % save new observer name
                setappdata(handles.Lumos,'room',room)
                % update list
                observer_listbox(hObject, eventdata, handles)
            case 5
                % observer viewing direction azimuth
                room{room_nr}.measurement{eventdata.Indices(1)}.azimuth = eventdata.NewData;
                % point normal
                p = room{room_nr}.measurement{eventdata.Indices(1)};
                if strcmp(room{room_nr}.measurement{eventdata.Indices(1)}.type,'area')
                    M1 = rotMatrixD([1 0 0],p.azimuth-90);
                    M2 = rotMatrixD([0 0 1],p.elevation);
                    M = M2*M1;
                    room{room_nr}.measurement{eventdata.Indices(1)}.normal = (M*([0 0 1])')';
                else
                    room{room_nr}.measurement{eventdata.Indices(1)}.normal = [cosd(p.elevation)*cosd(p.azimuth+90) cosd(p.elevation)*sind(p.azimuth+90) sind(p.elevation)];
                end
                % save new observer name
                setappdata(handles.Lumos,'room',room)
            case 6
                % observer viewing direction elevation
                room{room_nr}.measurement{eventdata.Indices(1)}.elevation = eventdata.NewData;
                % point normal
                p = room{room_nr}.measurement{eventdata.Indices(1)};
                if strcmp(room{room_nr}.measurement{eventdata.Indices(1)}.type,'area')
                    M1 = rotMatrixD([1 0 0],p.azimuth-90);
                    M2 = rotMatrixD([0 0 1],p.elevation);
                    M = M2*M1;
                    room{room_nr}.measurement{eventdata.Indices(1)}.normal = (M*([0 1 0])')';
                else
                    room{room_nr}.measurement{eventdata.Indices(1)}.normal = [cosd(p.elevation)*cosd(p.azimuth+90) cosd(p.elevation)*sind(p.azimuth+90) sind(p.elevation)];
                end
                    % save new observer name
                setappdata(handles.Lumos,'room',room)
            otherwise
                % observer data
                room{room_nr}.measurement{eventdata.Indices(1)}.coordinates(eventdata.Indices(2)-1) = eventdata.NewData;
                % check for areas
                %if strcmp(room{room_nr}.measurement{eventdata.Indices(1)}.type,'area')
                %    room{room_nr}.measurement{eventdata.Indices(1)} = get_points(room{room_nr}.measurement{eventdata.Indices(1)});
                %end
                % save new observer position
                setappdata(handles.Lumos,'room',room)
        end
    case 'area'
        data = get(handles.topview_point_table,'Data');
        %data = data(eventdata.Indices(1),:);
        switch eventdata.Indices(2)
            case 1 % not editable so far
                room{room_nr}.measurement{obs_nr}.name = data{1};
            case 2
                room{room_nr}.measurement{obs_nr}.width = data{2};
                if data{6} % DIN grid
                    [x,y,numx,numy] = DINgrid(data{2},data{3});
                    room{room_nr}.measurement{obs_nr}.pointsx = numx;
                    room{room_nr}.measurement{obs_nr}.pointsy = numy;
                    data{4} = numx;
                    data{5} = numy;
                    set(handles.topview_point_table,'Data',data);
                    z = zeros(size(x));
                    room{room_nr}.measurement{obs_nr}.points = [x(:) y(:) z(:)];
                else % user specified grid (not DIN)
                    dx = data{2}/data{4};
                    dy = data{3}/data{5};
                    xgrid = linspace(dx/2,data{2}-dx/2,data{4});
                    ygrid = linspace(dy/2,data{3}-dy/2,data{5});
                    [xq,yq] = meshgrid(xgrid,ygrid);
                    zq = zeros(size(xq));
                    room{room_nr}.measurement{obs_nr}.points = [xq(:) yq(:) zq(:)];
                end
            case 3
                room{room_nr}.measurement{obs_nr}.length = data{3};
                if data{6} % DIN grid
                    [x,y,numx,numy] = DINgrid(data{2},data{3});
                    room{room_nr}.measurement{obs_nr}.pointsx = numx;
                    room{room_nr}.measurement{obs_nr}.pointsy = numy;
                    data{4} = numx;
                    data{5} = numy;
                    set(handles.topview_point_table,'Data',data);
                    z = zeros(size(x));
                    room{room_nr}.measurement{obs_nr}.points = [x(:) y(:) z(:)];
                else % user specified grid (not DIN)
                    dx = data{2}/data{4};
                    dy = data{3}/data{5};
                    xgrid = linspace(dx/2,data{2}-dx/2,data{4});
                    ygrid = linspace(dy/2,data{3}-dy/2,data{5});
                    [xq,yq] = meshgrid(xgrid,ygrid);
                    zq = zeros(size(xq));
                    room{room_nr}.measurement{obs_nr}.points = [xq(:) yq(:) zq(:)];
                end
            case 4
                if data{6} % DIN grid
                    [x,y,numx,numy] = DINgrid(data{2},data{3});
                    room{room_nr}.measurement{obs_nr}.pointsx = numx;
                    room{room_nr}.measurement{obs_nr}.pointsy = numy;
                    data{4} = numx;
                    data{5} = numy;
                    set(handles.topview_point_table,'Data',data);
                    z = zeros(size(x));
                    room{room_nr}.measurement{obs_nr}.points = [x(:) y(:) z(:)];
                else % user specified grid (not DIN)
                    room{room_nr}.measurement{obs_nr}.pointsx = data{4};
                    dx = data{2}/data{4};
                    dy = data{3}/data{5};
                    xgrid = linspace(dx/2,data{2}-dx/2,data{4});
                    ygrid = linspace(dy/2,data{3}-dy/2,data{5});
                    [xq,yq] = meshgrid(xgrid,ygrid);
                    zq = zeros(size(xq));
                    room{room_nr}.measurement{obs_nr}.points = [xq(:) yq(:) zq(:)];
                end
            case 5
                if data{6} % DIN grid
                    [x,y,numx,numy] = DINgrid(data{2},data{3});
                    room{room_nr}.measurement{obs_nr}.pointsx = numx;
                    room{room_nr}.measurement{obs_nr}.pointsy = numy;
                    data{4} = numx;
                    data{5} = numy;
                    set(handles.topview_point_table,'Data',data);
                    z = zeros(size(x));
                    room{room_nr}.measurement{obs_nr}.points = [x(:) y(:) z(:)];
                else % user specified grid (not DIN)
                    room{room_nr}.measurement{obs_nr}.pointsy = data{5};
                    dx = data{2}/data{4};
                    dy = data{3}/data{5};
                    xgrid = linspace(dx/2,data{2}-dx/2,data{4});
                    ygrid = linspace(dy/2,data{3}-dy/2,data{5});
                    [xq,yq] = meshgrid(xgrid,ygrid);
                    zq = zeros(size(xq));
                    room{room_nr}.measurement{obs_nr}.points = [xq(:) yq(:) zq(:)];
                end
            case 6
                room{room_nr}.measurement{obs_nr}.DIN = logical(data{6});
                if data{6} % DIN grid
                    [x,y,numx,numy] = DINgrid(data{2},data{3});
                    room{room_nr}.measurement{obs_nr}.pointsx = numx;
                    room{room_nr}.measurement{obs_nr}.pointsy = numy;
                    data{4} = numx;
                    data{5} = numy;
                    set(handles.topview_point_table,'Data',data);
                    z = zeros(size(x));
                    room{room_nr}.measurement{obs_nr}.points = [x(:) y(:) z(:)];
                else % user specified grid (not DIN)
                    dx = data{2}/data{4};
                    dy = data{3}/data{5};
                    xgrid = linspace(dx/2,data{2}-dx/2,data{4});
                    ygrid = linspace(dy/2,data{3}-dy/2,data{5});
                    [xq,yq] = meshgrid(xgrid,ygrid);
                    zq = zeros(size(xq));
                    room{room_nr}.measurement{obs_nr}.points = [xq(:) yq(:) zq(:)];
                end
        end
        setappdata(handles.Lumos,'room',room);
end
% plot observer position
refresh_2D(hObject,eventdata,handles)
refresh_2D_objects(hObject,eventdata,handles)
plot_observer(hObject, eventdata, handles, obs_nr)
plot_area(hObject, eventdata, handles, obs_nr)
axes(handles.view)
%plot_3D(hObject,eventdata,handles)
refresh_3DObjects(hObject,eventdata,handles)
hold on
plot_observer(hObject, eventdata, handles, obs_nr)
plot_area(hObject, eventdata, handles, obs_nr)
% save handles
guidata(hObject,handles)






function [room_nr, observer_nr, list] = observer_room_nr(handles, nr)
room = getappdata(handles.Lumos,'room');
room_nr = [];
try
    selected = nr;
catch
    selected = get(handles.listbox,'Value');
end
% make list
ind = 1;
list = [];
observer_nr = [];
for r=1:max(size(room))
    list{1,ind} = room{r}.name;
    if isequal(selected,ind)
        room_nr = r;
    end
    ind = ind+1;
    try
        for o=1:size(room{r}.measurement,2)
            list{1,ind} = ['   ',room{r}.measurement{o}.name];
            if isequal(selected,ind)
                room_nr = r;
                observer_nr = o;
            end
            ind = ind+1;
        end
    catch
    end
end




function [room_nr, lum_nr, list, type] = lum_room_nr(handles, nr)
room = getappdata(handles.Lumos,'room');
room_nr = [];
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
for r=1:max(size(room))
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


% --- Executes on button press in results_tab.
function results_tab_Callback(hObject, eventdata, handles)
% hObject    handle to results_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.view)
colorbar('off')

% (de)activate  tools
toggle_menu_buttons(hObject,handles,[])

set(handles.listbox,'Value',1)
handles.data.room = 1;
try
    table = getappdata(handles.Lumos,'table');
    table{handles.data.room}.table_mode = 'result';
    setappdata(handles.Lumos,'table',table);
catch
end

%R = getappdata(handles.Lumos,'result');

result_table_callback(hObject, eventdata, handles)
result_listbox_callback(hObject, eventdata, handles);

% get app data
room = getappdata(handles.Lumos,'room');
%sky  = getappdata(handles.Lumos,'sky');

guidata(hObject,handles)



function resultstree(hObject, eventdata, handles)
% not working
% get app data
room = getappdata(handles.Lumos,'room');
sky = getappdata(handles.Lumos,'sky');
% create result ui tree
maketree(handles.listbox,'results');
addtreenode(handles.listbox,'results','root','room',room,'name',{@refresh_3D, hObject, eventdata, handles});

guidata(hObject,handles)


function tree = maketree(hObject,name)
% not working
% tree appdata name
str = ['tree' name];
try
    tree = getappdata(hObject,str);
catch
    tree.name = name;
    tree.nodes = [];
    tree.depth = 0;
end
setappdata(handles.Lumos,str,tree);


function addtreenode(hObject,treename,element,elementname,obj,ind,action)
% not working
str = ['tree' treename];
tree = getappdata(hObject,str);
if strcmp(element,'root')
    for n = 1:size(obj,2)
        eval(['tree.nodes{n}.name = obj{n}.',ind,';']);
        tree.nodes{n}.element = elementname;
        tree.nodes{n}.expand = 0;
        tree.nodes{n}.action = action;
        tree.depth = 1;
    end
else
    
end
setappdata(hObject,str,tree);


function displaytree(hObject,name)
str = ['tree' name];
treeobject = getappdata(hObject,str);
[list,ind] = gettreeinfo(treeobject,[]);
hObject.String = list;


function [list,ind,selected] = gettreeinfo(obj,value)
if ~exist('value','var')
    value = [];
end
% initiate
ind = 1;
list = [];
selected = [];
for n = 1:size(obj.nodes,2)
    if obj.nodes{n}.expand
        list{n} = ['- ',obj.nodes{n}.name];
        ind = ind+1;
        [list,ind] = gettreeinfo(obj.nodes{n});
    else
        list{n} = ['+ ',obj.nodes{n}.name];
        ind = ind+1;
    end
    
end



function result_table_callback(hObject, eventdata, handles)
% set table configuration
set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnName',{''})
set(handles.topview_point_table,'ColumnEditable',false)
guidata(hObject,handles)


function result_listbox_callback_not(hObject,eventdata,handles)


displaytree(hObject,'results')



function list = gettree(tree)
room = getappdata(handles.Lumos,'room');
sky = getappdata(handles.Lumos,'sky');

list = [];
ind = 1;
% loop rooms
for n = 1:size(tree,1)
    % loop elements
    for k = 1:5
        switch k
            case 1
                % room
                if isequal(tree{n,k},0)
                    list{ind} = ['+ ',room{n}.name];
                    ind = ind+1;
                    break
                else
                    list{ind} = ['- ',room{n}.name];
                    ind = ind+1;
                end
            case 2
                % sky
            case 3
                
            case 4
                
            case 5
                
        end
    end
end
%list


function list = result_listbox_callback(hObject,eventdata,handles)
room = getappdata(handles.Lumos,'room');
sky  = getappdata(handles.Lumos,'sky');
list = [];
ind = 1;
selected = get(handles.listbox,'Value');
results = getappdata(handles.Lumos,'result');


for R = 1:numel(results)
    if ~isempty(results{R})
        pre = room{R}.name;
        for S = 1:numel(results{R}.sky)
            % sky
            try
                % room
                list{ind,1} = [pre,' & ',sky{S-1}.filename];
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = [];
                plot_mode{ind} = 'room';
                ind = ind+1;
                list{ind,1} = ['   ',sky{S-1}.filename];
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = [];
                plot_mode{ind} = 'sky';
                ind = ind+1;
                % environment
                list{ind,1} = ['   ',pre,' environment'];
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = [];
                plot_mode{ind} = 'environment';
                ind = ind+1;
            catch
                % room
                try
                if isempty(room{R}.luminaire)
                    continue
                end
                catch
                    continue
                end
                list{ind,1} = pre;
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = [];
                plot_mode{ind} = 'room';
                ind = ind+1;
                % environment
                %list{ind,1} = ['   ',pre,' environment'];
                %list{ind,2} = R;
                %list{ind,3} = S;
                %list{ind,4} = [];
                %plot_mode{ind} = 'environment';
                %ind = ind+1;
            end
            % room rendering
            list{ind,1} = ['   ',pre,' room rendering'];
            list{ind,2} = R;
            list{ind,3} = S;
            list{ind,4} = [];
            plot_mode{ind} = 'room_render';
            ind = ind+1;
            % room false colors illuminance
            list{ind,1} = ['   ',pre,' room illuminance'];
            list{ind,2} = R;
            list{ind,3} = S;
            list{ind,4} = [];
            plot_mode{ind} = 'false_colours_E';
            ind = ind+1;
            % room false colors luminance
            list{ind,1} = ['   ',pre,' room luminance'];
            list{ind,2} = R;
            list{ind,3} = S;
            list{ind,4} = [];
            plot_mode{ind} = 'false_colours_L';
            ind = ind+1;
            % room mesh
            list{ind,1} = ['   ',pre,' room mesh'];
            list{ind,2} = R;
            list{ind,3} = S;
            list{ind,4} = [];
            plot_mode{ind} = 'room_mesh';
            ind = ind+1;
            for surface = 1:numel(results{R}.sky{S})
                switch results{R}.sky{S}{surface}.type
                    case 'window'
                        % material
                        list{ind,1} = ['      ',pre,' ',results{R}.sky{S}{surface}.name];
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'window_material';
                        ind = ind+1;
                        % window irradiance data
                        list{ind,1} = '         vertical external irradiance';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'window_irradiance';
                        ind = ind+1;
                        % window radiance data
                        %{
                        list{ind,1} = '         transmission weighted irradiance';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'window_radiance';
                        ind = ind+1;
                        %}
                    case 'luminaire'
                        % material
                        %list{ind,1} = ['   ',results{R}.sky{S}{surface}.name];
                        %list{ind,2} = R;
                        %list{ind,3} = S;
                        %list{ind,4} = surface;
                        %plot_mode{ind} = 'material';
                        %ind = ind+1;
                    otherwise
                        % material
                        list{ind,1} = ['   ',pre,' ',results{R}.sky{S}{surface}.name];
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'material';
                        ind = ind+1;
                        % irradiance
                        list{ind,1} = '      irradiance / illuminance';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'irradiance';
                        ind = ind+1;
                        % irradiance spectrogram
                        list{ind,1} = '      irradiance spectra';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'irradiance_spectro';
                        ind = ind+1;
                        % irradiance chromaticity
                        list{ind,1} = '      irradiance chromaticity';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'irradiance_chroma';
                        ind = ind+1;
                        % radiance
                        list{ind,1} = '      radiance / luminance';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'radiance';
                        ind = ind+1;
                        % radiance spectrogram
                        list{ind,1} = '      radiance spectra';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'radiance_spectro';
                        ind = ind+1;
                        % radiance chromaticity
                        list{ind,1} = '      radiance chromaticity';
                        list{ind,2} = R;
                        list{ind,3} = S;
                        list{ind,4} = surface;
                        plot_mode{ind} = 'radiance_chroma';
                        ind = ind+1;
                end
            end
            try
                if isempty(results{R}.measures{S})
                    continue
                end
                % measurement overview
                list{ind,1} = ['   ',pre,' metrics'];
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = 0;
                plot_mode{ind} = 'measurement_points';
                ind = ind+1;
                % point overview
                list{ind,1} = '      points overview';
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = 0;
                plot_mode{ind} = 'point_results';
                ind = ind+1;
                % point irradiance overview
                list{ind,1} = '         irradiance overview';
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = 0;
                plot_mode{ind} = 'point_chroma';
                ind = ind+1;
                
                for m = 1:numel(results{R}.measures{S})  
                    mode = results{R}.measures{S}{m}.type;
                    switch mode
                        case 'point'
                            % point
                            list{ind,1} = ['      ',results{R}.measures{S}{m}.name];
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point';
                            ind = ind+1;
                            % point irradiance
                            list{ind,1} = '         irradiance & chromaticity';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_data';
                            ind = ind+1;
                    end
                end
                % daylight factor overview
                list{ind,1} = '      DF overview';
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = 0;
                plot_mode{ind} = 'DF_results';
                ind = ind+1;
                % area overview
                list{ind,1} = '      area overview';
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = 0;
                plot_mode{ind} = 'area_overview';
                ind = ind+1;
                
                for m = 1:numel(results{R}.measures{S})
                    mode = results{R}.measures{S}{m}.type;
                    switch mode
                        case 'area'
                            % area
                            list{ind,1} = ['      ',results{R}.measures{S}{m}.name];
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'area';
                            ind = ind+1;
                            % area irradiance
                            list{ind,1} = '         irradiance / illuminance';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'area_data';
                            ind = ind+1;
                            % area irradiance spectrogram
                            list{ind,1} = '         irradiance spectal slice';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'area_spectro';
                            ind = ind+1;
                            % area irradiance chromaticity
                            list{ind,1} = '         irradiance chromaticity';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'area_chroma';
                            ind = ind+1;
                    end
                end
                %list{ind,1} = '         irradiance';
                %list{ind,2} = R;
                %list{ind,3} = S;
                %list{ind,4} = 0;
                %plot_mode{ind} = 'area_results';
                %ind = ind+1;
                % observer overview
                list{ind,1} = '      observer overview';
                list{ind,2} = R;
                list{ind,3} = S;
                list{ind,4} = 0;
                plot_mode{ind} = 'observer_overview';
                ind = ind+1;
                
                
                
                for m = 1:numel(results{R}.measures{S})

                    mode = results{R}.measures{S}{m}.type;
                    switch mode

                        case 'observer'
                           
                            % observer radiance
                            list{ind,1} = ['         ',results{R}.measures{S}{m}.name];
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '            observer perspective';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '               observer sc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_sc';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '               observer mc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_mc';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '               observer lc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_lc';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '               observer rh';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_rh';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '               observer mel';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_mel';
                            ind = ind+1;
                            
                            % observer view
                            list{ind,1} = '               observer L';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_L';
                            ind = ind+1;
                            
                            %{
                            % observer radiance
                            list{ind,1} = '            radiant incidence';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_radiant_incidence';
                            ind = ind+1;
                             % observer radiance sc
                            list{ind,1} = '               sc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_radiant_incidence_sc';
                            ind = ind+1;
                             % observer radiance sc
                            list{ind,1} = '               mc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_radiant_incidence_mc';
                            ind = ind+1;
                             % observer radiance sc
                            list{ind,1} = '               lc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_radiant_incidence_lc';
                            ind = ind+1;
                             % observer radiance sc
                            list{ind,1} = '               rhodopic';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_radiant_incidence_rh';
                            ind = ind+1;
                             % observer radiance sc
                            list{ind,1} = '               melanopic';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_radiant_incidence_mel';
                            ind = ind+1;
                            % observer luminance
                            %{
                            list{ind,1} = '            luminance & directogram';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'observer_illuminance';
                            ind = ind+1;
                            %}
                            % observer view
                            list{ind,1} = '            observer perspective';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view';
                            ind = ind+1;
                            % point view E
                            list{ind,1} = '               observer illuminance';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_E';
                            ind = ind+1;
                            % point view L
                            list{ind,1} = '               observer luminance';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_L';
                            ind = ind+1;
                            % point view sc
                            list{ind,1} = '               observer sc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_sc';
                            ind = ind+1;
                            % point view mc
                            list{ind,1} = '               observer mc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_mc';
                            ind = ind+1;
                            % point view lc
                            list{ind,1} = '               observer lc';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_lc';
                            ind = ind+1;
                            % point view rh
                            list{ind,1} = '               observer rhodopic';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_rh';
                            ind = ind+1;
                            % point view melanopic
                            list{ind,1} = '               observer melanopic';
                            list{ind,2} = R;
                            list{ind,3} = S;
                            list{ind,4} = m;
                            plot_mode{ind} = 'point_view_mel';
                            ind = ind+1;
                            %}

                    end
                end
            catch
            end
        end
    end
end

%handles.data.room = room_nr;
try
set(handles.listbox,'String',list(:,1));
guidata(hObject,handles)
catch
    return
end

% plot

data  = list(selected,:);
room_nr = data{2};
sky_nr = data{3};
surface = data{4};
handles.data.room = room_nr;
handles.data.sky = sky_nr;
guidata(hObject,handles)
camang = 130;

switch plot_mode{selected}
    case 'room'
        % plot luminaires and objects
        axes(handles.view)
        cla reset
        refresh_3DObjects(hObject, eventdata, handles,[],[])
        try
            objs = room{room_nr}.luminaire;
            clr = handles.orange;
            plot_object(objs, [], handles.view, '3D',clr)
        catch
        end
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            clr = handles.orange;
            plot_object(objs, [], handles.topview, '2D',clr)
        catch
        end
    case 'sky'
        % plot sky
        axes(handles.view)
        plot_tregenza_sky(sky{sky_nr-1},1,'explosion');
        axes(handles.topview)
        plot_tregenza_sky(sky{sky_nr-1},1,'2D');
        % set table
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','L','CCT'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,4))
        % sky list
        sky = getappdata(handles.Lumos,'sky');
        if size(sky,2) > 0
            set(handles.topview_point_table,'Data',[sky{sky_nr-1}.x sky{sky_nr-1}.y round(sky{sky_nr-1}.L) round(sky{sky_nr-1}.CCT)]);
        end
    case 'environment'
        % plot ground material
        axes(handles.topview)
        reset(handles.topview);
        try
        m = results{room_nr}.ground{sky_nr}.material;
        step = m.data(1,2)-m.data(1,1);
        if step <= 1
            plot(m.data(1,:),m.data(2,:),'Color',handles.blue)
        else
            stem(m.data(1,:),m.data(2,:),'Color',handles.blue,'Marker','.')
        end
        grid on
        xlabel('wavelength in nm')
        ylabel('spectral reflection value')
        title(strrep(results{room_nr}.ground{sky_nr}.material.name,'_',' '))
        a = axis;
        b = m.data(1,1);
        c = m.data(1,end);
        axis([b c 0 1])
        % plot ground irradiance
        axes(handles.view)

            M(1,:) = results{room_nr}.ground{sky_nr}.irradiance;
            M(2,:) = results{room_nr}.ground{sky_nr}.radiance;
            lambda = results{room_nr}.ground{sky_nr}.lambda;

            if step <= 1
                plot(lambda,M)
            else
                stairs(lambda,M(1,:))
                hold on
                stairs(lambda,M(2,:))
                hold off
            end
            legend('irradiance','radiance')
            grid on
            xlim([lambda(1,1) lambda(1,end)])
            xlabel('wavelength in nm')
            ylabel('E_{e,\lambda,h} in W/m^2/nm, L_{e,\lambda} in W/m^2/sr/nm')
            title('environment ground')
            [xyz,~,~,~,XYZ] = ciespec2xyz(lambda,M);
            Y = XYZ(:,2);
            T = CCT('x',xyz(:,1),'y',xyz(:,2));
            legend(['E_{h} = ',num2str(round(Y(1))),' lx',10,'x = ',num2str(round(xyz(1,1),4)),10,'y = ',num2str(round(xyz(1,2),4)),10,'T_{cp} = ',num2str(round(T(1))),' K'],...
                ['L = ',num2str(round(Y(2))),' cd/m^2',10,'x = ',num2str(round(xyz(2,1),4)),10,'y = ',num2str(round(xyz(2,2),4)),10,'T_{cp} = ',num2str(round(T(2))),' K'],...
                'Location','NorthOutside','Orientation','horizontal');
        catch
            plot(NaN,NaN)
            axis off
            text(0.5,0.5,'no data')
        end
        
        % table
        set(handles.topview_point_table,'Data',M,'ColumnName',lambda,'RowName',{'E_e','L_e'})
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));

    case 'room_render'
    % room rendering
        axes(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            clr = handles.orange;
            plot_object(objs, [], handles.topview, '2D',clr)
        catch
        end
        axes(handles.view)
        plotGouraud(results{room_nr}.sky{sky_nr},handles.view,handles.topview);
        set(handles.topview_point_table,'Data',[],'ColumnName',[],'RowName',[])
    case 'false_colours_E'
        axes(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            clr = handles.orange;
            plot_object(objs, [], handles.topview, '2D',clr)
        catch
        end
        axes(handles.view)
        plotGouraud(results{room_nr}.sky{sky_nr},handles.view,handles.topview,1,1,'false-colours_E');
        set(handles.topview_point_table,'Data',[],'ColumnName',[],'RowName',[]);
    case 'false_colours_L'
        axes(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            clr = handles.orange;
            plot_object(objs, [], handles.topview, '2D',clr)
        catch
        end
        axes(handles.view)
        plotGouraud(results{room_nr}.sky{sky_nr},handles.view,handles.topview,1,1,'false-colours_L');
        set(handles.topview_point_table,'Data',[],'ColumnName',[],'RowName',[])
    case 'room_mesh'
        % room mesh plot
        axes(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)
        refresh_2D(hObject, eventdata, handles)
        refresh_2D_objects(hObject, eventdata, handles)
        try
            objs = room{room_nr}.luminaire;
            clr = handles.orange;
            plot_object(objs, [], handles.topview, '2D',clr)
        catch
        end
        axes(handles.view)
        plotmesh3d(results{room_nr}.sky{handles.data.sky})
        set(handles.topview_point_table,'Data',[],'ColumnName',[],'RowName',[])
    case 'material'
        % plot material
        axes(handles.topview)
        reset(handles.topview)
        m = results{room_nr}.sky{sky_nr}{surface}.material;
        step = m.data(1,2)-m.data(1,1);
        if step <= 1
            plot(m.data(1,:),m.data(2,:),'Color',handles.blue)
        else
            stem(m.data(1,:),m.data(2,:),'Color',handles.blue,'Marker','.')
        end
        grid on
        xlabel('wavelength in nm')
        ylabel('spectral reflection value')
        title(strrep(results{room_nr}.ground{sky_nr}.material.name,'_',' '))
        a = axis;
        b = m.data(1,1);
        c = m.data(1,end);
        axis([b c 0 1])
        % plot selected item
        axes(handles.view)
        cla
        plot_surface(results{room_nr}.sky{sky_nr},surface)
        % surface table data
        sdata = results{room_nr}.sky{sky_nr}{surface}.vertices;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,4))
        set(handles.topview_point_table,'Data',sdata);
    case 'irradiance'
        % irradiance plot
        plot_room_part_result(handles,results{room_nr}.sky{sky_nr}{surface},handles.view,'E')
        % plot DIN grid
        plot_DIN_grid(handles,results{room_nr}.sky{sky_nr}{surface},handles.topview,1,'E','x')
        % correct table format
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        
    case 'radiance'
        % radiance plot
        plot_room_part_result(handles,results{room_nr}.sky{sky_nr}{surface},handles.view,'L')
        % plot DIN grid
        plot_DIN_grid(handles,results{room_nr}.sky{sky_nr}{surface},handles.topview,1,'L','x')
        % correct table format
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
   case 'irradiance_spectro'
        % irradiance spectrogram
        plot_surface_spectrogram(handles,results{room_nr}.sky{sky_nr}{surface},handles.topview,'E')
        plot_DIN_grid(handles,results{room_nr}.sky{sky_nr}{surface},handles.view,1,'E','num')
        % correct table format
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnName',results{room_nr}.sky{sky_nr}{surface}.lambda)
    case 'radiance_spectro'
        % radiance spectrogram
        plot_surface_spectrogram(handles,results{room_nr}.sky{sky_nr}{surface},handles.topview,'L')
        plot_DIN_grid(handles,results{room_nr}.sky{sky_nr}{surface},handles.view,1,'L','num')
        % correct table format
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnName',results{room_nr}.sky{sky_nr}{surface}.lambda)
    case 'irradiance_chroma'
        % irradiance chromaticity
        plot_DIN_grid(handles,results{room_nr}.sky{sky_nr}{surface},handles.topview,1,'E','num')
        plotChromaticityCIE1931(handles,results{room_nr}.sky{sky_nr}{surface},handles.view,'E')
     case 'radiance_chroma'
        % radiance chromaticity
        plot_DIN_grid(handles,results{room_nr}.sky{sky_nr}{surface},handles.topview,1,'L','num')
        plotChromaticityCIE1931(handles,results{room_nr}.sky{sky_nr}{surface},handles.view,'L')
        % correct table format
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
    case 'point'
        % measurement point
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface,'point')
        %plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface, 'point')
        %plot_area(hObject, eventdata, handles)
        % measurement data
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
    case 'measurement_points'
        % plots
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface)
        plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface)
        plot_area(hObject, eventdata, handles)
        % table
        observer_table(hObject,eventdata,handles)
    case 'point_results'
        % plots
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface,'point')
        %plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface,'point')
        %plot_area(hObject, eventdata, handles)
        % table
        data = [];%zeros(numel(results{room_nr}.measures{sky_nr}),4);
        names = {};%cell(numel(results{room_nr}.measures{sky_nr}),1);
        idx = 1;
        for ind = 1:numel(results{room_nr}.measures{sky_nr})
            if strcmp(results{room_nr}.measures{sky_nr}{ind}.type,'point')
                data(idx,1) = ciespec2Y(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E);
                xyz = ciespec2xyz(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E);
                x = xyz(1);
                y = xyz(2);
                Tc = RobertsonCCT('x',x,'y',y,'Warning','off');
                %[Tc,x,y]  = ciespec2cct(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E);
                data(idx,2) = x;
                data(idx,3) = y;
                data(idx,4) = Tc;
                names{idx} = results{room_nr}.measures{sky_nr}{ind}.name;
                idx = idx+1;
            end
        end
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'E','x','y','CCT'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName',names)
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
    case 'DF_results'
        % plots
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface)
        %plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface)
        %plot_area(hObject, eventdata, handles)
        % table
        data = [];
        names = {};
        idx = 1;
        for ind = 1:numel(results{room_nr}.measures{sky_nr})
            if strcmp(results{room_nr}.measures{sky_nr}{ind}.type,'DF')
                data(idx,1) = results{room_nr}.measures{sky_nr}{ind}.DF;
                names{idx} = results{room_nr}.measures{sky_nr}{ind}.name;
                idx = idx+1;
            end
        end
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'DF'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName',names)
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
    case 'area_overview'
        % plots
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        %plot_observer(hObject, [], handles, surface)
        plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        %plot_observer(hObject, [], handles, surface)
        plot_area(hObject, eventdata, handles)
        % table
        data = [];%zeros(numel(results{R}.measures{S}),4);
        names = {};%cell(numel(results{R}.measures{S}),1);
        idx = 1;
        for ind = 1:numel(results{room_nr}.measures{sky_nr})
            if strcmp(results{R}.measures{sky_nr}{ind}.type,'area')
                tind = 1;
                temp = [];
                for ind2 = 1:size(results{room_nr}.measures{sky_nr}{ind}.points,1)
                    temp(tind,1) = ciespec2Y(results{R}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E(ind2,:));
                    V = ciespec2Y(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E(ind2,:));
                    %xyz = ciespec2xyz(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E(ind2,:));
                    tind = tind+1;
                end
                data(idx,1) = mean(temp);
                data(idx,2) = min(temp);
                data(idx,3) = max(temp);
                data(idx,4) = data(idx,2)/data(idx,1);
                names{idx} = results{room_nr}.measures{sky_nr}{ind}.name;
                idx = idx + 1;
            end
        end
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'E_avg','E_min','E_max','U_0'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName',names)
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
    case 'area_results'
        % plots
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        %plot_observer(hObject, [], handles, surface)
        plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        %plot_observer(hObject, [], handles, surface)
        plot_area(hObject, eventdata, handles)
        % table
        data = [];%zeros(numel(results{R}.measures{sky_nr}),4);
        names = {};%cell(numel(results{R}.measures{sky_nr}),1);
        idx = 1;
        for ind = 1:numel(results{room_nr}.measures{sky_nr})
            if strcmp(results{room_nr}.measures{sky_nr}{ind}.type,'area')
                for ind2 = 1:size(results{room_nr}.measures{sky_nr}{ind}.points,1)
                    data(idx,1) = ciespec2Y(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E(ind2,:));
                    [Tc,x,y]  = ciespec2cct(results{room_nr}.measures{sky_nr}{ind}.lambda,results{room_nr}.measures{sky_nr}{ind}.E(ind2,:));
                    data(idx,2) = x;
                    data(idx,3) = y;
                    data(idx,4) = Tc;
                    names{idx} = [results{room_nr}.measures{sky_nr}{ind}.name,' ',num2str(ind2)];
                    idx = idx+1;
                end
            end
        end
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'E','x','y','CCT'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName',names)
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
    case 'point_chroma'
        % table
        data = [];%zeros(numel(results{R}.measures{sky_nr}),4);
        names = {};%cell(numel(results{R}.measures{sky_nr}),1);
        idx = 1;
        for ind = 1:numel(results{room_nr}.measures{sky_nr})
            if strcmp(results{room_nr}.measures{sky_nr}{ind}.type,'point')
                data(idx,:) = results{room_nr}.measures{sky_nr}{ind}.E;
                names{idx} = results{room_nr}.measures{sky_nr}{ind}.name;
                idx = idx+1;
            end
                
        end
        set(handles.topview_point_table,'Data',[]);
        if ~isempty(data)
            
            set(handles.topview_point_table,'ColumnName',results{room_nr}.measures{sky_nr}{ind}.lambda)
            set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric'})
            set(handles.topview_point_table,'RowName',names)
            set(handles.topview_point_table,'ColumnEditable',false(1,5))
            set(handles.topview_point_table,'Data',data);
            
            % plots
            axes(handles.topview)
            cla
            reset(handles.view)
            color = [0   0.4470   0.7410];
            labeltext = 'spectral irradiance E_{e,\lambda} in W m^{-2} nm^{-1}';
            plotspecrange(results{room_nr}.measures{sky_nr}{ind}.lambda,data,'Color',color,'ylabel',labeltext);
            
            axes(handles.view)
            cla
            reset(handles.view)
            [xyz] = ciespec2xyz(results{room_nr}.measures{sky_nr}{ind}.lambda,data);
            cie1931(xyz(:,1),xyz(:,2),'Planck','on','Marker','.','MarkerSize',10,'MarkerColor',[1 1 1])
        end
    case 'point_data'
        % point irradiance
        %comeback('point irradiance')
        plot_point(handles,results{room_nr}.measures{sky_nr}{surface},handles.topview)
        xyz = ciespec2xyz(results{room_nr}.measures{sky_nr}{surface}.lambda,results{room_nr}.measures{sky_nr}{surface}.E);
        axes(handles.view)
        cla
        reset(handles.view)
        cie1931(xyz(1),xyz(2),'Planck','on','Marker','.','MarkerSize',10,'MarkerColor',[1 1 1],'LegendMode','extended')
        %Tc = RobertsonCCT('x',xyz(1),'y',xyz(2));
        %text(425,150,['x = ',num2str(round(xyz(1),4)),', y = ',num2str(round(xyz(2),4)),', T_c = ',num2str(round(Tc)),' K'])
    
    case 'observer_overview'
        
        % observer overview
        % plots
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface,'observer')
        %plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface,'observer')
        %plot_area(hObject, eventdata, handles)
        % table
        data = [];%zeros(numel(results{room_nr}.measures{sky_nr}),4);
        names = {};%cell(numel(results{room_nr}.measures{sky_nr}),1);
        idx = 1;

        data = [];
        for n = 1:size(results{room_nr}.measures{sky_nr},2)
            if strcmp(results{room_nr}.measures{sky_nr}{n}.type,'observer')
                data = [data; results{room_nr}.measures{sky_nr}{n}.coordinates results{room_nr}.measures{sky_nr}{n}.azimuth results{room_nr}.measures{sky_nr}{n}.elevation];
            end
        end
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);

    case 'observer'
        
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface,'observer')
        %plot_area(hObject, eventdata, handles)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface, 'observer')
        %plot_area(hObject, eventdata, handles)
        % measurement data
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
    case 'point_view'
        
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        plot_observer(hObject, [], handles, surface, 'observer')
        %plot_area(hObject, eventdata, handles)
        % measurement data
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        
        % create image
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        I = hyperspec2srgb(IM,results{room_nr}.measures{sky_nr}{surface}.lambda);
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        image(I)
        axis off equal
        
    case 'point_view_E'
        
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'Data',[]);
        
        % WITHOUT SKY
        axes(handles.topview)
        reset(handles.topview)
        
        reset(handles.view)
        cla
        axis off
        text(0.5,0.5,'rendering...','HorizontalAlignment','center')
        h = figure('Visible','off');
        a = gca;
        if sky_nr == 1
            cdata = plotGouraud(results{room_nr}.sky{sky_nr},a,handles.topview,0,0,'false-colours_E',0,0,[],results{room_nr}.ground{sky_nr},results{room_nr}.measures{sky_nr}{surface}.coordinates);
        else
            cdata = plotGouraud(results{room_nr}.sky{sky_nr},a,handles.topview,0,0,'false-colours_E',0,0,sky{sky_nr-1},results{room_nr}.ground{sky_nr},results{room_nr}.measures{sky_nr}{surface}.coordinates);
        end
        axis equal
        %cdata = plotGouraud(results{room_nr}.sky{sky_nr},a,handles.topview,0,0,'false-colours_E',0,1,sky{sky_nr-1},results{room_nr}.ground{sky_nr});
        pos = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        set(a, 'CameraPosition', pos);
        az = results{room_nr}.measures{sky_nr}{surface}.azimuth;
        el = results{room_nr}.measures{sky_nr}{surface}.elevation;
        target = [cosd(el)*cosd(az+90) cosd(el)*sind(az+90) sind(el)];
        set(a, 'CameraTarget', pos+target);
        set(a, 'CameraViewAngle', camang);
        set(a, 'Projection', 'perspective');
        set(a, 'Position', [0 0 1 1]);
        set(h,'Position', [0 0 1000 1000]);
        set(h,'PaperUnits','inches','PaperPosition',[0 0 5 5],'Papersize',[5 5])
        im = getframe(h);
        im = im.cdata;
        close(h)
        %{
        % FISHEYE
        [nrows,ncols,~] = size(im);
        options = [nrows ncols 3];
        tf = maketform('custom', 2, 2, [], @fisheye_inverse, options);  % Make the transformation structure
            
        fisheye = imtransform(im, tf,'fill',255);
        imshow(fisheye)
        %}
        imshow(im)
        c = colorbar;
        caxis([0 max(cdata)])
        unit = 'E in lx';
        c.Label.String = unit;
        colormap(parula)
        
        
        % WITH SKY
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        text(0.5,0.5,'rendering...','HorizontalAlignment','center')
        h = figure('Visible','off');
        a = gca;
        if sky_nr == 1
            cdata = plotGouraud(results{room_nr}.sky{sky_nr},a,handles.topview,0,0,'false-colours_E',0,1,[],results{room_nr}.ground{sky_nr},results{room_nr}.measures{sky_nr}{surface}.coordinates);
        else
            cdata = plotGouraud(results{room_nr}.sky{sky_nr},a,handles.topview,0,0,'false-colours_E',0,1,sky{sky_nr-1},results{room_nr}.ground{sky_nr},results{room_nr}.measures{sky_nr}{surface}.coordinates);
        end
        axis equal
        %cdata = plotGouraud(results{room_nr}.sky{sky_nr},a,handles.topview,0,0,'false-colours_E',0,1,sky{sky_nr-1},results{room_nr}.ground{sky_nr});
        pos = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        set(a, 'CameraPosition', pos);
        az = results{room_nr}.measures{sky_nr}{surface}.azimuth;
        el = results{room_nr}.measures{sky_nr}{surface}.elevation;
        target = [cosd(el)*cosd(az+90) cosd(el)*sind(az+90) sind(el)];
        set(a, 'CameraTarget', pos+target);
        set(a, 'CameraViewAngle', camang);
        set(a, 'Projection', 'perspective');
        set(a, 'Position', [0 0 1 1]);
        set(h,'Position', [0 0 1000 1000]);
        set(h,'PaperUnits','inches','PaperPosition',[0 0 5 5],'Papersize',[5 5])
        im = getframe(h);
        im = im.cdata;
        close(h)
        %{
        % FISHEYE
        [nrows,ncols,~] = size(im);
        options = [nrows ncols 3];
        tf = maketform('custom', 2, 2, [], @fisheye_inverse, options);  % Make the transformation structure
            
        fisheye = imtransform(im, tf,'fill',255);
        imshow(fisheye)
        %}
        imshow(im)
        c = colorbar;
        caxis([0 max(cdata)])
        unit = 'E in lx';
        c.Label.String = unit;
        colormap(parula)
        
        
    case 'point_view_L'
        
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.topview)
        reset(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)

        cla
        axis off
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        I = reshape(ciespec2unit(results{room_nr}.measures{sky_nr}{surface}.lambda,reshape(IM,size(IM,1)*size(IM,2),size(IM,3)),'VL'),size(IM,1),size(IM,2));
        imagesc(I)
        c = colorbar;
        c.Label.String = 'L in cd m^{-2}';
        axis equal off
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        imagesc(I)
        c = colorbar;
        set(gca,'colorscale','log')
        c.Label.String = 'L in cd m^{-2}';
        axis equal off
        colormap('gray')
        
    case 'point_view_sc'
        
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.topview)
        reset(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)

        cla
        axis off
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        aopic = hyperspec2unit(IM,results{room_nr}.measures{sky_nr}{surface}.lambda,'aopic');
        lim = max(max(max(aopic)));
        
        amode = 'sc';
        unit = ['L_{e,',amode,'} in W m^{-2} sr^{-1}'];
        %I = reshape(ciespec2unit(results{room_nr}.measures{sky_nr}{surface}.lambda,reshape(IM,size(IM,1)*size(IM,2),size(IM,3)),amode),size(IM,1),size(IM,2));
        imagesc(aopic(:,:,1))
        c = colorbar;
        c.Label.String = unit;
        axis equal off
        caxis([0 lim])
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        imagesc(aopic(:,:,1))
        c = colorbar;
        set(gca,'colorscale','log')
        
        c.Label.String = unit;
        axis equal off
        colormap('parula')
        caxis([1e-3 lim])
        
    case 'point_view_mc'
        
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.topview)
        reset(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)

        cla
        axis off
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        amode = 'mc';
        unit = ['L_{e,',amode,'} in W m^{-2} sr^{-1}'];
        
        aopic = hyperspec2unit(IM,results{room_nr}.measures{sky_nr}{surface}.lambda,'aopic');
        lim = max(max(max(aopic)));
        %I = reshape(ciespec2unit(results{room_nr}.measures{sky_nr}{surface}.lambda,reshape(IM,size(IM,1)*size(IM,2),size(IM,3)),amode),size(IM,1),size(IM,2));
        imagesc(aopic(:,:,2))
        c = colorbar;
        c.Label.String = unit;
        axis equal off
        caxis([0 lim])
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        imagesc(aopic(:,:,2))
        c = colorbar;
        set(gca,'colorscale','log')
        
        c.Label.String = unit;
        axis equal off
        colormap('parula')
        caxis([1e-3 lim])
        
    case 'point_view_lc'
                data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.topview)
        reset(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)

        cla
        axis off
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        amode = 'lc';
        unit = ['L_{e,',amode,'} in W m^{-2} sr^{-1}'];
        
        aopic = hyperspec2unit(IM,results{room_nr}.measures{sky_nr}{surface}.lambda,'aopic');
        lim = max(max(max(aopic)));
        %I = reshape(ciespec2unit(results{room_nr}.measures{sky_nr}{surface}.lambda,reshape(IM,size(IM,1)*size(IM,2),size(IM,3)),amode),size(IM,1),size(IM,2));
        imagesc(aopic(:,:,3))
        c = colorbar;
        c.Label.String = unit;
        axis equal off
        caxis([0 lim])
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        imagesc(aopic(:,:,3))
        c = colorbar;
        set(gca,'colorscale','log')
        
        c.Label.String = unit;
        axis equal off
        colormap('parula')
        caxis([1e-3 lim])
        
    case 'point_view_rh'
        
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.topview)
        reset(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)

        cla
        axis off
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        amode = 'rh';
        unit = ['L_{e,',amode,'} in W m^{-2} sr^{-1}'];
        
        aopic = hyperspec2unit(IM,results{room_nr}.measures{sky_nr}{surface}.lambda,'aopic');
        lim = max(max(max(aopic)));
        %I = reshape(ciespec2unit(results{room_nr}.measures{sky_nr}{surface}.lambda,reshape(IM,size(IM,1)*size(IM,2),size(IM,3)),amode),size(IM,1),size(IM,2));
        imagesc(aopic(:,:,4))
        c = colorbar;
        c.Label.String = unit;
        axis equal off
        caxis([0 lim])
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        imagesc(aopic(:,:,4))
        c = colorbar;
        set(gca,'colorscale','log')
        
        c.Label.String = unit;
        axis equal off
        colormap('parula')
        caxis([1e-3 lim])
        
    case 'point_view_mel'      
                
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
        
        axes(handles.topview)
        reset(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)

        cla
        axis off
        IM = results{room_nr}.measures{sky_nr}{surface}.IM;
        amode = 'mel';
        unit = ['L_{e,',amode,'} in W m^{-2} sr^{-1}'];
        
        aopic = hyperspec2unit(IM,results{room_nr}.measures{sky_nr}{surface}.lambda,'aopic');
        lim = max(max(max(aopic)));
        %I = reshape(ciespec2unit(results{room_nr}.measures{sky_nr}{surface}.lambda,reshape(IM,size(IM,1)*size(IM,2),size(IM,3)),amode),size(IM,1),size(IM,2));
        imagesc(aopic(:,:,5))
        c = colorbar;
        c.Label.String = unit;
        axis equal off
        caxis([0 lim])
        
        axes(handles.view)
        reset(handles.view)
        cla
        axis off
        imagesc(aopic(:,:,5))
        c = colorbar;
        set(gca,'colorscale','log')
        
        c.Label.String = unit;
        axis equal off
        colormap('parula')
        caxis([1e-3 lim])
                
    case 'observer_illuminance'
        
        comeback('observer luminance')
        
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.view)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        Y = ciespec2Y(lambda,data.E);
        xyz = ciespec2xyz(lambda,data.E);
        c = xyz2srgb(xyz,'E',Y);
        c(c<0) = 0;
        c(c>1) = 1;
       
        
        plotskydirecto(log(round(Y,1)),c)
        axes(handles.topview)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)

    case 'observer_radiant_incidence'
        
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.topview)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        Y = ciespec2Y(lambda,data.J);
        L = Y;
        xyz = ciespec2xyz(lambda,data.J);
        c = xyz2srgb(xyz);
        
        % illuminance factor
        fa = (Y./max(Y)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        Y = 116.*fa-16;
        % gamma correctiom
        Y = real((Y./max(Y)).^(1/2));
        % white balancing
        wb = max(Y)/max(mean(c,'omitnan'));
        % ensure displayable color values
        col = (c.*Y.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        
        plottregenza(round(L),col,{'radiant incidence','J_e in W sr^{-1}','perceived colours'}, [], [], [], [], 0)
        
        
        axes(handles.view)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        plotskydirecto(L,col,[0 -90],1,'view')
        
        % measurement data

        data = [results{room_nr}.measures{sky_nr}{surface}.J];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        %set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
         set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnEditable',false(1,size(data,2)))
        set(handles.topview_point_table,'Data',data);
        
    case 'observer_radiant_incidence_sc'
        
        %comeback('observer radiant incidence')
        
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.topview)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        Y = ciespec2unit(lambda,data.J,'VL');
        L = ciespec2unit(lambda,data.J,'sc');
        xyz = ciespec2xyz(lambda,data.J);
        c = xyz2srgb(xyz);
        
        % illuminance factor
        fa = (Y./max(Y)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        Y = 116.*fa-16;
        % gamma correctiom
        Y = real((Y./max(Y)).^(1/2));
        % white balancing
        wb = max(Y)/max(mean(c,'omitnan'));
        % ensure displayable color values
        col = (c.*Y.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        
        plottregenza(round(L.*1000),col,{'radiant sc incidence','J_{e,sc} in mW sr^{-1}','perceived colours'}, [], [], [], [], 0)
       
        axes(handles.view)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        plotskydirecto(L,col,[0 -90],1,'view')
        
        % measurement data

        data = L;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        %set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnEditable',false(1,size(data,2)))
        set(handles.topview_point_table,'Data',data);
        
    case 'observer_radiant_incidence_mc'
        
  
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.topview)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        L = ciespec2unit(lambda,data.J,'mc');
        Y = ciespec2unit(lambda,data.J,'VL');
        xyz = ciespec2xyz(lambda,data.J);
        c = xyz2srgb(xyz);
        
        % illuminance factor
        fa = (Y./max(Y)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        Y = 116.*fa-16;
        % gamma correctiom
        Y = real((Y./max(Y)).^(1/2));
        % white balancing
        wb = max(Y)/max(mean(c,'omitnan'));
        % ensure displayable color values
        col = (c.*Y.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        
        plottregenza(round(L.*1000),col,{'radiant mc incidence','J_{e,mc} in mW sr^{-1}','perceived colours'}, [], [], [], [], 0)
        
        
        axes(handles.view)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        plotskydirecto(L,col,[0 -90],1,'view')

        % measurement data
        data = L;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        %set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnEditable',false(1,size(data,2)))
        set(handles.topview_point_table,'Data',data);
        
        
    case 'observer_radiant_incidence_lc'
               
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.topview)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        L = ciespec2unit(lambda,data.J,'lc');
        Y = ciespec2unit(lambda,data.J,'VL');
        xyz = ciespec2xyz(lambda,data.J);
        c = xyz2srgb(xyz);
        
        % illuminance factor
        fa = (Y./max(Y)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        Y = 116.*fa-16;
        % gamma correctiom
        Y = real((Y./max(Y)).^(1/2));
        % white balancing
        wb = max(Y)/max(mean(c,'omitnan'));
        % ensure displayable color values
        col = (c.*Y.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        
        plottregenza(round(L.*1000),col,{'radiant lc incidence','J_{e,lc} in mW sr^{-1}','perceived colours'}, [], [], [], [], 0)
        
        
        axes(handles.view)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        plotskydirecto(L,col,[0 -90],1,'view')
        
        % measurement data
        data = L;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        %set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnEditable',false(1,size(data,2)))
        set(handles.topview_point_table,'Data',data);
        
        
    case 'observer_radiant_incidence_rh'
        
        %comeback('observer radiant incidence')
        
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.topview)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        L = ciespec2unit(lambda,data.J,'rh');
        Y = ciespec2unit(lambda,data.J,'VL');
        xyz = ciespec2xyz(lambda,data.J);
        c = xyz2srgb(xyz);
        
        % illuminance factor
        fa = (Y./max(Y)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        Y = 116.*fa-16;
        % gamma correctiom
        Y = real((Y./max(Y)).^(1/2));
        % white balancing
        wb = max(Y)/max(mean(c,'omitnan'));
        % ensure displayable color values
        col = (c.*Y.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        
        plottregenza(round(L.*1000),col,{'radiant rh incidence','J_{e,rh} in mW sr^{-1}','perceived colours'}, [], [], [], [], 0)
        
        axes(handles.view)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        plotskydirecto(L,col,[0 -90],1,'view')
        
        % measurement data

        data = L;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        %set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnEditable',false(1,size(data,2)))
        set(handles.topview_point_table,'Data',data);
        
        
    case 'observer_radiant_incidence_mel'
        
        %comeback('observer radiant incidence')
        
        data = results{room_nr}.measures{sky_nr}{surface};%room{room_nr}.measures{observer_nr}.spatial{sky_nr}.L;
        lambda = results{room_nr}.measures{sky_nr}{surface}.lambda;
        axes(handles.topview)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        L = ciespec2unit(lambda,data.J,'mel');
        Y = ciespec2unit(lambda,data.J,'VL');
        xyz = ciespec2xyz(lambda,data.J);
        c = xyz2srgb(xyz);
        
        % illuminance factor
        fa = (Y./max(Y)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        Y = 116.*fa-16;
        % gamma correctiom
        Y = real((Y./max(Y)).^(1/2));
        % white balancing
        wb = max(Y)/max(mean(c,'omitnan'));
        % ensure displayable color values
        col = (c.*Y.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        
        plottregenza(round(L.*1000),col,{'radiant mel incidence','J_{e,mel} in mW sr^{-1}','perceived colours'}, [], [], [], [], 0)
        
        axes(handles.view)
        %plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        plotskydirecto(L,col,[0 -90],1,'view')
        
        % measurement data
        data = L;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',[])
        set(handles.topview_point_table,'RowName','numbered')
        %set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(handles.topview_point_table,2)));
        set(handles.topview_point_table,'ColumnEditable',false(1,size(data,2)))
        set(handles.topview_point_table,'Data',data);
        
        
    case 'area'
        % measurements
        axes(handles.view)
        cla
        reset(handles.view)
        refresh_3DObjects(hObject,eventdata,handles)
        hold on
        %plot_observer(hObject, [], handles, surface)
        plot_area(hObject, [], handles, surface)
        axes(handles.topview)
        cla
        reset(handles.topview)
        refresh_2D(hObject,eventdata,handles)
        hold on
        %plot_observer(hObject, [], handles, surface)
        plot_area(hObject, [], handles, surface)
        % measurement data
        data = results{room_nr}.measures{sky_nr}{surface}.coordinates;
        data = [data results{room_nr}.measures{sky_nr}{surface}.azimuth];
        data = [data results{room_nr}.measures{sky_nr}{surface}.elevation];
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z','az','el'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric'})
        set(handles.topview_point_table,'ColumnEditable',false(1,5))
        set(handles.topview_point_table,'Data',data);
    case 'area_data'
        % irradiance plot
        plot_room_part_result(handles,results{room_nr}.measures{sky_nr}{surface},handles.view,'E')
        % plot DIN grid
        plot_grid(handles,results{room_nr}.measures{sky_nr}{surface},handles.topview,1,'E','x')
    case 'area_spectro'
        axes(handles.topview)
        cla
        reset(handles.topview)
        plotspectro(results{room_nr}.measures{sky_nr}{surface}.lambda,results{room_nr}.measures{sky_nr}{surface}.E,'spectral irradiance E_{e,\lambda} in W m^{-2} nm^{-1}')
        xlabel('point')
        % plot DIN grid
        plot_grid(handles,results{room_nr}.measures{sky_nr}{surface},handles.view,1,'E','num')
        % measurement data
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{results{room_nr}.measures{sky_nr}{surface}.lambda})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,size(results{room_nr}.measures{sky_nr}{surface}.E,2)));
        set(handles.topview_point_table,'ColumnEditable',false)
        set(handles.topview_point_table,'Data',results{room_nr}.measures{sky_nr}{surface}.E);
    case 'area_chroma'
        plot_grid(handles,results{room_nr}.measures{sky_nr}{surface},handles.topview,1,'E','num')
        [xyz,~,~,~,Yint] = ciespec2xyz(results{room_nr}.measures{sky_nr}{surface}.lambda,results{room_nr}.measures{sky_nr}{surface}.E);
        Yint = Yint(:,2);
        plot_x = xyz(:,1)';
        plot_y = xyz(:,2)';
        Tc = CCT('x',plot_x,'y',plot_y,'warning','off');
        cie1931(plot_x,plot_y,'Planck','on','Marker','.','MarkerSize',10,'MarkerColor',[1 1 1])
        % measurement data
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','CCT','E'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,4));
        set(handles.topview_point_table,'ColumnEditable',false)
        set(handles.topview_point_table,'Data',[xyz(:,1) xyz(:,2) Tc' Yint]);
    case 'window_material'
        % plot
        %plot_material(hObject,eventdata,handles, handles.data.room, results{room_nr}.sky{sky_nr}{surface})
        % plot material
        axes(handles.topview)
        reset(handles.topview)
        m = results{room_nr}.sky{sky_nr}{surface}.material;
        step = m.data(1,2)-m.data(1,1);
        if step <= 1
            plot(m.data(1,:),m.data(2,:),'Color',handles.blue)
        else
            stem(m.data(1,:),m.data(2,:),'Color',handles.blue,'Marker','.')
        end
        grid on
        xlabel('wavelength in nm')
        ylabel('spectral reflection value')
        title(strrep(results{room_nr}.sky{sky_nr}{surface}.material.name,'_',' '))
        a = axis;
        b = m.data(1,1);
        c = m.data(1,end);
        axis([b c 0 1])
        % plot selected item
        axes(handles.view)
        cla
        plot_surface(results{room_nr}.sky{sky_nr},surface)
        % surface table data
        sdata = results{room_nr}.sky{sky_nr}{surface}.vertices;
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,3))
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,3));
        set(handles.topview_point_table,'Data',sdata);
    case 'window_irradiance'
        axes(handles.topview)
        reset(handles.topview)
        wnorm = -results{room_nr}.sky{sky_nr}{surface}.normal;
        [az,~,~] = cart2sph(wnorm(1),wnorm(2),wnorm(3));
        az = -rad2deg(az)+90;
        [~,ir] = polardataE(sky{sky_nr-1}.spectrum(2:end,:),az);
        lam = sky{sky_nr-1}.spectrum(1,:);
        idx = lam==0;
        lam = lam(~idx);
        ir = ir(~idx);
        if lam(2)-lam(1) <= 1
            plotspec(lam,ir);
        else
            stem(lam,ir)
        end
        grid on
        xlabel('wavelength \lambda in nm')
        ylabel('spectral irradiance in W m^{-2} nm^{-1}')
        title(results{room_nr}.sky{sky_nr}{surface}.name)
        E = ciespec2Y(lam,ir);
        xyz = ciespec2xyz(lam,ir);
        legend(['E = ',num2str(round(E,1)),' lx'])
        axes(handles.view)
        reset(handles.view)
        cie1931(xyz(1),xyz(2),'Planck','on','Marker','.','MarkerSize',10,'MarkerColor',[1 1 1])
        set(handles.topview_point_table,'Data',[]);
        str = strsplit(num2str(lam));
        set(handles.topview_point_table,'ColumnName',str)
        set(handles.topview_point_table,'ColumnEditable',false(1,3))
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,length(ir)));
        set(handles.topview_point_table,'Data',ir);
    case 'window_radiance'
        axes(handles.topview)
        reset(handles.topview)
        wnorm = -results{room_nr}.sky{sky_nr}{surface}.normal;
        [az,~,~] = cart2sph(wnorm(1),wnorm(2),wnorm(3));
        az = -rad2deg(az)+90;
        spec = sky{sky_nr-1}.spectrum(2:end,:);
        wlam = results{room_nr}.sky{sky_nr}{surface}.material.data(1,:);
        wspec = results{room_nr}.sky{sky_nr}{surface}.material.data(2,:);
        [~,ra] = polardataspec(spec,az,'complete');
        lam = sky{sky_nr-1}.spectrum(1,:);
        idx1 = ismember(lam,wlam);
        idx2 = ismember(wlam,lam);
        lam = lam(idx1);
        ra = ra(idx1).*wspec(idx2);     
        if lam(2)-lam(1) <= 1
            plotspec(lam,ra);
        else
            stem(lam,ra)
        end
        grid on
        xlabel('wavelength \lambda in nm')
        ylabel('spectral radiance in W m^{-2} nm^{-1}')
        title(results{room_nr}.sky{sky_nr}{surface}.name)
        %L = ciespec2Y(lam,ra);
        xyz = ciespec2xyz(lam,ra);
        %legend(['L = ',num2str(round(L,1)),' cd m^{-2}'])
        axes(handles.view)
        reset(handles.view)
        cie1931(xyz(1),xyz(2),'Planck','on','Marker','.','MarkerSize',10,'MarkerColor',[1 1 1])
        set(handles.topview_point_table,'Data',[]);
        %set(handles.topview_point_table,'RowName',num2str(lam))
        set(handles.topview_point_table,'ColumnEditable',false(1,3))
        set(handles.topview_point_table,'ColumnFormat', repmat({'numeric'},1,length(ra)));
        set(handles.topview_point_table,'Data',ra);
    case plot_mode{selected}
        plot_mode{selected}
    otherwise
        
end



function U = fisheye_inverse(X, T) % not used anymore
% https://stackoverflow.com/questions/2589851/how-can-i-implement-a-fisheye-lens-effect-barrel-transformation-in-matlab
% see also
% http://paulbourke.net/dome/fisheye/ (not used)

imageSize = T.tdata(1:2);
origin = (imageSize+1)./2;
scale = imageSize./2;

x = (X(:, 1)-origin(1))/scale(1);
y = (X(:, 2)-origin(2))/scale(2);
R = sqrt(x.^2+y.^2);
theta = atan2(y, x);

cornerScale = min(abs(1./sin(theta)), abs(1./cos(theta)));
cornerScale(R < 1) = 1;
exponent = 2.5;%2.3;
R = cornerScale.*R.^exponent;

x = scale(1).*R.*cos(theta)+origin(1);
y = scale(2).*R.*sin(theta)+origin(2);
U = [x y];


function plot_surface(surfaces,nr)
reset(gca)
for s = 1:numel(surfaces)
    % plot borders
    c = surfaces{s}.vertices;
    %if ~strcmp(surfaces{s}.type,'window')
        line('XData',c(:,1),'YData',c(:,2),'ZData',c(:,3),'Color','k');
    %end
    try
        for b = 1:numel(surfaces{s}.blank)
            C = surfaces{s}.blank{b}.vertices;
            line('XData',C(:,1),'YData',C(:,2),'ZData',C(:,3),'Color','k','LineStyle','--');
        end
    catch
    end
    if isequal(s,nr)
        p = patch('Vertices',c,'Faces',1:size(c,1),...
            'EdgeColor','none',...
            'FaceVertexCData',repmat([1.0000 0 0.2585],size(c,1),1),...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FaceAlpha',0.8,...
            'FacesMode','auto');
    end
end
axis off
axis equal
title('')
view([315 30])



function plot_point(handles,m,axh)
reset(axh)
axes(axh)
step = m.lambda(2)-m.lambda(1);
c  = [0 0.5267 0.6461];
if step <= 1
    plot(m.lambda,m.E,'Color',c)
else
    stem(m.lambda,m.E,'Color',c,'Marker','.')
end
grid on
xlabel('wavelength in nm')
ylabel('spectral irradiance in W m^{-2} nm^{-1}')
title(strrep(m.name,'_',' '))
a = axis;
b = m.lambda(1,1);
c = m.lambda(1,end);
axis([b c a(3) a(4)])

data = round(ciespec2unit(m.lambda,m.E,'a-opic'),1);
E = round(ciespec2unit(m.lambda,m.E,'VL'),1);

str = ['E_{sc} = ',num2str(data(1)),...
       ', E_{mc} = ',num2str(data(2)),...
       ', E_{lc} = ',num2str(data(3)),...
       ', E_{rh} = ',num2str(data(4)),...
       ', E_{mel} = ',num2str(data(5)),...
       ', E = ',num2str(E(1)),' in W m^{-2}',...
       ];
legend(str,'Location','northoutside')

set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'ColumnName',[])
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnEditable',false)
set(handles.topview_point_table,'Data',[m.lambda;m.E]);





function result_listbox_callback_OLD(hObject,eventdata,handles)
if isequal(sum(part_nr),0) && isempty(observer_nr) && ~isempty(sky_nr)
    
    % room rendering
    if parameter == 4
        axes(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)
        refresh_2D(hObject, eventdata, handles)
        axes(handles.view)
        %plot_gouraud(room{room_nr},handles.data.sky,handles.view,handles.topview,room_nr)
        plotGouraud(R{handles.data.room}.sky{handles.data.sky},handles.view,handles.topview);
        % room mesh plot
    elseif parameter == 7
        axes(handles.topview)
        handles.data.room = room_nr;
        guidata(hObject,handles)
        refresh_2D(hObject, eventdata, handles)
        axes(handles.view)
        %plotmesh3d(room{room_nr},handles.data.sky)
        plotmesh3d(R{room_nr}.sky{handles.data.sky})
        
    else
        % plot sky
        axes(handles.view)
        plot_tregenza_sky(sky{sky_nr},1,'explosion');
        axes(handles.topview)
        plot_tregenza_sky(sky{sky_nr},1,'2D');
        
        % set table
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','L','CCT'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,4))
        % sky list
        sky = getappdata(handles.Lumos,'sky');
        if size(sky,2) > 0
            set(handles.topview_point_table,'Data',[sky{sky_nr}.x sky{sky_nr}.y round(sky{sky_nr}.L) round(sky{sky_nr}.CCT)]);
        end
        
        
    end
    
elseif isequal(sum(part_nr),0) && isempty(observer_nr) && isempty(sky_nr)
    % plot room geometry
    axes(handles.topview)
    refresh_2D(hObject,eventdata,handles)
    handles = guidata(hObject);
    plot_observer(hObject, eventdata, handles)
    axes(handles.view)
    plot_3D(hObject, eventdata, handles, -100, 0)
    plot_observer(hObject, eventdata, handles)
    % set room table
    table = getappdata(handles.Lumos,'table');
    data = table{room_nr}.room;
    set(handles.topview_point_table,'Data',[]);
    set(handles.topview_point_table,'ColumnName',{'x','y','z'})
    set(handles.topview_point_table,'RowName','numbered')
    set(handles.topview_point_table,'ColumnEditable',false(1,4))
    set(handles.topview_point_table,'Data',data);
    
elseif ~isequal(sum(part_nr),0)
    % material plot
    if isequal(parameter,0)
        
        axes(handles.topview)
        
        part = find(part_nr~=0,1);
        switch part
            case 1 % floor
                if part_nr(1) == -100
                    
                    data = [];
                    
                    axes(handles.topview)
                    x = room{room_nr}.environment_ground.material.data(1,:);
                    y = room{room_nr}.environment_ground.material.data(2,:);
                    plot(x,y,'Color',handles.blue)
                    grid on
                    xlabel('wavelength in nm')
                    ylabel('spectral reflection value')
                    title('spectral material properties')
                    %a = axis;
                    b=x(1,1);
                    c=x(1,end);
                    axis([b c 0 1])
                    
                    axes(handles.view)
                    cla
                    colorbar off
                    legend('off')
                    reset(handles.view)
                    y = R{room_nr}.ground{sky_nr}.irradiance;
                    x = R{room_nr}.ground{sky_nr}.lambda;%sky{sky_nr}.spectrum(1,:);
                    
                    out = x==0;
                    x(out) = [];
                    a = axis;
                    axis([b c 0 a(4)])
                    plot(x,y,'Color',[0   0.4470   0.7410])
                    [xyz1,~,~,~,E] = ciespec2xyz(x,y);
                    E = E(:,2);
                    T1 = CCT('x',xyz1(1),'y',xyz1(2));
                    hold on
                    
                    y = R{room_nr}.ground{sky_nr}.radiance;
                    x = R{room_nr}.ground{sky_nr}.lambda;
                    plot(x,y,'Color',[0.8594    0.5153   0]);
                    xlim([x(1) x(end)])
                    grid on
                    xlabel('wavelength in nm')
                    ylabel('E_{e,\lambda,h} in W/m^2/nm, L_{e,\lambda} in W/m^2/sr/nm')
                    title('environment ground')
                    [xyz2,~,~,~,L] = ciespec2xyz(x,y);
                    L = L(:,2);
                    T2 = CCT('x',xyz2(1),'y',xyz2(2));
                    legend(['E_{h} = ',num2str(round(E)),' lx',10,'x = ',num2str(round(xyz1(1),4)),10,'y = ',num2str(round(xyz1(2),4)),10,'T_{cp} = ',num2str(round(T1)),' K'],...
                        ['L = ',num2str(round(L)),' cd/m^2',10,'x = ',num2str(round(xyz2(1),4)),10,'y = ',num2str(round(xyz2(2),4)),10,'T_{cp} = ',num2str(round(T2)),' K'],...
                        'Location','NorthOutside','Orientation','horizontal');
                else
                    plot_material(hObject,eventdata,handles, room_nr,0 , 0)
                    axes(handles.view)
                    cla
                    plot_3D(hObject, eventdata, handles, 0, 0)
                    try
                        data = room{room_nr}.floor{part_nr(1)}.vertices;
                    catch
                        data = room{room_nr}.floor.vertices;
                    end
                end
            case 2 % wall
                plot_material(hObject,eventdata,handles, room_nr,part_nr(part) , 0)
                axes(handles.view)
                cla
                plot_3D(hObject, eventdata, handles, part_nr(part), 0)
                data = room{room_nr}.walls{part_nr(2)}.vertices;
            case 3 % ceiling
                plot_material(hObject,eventdata,handles, room_nr,max(size(room{room_nr}.walls))+1 , 0)
                axes(handles.view)
                cla
                plot_3D(hObject, eventdata, handles, w+1, 0)
                try
                    data = room{room_nr}.ceiling{part_nr(3)}.vertices;
                catch
                    data = room{room_nr}.ceiling.vertices;
                end
                
        end
        % set room table
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'x','y','z'})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,4))
        set(handles.topview_point_table,'Data',data);
    else
        % spectrogram
        if parameter == 3 || parameter == 4
            plot_surface_spectrogram(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
            plot_DIN_grid(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.view,1,'num')
            % chromaticity
        elseif parameter == 5 || parameter == 6
            
            axes(handles.view)
            cla
            reset(handles.view)
            plot_DIN_grid(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.view,1,'num')
            % chromaticity
            reset(handles.topview)
            axes(handles.topview)
            cla
            plotChromaticityCIE1931(room,room_nr,part_nr,sky_nr,parameter,handles.topview,handles)
            
            % illuminance and luminance
        elseif parameter == 1 || parameter == 2
            plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
            plot_DIN_grid(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.view,1,'x')
        end
    end
elseif ~isempty(observer_nr)
    
    if isequal(parameter,1)
        data = room{room_nr}.observer{observer_nr}.spatial{sky_nr}.L;
        lambda = room{room_nr}.results{sky_nr}.walls{1}.lambda;
        axes(handles.view)
        colorbar off
        legend('off')
        cla
        % plot directogram - input: data matrix, lambda, plot_rgb: 1 = color, 0 = gray
        double_hemisphere(data,lambda,1)
        axes(handles.topview)
        plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.topview)
        
    elseif isequal(parameter,0)
        
        axes(handles.view)
        plot_3D(hObject, eventdata, handles, -100, 0)
        plot_observer(hObject, eventdata, handles, observer_nr)
        
        refresh_2D(hObject, eventdata, handles)
        handles = guidata(hObject);
        plot_observer(hObject, eventdata, handles, observer_nr)
        % clear gui table
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'','','',''})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,4))
        
        
    elseif isequal(parameter,2)
        
        data = room{room_nr}.observer{observer_nr}.spatial{sky_nr}.J;
        data(isnan(data)) = 0;
        lambda = room{room_nr}.results{sky_nr}.walls{1}.lambda;
        patches = [1:145 -1:-1:-145];
        axes(handles.topview)
        reset(handles.topview)
        cla
        legend('off')
        colorbar off
        
        plot_spectrogram(lambda, data, patches, '2D')
        
        axes(handles.view)
        reset(handles.view)
        cla
        legend('off')
        colorbar off
        
        plot_spectrogram(lambda, data, patches, '3D')
        
        % set gui table
        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'ColumnName',{'','','',''})
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,4))
        set(handles.topview_point_table,'Data',data);
    elseif isequal(parameter,5)
        % observer chromaticity
        plotChromaticityCIE1931(room,room_nr,part_nr,sky_nr,parameter,handles.topview,handles,room{room_nr}.observer,observer_nr)
        plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.view)
        
        
    elseif isequal(parameter,7)
        % testing viewing field plot -> doesn't seem to work
        comeback('testing view plot')
        plot_room_part_result(handles,room{room_nr},sky_nr,part_nr,observer_nr,parameter,handles.view)
        axes(handles.view)
        plot_gouraud(room{room_nr},handles.data.sky,handles.view,handles.topview,room_nr)
        set(gca,'CameraPosition','auto')
        campos([room{room_nr}.observer{observer_nr}.coordinates])
        
        
    end
    
end


function plot_spectrogram(lambda, data, patches, modus)

surf(lambda,patches,data,'Edgecolor','none')
colormap('parula')

c = colorbar;
ylabel('patchnumber')
xlabel('\lambda in nm')
if strcmp('2D',modus)
    view([-90 90])
    grid off
    axis([lambda(1) lambda(end) -145 145 ])
else
    view([60 30])
    axis([lambda(1) lambda(end) -145 145 0 inf])
end
ylabel(c,'spectral radiant incidence J''_{e,\lambda} in W/sr/nm')



function plot_surface_spectrogram(handles,surface,axh,input)
reset(axh)
lambda = surface.lambda;

% rotate in y-z axis
[vertices,blank,mesh] = yz_plane_rotation(surface);
mesh_coordinates = mesh.patchcenter;

% bugfix
fix = 0;
if (max(mesh_coordinates(:,2)) - min(mesh_coordinates(:,2))) < 1e-10
    mesh_coordinates(:,2) = mesh_coordinates(:,1)-min(mesh_coordinates(:,1));
    fix = 1;
end

% DIN EN 12464-1 point grid
%check = max(vertices(:,2))-min(vertices(:,2))>2 && max(vertices(:,3))-min(vertices(:,3))>2;
check = 0;

if check
    d = max(vertices(:,2))-min(vertices(:,2))-1;
    b = max(vertices(:,3))-min(vertices(:,3))-1;
else
    d = max(vertices(:,2))-min(vertices(:,2));
    b = max(vertices(:,3))-min(vertices(:,3));
end
d = round(d,12);
b = round(b,12);
p = 0.2*5^(log10(d));
p = real(p);

if p > 10
    p = 10;
end
dn = ceil(d/p);
if isequal(mod(dn,2),0)
    dn  = dn+1;
end
bn = ceil(b/p);
if isequal(mod(bn,2),0)
    bn = bn+1;
end
if d/dn > p
    dw = p;
else
    dw = d/dn;
end
if b/bn > p
    bw = p;
else
    bw = b/bn;
end

% interpolation grid
if check
    rgrid = linspace(0.5+dw/2,d+0.5-dw/2,dn);
    rgrid = [0.5 rgrid 0.5+d];
    zgrid = linspace(0.5+bw/2,b+0.5-bw/2,bn);
    zgrid = [0.5 zgrid 0.5+b];
else
    rgrid = linspace(dw/2,d-dw/2,dn);
    zgrid = linspace(bw/2,b-bw/2,bn);
end
[xq,yq] = meshgrid(rgrid,zgrid);


% data values
switch input
    case 'E'
        unit = 'spectral irradiance E_{e,\lambda} in W m^{-2} nm^{-1}';
        data = surface.E;
    case 'L'
        unit = 'spectral radiance L_{e,\lambda} in W m^{-2} sr^{-1} nm^{-1}';
        data = surface.L;
end



% allocate empty 3D matrix
if check
    value_inter = zeros((size(xq,1)-2),(size(xq,2)-2),size(data,2));
else
    value_inter = zeros((size(xq,1)),(size(xq,2)),size(data,2));
end
ind = 1;
for lam = 1:size(lambda,2)
    % interpolate spectra for grid points
    if check
        value_inter(:,:,lam) = griddata(mesh_coordinates(:,2),mesh_coordinates(:,3)',data(:,lam),rgrid(2:end-1)',zgrid(2:end-1));
    else
        value_inter(:,:,lam) = griddata(mesh_coordinates(:,2),mesh_coordinates(:,3)',data(:,lam),rgrid',zgrid);
        value_inter(:,:,lam) = fillmissing(value_inter(:,:,lam),'linear',2,'EndValues','nearest');
        value_inter(:,:,lam) = fillmissing(value_inter(:,:,lam),'linear',1,'EndValues','nearest');
    end
    ind = ind+1;
end

% rotate
value_inter = rot90(value_inter,1);

% reshape matrix
data = [];
%value_inter(~repmat(flipud(inpol),1,1,size(value_inter,3))) = NaN;
if check
    data = reshape(value_inter,(size(xq,1)-2)*(size(xq,2)-2),size(lambda,2));
else
    data = reshape(value_inter,(size(xq,1))*(size(xq,2)),size(lambda,2));
end
data(isnan(data)) = 0;

% blank areas?
try
    inpol = inpolygon(rot90(xq,-3),rot90(yq,-3),vertices(:,2),vertices(:,3));
    data(~inpol(:),:) = NaN;
    for w = 1:size(surface.blank,2)
        x = blank{w}.vertices(:,2);
        y = blank{w}.vertices(:,3);
        % erase points in windows from table
        %in = inpolygon(xq(2:end-1,2:end-1)',yq(2:end-1,2:end-1)',x,y);
        in = inpolygon(fliplr(xq),yq,x,y);
        in = in';
        data(in(:),:) = 0;
    end
catch
    % no blank areas
end



% plot
axes(axh)
num = 1:size(data,1);
imagesc(data);

%axis([lambda(1) lambda(end) 1 size(data,1)])
CB = colorbar;
CB.Label.String = unit;
caxis([0 CB.Limits(2)]);
xlabel('\lambda in nm')
ylabel('point')
if numel(num)>50
    yline(num(2:end)-0.5,'w','Linewidth',1)
else
    yline(num(2:end)-0.5,'w','Linewidth',2)
end
grid off
%view([0 270])
if numel(num)<20
    yticks(num);
end

% set gui table
x = 1:numel(lambda)-1;
x = x(~(rem(numel(lambda)-1, x)));
n = (numel(lambda)-1)./x;
[~,ind] = find(n<=8 & n>=4);
try
    ind = ind(1);
catch
end
if isempty(ind)
    inc = round(numel(lambda)/8);
else
    inc = x(ind);
end
xt = 1:inc:numel(lambda);

xticks(xt)
xticklabels(lambda(xt))


set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'ColumnName',{'','','',''})
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnEditable',false(1,4))
set(handles.topview_point_table,'Data',data(1:end,:));
% -- end of function --%


function plot_room_part_result(handles,surface,axh,mode)
reset(axh)
axes(axh)
cla
colorbar off

switch mode
    case 'E'
        data = surface.E;
        color = [0   0.4470   0.7410];
        labeltext = 'spectral irradiance E_{e,\lambda} in W m^{-2} nm^{-1}';
        lambda = surface.lambda;
    case 'L'
        data = surface.L;
        color = [0.8500    0.3250    0.0980];
        labeltext = 'spectral radiance L_{e,\lambda} in W m^{-2} sr^{-1} nm^{-1}';
        lambda = surface.lambda; 
end


start = find(data(1,:)~=0,1);
if isempty(start)
    start=1;
end
check = sum(data,2);
check = find(check == 0);
data(check,:) = [];

datamin = min(data,[],1);
datamax = max(data,[],1);
var = sum(((data-mean(data,1)).^2),1)./(size(data,1)-1);
std = sqrt(var);
%axes(axh)
%figure
cla

if ~isempty(datamax)

patch([lambda fliplr(lambda)],[datamax fliplr(datamin)],color,'EdgeColor','none','FaceAlpha',0.5)
hold on
patch([lambda fliplr(lambda)],[mean(data)+std fliplr(mean(data)-std)],color,'EdgeColor','none','FaceAlpha',0.6)
plot(lambda,mean(data,1),'Color',color)
axis([lambda(start) lambda(end) 0 inf])
grid on
set(gca, 'Layer', 'top')
xlabel('\lambda in nm')
ylabel(labeltext)
hold off
else
    axis off
    text(0.5,0.5,'no data')
end



function plot_DIN_grid(handles,surface,axh,table,input,modus)
reset(axh)
%mesh = surface.mesh;

% rotate in y-z axis
[vertices,blank,mesh] = yz_plane_rotation(surface);
mesh_coordinates = mesh.patchcenter;

% bugfix
fix = 0;
if (max(mesh_coordinates(:,2)) - min(mesh_coordinates(:,2))) < 1e-10
    mesh_coordinates(:,2) = mesh_coordinates(:,1)-min(mesh_coordinates(:,1));
    fix = 1;
end
% DIN EN 12464-1 point grid
%check = max(vertices(:,2))-min(vertices(:,2))>2 && max(vertices(:,3))-min(vertices(:,3))>2;
check = 0;


if check
    d = max(vertices(:,2))-min(vertices(:,2))-1;
    b = max(vertices(:,3))-min(vertices(:,3))-1;
else
    d = max(vertices(:,2))-min(vertices(:,2));
    b = max(vertices(:,3))-min(vertices(:,3));
end

d = round(d,12);
b = round(b,12);
p = 0.2*5^(log10(d));
p = real(p);

if p > 10
    p = 10;
end
dn = ceil(d/p);
if isequal(mod(dn,2),0)
    dn  = dn+1;
end
bn = ceil(b/p);
if isequal(mod(bn,2),0)
    bn = bn+1;
end
if d/dn > p
    dw = p;
else
    dw = d/dn;
end
if b/bn > p
    bw = p;
else
    bw = b/bn;
end

% interpolation grid
if check
    rgrid = linspace(0.5+dw/2,d+0.5-dw/2,dn);
    rgrid = [0.5 rgrid 0.5+d];
    zgrid = linspace(0.5+bw/2,b+0.5-bw/2,bn);
    zgrid = [0.5 zgrid 0.5+b];
else
    rgrid = linspace(dw/2,d-dw/2,dn);
    zgrid = linspace(bw/2,b-bw/2,bn);
end
exrgrid = [0 rgrid max(vertices(:,2))];
exzgrid = [0 zgrid max(vertices(:,3))];
[xq,yq] = meshgrid(rgrid,zgrid);
[exxq,exyq] = meshgrid(exrgrid,exzgrid);


% data values
switch input
    case 'E'
        unit = 'E in lx';
        V = ciespec2Y(surface.lambda,surface.E);
    case 'L'
        unit = 'L in cd m^{-2}';
        V = ciespec2Y(surface.lambda,surface.L);
end


% interpolate luminance and illuminance
if exist('V','var')
    value_inter = griddata(mesh_coordinates(:,2),mesh_coordinates(:,3)',V,exrgrid',exzgrid);
    value_inter = fillmissing(value_inter,'linear',2,'EndValues','nearest');
    value_inter = fillmissing(value_inter,'linear',1,'EndValues','nearest');
else
    value_inter = [];
end


% plot
axes(axh)
legend('off');
colorbar off;
cla
reset(axh)
%extended = 'n';
% view from inside the room
if strcmp(surface.type,'object')
    
    value_inter = rot90(value_inter,1);
    xq = rot90(xq,1);
    yq = rot90(yq,1);
    exxq = rot90(exxq,1);
    exyq = rot90(exyq,1);
    %p = patch(vertices(:,2),max(vertices(:,3))-vertices(:,3),'w');
    plot(vertices(:,2),max(vertices(:,3))-vertices(:,3),'k')
    hold on
    
    % contour border
    if check
        plot([0.5 0.5+d 0.5+d 0.5 0.5],[0.5 0.5 0.5+b 0.5+b 0.5],'k');
    end
    % isolines
    if isequal(size(xq,2),1) && isequal(sum(diff(yq)),0)
        xq = [xq xq];
        yq = [yq-yq yq+yq];
        value_inter = [value_inter value_inter];
        extended = 'y';
    elseif isequal(size(xq,2),1) && isequal(sum(diff(xq)),0)
        yq = [yq yq];
        xq = [xq-xq xq+xq];
        value_inter = [value_inter value_inter];
        extended = 'x';
    end
    contourf(exxq,exyq,value_inter,'LineStyle','none');
    colormap default
    CB = colorbar;
    CB.Label.String = unit;
    caxis([0 CB.Limits(2)]);
    value_inter = rot90(value_inter(2:end-1,2:end-1),-1);
else
    
    % contour border
    if check
        plot([0.5 0.5+d 0.5+d 0.5 0.5],[0.5 0.5 0.5+b 0.5+b 0.5],'k')
    end
    if isequal(size(xq,2),1) && isequal(sum(diff(yq)),0)
        xq = [xq xq];
        yq = [yq-yq yq+yq];
        value_inter = [value_inter value_inter];
        extended = 'y';
    elseif isequal(size(xq,2),1) && isequal(sum(diff(xq)),0)
        yq = [yq yq];
        xq = [xq-xq xq+xq];
        value_inter = [value_inter value_inter];
        extended = 'x';
    end
    % isolines
    contourf(exxq,exyq,value_inter,'LineStyle','none')
    colormap default
    CB = colorbar;
    CB.Label.String = unit;
    caxis([0 CB.Limits(2)]);
    hold on

    % plot white mask
    fx = exxq(end)*0.001;
    fy = exyq(end)*0.001;
    pgon = polyshape({[exxq(1)-fx exxq(end)+fx exxq(end)+fx exxq(1)-fx],vertices(1:end-1,2)},{[exyq(1)-fy exyq(1)-fy exyq(end)+fy exyq(end)+fy],vertices(1:end-1,3)});
    plot(pgon,'FaceColor','w','FaceAlpha',1)


end

value_inter = value_inter(2:end-1,2:end-1);

% blank areas?
try
    for w = 1:size(surface.blank,2)
        % rotate window coordinates accordingly
        data = blank{w}.vertices;

        % coordinates
        y = data(:,3) - min(mesh_coordinates(:,3));
        if isequal(fix,0)
            x = data(:,2) - min(mesh_coordinates(:,2));
        else
            x = data(:,1) - min(mesh_coordinates(:,1));
        end
        % erase points in windows from table
        in = inpolygon(xq,yq,x,y);
        
        value_inter(in) = NaN;
        % plot window
        patch(x,y,[1 1 1])
    end
catch
    % no windows
end
set(gca,'ydir','reverse','xdir','reverse')
%end
a = gca;

%bookmark('DIN Grid')
inpol = inpolygon(xq,yq,vertices(:,2),vertices(:,3));
rotn = 0;
if contains(surface.name,'floor')
    rotn = 1;
    value_inter = rot90(value_inter,-rotn);
    inpol = rot90(inpol,-rotn);
    %value_inter = flipud(value_inter);
    %a.View = [90 90];
elseif contains(surface.name,'wall')
    rotn = 2;
    value_inter = rot90(value_inter,-rotn);
    value_inter = fliplr(flipud(value_inter));
    inpol = rot90(inpol,-rotn);
    %a.View = [180 90];
elseif contains(surface.name,'ceiling')
    rotn = 1;
    value_inter = rot90(value_inter,-rotn);
    %value_inter = value_inter(2:end-1,2:end-1);
    inpol = rot90(inpol,-rotn);
    %a.View = [90 90];
elseif contains(surface.name,'object')
    rotn = 2;
end
a.View = [rotn*90 90];
%value_inter = rot90(value_inter,-rotn);
axis off equal

if strcmp(modus,'x')
    % mark grid points
    if check
        plot(xq(2:end-1,2:end-1),yq(2:end-1,2:end-1),'xk','Markersize',6,'LineWidth',1.25)
    else
        % values outside surface polygon
        in = inpolygon(xq,yq,vertices(:,2),vertices(:,3));
        xq(~in) = NaN;
        yq(~in) = NaN;
        plot(xq,yq,'xk','Markersize',6,'LineWidth',1.25)
    end
    % show table data
    if table

        value_inter(~inpol) = NaN;

        set(handles.topview_point_table,'Data',[]);
        set(handles.topview_point_table,'RowName','numbered')
        set(handles.topview_point_table,'ColumnEditable',false(1,size(value_inter,2)))
        set(handles.topview_point_table,'columnname','numbered')
        set(handles.topview_point_table,'Data',flipud(value_inter))
    end
    
elseif strcmp(modus,'num')
    
    if check
        xqn = xq(2:end-1,2:end-1);
        yqn = yq(2:end-1,2:end-1);
        for point = 1:(size(xq,1)-2)*(size(xq,2)-2)
            text(xqn(point),yqn(point),num2str(point),'HorizontalAlignment','center','VerticalAlignment','middle','Fontsize',8,'Color','k','FontWeight','bold');
        end
    else

        xqn = xq';
        xqn = flipud(xqn(:));
        yqn = yq';

         % values outside surface polygon
        in = inpolygon(xqn,yqn,vertices(:,2),vertices(:,3));
        xqn(~in) = NaN;
        yqn(~in) = NaN;

        for point = 1:(size(xq,1))*(size(xq,2))
            text(xqn(point),yqn(point),num2str(point),'HorizontalAlignment','center','VerticalAlignment','middle','Fontsize',8,'Color','k','FontWeight','bold');
        end
    end
    
end

 % -- end of function --


function plot_grid(handles,surface,axh,table,input,modus)

% data values
switch input
    case 'E'
        unit = 'E in lx';
        V = ciespec2Y(surface.lambda,surface.E);
    case 'L'
        unit = 'L in cd m^{-2}';
        V = ciespec2Y(surface.lambda,surface.L);
end

% plot
axes(axh)
legend('off');
colorbar off;
cla
reset(axh)


x = reshape(surface.points(:,1),surface.pointsy,surface.pointsx);
y = reshape(surface.points(:,2),surface.pointsy,surface.pointsx);
Y = reshape(V,surface.pointsy,surface.pointsx);
Y(isnan(Y)) = 0;
% add border coordinates
xb = ones(size(x)+2).*NaN;
yb = ones(size(y)+2).*NaN;
Vex = ones(size(Y)+2).*NaN;
Vex(2:end-1,2:end-1) = Y;
xb(2:end-1,2:end-1) = x;
xb(:,1) = 0;
xb(:,end) = surface.width;
xb(1,:) = xb(2,:);
xb(end,:) = xb(end-1,:);
yb(2:end-1,2:end-1) = y;
yb(1,:) = 0;
yb(end,:) = surface.length;
yb(:,1) = yb(:,2);
yb(:,end) = yb(:,end-1);
% get border values (extrapolation: nearest value)
%value_inter = griddata(mesh_coordinates(:,2),mesh_coordinates(:,3)',V,rgrid',zgrid);
Vex = fillmissing(Vex,'linear',2,'EndValues','extrap');
Vex = fillmissing(Vex,'linear',1,'EndValues','extrap');


% plot false colours
plot(NaN,NaN,'w')
hold on
p = contourf(xb,yb,Vex,'LineStyle','none');
colormap default
CB = colorbar;
CB.Label.String = unit;
hold on

minY = min(min(Y));
maxY = max(max(Y));
meanY = mean(mean(Y));
U_0 = minY/meanY;
% point markers
if strcmp(modus,'x')
    plot(x(:),y(:),'xk','Markersize',6,'LineWidth',1.25)
else
    for point = 1:size(surface.points,1)
        text(surface.points(point,1),surface.points(point,2),num2str(point),'HorizontalAlignment','center','VerticalAlignment','middle','Fontsize',8,'Color','k','FontWeight','bold');
    end
end
    legend(['E_{min} = ',num2str(round(minY,2)),' lx , E_{max} = ',num2str(round(maxY,2)),' lx , E_{mean} = ',num2str(round(meanY,2)),' lx , U_0 = ',num2str(round(U_0,2)),'	'],'Location','northoutside')
    set(handles.topview_point_table,'Data',[]);
    set(handles.topview_point_table,'RowName','numbered')
    set(handles.topview_point_table,'ColumnEditable',false(1,size(Y,2)))
    set(handles.topview_point_table,'ColumnEditable',false(1,size(Y,2)))
    set(handles.topview_point_table,'columnname','numbered')
    set(handles.topview_point_table,'Data',flipud(Y))
    
axis auto
axis equal
axis off






function plot_wall(room,w,h)
part = find(w~=0,1);
w = w(part);
switch part
    case 1 % floor
        try
            data = room.floor{w}.vertices;
            normal = wall_normal(room,room.floor{w},0.1);
            handles.data.normal_direction = 1;
        catch
            data = room.floor.vertices;
            normal = wall_normal(room,room.floor,0.1);
            handles.data.normal_direction = 1;
        end
    case 2 % wall
        data = room.walls{w}.vertices;
        normal = wall_normal(room,room.walls{w},0.1);
        handles.data.normal_direction = 1;
    case 3 % ceiling
        try
            data = room.ceiling{w}.vertices;
            normal = wall_normal(room,room.ceiling{w},0.1);
            handles.data.normal_direction = 1;
        catch
            data = room.ceiling.vertices;
            normal = wall_normal(room,room.ceiling,0.1);
            handles.data.normal_direction = 1;
        end
end
% calculate normal vector
x = [min(data(:,1)) max(data(:,1))];
y = [min(data(:,2)) max(data(:,2))];
z = [min(data(:,3)) max(data(:,3))];
v1 = [x(1) y(1) z(1)]-[x(2) y(2) z(1)];
v2 = [x(1) y(1) z(1)]-[x(1) y(1) z(2)];

% select axes
axes(h)
legend('off');
colorbar off;
% set camera to a orthogonal point of view
campos([mean(x) mean(y) mean(z)]+normal); % camera position coordinates
camtarget([mean(x) mean(y) mean(z)]); % camera target coordinates

if sum(normal) == 0
    campos([mean(x) mean(y) 1]);
end
% delete old plots
children = get(gca, 'children');
if ~isempty(children)
    delete(children);
end

% plot wall in 2D view
wall = patch(data(:,1),data(:,2),data(:,3),[0.75 0.75 0.75]);
set(wall,'HitTest','on','PickableParts','all','ButtonDownFcn',{@add_window, handles, w})

% add measurement labels - textlabel(1:3)
Vector = [x(2)-x(1) y(2)-y(1)];
Vector = Vector/max(Vector);
textlabel(1) = text(mean(x), mean(y), min(data(:,3))-0.5,[num2str(round((sqrt((data(2,1)-data(1,1))^2+(data(1,2)-data(2,2))^2)*100))/100),' m'],'HorizontalAlignment','Center');
if handles.data.normal_direction == 0
    textlabel(2) = text(min(x)-0.5*Vector(1), min(y)-0.5*Vector(2), mean(z),[num2str(data(3,3)),' m'],'VerticalAlignment','middle');
else
    textlabel(2) = text(min(x)-0.5*Vector(1), min(y)-0.5*Vector(2), mean(z),[num2str(data(4,3)),' m'],'VerticalAlignment','middle');
end
set(textlabel(2), 'rotation', 90)
if handles.data.normal_direction == 0
    textlabel(3) = text(max(x)+0.5*Vector(1), max(y)+0.5*Vector(2), mean(z),[num2str(data(4,3)),' m'],'VerticalAlignment','middle');
else
    textlabel(3) = text(max(x)+0.5*Vector(1), max(y)+0.5*Vector(2), mean(z),[num2str(data(3,3)),' m'],'VerticalAlignment','middle');
end
set(textlabel(3), 'rotation', 90)

% plot existing windows
if isequal(part,2)
    try
        for win = 1:size(room.walls{w}.windows,2)
            window = patch(room.walls{w}.windows{win}.data(:,1),room.walls{w}.windows{win}.data(:,2),room.walls{w}.windows{win}.data(:,3),[     0    0.5267    0.6461]);
            % window handle
            room.walls{w}.windows{win}.handle = window;
        end
    catch
    end
end
hold off
axis auto
d = 1;
axis([x(1)-d x(2)+d y(1)-d y(2)+d z(1)-d z(2)+d])
axis off
axis equal


% --------------------------------------------------------------------
function uipushtool8_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.topview_point_table,'data');
rnames = get(handles.topview_point_table,'RowName');
cnames = get(handles.topview_point_table,'ColumnName');

file = savefile('Table','xlsx');
% TODO: add column names
T = array2table(data,'VariableNames',cellstr(handles.topview_point_table.ColumnName),'RowNames',cellstr(handles.topview_point_table.RowName));

try
    writetable(T,file,'WriteRowNames',true);
catch
    %file = [file(1:end-3) 'txt'];
    %fid = fopen(file,'wt');
    %for i = 1:size(data,1)
    %    fprintf(fid, '%f  %f  %f\n', data(i,:));
    %end
    %fclose(fid);
end


% --------------------------------------------------------------------
function uipushtool9_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

export_plot(handles,handles.topview,1);


% --------------------------------------------------------------------
function uipushtool10_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_plot(handles,handles.view,2);



function export_plot(handles,axh,nr)
% save plot as png with 300 DPI resolution
saveplot(['plot-',num2str(nr)],'handle',axh,'fileformat','png','resolution',300,'InvertHardcopy','off');
%saveplot(['plot-',num2str(nr)],'handle',axh,'fileformat','png','resolution',1200);



% --------------------------------------------------------------------
function export_table_Callback(hObject, eventdata, handles)
% hObject    handle to export_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uipushtool8_ClickedCallback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_plot1_Callback(hObject, eventdata, handles)
% hObject    handle to export_plot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_plot(handles,handles.topview,1);

% --------------------------------------------------------------------
function export_plot2_Callback(hObject, eventdata, handles)
% hObject    handle to export_plot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_plot(handles,handles.view,2);


% --------------------------------------------------------------------
function menu_new_Callback(hObject, eventdata, handles)
% hObject    handle to menu_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ask for saving
opts.Interpreter = 'tex';
opts.Default = 'Cancel';
answer = questdlg('Save current project?', ...
    'New project', ...
    'Save project','Discard project','Cancel',opts);
switch answer
    case 'Save project'
        uipushtool2_ClickedCallback(hObject, eventdata, handles)
        
    case 'Discard project'
        
    case 'Cancel'
        return
        
end
%clear data
handles.data = [];
handles.data.draw = 0;
handles.data.room_standard_height = 3.2;
handles.SpecSimulation.Name = 'LUMOS - untitled.spr';
setappdata(handles.Lumos,'room',[]);
setappdata(handles.Lumos,'result',[]);
setappdata(handles.Lumos,'table',[]);
setappdata(handles.Lumos,'material',[]);
setappdata(handles.Lumos,'sky',[]);
guidata(hObject,handles)
% open room tab
room_tab_Callback(hObject, eventdata, handles)
set(handles.results_tab,'Enable','off')
guidata(hObject, handles)


% --- Executes on button press in objects_tab.
function objects_tab_Callback(hObject, eventdata, handles)
% hObject    handle to objects_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of objects_tab

axes(handles.view)
colorbar('off')

table = getappdata(handles.Lumos,'table');
if ~exist('handles.data.room','var')
    handles.data.room = 1;
end
table{handles.data.room}.table_mode = 'objects';
% save data
setappdata(handles.Lumos,'table',table);

handles.data.room = 1;
handles.data.object = [];
table{1}.table_mode = 'room';
% (de)activate  tools
toggle_menu_buttons(hObject,handles,[19:23])

R = getappdata(handles.Lumos,'room');
if size(R,1) > size(R,2)
    R = R';
end
T = getappdata(handles.Lumos,'table');
T{1}.table_mode = 'room';
% make list
for l=1:size(R,2)
    list{l,1} = R{l}.name;
end
if size(R,2) > 0
    set(handles.listbox,'Value',1)
else
    set(handles.listbox,'Value',0)
end

% table
guidata(hObject,handles)
object_table(hObject, eventdata, handles)
handles = guidata(hObject);

% listbox
guidata(hObject,handles)
object_listbox(hObject, eventdata, handles)
handles = guidata(hObject);


refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)


try
    refresh_3DObjects(hObject, eventdata, handles)
catch
    view_CreateFcn(hObject, eventdata, handles)
end
guidata(hObject, handles)



function toggle_menu_buttons(hObject,handles,on)
buttons = [10:11 13:15 17 18 19:24 26 28:33];
for n = on
    str = ['toggled = set(handles.uitoggletool',num2str(n),',''Enable'',''on'');'];
    eval(str);
    if strcmp(toggled,'on')
        handles.selected_tool = n;
    end
end
for n = buttons(~ismember(buttons,on))
    str = ['toggled = set(handles.uitoggletool',num2str(n),',''Enable'',''off'');'];
    eval(str);
    if strcmp(toggled,'on')
        handles.selected_tool = n;
    end
end
guidata(hObject, handles)



% --------------------------------------------------------------------
function add_object(hObject, eventdata, handles, r)
% hObject    handle to uitoggletool19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
room = getappdata(handles.Lumos,'room');

% room nr
try
    R = r;
catch
    R = handles.data.room;
end

% add object
try
    nr = size(room{R}.objects,2)+1;
    room{R}.objects{nr}.type = 'single';
    room{R}.objects{nr}.objetcs = [];
    room{R}.objects{nr}.geometry = {[0 0 0 1;1 0 0 1;1 1 0 1;0 1 0 1]};
    room{R}.objects{nr}.coordinates = [1 1 0];
    room{R}.objects{nr}.rotation = [0 0 0];
    room{R}.objects{nr}.name = ['object ',num2str(nr)];
    room{R}.objects{nr}.material = [];
catch
    room{R}.objects{1}.type = 'single';
    room{R}.objects{1}.objetcs = [];
    room{R}.objects{1}.geometry = {[0 0 0 1;1 0 0 1;1 1 0 1;0 1 0 1]};
    room{R}.objects{1}.coordinates = [1 1 0];
    room{R}.objects{1}.rotation = [0 0 0];
    room{R}.objects{1}.name = 'object 1';
    room{R}.objects{1}.material = [];
end

% Save data
setappdata(handles.Lumos,'room',room)

% update list, table and plots
object_listbox(hObject, eventdata, handles)
object_table(hObject, eventdata, handles)
%object_table(hObject,eventdata,handles)
refresh_3DObjects(hObject, eventdata, handles)
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)

guidata(hObject,handles)



function object_listbox(hObject, ~, handles)
% get room data
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
        % list objects
        for o = 1:size(room{r}.objects,2)
            
            list{ind,1} = ['    ',room{r}.objects{o}.name];
            ind = ind + 1;
        end
    catch
        
    end
end
% update listbox
set(handles.listbox,'String',list)

guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool8_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modus = get(hObject,'State');
if strcmp(modus,'on')
    %handles.rot.ActionPreCallback = @wireframe;
    handles.rot = rotate3d;
    handles.rot.RotateStyle = 'orbit';
    handles.rot.Enable = 'on';
    handles.rot.ActionPostCallback = @hidewall;
elseif strcmp(modus,'off')
    handles.rot.Enable= 'off';
end
guidata(hObject,handles)



function hidewall(~,axh)
% camera view vector
try
    a = axh.Axes;
    pos = a.CameraPosition;
    target = a.CameraTarget;
    v = target-pos;
    v = v./norm(v);
    % get all patches
    o = findall(a,'Type','patch');

    % get facenormals
    fn = get(o,'VertexNormals');
    if isempty(fn)
        return
    end
    
    % set patches visible
    %set(o,'FaceAlpha',1,'PickableParts','all')
    
    % get angles between camera view vector and facenormals
    ang = rad2deg(abs(acos(fn*v')));
    vis = ang>90;
    % set patches invisible
    set(o,'FaceVertexAlphaData',double(vis))
    
catch me
    %catcher(me)
end




% --- Executes on selection change in listbox5.
function listbox5_Callback(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox5


% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox5.
function listbox5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uitoggletool20_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    group_objects(hObject, eventdata, handles, 1,'object')
catch
end



% save object --------------------------------------------------------
function uitoggletool21_ClickedCallback(hObject, eventdata, handles)
% get data
room = getappdata(handles.Lumos,'room');
% check if object is selected
if isempty(handles.data.object)
    f = warndlg('no object selected.','save object','replace');
else
    obj = room{handles.data.room}.objects{handles.data.object};
end
% get filename (ui window)
file = savefile('object','obt');
save(file,'obj')



% load object --------------------------------------------------------
function uitoggletool22_ClickedCallback(hObject, eventdata, handles)
% get data
room = getappdata(handles.Lumos,'room');
% get filename (ui window)
file = loadfile('object','obt');
if isempty(file)
    return
end
try
    load(file,'-mat')
catch
    errordlg('Could not load object.','error open file','replace')
end
% add loaded object to room
idx = numel(room{handles.data.room}.objects);
room{handles.data.room}.objects{idx+1} = obj;
guidata(hObject,handles)
object_table(hObject, eventdata, handles)
handles = guidata(hObject);
% save room data
setappdata(handles.Lumos,'room',room);
guidata(hObject,handles)
% listbox
guidata(hObject,handles)
object_listbox(hObject, eventdata, handles)
handles = guidata(hObject);
% refresh plots
refresh_2D(hObject, eventdata, handles)
refresh_2D_objects(hObject, eventdata, handles)
try
    refresh_3DObjects(hObject, eventdata, handles)
catch
    view_CreateFcn(hObject, eventdata, handles)
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function uitoggletool23_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
r = handles.data.room;
o = handles.data.object;
room = getappdata(handles.Lumos,'room');
if isempty(o)
    o = 1;
else
end
obj = room{r}.objects{o};
copy_object(obj,r,o)


% --------------------------------------------------------------------
function uitoggletool24_ClickedCallback(hObject, eventdata, handles, room_nr)
room = getappdata(handles.Lumos,'room');

% room nr
try
    R = room_nr;
catch
    R = observer_room_nr(handles);
end

% add observer
try
    nr = size(room{R}.measurement,2)+1;
    room{R}.measurement{nr}.coordinates = [0 0 0];
    room{R}.measurement{nr}.azimuth = 0;
    room{R}.measurement{nr}.elevation = 0;
    room{R}.measurement{nr}.normal = [0 1 0];
    room{R}.measurement{nr}.name = ['point ',num2str(nr)];
    room{R}.measurement{nr}.type = 'point';
catch
    room{R}.measurement{1}.coordinates = [0 0 0];
    room{R}.measurement{1}.azimuth = 0;
    room{R}.measurement{1}.elevation = 0;
    room{R}.measurement{1}.normal = [0 1 0];
    room{R}.measurement{1}.name = 'point 1';
    room{R}.measurement{1}.type = 'point';
end
% Save data
setappdata(handles.Lumos,'room',room)
guidata(hObject, handles)
% update list, table and plots
observer_listbox(hObject, eventdata, handles)
observer_table(hObject,eventdata,handles)
plot_observer(hObject, eventdata, handles)
handles = guidata(hObject);

guidata(hObject,handles)


% --- Executes on button press in luminaire_tab.
function luminaire_tab_Callback(hObject, eventdata, handles)

% (de)activate  tools
toggle_menu_buttons(hObject,handles,[26 28:31])

axes(handles.view)
colorbar('off')

room = getappdata(handles.Lumos,'room');
table = getappdata(handles.Lumos,'table');
if ~exist('handles.data.room','var')
    handles.data.room = 1;
end
table{handles.data.room}.table_mode = 'luminaire';
% save data
setappdata(handles.Lumos,'table',table);

[~, ~, list] = lum_room_nr(handles);
try
    set(handles.listbox,'Value',1);
    if size(room{1}.luminaire,2) > 0
        set(handles.listbox,'String',list);
        luminaire_table(hObject, eventdata, handles)
    end
catch
    set(handles.listbox,'String','');
end
try
    plot_luminaire(handles,eventdata,hObject)
catch
    cla
end
% update guidata
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool29_ClickedCallback(hObject, eventdata, handles)
load_LDT(hObject,eventdata,handles)
luminaire_table(hObject,eventdata,handles)
%plot_luminaire(handles,eventdata,hObject)
guidata(hObject, handles)




function load_LDT(hObject,eventdata,handles)

[file,path] = uigetfile('*.ldt','Load LDT data...','MultiSelect','on');
try % single file
    if file == 0
        guidata(hObject,handles)
        return
    end
    
    filename = [path file];
    ldc = read_ldt(filename);

    
    ldt = getappdata(handles.Lumos,'ldt');
    nr = size(ldt,2)+1;

    ldt{nr} = ldc;
    setappdata(handles.Lumos,'ldt',ldt)
    
catch % multiple files
    ldt = getappdata(handles.Lumos,'ldt');
    nr = size(ldt,2)+1;
    for i = 1:size(file,2)
        try
            filename = [path file{i}];
        catch
            filename = [path file];
        end
        ldt{nr} = read_ldt(filename);

        nr = nr + 1;
    end
    setappdata(handles.Lumos,'ldt',ldt)
    
end


function load_lumspec(hObject,eventdata,handles)

[file,path] = uigetfile('*.txt','Load spectral data...','MultiSelect','on');
try % single file
    if file == 0
        guidata(hObject,handles)
        return
    end
    
    filename = [path file];
    lumspec = load(filename);
    
    spec = getappdata(handles.Lumos,'spectra');
    nr = size(spec,2)+1;
    spec{nr}.name = file(1:end-4);
    spec{nr}.data = lumspec;
    spec{nr}.range = [num2str(lumspec(1,1)),'-',num2str(lumspec(1,end))];
    setappdata(handles.Lumos,'spectra',spec)
    
catch % multiple files
    spec = getappdata(handles.Lumos,'spectra');
    nr = size(spec,2)+1;
    for i =1:size(file,2)
        filename = [path file{i}];
        spec{nr}.name = file{i}(1:end-4);
        spec{nr}.data = load(filename);
        spec{nr}.range = [num2str(spec{nr}.data(1,1)),'-',num2str(spec{nr}.data(1,end))];
        nr = nr + 1;
    end
    setappdata(handles.Lumos,'spectra',spec)
    
end

guidata(hObject,handles)


% --------------------------------------------------------------------
function uitoggletool28_ClickedCallback(hObject, eventdata, handles)
load_lumspec(hObject,eventdata,handles)
luminaire_table(hObject,eventdata,handles)
%plot_luminaire(handles,eventdata,hObject)
guidata(hObject, handles)


% --------------------------------------------------------------------
function uitoggletool26_ClickedCallback(hObject, eventdata, handles, r)

room = getappdata(handles.Lumos,'room');

% room nr
try
    R = r;
catch
    %R = handles.data.room;
    ind = 1;
    try
        for n = 1:size(room,2)
            if handles.listbox.Value == ind
                R = n; 
            end
            ind = ind+1;
            for m = 1:size(room{n}.luminaire,2)
                if handles.listbox.Value == ind
                    R = n;
                end
                ind = ind+1;
            end
        end
    catch
        R = 1;
    end
end

% add object
try
    nr = size(room{R}.luminaire,2)+1;
    room{R}.luminaire{nr}.type = 'luminaire';
    room{R}.luminaire{nr}.name = ['luminaire ',num2str(nr)];
    %room{R}.luminaire{nr}.objetcs = [];
    room{R}.luminaire{nr}.geometry = {[0 0 0 1;1 0 0 1;1 1 0 1;0 1 0 1].*0.1};
    room{R}.luminaire{nr}.coordinates = [1 1 3.2-0.1];
    room{R}.luminaire{nr}.rotation = [0 0 0];
    room{R}.luminaire{nr}.normal = [0 0 -1];
    room{R}.luminaire{nr}.lambda = [];
    room{R}.luminaire{nr}.spectrum = [];
    room{R}.luminaire{nr}.ldt = [];
    room{R}.luminaire{nr}.dimming = 1;
catch
    nr = 1;
    room{R}.luminaire{nr}.type = 'luminaire';
    room{R}.luminaire{nr}.name = ['luminaire ',num2str(nr)];
    %room{R}.luminaire{nr}.objetcs = [];
    room{R}.luminaire{nr}.geometry = {[0 0 0 1;1 0 0 1;1 1 0 1;0 1 0 1].*0.1};
    room{R}.luminaire{nr}.coordinates = [1 1 3.2-0.1];
    room{R}.luminaire{nr}.rotation = [0 0 0];
    room{R}.luminaire{nr}.normal = [0 0 -1];
    room{R}.luminaire{nr}.lambda = [];
    room{R}.luminaire{nr}.spectrum = [];
    room{R}.luminaire{nr}.ldt = [];
    room{R}.luminaire{nr}.dimming = 1;
end

% Save data
setappdata(handles.Lumos,'room',room)

% update list, table and plots
[~,~,list] = lum_room_nr(handles, nr);
set(handles.listbox,'String',list);

luminaire_table(hObject, eventdata, handles)
plot_luminaire(handles,eventdata,hObject)

guidata(hObject,handles)


% --------------------------------------------------------------------
function uitoggletool30_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    group_objects(hObject, eventdata, handles, 1,'luminaire')
catch
end


% --------------------------------------------------------------------
function uitoggletool31_ClickedCallback(hObject, eventdata, handles)
nr = handles.listbox.Value;
[r, L] = lum_room_nr(handles, nr);
room = getappdata(handles.Lumos,'room');
if isempty(L)
    L = 1;
else
end
obj = room{r}.luminaire{L};
copy_object(obj,r,L,'luminaire')


% --------------------------------------------------------------------
function uitoggletool32_ClickedCallback(hObject, eventdata, handles)
% add measurement area
room = getappdata(handles.Lumos,'room');

% room nr
try
    R = room_nr;
catch
    R = observer_room_nr(handles);
end

% add observer
[x,y,numx,numy] = DINgrid(1,1);
z = zeros(size(x));
try
    nr = size(room{R}.measurement,2)+1;
    room{R}.measurement{nr}.coordinates = [0 0 0];
    room{R}.measurement{nr}.azimuth = 0;
    room{R}.measurement{nr}.elevation = 90;
    room{R}.measurement{nr}.normal = [0 0 1];
    room{R}.measurement{nr}.name = ['area ',num2str(nr)];
    room{R}.measurement{nr}.type = 'area';
    room{R}.measurement{nr}.width = 1;
    room{R}.measurement{nr}.length = 1;
    room{R}.measurement{nr}.pointsx = numx;
    room{R}.measurement{nr}.pointsy = numy;
    room{R}.measurement{nr}.DINpoints = 1;
    room{R}.measurement{nr}.points = [x(:) y(:) z(:)];
catch
    room{R}.measurement{1}.coordinates = [0 0 0];
    room{R}.measurement{1}.azimuth = 0;
    room{R}.measurement{1}.elevation = 90;
    room{R}.measurement{1}.normal = [0 0 1];
    room{R}.measurement{1}.name = 'area 1';
    room{R}.measurement{1}.type = 'area';
    room{R}.measurement{1}.width = 1;
    room{R}.measurement{1}.length = 1;
    room{R}.measurement{1}.pointsx = numx;
    room{R}.measurement{1}.pointsy = numy;
    room{R}.measurement{1}.DINpoints = 1;
    room{R}.measurement{1}.points = [x(:) y(:) z(:)];
end
% Save data
setappdata(handles.Lumos,'room',room)
guidata(hObject, handles)
% update list, table and plots
observer_listbox(hObject, eventdata, handles)
observer_table(hObject,eventdata,handles)
axes(handles.topview)
plot_area(hObject, eventdata, handles)
axes(handles.view)
plot_area(hObject, eventdata, handles)
handles = guidata(hObject);

guidata(hObject,handles)


function plot_area(hObject, eventdata, handles, nr)

try
    hold on
    
    data = [];
    room = getappdata(handles.Lumos,'room');
    for o = 1:max(size(room{handles.data.room}.measurement))
        try
            data = [room{handles.data.room}.measurement{o}.coordinates room{handles.data.room}.measurement{o}.azimuth room{handles.data.room}.measurement{o}.elevation];
        catch
            continue
        end
        if strcmp(room{handles.data.room}.measurement{o}.type,'area')
            try
                if isequal(o,nr)
                    color = handles.red;
                    line = 2;
                    mark = 10;
                else
                    color = handles.green;
                    line = 1;
                    mark = 5;
                end
            catch
                color = handles.green;
                line = 1;
                mark = 5;
            end
            % width & length
            wi = room{handles.data.room}.measurement{o}.width;
            le = room{handles.data.room}.measurement{o}.length;
            or = data(1:3);
            cx = [or(1) or(1)+wi or(1)+wi or(1) or(1)];
            cy = [or(2) or(2) or(2)+le or(2)+le or(2)];
            cz = [or(3) or(3) or(3) or(3) or(3)];
            ox = min(cx);
            oy = min(cy);
            oz = min(cz);
            cx = cx-ox;
            cy = cy-oy;
            cz = cz-oz;
            xyz = [cx' cy' cz'];
            M1 = rotMatrixD([1 0 0],data(5)-90);
            M2 = rotMatrixD([0 0 1],data(4));
            M = M2*M1;
            c = (M*xyz')';
            c = c+[ox oy oz];
            % area
            plot3(c(:,1),c(:,2),c(:,3),'-','Color',color,'LineWidth',line)
            % normal direction
            %normal = room{handles.data.room}.measurement{o}.normal;
            cx = [wi/2 wi/2];
            cy = [le/2 le/2];
            cz = [0 1/3];
            xyz = (M*([cx' cy' cz'])')';
            cx = xyz(:,1);
            cy = xyz(:,2);
            cz = xyz(:,3);

            plot3(cx+or(1),cy+or(2),cz+or(3),'Color',color,'Linewidth',line)
            % points
            xyz = room{handles.data.room}.measurement{o}.points;
            c = (M*xyz')';
            c = c+data(1:3);
            plot3(c(:,1),c(:,2),c(:,3),'.','Color',color,'MarkerSize',mark)

        end
    end
    hold off
catch me
    %catcher(me)
    hold off
end
guidata(hObject,handles)



function c = get_points(area)
M1 = rotMatrixD([1 0 0],area.elevation-90);
M2 = rotMatrixD([0 0 1],area.azimuth);
M = M2*M1;
% points
xyz = area.points;
c = (M*xyz')';
c = c+area.coordinates;


% --------------------------------------------------------------------
function uitoggletool33_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% daylight factor added to point...

%comeback('add DF')

room = getappdata(handles.Lumos,'room');

% room nr
try
    R = room_nr;
catch
    R = observer_room_nr(handles);
end

% add Daylight Factor point
try
    nr = size(room{R}.measurement,2)+1;
    room{R}.measurement{nr}.coordinates = [0 0 0];
    room{R}.measurement{nr}.azimuth = 0;
    room{R}.measurement{nr}.elevation = 0;
    room{R}.measurement{nr}.normal = [0 1 0];
    room{R}.measurement{nr}.name = ['DF ',num2str(nr)];
    room{R}.measurement{nr}.type = 'DF';
catch
    room{R}.measurement{1}.coordinates = [0 0 0];
    room{R}.measurement{1}.azimuth = 0;
    room{R}.measurement{1}.elevation = 0;
    room{R}.measurement{1}.normal = [0 1 0];
    room{R}.measurement{1}.name = 'DF 1';
    room{R}.measurement{1}.type = 'DF';
end
% Save data
setappdata(handles.Lumos,'room',room)
guidata(hObject, handles)
% update list, table and plots
observer_listbox(hObject, eventdata, handles)
observer_table(hObject,eventdata,handles)
plot_observer(hObject, eventdata, handles)
handles = guidata(hObject);

guidata(hObject,handles)
