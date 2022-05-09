% function vecangle
%
% ang = vecangle(vec1,vec2)
%
%      where: ang is the angle between the two vectors vec1 and vec2           
%             vec1 and vec2 are vectors: [x y z]
%
% Author: Frederic Rudawski
% Date: 20.10.2020

function ang = vecangle(v1,v2)
% nomalize vectors
v1 = v1./norm(v1);
v2 = v2./norm(v2);
% angle calculation
ang = acos(dot(v1,v2));

