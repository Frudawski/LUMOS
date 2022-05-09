
function plot_mesh_3D(surfaces)


reset(gca)
legend off
cla
colorbar off
axis off
title('')

FaceNormal = [];
VertexNormal = [];
Vertices = [];
Faces = [];
for s = 1:numel(surfaces)
    % face normal
    if strcmp(surfaces{s}.type,'object')
        wn = surfaces{s}.normal;
    else
        wn = surfaces{s}.normal;
    end
    FaceNormal = [FaceNormal;repmat(wn,size(surfaces{s}.mesh.list,1),1)];
    VertexNormal = [VertexNormal;repmat(wn,size(surfaces{s}.mesh.points,1),1)];
    Faces = [Faces;surfaces{s}.mesh.list+size(Vertices,1)];
    Vertices = [Vertices;surfaces{s}.mesh.points];
end

%p = patch('Vertices',Vertices,'Faces',Faces,'FaceColor',ones(size(Faces)).*0.8);
p = patch('Vertices',Vertices,'Faces',Faces,...
    'EdgeColor','flat',...
    'EdgeAlpha','flat',...
    'FaceColor','white',...
    'FaceVertexCData',zeros(size(VertexNormal)),...
    'FaceVertexAlphaData',zeros(size(VertexNormal,1),1),...
    'VertexNormal',VertexNormal,...
    'FacesMode','auto');

light
%lightangle(gca,-45,30)
%lighting gouraud

axis off
axis equal
view([315 30])


% hide surfaces if normal points in viewing direction
a = gca;
pos = a.CameraPosition;
target = a.CameraTarget;
v = target-pos;
v = v./norm(v);
% get all patches
o = findall(a,'Type','patch');
% set patches visible
set(o,'FaceAlpha',1,'PickableParts','all')
% get facenormals
fn = get(o,'VertexNormals');
% get angles between camera view vector and facenormals
ang = rad2deg(abs(acos(fn*v')));
vis = ang>90;
% set patches invisible
set(o,'FaceAlpha','interp','FaceVertexAlphaData',double(vis))

