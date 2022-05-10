% LUMOS Mesh function
%
% Author: Frederic Rudawski
% Date: 08.11.2017 - last updated: 05.10.2021


function mesh = Meshing(input_surface,density,plot_mode,luminaires,measurements)


surface = input_surface;
% initialize
mesh.points = [];
mesh.list = [];
mesh.patchcenter = [];
mesh.patches = [];

% density setting
density = sqrt(density/2);

% gaps in surface?
if ~isempty(surface.blank)
    blank = 1;
else
    blank = 0;
end

% wall global coordinates
surfx = surface.vertices(:,1);
surfy = surface.vertices(:,2);
surfz = surface.vertices(:,3);

% surface normal
normal = surface.normal;

% global blank coordinates
if blank
    for b = 1:numel(surface.blank)
        % gaps
        gap{b} = surface.blank{b}.vertices;
    end
end

%dummy = 1;

% plane elevation rotation angle
[~,elevation,~] = cart2sph(normal(1),normal(2),normal(3));
% rotate parallel to y-z-axis
if ~isnan(elevation) && ~isequal(elevation,0)
    % rotation matrix
    if abs(normal(3)) == 1
        %rotax = [0 1 0];
        %R = makehgtform('axisrotate',rotax,pi/2);
        R = rotMatrix([0 rad2deg(pi/2) 0]);
    else
        rotax = cross(normal,[0 0 1]);
        R = rotMatrixD(rotax,rad2deg(elevation));
        
        %{
        figure(2)
        hold off
        plot3(surfx,surfy,surfz,'k-')
        axis equal
        grid
        hold on
        plot3([mean(surfx(1:end-1)) mean(surfx(1:end-1))+normal(1)],...
            [mean(surfy(1:end-1)) mean(surfy(1:end-1))+normal(2)],...
            [mean(surfz(1:end-1)) mean(surfz(1:end-1))+normal(3)],...
            'k-')
        plot3([mean(surfx(1:end-1)) mean(surfx(1:end-1))+rotax(1)],...
              [mean(surfy(1:end-1)) mean(surfy(1:end-1))+rotax(2)],...
              [mean(surfz(1:end-1)) mean(surfz(1:end-1))+rotax(3)],...
              'k--')
          
          dummy = 1;
        %}
    end
    
    % rotate
    a = R*[surfx surfy surfz]';
    px = a(1,:);
    py = a(2,:);
    pz = a(3,:);
    
else
    R = eye(3);
    px = surfx;
    py = surfy;
    pz = surfz;
end


% rotate in y-z plane
if size(px,1) > size(px,2)
    newsurf.vertices = [px py pz];
else
    px = px';
    py = py';
    pz = pz';
    newsurf.vertices = [px py pz];
end

