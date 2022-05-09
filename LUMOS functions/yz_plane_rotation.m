function [vertices,blank,mesh] = yz_plane_rotation(surface)
% roompart normal vector
normal = surface.normal;
% plane elevation rotation angle
[~,elevation,~] = cart2sph(normal(1),normal(2),normal(3));
% room part vertices
wallx = surface.vertices(:,1);
wally = surface.vertices(:,2);
wallz = surface.vertices(:,3);

blank = surface.blank;
mesh = surface.mesh;

% rotate parallel to z-axis
if ~isnan(elevation) && ~isequal(elevation,0)
    % rotation matrix
    if abs(normal(3)) == 1
        rotax = [0 1 0];
        R = makehgtform('axisrotate',rotax,pi/2);
    else
        rotax = cross(normal,[0 0 1]);
        R = makehgtform('axisrotate',rotax,-elevation);
    end
    R = R(1:3,1:3);
    % rotate
    a = R*[wallx wally wallz]';
    px = a(1,:)';
    py = a(2,:)';
    pz = a(3,:)';
    mesh.patchcenter = (R*mesh.patchcenter')';
    mesh.points = (R*mesh.points')';
    for b = 1:numel(blank)
        blank{b}.vertices = (R*blank{b}.vertices')';
    end
else
    R = eye(3);
    px = wallx;
    py = wally;
    pz = wallz;
end

% rotate in y-z plane
if size(px,1) > size(px,2)
    newwall.vertices = [px py pz];
else
    px = px';
    py = py';
    pz = pz';
    newwall.vertices = [px py pz];
end
newnorm = wall_normal([],newwall,[]);
[azimuth,~,~] = cart2sph(newnorm(1),newnorm(2),newnorm(3));
if ~isequal(mod(azimuth,pi),0)
    P = makehgtform('axisrotate',[0 0 1],-azimuth);
    P = P(1:3,1:3);
    % rotate
    a = P*[px py pz]';
    px = a(1,:);
    py = a(2,:);
    pz = a(3,:);
    mesh.patchcenter = (P*mesh.patchcenter')';
    mesh.points = (P*mesh.points')';
    for b = 1:numel(blank)
        blank{b}.vertices = (P*blank{b}.vertices')';
    end
else 
    P = eye(3);
end
if size(px,2) > size(px,1)
    px = px';
    py = py';
    pz = pz';
end

% find longest side
L = vecnorm(diff([px py pz]),2,2);
[~,idx] = max(L);
%idx = size(px,1)-1;
vec = [px(idx+1)-px(idx) py(idx+1)-py(idx) pz(idx+1)-pz(idx)];
%vec = vec./norm(vec);
if vec(3)<0 && vec(2)>0
    vec = -vec;
end
[~,elevation,~] = cart2sph(vec(1),vec(2),vec(3));
%elevation = acos(dot(vec,[1 0 0]))
% rotate so that longest side is parallel to y-axis
Q = makehgtform('axisrotate',[1 0 0],elevation);
Q = Q(1:3,1:3);
% rotate
a = Q*[px py pz]';
px = a(1,:);
py = a(2,:);
pz = a(3,:);
mesh.patchcenter = (Q*mesh.patchcenter')';
mesh.points = (Q*mesh.points')';
for b = 1:numel(blank)
    blank{b}.vertices = (Q*blank{b}.vertices')';
end
if size(px,2) > size(px,1)
    px = px';
    py = py';
    pz = pz';
end
% translate to 0
px = zeros(size(px));
yoffset = min(py);
zoffset = min(pz);
py = py-yoffset ;
pz = pz-zoffset;
mesh.patchcenter(:,1) = zeros(size(mesh.patchcenter(:,2)));
mesh.patchcenter(:,2) = mesh.patchcenter(:,2)-yoffset;
mesh.patchcenter(:,3) = mesh.patchcenter(:,3)-zoffset;
mesh.points(:,1) = zeros(size(mesh.points(:,1)));
mesh.points(:,2) = mesh.points(:,2)-yoffset;
mesh.points(:,3) = mesh.points(:,3)-zoffset;
for b = 1:numel(blank)
    blank{b}.vertices(:,1) = zeros(size(blank{b}.vertices(:,1)));
    blank{b}.vertices(:,2) = blank{b}.vertices(:,2)-yoffset;
    blank{b}.vertices(:,3) = blank{b}.vertices(:,3)-zoffset;
end
%rotm = R*P*Q;
%vertices = [wallx wally wallz]*rotm;
vertices = [px py pz];
% end of function
