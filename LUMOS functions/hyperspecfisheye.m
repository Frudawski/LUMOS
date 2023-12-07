% hyper spectral fisheye image from LUMOS data
%
% Author: Frederic Rudawski
% Date: 05.11.2021

function hyspec = hyperspecfisheye(surfaces,sky,luminaires,ground,information,observer,lambda,reso,fisheyeang)

%pnt(isnan(pnt)) = 0;
if ~exist('fisheyeang','var')
    fisheyeang = 180;
end

%nord_angle = information.nord_angle;
P = observer;

if ~exist('reso','var')
    reso = 500;
end

% Tregenza table
% almucantar number, number of patches, almucantar center angle, azimuth increament, solid angle? 
%TR = [1 30 6 12 12; 2 30 18 12 12; 3 24 30 15 12; 4 24 42 15 12; 5 18 54 20 12; 6 12 66 30 12; 7 6 78 60 12; 8 1 90 0 12];
% patch numbers and angles
% line 1: almucantars, line 2: azimuths, line 3: Patchnumber
pnt = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 66 66 66 66 66 66 66 66 66 66 66 66 78 78 78 78 78 78 90;180 192 204 216 228 240 252 264 276 288 300 312 324 336 348 0 12 24 36 48 60 72 84 96 108 120 132 144 156 168 168 156 144 132 120 108 96 84 72 60 48 36 24 12 0 348 336 324 312 300 288 276 264 252 240 228 216 204 192 180 180 195 210 225 240 255 270 285 300 315 330 345 0 15 30 45 60 75 90 105 120 135 150 165 165 150 135 120 105 90 75 60 45 30 15 0 345 330 315 300 285 270 255 240 225 210 195 180 180 200 220 240 260 280 300 320 340 0 20 40 60 80 100 120 140 160 150 120 90 60 30 0 330 300 270 240 210 180 180 240 300 0 60 120 0;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];

% polar coordinate grid in image resolution
x = linspace(-deg2rad(fisheyeang)/2,deg2rad(fisheyeang)/2,reso);
y = x;
[x,y] = meshgrid(x,y);
[az,el] = cart2pol(x,y);
% in deg
eld = rad2deg(el);
eld = fisheyeang/2-eld;
eld(eld<0) = NaN;
eld(eld>fisheyeang/2) = NaN;
azd = rad2deg(az);
% azimuth range [0 360]
azd(azd<0) = 360+azd(azd<0);

% rotation Matrix
ax  = cross([0 0 1],observer.normal);
ang = hemdistd(0,90,observer.azimuth,observer.elevation);
M   = rotMatrixD(ax,ang);
% check correct rotation direction, cross product has two valid solutions
up = [0 0 1]; 
if round(up*M,6) ~= round(observer.normal,6)
    ax = -ax;
    M = rotMatrixD(ax,ang);
end

% initialize hyperspectral-image
im = zeros(size(el,1)*size(el,2),numel(lambda)).*NaN;
hyspec = zeros(reso,reso,numel(lambda));

