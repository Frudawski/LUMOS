% Point visibility Matrix for LUMOS
%
% Author: Frederic Rudawski
% Date: 16.05.2020


function [vis,ina,ema,R,vec1] = pointVisibilityMatrix(incidence,emission,surfaces,fisheye)

if ~exist('fisheye','var')
    fisheye = 0;
end

% normal vectors
inormal = incidence.normal;
enormal = emission.normal;
% point coordinates
c = incidence.coordinates;
% get vector: point -> surface patches
vec1 = emission.mesh.patchcenter-c;
% coordinate vector for loop
c = repmat(c,size(vec1,1),1);
% get vector: surface patches -> point
vec2 = -vec1;
% get distance point -> surfaces patches
R = sqrt(vec1(:,1).^2 + vec1(:,2).^2 + vec1(:,3).^2);
% surface emission angle
ema = abs(acosd(dot(repmat(enormal,size(vec2,1),1),vec2,2)./R));
% point incidence angle
ina = abs(acosd(dot(repmat(inormal,size(vec1,1),1),vec1,2)./R));
% patch visibility matrix
vis = zeros(size(ina));
if ~isequal(fisheye,0)
    vis(ema<90 & ema>=0 & ina<fisheye & ina>=0) = 1;
else
    vis(ema<90 & ema>=0 & ina<90 & ina>=0) = 1;
end
% 2nd visibility matrix (blocked by other surface)
VIS = ones(size(vis));
% loop over surfaces
for s = 1:numel(surfaces)
    
    % skip windows
    if strcmp(surfaces{s}.type,'window')
        continue
    end
    % skip current window wall
    %{
    check = 0;
    for n = 1:length(surfaces{s}.blank)
        if isequal(sum(sum(unique(emission.vertices,'rows') == sum(unique(surfaces{s}.blank{n}.vertices,'rows')))),12)
            check = 1;
        end
    end
    if check
        continue
    end
    %}
    
    % check that blank is not part of surface
    abort = 0;
    for b = 1:numel(surfaces{s}.blank)
        [s1,s2] = size(surfaces{s}.blank{b}.vertices);
        [s3,s4] = size(emission.vertices);
        if s1==s3 && s2 == s4
            if sum(sum(surfaces{s}.blank{b}.vertices == emission.vertices)) == s1*s2
                abort = 1;
            end
        end
    end
    if abort
        continue
    end
    
    % normal vector
    normal = repmat(surfaces{s}.normal,size(vec1,1),1);
    %normal = repmat(cat(3,normal(1),normal(2),normal(3)),s1,s2,1);
    % point in plane
    q = repmat(surfaces{s}.vertices(1,:),size(vec1,1),1);
    % p-matrix
    p = dot(normal,c-q,2);
    % r-matrix
    r = dot(normal,vec1,2);
    % parameter a
    a = -p./r;

    % intersection point
    I = c + a.*vec1;
    
    % rotate intersection plane to y-z plane
    
    % normal vector
    normal = surfaces{s}.normal;
    % plane elevation rotation angle
    [~,elevation,~] = cart2sph(normal(1),normal(2),normal(3));
    % rotate parallel to y-z-axis
    if ~isnan(elevation) && ~isequal(elevation,0)
        % rotation matrix
        if abs(normal(3)) == 1
            %rotax = [0 1 0];
            R1 = rotMatrix([0 rad2deg(pi/2) 0]);
        else
            rotax = cross(normal,[0 0 1]);
            R1 = rotMatrix([0 rad2deg(-elevation) 0]);
            
        end
    else
        R1 = eye(3);
    end
    newnorm = surfaces{s}.normal*R1;
    [azimuth,~,~] = cart2sph(newnorm(1),newnorm(2),newnorm(3));
    if ~isequal(mod(azimuth,pi),0)
        R2 = rotMatrix([0 0 rad2deg(azimuth)]);
    else
        R2 = eye(3);
    end

    % rearange data structure and rotate intersection plane
    rip = (R1*R2*I')';
    % rotate blocking surface vertices
    polyg = (R1*R2*surfaces{s}.vertices')';
    polyg = unique(polyg,'rows','stable');
    % check if intersection point is inside surface polygon
    in = inpolygon(rip(:,2),rip(:,3),polyg(:,2),polyg(:,3));
    in = reshape(in,size(vis));
    % ensure intersection point lies between surface 1 and surface 2
    in(a>1|a<0) = 0;
    % update 2nd visibility matrix
    VIS(in) = 0;
    
end
vis = vis & VIS;

