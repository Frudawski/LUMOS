% rotate object in 3D

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