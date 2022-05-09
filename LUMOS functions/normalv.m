% calculates a normal vector to a plane, assuming clockwise vertices
%
% normal = normalv(2Dpolygon)
%
% Author: Frederic Rudawski
% Date: 21.04.2020

function normal = normalv(polygon)
% normal vector
normal = cross(polygon(1,:)-polygon(2,:),polygon(1,:)-polygon(3,:));
% normalization of normal vector
normal = normal./norm(normal);