% loop over surfaces
for s = 1:numel(surfaces)
    % other surfaces index
    o = 1:numel(surfaces);
    o = o(~(o==s));
    
    % rotate radiance points to observer view direction
    rotp = (M*(surfaces{s}.mesh.patchcenter-P.coordinates)')';
    
    % polar angles of rotated radiance points
    [raz,rel] = cart2sph(rotp(:,1),rotp(:,2),rotp(:,3));
    % rotated radiance points in degree
    razd = rad2deg(raz)-observer.azimuth;
    reld = rad2deg(rel);
    % azimuth range 0 - 360
    razd(razd<0) = 360+razd(razd<0);
    
    % get radiance data depending on surface type
    switch surfaces{s}.type
        case 'window'
            % angles to window
            winvec = surfaces{s}.mesh.patchcenter-P.coordinates;
            [winaz,winel] = cart2sph(winvec(:,1),winvec(:,2),winvec(:,3));
            winaz = rad2deg(winaz)+information.nord_angle+90;
            while sum(winaz<0)>0
                winaz(winaz<0) = 360+winaz(winaz<0);
            end
            while sum(winaz>=360)>0
                winaz(winaz>=360) = winaz(winaz>=360)-360;
            end
            %winaz = unwrap(winaz);
            winel = rad2deg(winel);
            % add sky elevation < 0 for extrapolation
            %skyaz = [pnt(2,:)'-360;pnt(2,:)'-360;pnt(2,:)';pnt(2,:)';pnt(2,:)'+360;pnt(2,:)'+30];
            %skyel = [pnt(1,:)';-pnt(1,:)';pnt(1,:)';-pnt(1,:)';pnt(1,:)';-pnt(1,:)'];
            
            % initialize L
            L = zeros(size(razd,1),numel(lambda));
            % lambda indices
            if ~isempty(sky)
                skyidx = ismember(sky.spectrum(1,:),lambda);
                winidx = ismember(surfaces{s}.material.data(1,:),lambda);
                % interpolate tregenza hemisphere
                [skyaz,skyel,Y] = tregenzaint(sky.spectrum(2:146,skyidx).*surfaces{s}.material.data(2,winidx),pnt(2,:),pnt(1,:),1);

            else
                skyidx = [];
                skyaz = pnt(2,:)';
                skyel = pnt(1,:)';
            end

            % 2nd iteration
            %[skyaz,skyel,Y] = tregenzaint(Y,skyaz,skyel);
            % scattered interpolant
            F = scatteredInterpolant(skyaz,skyel,zeros(numel(skyel),1),'linear','linear');
            for n = 1:numel(lambda)
                if ~isempty(sky)
                    %F = scatteredInterpolant(skyaz,skyel,repmat(sky.spectrum(2:146,n),6,1),'linear','linear');
                    F.Values = Y(:,n);
                    L(:,n) = F(winaz,winel);
                else
                    F.Values = zeros(size(skyel));
                    L(:,n) = F(winaz,winel);
                end
            end
        case 'luminaire'
            %L = surfaces{s}.L;
            
            % luminaire number
            lumnum = [];
            for lum = 1:numel(luminaires)
                 if strcmp(luminaires{lum}.name,surfaces{s}.name(1:end-2))
                    lumnum = lum; 
                 end
            end
            % luminaire I and resulting E at observer
            %[Iv,Ev] = ldc2IE(luminaires{lumnum},observer);
            % find all surfaces of current luminaire
            %lumsurf = [];
            lumI = [];
            lumA = [];
            obsE = [];
            ind1 = [];
            ind2 = [];
            for sn = 1:numel(surfaces)
                %[num2str(s),':   ',surfaces{s}.name,'   ', surfaces{sn}.name]
                if strcmp(luminaires{lumnum}.name,surfaces{sn}.name(1:end-2))
                    % patch visibility matrix, incidence angles, emission angles, distance R
                    vis = pointVisibilityMatrix(P,surfaces{s},[]);
                    if sum(vis)>0
                        % if visible get patch areas and patch radiant
                        % intensities and resulting E at observer 
                        if sn == s
                           ind1 = numel(lumI)+1;
                           ind2 = numel(lumI)+numel(surfaces{s}.mesh.patch_area);
                        end
                        lumA = [lumA; surfaces{s}.mesh.patch_area];
                        [I,E] = lum2IE(luminaires{lumnum},observer,surfaces{s});
                        lumI = [lumI; I];
                        obsE = [obsE; E];
                    end
                end
            end
            if sum(vis)>0
                % radiance
                lumL = lumI./lumA;
                lumL = lumL(ind1:ind2)./size(surfaces{s}.mesh.list,1);
                %lumL = repmat(mean(lumL(ind1:ind2))./numel(lumA(ind1:ind2)),numel(lumA(ind1:ind2)),1);%
                lamidx = ismember(luminaires{lumnum}.spectrum.data(1,:),lambda);
                specL = ciespec2Y(lambda,luminaires{lumnum}.spectrum.data(2,lamidx));
                factor = lumL./specL;
                L = factor.*repmat(luminaires{lumnum}.spectrum.data(2,lamidx),numel(factor),1);
            else
                continue
            end

            
        case 'room'
            L = surfaces{s}.L;
        case 'object'
            L = surfaces{s}.L;
        otherwise
    end
    
    % azimuth range of radaince points > 0-360 and el > 90 for inter- and extrapolation
    [~,idx] = max(reld);
    singularity = (-360:90:720)';
    razd = [razd-360; razd; razd+360; singularity];
    reld = [repmat(reld,3,1);repmat(90,numel(singularity),1)];
    try
    L = [repmat(L,3,1);repmat(L(idx,:),numel(singularity),1)];
    catch
        dummy = 1;
    end

    
    % surface polygon
    N = 100;
    surfgon = zeros(4*N,3).*NaN;
    %surfgon(end,:) = surfaces{s}.vertices(end,:);
    for n = 0:3
        for m = 1:3
            surfgon(n*N+1:(n+1)*N,m) = linspace(surfaces{s}.vertices(n+1,m),surfaces{s}.vertices(n+2,m),N);
        end
    end
    
    % surface polygon rotation
    surfpol = (M*(surfgon-P.coordinates)')';
    % surface polygon polar angles
    [paz,pel] = cart2sph(surfpol(:,1),surfpol(:,2),surfpol(:,3));
    % in degree
    paz = rad2deg(paz)-observer.azimuth;
    paz(paz<0) = 360+paz(paz<0);
    paz(paz>=360) = paz(paz>=360)-360;
    paz(paz==360) = 0;

    pel = rad2deg(pel);
    
    % image pixels inside surface polygon
    %in = inpolygon(azd(:),eld(:),paz,pel);
    
    %in case of azimuth angle crosses 0 -> 360 degree
    if max(diff(paz)) > 180
        [~,idx] = max(diff(paz));
        % go to el = 0 and rotate to az = 360
        paz = [paz(1:idx);0;0;360;360;paz(idx+1:end)];
        pel = [pel(1:idx);(pel(idx)+pel(idx+1))/2;0;0;(pel(idx)+pel(idx+1))/2;pel(idx+1:end)];
    end
    % in case of azimuth angle crosses 360 -> 0 degree
    if min(diff(paz)) < -180
        [~,idx] = min(diff(paz));
        % go to el = 0 and rotate to az = 0
        paz = [paz(1:idx);360;360;0;0;paz(idx+1:end)];
        pel = [pel(1:idx);(pel(idx)+pel(idx+1))/2;0;0;(pel(idx)+pel(idx+1))/2;pel(idx+1:end)];
    end
    
    % view direction center in surface polygon?
    p = dot(surfaces{s}.normal,P.coordinates-surfaces{s}.vertices(1,:));
    r = dot(P.normal,surfaces{s}.normal);
    a = -p/r;
    % if intersection point lies in viewing direction check if intersection
    % point lies in surface polygon or not
    if a>0
        % intersection point
        I = P.coordinates+a*P.normal;
        % rotate surface plane to y-z plane
        normal = surfaces{s}.normal;
        % plane elevation rotation angle
        [~,elevation,~] = cart2sph(normal(1),normal(2),normal(3));
        % rotate parallel to y-z-axis
        if ~isnan(elevation) && ~isequal(elevation,0)
            % rotation matrix
            if abs(normal(3)) == 1
                R1 = rotMatrix([0 rad2deg(pi/2) 0]);
            else
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
        incenter = inpolygon(rip(:,2),rip(:,3),polyg(:,2),polyg(:,3));
    else
        incenter = 0;
    end
    
    % image pixels inside surface polygon
    if incenter
        [in,on] = inpolygon(azd(:),eld(:),paz,pel);
        in = ~in | on;
    else
        [in,on] = inpolygon(azd(:),eld(:),paz,pel);
        in = in | on;
    end    
    
    % pixel surface coordinates
    [x,y,z] = sph2cart(deg2rad(azd(in)+P.azimuth),deg2rad(eld(in)),ones(size(azd(in))));
    R = (M\[x y z]')';
    normal = repmat(surfaces{s}.normal,size(R,1),1);
    c = repmat(P.coordinates,size(R,1),1);
    q = repmat(surfaces{s}.vertices(1,:),size(R,1),1);
    p = dot(normal,c-q,2);
    r = dot(normal,R,2);
    a = -p./r;
    % intersection points on surface
    I = c + a.*R;
    
    % pixel visibility
    pixsurf = surfaces{s};
    pixsurf.mesh.patchcenter = I;
    vis = pointVisibilityMatrix(P,pixsurf,surfaces(o));
    
    if sum(vis)>0
        % interpolate radiance pixel grid data
        idx = find(in);
        F = scatteredInterpolant(razd,reld,L(:,n),'linear','linear');

        for n = 1:numel(lambda)
            F.Values = L(:,n);
            try
                im(idx(vis),n) = F(azd(idx(vis)),eld(idx(vis)));
            catch
            end
        end
    end
    
    
    % window -> ground radiance
    if strcmp(surfaces{s}.type,'window')
        
        % ground polygon
        gaz = 0:360;
        gel = zeros(size(gaz));
        grd  = ones(size(gaz))*.1e4;
        % ground polygon xyz
        [x,y,z] = sph2cart(deg2rad(gaz),deg2rad(gel),grd);
        % rotate ground according to viewing direction
        R1 = rotMatrixD([1 0 0],90);
        R2 = rotMatrixD([1 0 0],P.elevation);
        gxyz = (R1*R2*[x;y;z])';
        
        % transform back to spherical coordinates
        [gaz,gel] = cart2sph(gxyz(:,1),gxyz(:,2),gxyz(:,3));
        gaz = rad2deg(gaz);
        gaz(gaz<0) = 360+gaz(gaz<0);
        gaz(gaz>360) = gaz(gaz>360)-360;
        gel = rad2deg(gel);
        
        % find ground pixels in window frame
        gin = inpolygon(azd(:),eld(:),gaz,gel);
        if P.elevation >= 0
            gin = gin & in & eld(:)>=0;
        else
            gin = ~gin & in & eld(:)>=0;
        end
        gidx = ismember(ground.lambda,lambda);
        widx = ismember(surfaces{s}.material.data(1,:),lambda);
        im(gin,:) = repmat(ground.radiance(gidx).*surfaces{s}.material.data(2,widx),sum(gin),1);

    end
    
end

% extrapolation values < 0?
im(im<0) = 0;

% rearrange image pixels
for n = 1:numel(lambda)
    hyspec(:,:,n) = reshape(im(:,n)',[reso,reso]);
end

%idx = sum(isequal(hyspec,0),3);




