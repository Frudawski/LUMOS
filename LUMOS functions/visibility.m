% visibility determination for two surfacae meshes in LUMOS
%
% Author: Frederic Rudawski
% Date: 24.12.2019

function vis = visibility(surfaces,s,os,ang1,ang2,osx,osy,osz,dosx,dosy,dosz)

% patch visibility matrix
vis = zeros(size(ang1));
vis(ang1<90 & ang1>=0 & ang2<90 & ang2>=0) = 1;
% vector with all surfaces except actual two surfaces
n = 1:numel(surfaces);
n([s os]) = [];

% 2nd visibility matrix (blocked by other surface)
VIS = ones(size(vis));
% check if other surfaces block line of sight
for nb = n
    
    % check that blank is not part of surface
    abort = 0;
    for b = 1:numel(surfaces{nb}.blank)
        [s1,s2] = size(surfaces{nb}.blank{b}.vertices);
        [s3,s4] = size(surfaces{os}.vertices);
        if s1==s3 && s2 == s4
            if sum(sum(surfaces{nb}.blank{b}.vertices == surfaces{os}.vertices)) == s1*s2
                abort = 1;
            end
        end
    end
    if abort
        continue
    end
    
    % plane - line intersection
    % source: "Computer Graphics: Principles and Practice, 3rd Edition", 2013
    % by James D. Foley, Andries van Dam, Steven K. Feiner, John Hughes, Morgan McGuire, David F. Sklar, and Kurt Akeley and published by Addison–Wesley.
    % http://cgpp.net/about.xml
    
    % size of patches matrix
    [s1,s2] = size(dosx);
    % normal vector
    normal = surfaces{nb}.normal;
    normal = repmat(cat(3,normal(1),normal(2),normal(3)),s1,s2,1);
    % point in plane
    q = surfaces{nb}.vertices(1,:);
    % p-matrix
    p = dot(normal,cat(3,osx,osy,osz)-repmat(cat(3,q(1),q(2),q(3)),s1,s2,1),3);
    % r-matrix
    r = dot(normal,cat(3,dosx,dosy,dosz),3);
    % parameter a
    a = -p./r;
    % clear some memory
    clearvars p q r s1 s2
    % intersection point
    I = cat(3,osx,osy,osz) + a.*cat(3,dosx,dosy,dosz);
    
    % rotate intersection plane to y-z plane
    
    % normal vector
    normal = surfaces{nb}.normal;
    % plane elevation rotation angle
    [~,elevation,~] = cart2sph(normal(1),normal(2),normal(3));
    % rotate parallel to y-z-axis
    if ~isnan(elevation) && ~isequal(elevation,0)
        % rotation matrix
        if abs(normal(3)) == 1
            %rotax = [0 1 0];
            R1 = rotMatrix([0 rad2deg(pi/2) 0]);
        else
            %rotax = cross(normal,[0 0 1]);
            R1 = rotMatrix([0 0 rad2deg(-elevation)]);
            
        end
    else
        R1 = eye(3);
    end
    newnorm = surfaces{nb}.normal*R1;
    [azimuth,~,~] = cart2sph(newnorm(1),newnorm(2),newnorm(3));
    if ~isequal(mod(azimuth,pi),0)
        R2 = rotMatrix([0 0 rad2deg(azimuth)]);
    else
        R2 = eye(3);
    end
    % extract x,y,z coordinate matrices
    A = I(:,:,1);
    B = I(:,:,2);
    C = I(:,:,3);
    % rearrange data structure and rotate intersection plane
    rip = (R1*R2*[A(:) B(:) C(:)]')';
    % rotate blocking surface vertices
    polyg = (R1*R2*surfaces{nb}.vertices')';
    % check if intersection point is inside surface polygon
    in = inpolygon(rip(:,2),rip(:,3),polyg(:,2),polyg(:,3));
    in = reshape(in,size(vis));
    % ensure intersection point lies between surface 1 and surface 2
    in(a>1|a<0) = 0;
    % update 2nd visibility matrix
    VIS(in) = 0;

end
% update visibility matrix
vis = vis & VIS;

