% visibility Matrix for LUMOS
%
% Author: Frederic Rudawski
% Date: 16.05.2020 


function [vis,inter,vec1,vec2,R] = visibilityMatrix(incidence,emission,surfaces)
% normal vectors
inormal = incidence.normal;
enormal = emission.normal;
% get vector: surface patches 1 -> surface patches 2
vec1 = emission.mesh.patchcenter-incidence.coordinates;
% get vector: surface patches 2 -> surface patches 1
vec2 = -vec1;
% get distance point -> surfaces patches
R = sqrt(vec1(:,1).^2 + vec1(:,2).^2 + vec1(:,3).^2);
% surface emission angle
ema = acosd(dot(repmat(enormal,size(vec2,1),1),vec2,2)./R);
% point incidence angle
ina = acosd(dot(repmat(inormal,size(vec1,1),1),vec1,2)./R);

vis = zeros(size(ina));
vis(ema<90 & ema>0 & ina<90 & ina>0) = 1;

% check if other surface block visibility

% loop over surfaces
for s = 1:numel(surfaces)
     % patch visibility matrix
     vis = visibilityMatrix(p,surfaces);
end