newnorm = (R*([surface.normal]'))';
if any(isnan(newnorm))
    newnorm = [0 0 0];
end

%{
if dummy
figure(2)
plot3(px,py,pz,'b-')
plot3([mean(px(1:end-1)) mean(px(1:end-1))+newnorm(1)],...
            [mean(py(1:end-1)) mean(py(1:end-1))+newnorm(2)],...
            [mean(pz(1:end-1)) mean(pz(1:end-1))+newnorm(3)],...
            'b-')
        dummy = 1;
end
%}

[azimuth,~,~] = cart2sph(newnorm(1),newnorm(2),newnorm(3));

if ~isequal(mod(azimuth,pi),0)
    P = rotMatrix([0 0 rad2deg(-azimuth)]);
    % rotate
    a = P*[px py pz]';
    px = a(1,:);
    py = a(2,:);
    pz = a(3,:);
else 
    P = eye(3);
end

% shift coordinates to zero
xmin = min(px);
ymin = min(py);
zmin = min(pz);
px = px-min(px);
py = py-min(py);
pz = pz-min(pz);

%newnorm = normalv(newsurf.vertices);
newnorm = (R*(P*[surface.normal]'))';
if any(isnan(newnorm))
    newnorm = [0 0 0];
end

%{
if dummy
figure(2)
hold off

plot3(px,py,pz,'g-')
hold on
plot3([mean(px(1:end-1)) mean(px(1:end-1))+newnorm(1)],...
            [mean(py(1:end-1)) mean(py(1:end-1))+newnorm(2)],...
            [mean(pz(1:end-1)) mean(pz(1:end-1))+newnorm(3)],...
            'g-')
        axis equal 
        grid on
        hold off
end
%}

% shift & rotate windows accordingly
if blank
    rotgap = cell(size(gap));
    for b = 1:numel(gap)
        rotgap{b} = (R*P*gap{b}')' - [xmin ymin zmin];
    end
end


% rotate luminares accordingly
for L = 1:length(luminaires)
    luminaires{L}.coordinates = (R*P*luminaires{L}.coordinates')' - [xmin ymin zmin];
end

% width parameter r
r = py;
r1 = min(r);
r2 = max(r);

% defining grid points (2 grids overlaying)
a = round(density*abs(max(r)-min(r)));
b = round(density*abs(max(pz)-min(pz)));
nr = max([a 3]);
nz = max([b 3]);
if strcmp(input_surface.type,'window')
    nr = round(nr*1.5);
    nz = round(nz*1.5);
end
m = 2*max([a b]);
% grid points coordinates
xgrid1 = linspace(r1,r2,nr);
xgrid2 = linspace(r1+xgrid1(1,2)/2,r2-xgrid1(1,2)/2,nr-1);
zgrid1 = linspace(min(pz),max(pz),nz);
zgrid2 = linspace(min(pz)+zgrid1(1,2)/2,max(pz)-zgrid1(1,2)/2,nz-1);
% border grid points
borderz = [];
bordery = [];
nborderz = [];
nbordery = [];
for i = 1:numel(pz)-1
    m = round(3*density*norm([r(i+1)-r(i);pz(i+1)-pz(i)]))-2;    
    if m<2
        m = 2;
    end
    n = m-1;

    z = linspace(pz(i),pz(i+1),m);
    y = linspace(r(i),r(i+1),m);
    borderz = [borderz z];
    bordery = [bordery y];

    if strcmp(input_surface.type,'room')
        % near border grid
        ystep = (y(2)-y(1))/2;
        zstep = (z(2)-z(1))/2;
        nborderz = [nborderz linspace(pz(i)+zstep,pz(i+1)-zstep,n)-ystep linspace(pz(i)+zstep,pz(i+1)-zstep,n)+ystep];
        nbordery = [nbordery linspace(r(i)+ystep,r(i+1)-ystep,n)+zstep linspace(r(i)+ystep,r(i+1)-ystep,n)-zstep];
    end
end

%
% checking point distance of nearborder points
tol = 1/(10*density);
idx = ones(size(nborderz));
for n = 1:numel(nborderz)
    distance = sqrt((nborderz-nborderz(n)).^2 + (nbordery-nbordery(n)).^2);
    ind = distance<tol;
    ind(n) = 0;
    idx = idx & ~ind;
end
nborderz = nborderz(idx);
nbordery = nbordery(idx);
%}

% meshgrid for triangulation
if numel(xgrid1)>2 && ~strcmp(input_surface.type,'window')
    [y1,z1] = meshgrid(xgrid1(2:end-1),zgrid1(2:end-1));
elseif numel(xgrid1)>2 && strcmp(input_surface.type,'window')
    [y1,z1] = meshgrid(xgrid1,zgrid1);
else
    y1 = [];
    z1 = [];
end
[y2,z2] = meshgrid(xgrid2,zgrid2);


lumrayx = [];
lumrayz = [];

% luminare equidist ray2plane grid points

% check surface type
if ~strcmp(surface.type,'luminaire')

    % delta angle stepwidth in degree
    %da = 30;
    % point on surface plane
    %Q = [px(1) py(1) pz(1)];
    % surface normal (y-z plane)
    n = [1 0 0];
    for L = 1:size(luminaires,2)
        % luminare emittance vectors
        [alpha,theta] = meshgrid(15:27.5:345,15:27.5:345);
        theta(:,2:4:end) = theta(:,2:4:end)+11.25;
        theta(:,4:4:end) = theta(:,4:4:end)+11.25;

        alpha = deg2rad(alpha);
        theta = deg2rad(theta);
        [Lx,Ly,Lz] = sph2cart(alpha(:),theta(:),ones(size(alpha(:))));
        Lxyz = (R*(P*[Lx Ly Lz]'))';
        Lx = Lxyz(:,1);
        Ly = Lxyz(:,2);
        Lz = Lxyz(:,3);
        % intersection calculation parameters
        p = dot(luminaires{L}.coordinates,n);
        vecr = dot([Lx Ly Lz],repmat(n,size(Lx,1),1),2);
        para = -p./vecr;
        S = (para.*[Lx,Ly,Lz]);
        % intersection points
        lumrayx = [lumrayx;S(:,2)+luminaires{L}.coordinates(2)];
        lumrayz = [lumrayz;S(:,3)+luminaires{L}.coordinates(3)];
        
    %{
    % debuging
    if dummy
        hold on
        plot3(luminaires{L}.coordinates(1),luminaires{L}.coordinates(2),luminaires{L}.coordinates(3),'r*')
        plot3(Lx+luminaires{L}.coordinates(1),Ly+luminaires{L}.coordinates(2),Lz+luminaires{L}.coordinates(3),'r.')
    end
    %}

    end

    ind = lumrayx>min(py) & lumrayx<max(py);
    lumrayx = lumrayx(ind);
    lumrayz = lumrayz(ind);
    ind = lumrayz>min(pz) & lumrayz<max(pz);
    lumrayx = lumrayx(ind);
    lumrayz = lumrayz(ind);

end


% observer ray2plane grid points
orayx = [];
orayz = [];

% TODO: change to user defined resolution
% Tregenza table
% almucantar number, number of patches, almucantar center angle, azimuth increament, solid angle? 
TR = [1 30 6 12 12; 2 30 18 12 12; 3 24 30 15 12; 4 24 42 15 12; 5 18 54 20 12; 6 12 66 30 12; 7 6 78 60 12; 8 1 90 0 12];
% patch numbers and angles
% line 1: almucantars, line 2: azimuths, line 3: Patchnumber
pnt = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 66 66 66 66 66 66 66 66 66 66 66 66 78 78 78 78 78 78 90;180 192 204 216 228 240 252 264 276 288 300 312 324 336 348 0 12 24 36 48 60 72 84 96 108 120 132 144 156 168 168 156 144 132 120 108 96 84 72 60 48 36 24 12 0 348 336 324 312 300 288 276 264 252 240 228 216 204 192 180 180 195 210 225 240 255 270 285 300 315 330 345 0 15 30 45 60 75 90 105 120 135 150 165 165 150 135 120 105 90 75 60 45 30 15 0 345 330 315 300 285 270 255 240 225 210 195 180 180 200 220 240 260 280 300 320 340 0 20 40 60 80 100 120 140 160 150 120 90 60 30 0 330 300 270 240 210 180 180 240 300 0 60 120 NaN;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];
TR(8,4) = 360;
azinc = [];
elinc = [];
for n = 1:size(TR,1)
    azinc = [azinc repmat(TR(n,4),1,TR(n,2))];
    elinc = [elinc repmat(TR(n,5),1,TR(n,2))];
end

n = [1 0 0];
for obs = 1:size(measurements,2)
    % observer emittance vectors
    [alpha,theta] = meshgrid(15:27.5:345,15:27.5:345);
    theta(:,2:4:end) = theta(:,2:4:end)+11.25;
    theta(:,4:4:end) = theta(:,4:4:end)+11.25;

    alpha = deg2rad(alpha);
    theta = deg2rad(theta);
    [Lx,Ly,Lz] = sph2cart(alpha(:),theta(:),ones(size(alpha(:))));
    Lxyz = (R*(P*[Lx Ly Lz]'))';
    Lx = Lxyz(:,1);
    Ly = Lxyz(:,2);
    Lz = Lxyz(:,3);
    % intersection calculation parameters
    p = dot(measurements{obs}.coordinates,n);
    vecr = dot([Lx Ly Lz],repmat(n,size(Lx,1),1),2);
    para = -p./vecr;
    S = (para.*[Lx,Ly,Lz]);
    % intersection points
    orayx = [orayx;S(:,2)+measurements{obs}.coordinates(2)];
    orayz = [orayz;S(:,3)+measurements{obs}.coordinates(3)];
end
ind = orayx>min(py) & orayx<max(py);
orayx = orayx(ind);
orayz = orayz(ind);
ind = orayz>min(pz) & orayz<max(pz);
orayx = orayx(ind);
orayz = orayz(ind);



% finding gridpoints inside of the surface polygon
x = [bordery';y1(:);y2(:);nbordery';lumrayx;orayx];
z = [borderz';z1(:);z2(:);nborderz';lumrayz;orayz];

%{
    % debuging
    if dummy
        hold on
        %plot3(zeros(size(x)),x,z,'g.')
        plot3(zeros(size(lumrayx)),lumrayx,lumrayz,'r.')
    end
%}

% minimal distance
%{
tol = 1e-6;
idx = ones(size(x));
for n = 1:numel(x)
    distance = sqrt((x-x(n)).^2 + (z-z(n)).^2);
    ind = distance<tol;
    ind(n) = 0;
    idx = idx & ~ind;
end
x = x(idx);
z = z(idx);
%}

if max(size(r)) ~= max(size(pz))
    r = [r(1) r(2) r(4) r(5)];
end
[in,on] = inpolygon(x,z,r,pz);

x = x(in|on);
z = z(in|on);

blankframex = [];
blankframez = [];
% remove surface gridpoints in blanks
if blank
    for b = 1:numel(rotgap)
        % finding points in blank polygon
        blankr = rotgap{b}(:,2);
        blankz = rotgap{b}(:,3);
        [inblank,~] = inpolygon(x,z,blankr,blankz);
        % deleting points in windows
        x = x(~inblank);
        z = z(~inblank);
        % density correction factor
        correction = 3; 
        
        blankrgrid = [];
        blankzgrid = [];
        for v = 1:size(rotgap{b},1)-1
            % number of blank frame points in r and z direction
            nrpoints = round(density*(abs(blankr(v)-blankr(v+1)))*correction)+1;
            nzpoints = round(density*(abs(blankz(v)-blankz(v+1)))*correction)+1;
            points = max([nrpoints nzpoints]);
            if points<2
                points = 3;
            end
            % adding frame points
            blankrgrid = [blankrgrid linspace(blankr(v),blankr(v+1),points)];
            blankzgrid = [blankzgrid linspace(blankz(v),blankz(v+1),points)];
        end
        % join points
        x = [x;blankrgrid'];
        z = [z;blankzgrid'];
        blankframex{b} = blankrgrid';
        blankframez{b} = blankzgrid';
    end
end

% triangulate mesh from gridpoints
%DT = c_delaunaytri(unique([x z],'rows'));
try
    DT = delaunayTriangulation(unique([x z],'rows'));
catch
    DT = c_delaunaytri(unique([x z],'rows'));
end
% get surface edge points
%edges = [bordery' borderz'];
% force border edges for concav geometries
%chw = find(ismember(round(DT.Points,12),round(edges,12),'rows'));
%surfedges = sort([chw [chw(2:end);chw(1)]],2);

for i = 1:numel(pz)-1
    m = round(3*density*norm([r(i+1)-r(i);pz(i+1)-pz(i)]))-2;    
    if m<2
        m = 2;
    end
    z = linspace(pz(i),pz(i+1),m);
    y = linspace(r(i),r(i+1),m);
    chw = find(ismember(ltfround(DT.Points,12),ltfround([y' z'],12),'rows'));
    surfedges = [chw(1:end-1) chw(2:end)];
    if ~isempty(surfedges)
       DT = force_edge(DT,surfedges);
    end
end

% remove point on blank area
if blank
    for b = 1:numel(rotgap)
        chw = find(ismember(ltfround(DT.Points,12),ltfround([blankframex{b} blankframez{b}],12),'rows'));
        indn = c_quickhull(DT.Points(chw,:));
        indn = indn(1:end-1);
        chw = chw(indn);
        % force blank area border edges
        if ~isempty(chw)
            blankedges = sort([chw [chw(2:end);chw(1)]],2);
            DT = force_edge(DT,blankedges);
        end
        % triangluation patch center points
        PointR = DT.Points(:,1);
        PointZ = DT.Points(:,2);
        % triangle center points
        pcr = mean(PointR(DT.ConnectivityList),2);
        pcz = mean(PointZ(DT.ConnectivityList),2);
        % remove patches in blank
        in = inpolygon(pcr,pcz,blankframex{b},blankframez{b});
        DT.ConnectivityList(in,:) = [];
    end
end

% copy trianguation for editing
dt.Points = DT.Points;
dt.ConnectivityList = DT.ConnectivityList;
dt.Constraint = [];


% triangle center points
surfpointsx = dt.Points(:,1);
surfpointsz = dt.Points(:,2);
surftrix = mean(surfpointsx(dt.ConnectivityList),2);
surftriz = mean(surfpointsz(dt.ConnectivityList),2);
% delete points outside surface geometry
[inside,~] = inpolygon(surftrix,surftriz,r,pz);
surftrix(~inside) = [];
surftriz(~inside) = [];
dt.ConnectivityList(~inside,:) = [];
% delete points on surface borders
[~,onborder] = inpolygon(surftrix,surftriz,r,pz);
surftrix(onborder) = [];
surftriz(onborder) = [];
dt.ConnectivityList(onborder,:) = [];
% delete points in blank areas (gaps)

% 3D wall points
Points = [zeros(size(dt.Points,1),1) dt.Points(:,1) dt.Points(:,2)];

% shift points back to origin
Points = Points+[xmin ymin zmin];

% rotate back
rotPoints = (R\(P\Points'))';

%{
if dummy
    comeback('object mesh problem')
    plot3(rotPoints(:,1),rotPoints(:,2),rotPoints(:,3),'r*')
    dummy = 1;
end
%}

% mesh data
surface.mesh.points = [rotPoints(:,1) rotPoints(:,2) rotPoints(:,3)];
surface.mesh.list = dt.ConnectivityList;
PointX = rotPoints(:,1);
PointY = rotPoints(:,2);
PointZ = rotPoints(:,3);
% triangle center points
pcx = mean(PointX(dt.ConnectivityList),2);
pcy = mean(PointY(dt.ConnectivityList),2);
pcz = mean(PointZ(dt.ConnectivityList),2);
surface.mesh.patchcenter = [pcx pcy pcz];
% patches [x y z]
surface.mesh.points(isnan(surface.mesh.points)) = 0;
try
    datax = [surface.mesh.points(surface.mesh.list(:,1),1) surface.mesh.points(surface.mesh.list(:,2),1) surface.mesh.points(surface.mesh.list(:,3),1) surface.mesh.points(surface.mesh.list(:,1),1)];
    datay = [surface.mesh.points(surface.mesh.list(:,1),2) surface.mesh.points(surface.mesh.list(:,2),2) surface.mesh.points(surface.mesh.list(:,3),2) surface.mesh.points(surface.mesh.list(:,1),2)];
    dataz = [surface.mesh.points(surface.mesh.list(:,1),3) surface.mesh.points(surface.mesh.list(:,2),3) surface.mesh.points(surface.mesh.list(:,3),3) surface.mesh.points(surface.mesh.list(:,1),3)];
    surface.mesh.patches(:,:,1) = datax;
    surface.mesh.patches(:,:,2) = datay;
    surface.mesh.patches(:,:,3) = dataz;
    % patch areas - heron's formula
    a = sqrt([(datax(:,2)-datax(:,1)).^2 + (datay(:,2)-datay(:,1)).^2 + (dataz(:,2)-dataz(:,1)).^2]);
    b = sqrt([(datax(:,3)-datax(:,2)).^2 + (datay(:,3)-datay(:,2)).^2 + (dataz(:,3)-dataz(:,2)).^2]);
    c = sqrt([(datax(:,4)-datax(:,3)).^2 + (datay(:,4)-datay(:,3)).^2 + (dataz(:,4)-dataz(:,3)).^2]);
    s = (a+b+c)./2;
    area = real(sqrt(s.*(s-a).*(s-b).*(s-c)));
    surface.mesh.patch_area = area;
catch
    % no mesh data available
    surface.mesh.patches = [];
    %wall.mesh.patches(:,:,1) = [];
    %wall.mesh.patches(:,:,2) = [];
    %wall.mesh.patches(:,:,3) = [];
    surface.mesh.patch_area = [];
end
% plot ?
try
    if strcmp(plot_mode,'plot2D')
        plot_mesh_2D(dt,WDT)
    elseif strcmp(plot_mode,'plot3D')
        plot_mesh_3D(surface)
    end
catch
    % no plot
end

% return result
mesh = surface;
% end of mesh function
%toc
end



function plot_mesh_2D(dt,windows)
% plot 2D coordinates

clf
hold on
datax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
dataz = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];

for i = 1:size(datax,1)
    fill(datax(i,:),dataz(i,:),[0.75 0.75 0.75],'Facecolor',[0.5 0.5 0.5]);%,'FaceAlpha',0.5
    %plot(datax(i,:),dataz(i,:),'-k')
end
axis off

% window
for win = 1:size(windows,2)
     %triplot(windows{win},'Color','b')
     
     dt = [];
     dt.Points = windows{win}.Points;
     dt.ConnectivityList = windows{win}.ConnectivityList;
     
     datax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
     dataz = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];
     %dataz = [dt.Points(dt.ConnectivityList(:,1),3) dt.Points(dt.ConnectivityList(:,2),3) dt.Points(dt.ConnectivityList(:,3),3) dt.Points(dt.ConnectivityList(:,1),3)];
     for i = 1:size(datax,1)
         fill(datax(i,:),dataz(i,:),[0 0.5 0.75],'Facecolor',[0 0.5267 0.6461])%,'Facealpha',0.5
     end
end
axis equal

% end of plot 2D
end


function plot_mesh_3D(wall)
% 3D coordinates 

dt.Points = wall.mesh.points;
dt.ConnectivityList = wall.mesh.list;

hold on
grid on
axis equal

datax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
datay = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];
dataz = [dt.Points(dt.ConnectivityList(:,1),3) dt.Points(dt.ConnectivityList(:,2),3) dt.Points(dt.ConnectivityList(:,3),3) dt.Points(dt.ConnectivityList(:,1),3)];

for i = 1:size(datax,1)
    fill3(datax(i,:),datay(i,:),dataz(i,:),[0.75 0.75 0.75],'Facecolor',[0.5 0.5 0.5]); % ,'FaceAlpha',0.1
end

% window(s)
try
    for win = 1:size(wall.windows,2)
        
        dt.Points = wall.windows{win}.mesh.points;
        dt.ConnectivityList = wall.windows{win}.mesh.list;
        
        wdatax = [dt.Points(dt.ConnectivityList(:,1),1) dt.Points(dt.ConnectivityList(:,2),1) dt.Points(dt.ConnectivityList(:,3),1) dt.Points(dt.ConnectivityList(:,1),1)];
        wdatay = [dt.Points(dt.ConnectivityList(:,1),2) dt.Points(dt.ConnectivityList(:,2),2) dt.Points(dt.ConnectivityList(:,3),2) dt.Points(dt.ConnectivityList(:,1),2)];
        wdataz = [dt.Points(dt.ConnectivityList(:,1),3) dt.Points(dt.ConnectivityList(:,2),3) dt.Points(dt.ConnectivityList(:,3),3) dt.Points(dt.ConnectivityList(:,1),3)];
        
        for i = 1:size(wdatax,1)
            fill3(wdatax(i,:),wdatay(i,:),wdataz(i,:),[0 0.5 0.75],'Facecolor',[0 0.5267 0.6461])
        end
    end
catch
end

% end of plot3d
end