% calculates a normal vector for two given vectors
%
% normal = normvec(vec1,vec2)
%
% Author: Frederic Rudawski
% Date: 20.10.2020

function normal = normvec(v1,v2)
% nomalize vectors
v1 = v1./norm(v1);
v2 = v2./norm(v2);
% normal vector
normal = cross(v1,v2);
% normalization of normal vector
normal = normal./norm(normal);
