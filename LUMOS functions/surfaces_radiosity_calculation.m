% Radiosity computation
%
% Author: Frederic Rudawski
% Date: 10-11-2017, last edited: 04.06.2020
%
% A indoor radiosity calculation model for spectral data
%
% The surface data is first divided into mesh patches which are used for the
% radiosity computation.


function [calculation,ground,measurements] = surfaces_radiosity_calculation(surfaces,sky,luminaires,ground,information,measurements)

calculation = [];

density = information.density;
reflections = information.reflections;
nord_angle = information.nord_angle;

% Tregenza table
% almucantar number, number of patches, almucantar center angle, azimuth increament, solid angle? 
TR = [1 30 6 12 12; 2 30 18 12 12; 3 24 30 15 12; 4 24 42 15 12; 5 18 54 20 12; 6 12 66 30 12; 7 6 78 60 12; 8 1 90 0 12];
% patch numbers and angles
% line 1: almucantars, line 2: azimuths, line 3: Patchnumber
pnt = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 66 66 66 66 66 66 66 66 66 66 66 66 78 78 78 78 78 78 90;180 192 204 216 228 240 252 264 276 288 300 312 324 336 348 0 12 24 36 48 60 72 84 96 108 120 132 144 156 168 168 156 144 132 120 108 96 84 72 60 48 36 24 12 0 348 336 324 312 300 288 276 264 252 240 228 216 204 192 180 180 195 210 225 240 255 270 285 300 315 330 345 0 15 30 45 60 75 90 105 120 135 150 165 165 150 135 120 105 90 75 60 45 30 15 0 345 330 315 300 285 270 255 240 225 210 195 180 180 200 220 240 260 280 300 320 340 0 20 40 60 80 100 120 140 160 150 120 90 60 30 0 330 300 270 240 210 180 180 240 300 0 60 120 NaN;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];


% calculate necessary steps for simulation
% first step is meshing, then direct light, artificial light then reflections
steps = (3+reflections)*numel(surfaces)+numel(measurements);
if isempty(steps)
    steps = numel(measurements);
end
% waitbar
wbh = waitbar(0,'Meshing...','name','Calculating:','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(wbh,'canceling',0);

% start simulation progress
step = 0;
lstep = 1;
% catch errors to close waitbar - otherwise it wouldn't close anymore
try
    
    % PART 1 - MESHING
    
    % plot mode
    plot_mode = 'none';
    %{
        plot_mode = 'plot3D'; % <- for mesh plotting
        figure(2)
        clf
        view(0,45)
        xlabel('x')
        ylabel('y')
    %}
    
    surfacelam = surfaces{1}.material.data(1,:);
    % loop over surfaces
    for s = 1:numel(surfaces)
        if getappdata(wbh,'canceling')
            break
        end
        
        step = step + 1;
        waitbar(step/steps,wbh,['Meshing: surface ',num2str(s),'/',num2str(numel(surfaces))]);
        
        % result initialisation
        result{s}.E{1} = [];
        result{s}.L{1} = [];
        result{s}.lambda{1} = [];
        
        surfaces{s}.lambda = [];
        surfaces{s}.E = [];
        surfaces{s}.L = [];
        
        %comeback('remove mesh error warning due to area = 0')
        
        if isequal(size(surfaces{s}.vertices,1),3)
            surfaces{s}.mesh.points = [0 0 0;0 0 0;0 0 0];
            surfaces{s}.mesh.list = [1 2 3];
            surfaces{s}.mesh.patchcenter = [0 0 0];
            surfaces{s}.mesh.patches = [0 0 0 0];
            surfaces{s}.mesh.patch_area = 1;
            continue
        end
        

        
        surfaces{s} = Meshing(surfaces{s},density,plot_mode,luminaires,measurements);
        % surface lambda
        %figure(2)
        if strcmp(surfaces{s}.type,'window') && (isempty(surfaces{s}.material) || isempty(surfaces{s}.material.data))
        else
            surfacelam = intersect(surfacelam,surfaces{s}.material.data(1,:));
        end
        % surface lambda
        try
            if surfaces{s}.material.data(1,2)-surfaces{s}.material.data(1,1) > lstep
                lstep = surfaces{s}.material.data(1,2)-surfaces{s}.material.data(1,1);
            end
        catch me
            %catcher(me)
        end
    end
    
catch ERROR
    % close waitbar
    delete(wbh)
    % show ERROR
    catcher(ERROR)
    % reset room data
    result = [];
    return
end

for lum = 1:numel(luminaires)
    surfacelam = intersect(surfacelam,luminaires{lum}.lambda);
    % surface lambda
    try
        if luminaires{lum}.lambda(1,2)-luminaires{lum}.lambda(1,1) > lstep
            lstep = luminaires{lum}.lambda(1,2)-luminaires{lum}.lambda(1,1);
        end
    catch me
        catcher(me)
    end
end

for s = 1:numel(surfaces)
    %surfaces{s}.type
    if strcmp(surfaces{s}.type,'luminaire')
        surfaces{s}.material.data(2,:) = surfaces{s}.material.data(2,:)./4./max(surfaces{s}.material.data(2,:));
        %surfaces.material
    end
    if strcmp(surfaces{s}.type,'window') && (isempty(surfaces{s}.material) || isempty(surfaces{s}.material.data))
        surfaces{s}.material.name = 'blank';
        surfaces{s}.material.data = [surfacelam;ones(size(surfacelam))];
        surfaces{s}.material.rho = 1;
    end
end

% PART 2 - SIMULATION
LAMBDA = surfacelam;
try
    
    % PART 2.1 - DAYLIGHT
    
    if ~isempty(sky)
        % skylambda
        ind = 1;
        while sky.spectrum(ind) == 0
            ind = ind+1;
        end
        if sky.spectrum(1,ind+1)-sky.spectrum(1,ind) > lstep
            lstep = sky.spectrum(1,ind+1)-sky.spectrum(1,ind);
        end
        
        % environment ground lambda
        if ground.material.data(1,2)-ground.material.data(1,1) > lstep
            lstep = ground.material.data(1,2)-ground.material.data(1,1);
        end
        
        groundlam = ground.material.data(1,:);
        skylam = sky.spectrum(1,:);
        
        LAMBDA = intersect(skylam,groundlam);
        LAMBDA = intersect(LAMBDA,surfacelam);
        groundlam = LAMBDA;
        ground.lambda = LAMBDA;
        
        % for all surfaces
        for s = 1:numel(surfaces)
            % check cancel button
            if getappdata(wbh,'canceling')
                break
            end
            
            % waitbar update
            step = step + 1;
            waitbar(step/steps,wbh,['Daylight: surface ',num2str(s),'/',num2str(numel(surfaces))]);
            
            % skip windows
            if strcmp(surfaces{s}.type,'window')
                continue
            end
            
            % other walls
            othersurfaces = 1:numel(surfaces);
            othersurfaces(s) = [];
            
            % sky lambda
            %skylam = sky.spectrum(1,:);
            %skylam(skylam==0) = [];
            
            % wall lambda
            %surfacelam = surfaces{s}.material.data(1,:);
            
            % loop over all other surfaces
            for os = othersurfaces %
                % check canceling
                if getappdata(wbh,'canceling')
                    break
                end
                
                % if other surface is window
                if strcmp(surfaces{os}.type,'window')
                    
                    % surface coordinate matrices
                    csx = repmat(surfaces{s}.mesh.patchcenter(:,1), 1, size(surfaces{os}.mesh.patchcenter,1));
                    csy = repmat(surfaces{s}.mesh.patchcenter(:,2), 1, size(surfaces{os}.mesh.patchcenter,1));
                    csz = repmat(surfaces{s}.mesh.patchcenter(:,3), 1, size(surfaces{os}.mesh.patchcenter,1));
                    % other surface coordinate matrices
                    osx = repmat(surfaces{os}.mesh.patchcenter(:,1)', size(surfaces{s}.mesh.patchcenter,1), 1);
                    osy = repmat(surfaces{os}.mesh.patchcenter(:,2)', size(surfaces{s}.mesh.patchcenter,1), 1);
                    osz = repmat(surfaces{os}.mesh.patchcenter(:,3)', size(surfaces{s}.mesh.patchcenter,1), 1);
                    
                    %figure
                    %plot3(csx,csy,csz,'g*');
                    %hold on
                    %plot3(osx,osy,osz,'r+');
                    
                    % vectors from patches of surface 1 to patches of surface 2
                    % direction current surface xyz
                    dcsx = osx-csx;
                    dcsy = osy-csy;
                    dcsz = osz-csz;
                    % vectors from patches of surface 2 to patches of surface 1
                    % direction other surface xyz
                    dosx = csx-osx;
                    dosy = csy-osy;
                    dosz = csz-osz;
                    
                    % wall normals
                    normal = surfaces{s}.normal;
                    sn(1,1,:) = normal;
                    snormal = repmat(sn,size(csx,1),size(csx,2));
                    
                    % other wall normals
                    onormal = surfaces{os}.normal;
                    osn(1,1,:) = onormal;
                    onormal = repmat(osn,size(csx,1),size(csx,2));
                    
                    % emission angle matrices
                    %OSPHI = abs(90 - acosd(dot(cat(3,dosx, dosy, dosz), onormal,3)./sqrt(sum(cat(3,dosx,dosy,dosz).^2,3))));
                    % incidience angle matrices
                    %CSPHI = abs(90 - acosd(dot(cat(3,dcsx, dcsy, dcsz), snormal,3)./sqrt(sum(cat(3,dcsx,dcsy,dcsz).^2,3))));
                    
                    % emission angle matrix in degree
                    ang1 = abs(acosd(dot(cat(3,dosx, dosy, dosz), onormal,3)./sqrt(sum(cat(3,dosx,dosy,dosz).^2,3))));
                    % incidence angle matrix in degree
                    ang2 = abs(acosd(dot(cat(3,dcsx, dcsy, dcsz), snormal,3)./sqrt(sum(cat(3,dcsx,dcsy,dcsz).^2,3))));

                    
                    %
                    % patch visibility matrix
                    vis = zeros(size(ang2));
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
                        % https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
                        
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
                        
                        % debugging plots
                        %{
                         d = surfaces{s}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         hold on
                         d = surfaces{os}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         d = surfaces{nb}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         plot3(A(in),B(in),C(in),'.')
                         dummy = 1
                        %}
                    end
                    % update visibility matrix
                    vis = vis & VIS;
                    %}
                    
                    % area matrices
                    ACS = repmat(surfaces{s}.mesh.patch_area,1,size(surfaces{os}.mesh.patch_area,1));
                    AOS = repmat(surfaces{os}.mesh.patch_area,1,size(surfaces{s}.mesh.patch_area,1))';
                    
                    % azimuth and eleveation angles to window patch
                    [a,e,R] = cart2sph(dcsx,dcsy,dcsz);
                    az = 180+a./(pi/180)-90; % azimuth in degree
                    el = e./(pi/180);        % elevation in degree
                    
                    % nord angle modification - clockwise
                    az = az + nord_angle;
                    az(az>=360) = az(az>=360)-360;
                    az(az<0) = az(az<0)+360;
                    
                    % find corresponding sky patches
                    patch = zeros(size(ang1));
                    %comeback('sort sky patches over 145 nonsense 1')
                    patch(el<0) = 146; % 146 = ground
                    % almucantar loop
                    for i = 1:size(TR,1)
                        % cancel check
                        if getappdata(wbh,'canceling')
                            break
                        end
                        ind1 = el > TR(i,3)-6 & el <= TR(i,3)+6;
                        center = 0;
                        if sum(sum(ind1)) > 0
                        % azimuth loop
                        for j = 1:TR(i,2)
                            % cancel check
                            if getappdata(wbh,'canceling')
                                break
                            end
                            lo = center-TR(i,4)/2;
                            lo(lo<0) = 360+lo(lo<0);
                            hi = center+TR(i,4)/2;
                            hi(hi>=360) = hi(hi>=360)-360;
                            if hi > lo
                                ind2 = az >= lo &  az < hi;
                            else
                                ind2 = az >= lo |  az < hi;
                            end
                            center = center+TR(i,4);
                            almucantar = i*12-6;
                            azimuth = (j-1)*TR(i,4);
                            %sky{s}
                            ind = ind1 & ind2;
                            p = pnt(3,(pnt(1,:)==almucantar & pnt(2,:)==azimuth));
                            % zenit patch
                            if almucantar == 90
                                p = 145;
                            end
                            patch(ind) = p;
                        end
                        end
                    end
                    %comeback('sort sky patches over 145 nonsense 2')
                    patch(patch==0) = 147; % 147 = empty patch
                    
                    % luminaire lambda
                    if ~isempty(luminaires)
                        lumlam = luminaires{lum}.lambda;
                    else
                        lumlam = surfacelam;
                    end
                    % environment ground spectral refelectance
                    %groundlam = ground.material.data(1,:);
                    % lambda parity
                    %lamstart = max([surfacelam(1) skylam(1) groundlam(1) lumlam(1)]);
                    %lamend   = min([surfacelam(end) skylam(end) groundlam(end) lumlam(end)]);
                    lamstart = LAMBDA(1);
                    lamend = LAMBDA(end);
                    
                    %comeback('Add height above ground:')
                    % TODO
                    % + add height above ground
                    
                    ground.irradiance = [];
                    ground.radiance = [];
                    %firstground = find(ground.material.data(1,:)==lamstart);
                    %lastground  = find(ground.material.data(1,:)==lamend);
                    % integral horizontal spectral luminance distribution on the ground
                    azinc = [ones(60,1).*12;ones(48,1).*15;ones(18,1).*24;ones(12,1).*30;ones(6,1).*60;360];
                    %elinc = ones(145,1).*12;
                    % solid angles of hemisphere subdivision
                    solidangle = (sind([(pnt(1,1:end-1)'+6);90])-sind((pnt(1,:)'-6))).*azinc.*pi./180;
                    skylam2 = sky.spectrum(1,:);
                    skylam3 = skylam2~=0;
                    skylam4 = skylam3 & ismember(skylam2,LAMBDA);
                    %ground.irradiance = sum(repmat(solidangle,[1 size(sky.spectrum(:,skylam3),2)]) .* repmat(sind(pnt(1,:))',[1 size(sky.spectrum(:,skylam3),2)]) .* sky.spectrum(2:146,skylam3) );
                    ground.irradiance = polardataE(sky.spectrum(2:146,skylam4));
                    
                    % ground lambda start & stop
                    first = find(skylam==lamstart);
                    last  = find(skylam==lamend);
                    % TODO: FIX lambda parity
                    %comeback('ERROR')
                    idx = ismember(ground.lambda,LAMBDA);%skylam(first:last);
                    %sidx = ismember(skylam,LAMBDA);
                    sidx = ismember(LAMBDA,ground.lambda);
                    
                    %groundmatinterp = interp1(ground.material.data(1,:),ground.material.data(2,firstground:lastground),skylam);
                    %groundmatinterp = interp1(ground.material.data(1,:),ground.material.data(2,firstground:lastground),LAMBDA);
                    ground.radiance = ground.irradiance(sidx).*ground.material.data(2,idx)./pi;
                    ground.irradiance = ground.irradiance(sidx);
                    %comeback('sort sky patches over 145 nonsense 3')
                    %try
                    sky.spectrum(147,:) = zeros(1,size(sky.spectrum,2));
                    sky.spectrum(147,sidx) = ground.radiance;
                    %catch
                    %    dummy = 1;
                    %end
                    
                    % empty zero patches
                    sky.spectrum(148,first:last) = zeros(1,size(sky.spectrum(:,first:last),2)); % empty
                    
                    % reset E and L
                    %comeback('initialize calculation struct')
                    if isempty(result{s}.E{1})
                        result{s}.E{1} = zeros(size(surfaces{s}.mesh.patchcenter,1),size(lamstart:lstep:lamend,2));
                        result{s}.L{1} = zeros(size(surfaces{s}.mesh.patchcenter,1),size(lamstart:lstep:lamend,2));
                    end
                    
                    % loop over spectrum
                    ind = 1;
                    for lamstep = LAMBDA%lamstart:lstep:lamend
                        
                        % cancel check
                        if getappdata(wbh,'canceling')
                            break
                        end
                        
                        % indices
                        wallind = surfaces{os}.material.data(1,:)==lamstep;
                        skyind  = skylam==lamstep;
                        %comeback('other surface lambda abgleich nicht vergessen')
                        %winind  = find(winlam==lamstep);
                        groundind = groundlam==lamstep;
                        
                        % sky luminance
                        slum = sky.spectrum(patch+1,skyind);
                        groundindex = find(patch==146);
                        
                        if ~isempty(groundindex)
                            %comeback('add sin/cos correction of environment ground patch')
                            %slum(groundindex) = slum(groundindex).*(abs(sind(el(groundindex)))).^2 .* ground.material.data(2,groundind) ./pi;
                            %slum(groundindex) = slum(groundindex) .* ground.material.data(2,groundind);
                            slum(groundindex) = slum(groundindex) .* ground.material.data(2,groundind);
                            % reshape to correct matrix size
                            slum = reshape(slum,size(patch));
                        else
                            %slum = zeros(size(patch));
                            try
                                slum = reshape(slum,size(patch));
                            catch
                                comeback('testing...')
                            end
                        end
                        
                        grounddistance = zeros(size(el));
                        grounddistance(groundindex) = (ground.height)./abs(sind(el(groundindex)));
                        

                        % window transmission angle dependend according to CIE TR 171 sec 5.5
                        if ~strcmp(surfaces{os}.material.name,'blank')
                            % spectral factor: fresnel simplification by Schlick 1993, A Customizable Reflectance Model for Everyday Rendering
                            R0 = 1-surfaces{os}.material.data(2,wallind);
                            T1 = 1-(R0+(1-R0).*(1-cosd(ang1)).^5);
                            T = T1./surfaces{os}.material.data(2,wallind);
                        else
                            T = ones(size(ang1));
                        end
                        
                        % irradiance
                        E = sum(vis.* T .* slum.*ACS.*(cosd(ang2)).*AOS.*(cosd(ang1))./((R+grounddistance).^2) ,2) .* surfaces{os}.material.data(2,wallind);
                        
                        % save results
                        result{s}.E{1}(:,ind) = result{s}.E{1}(:,ind) + E;
                        
                        % increase index
                        ind = ind+1;
                    end
                    % spectrum
                    result{s}.lambda = LAMBDA;%lamstart:lstep:lamend;
                    
                end
                
                % end of other wall loop
            end
            % SI units E_e & L_e
            try
                idx = ismember(surfaces{s}.material.data(1,:),LAMBDA);
                result{s}.E{1} = result{s}.E{1};%./surfaces{s}.mesh.patch_area;
                result{s}.E{1}(isnan(result{s}.E{1})) = 0;
                result{s}.E{1}(isinf(result{s}.E{1})) = 0;
                % radiance
                result{s}.L{1} = result{s}.E{1}.*surfaces{s}.material.data(2,idx)./(pi);
            catch me
                catcher(me)
            end
            % end wall loop
        end
        
    end
    
    % test for result, if not available set to zero
    for test = 1:numel(surfaces)
        try
            if isempty(result{test}.E{1})
                %idx = ismember(surfaces{test}.material.data(1,:),surfacelam);
                result{test}.E{1} = zeros(size(surfaces{test}.mesh.patch_area,1),size(lamstart:lstep:lamend,2));
                result{test}.L{1} = zeros(size(surfaces{test}.mesh.patch_area,1),size(lamstart:lstep:lamend,2));
                result{test}.lambda = zeros(size(lamstart:lstep:lamend));
            end
        catch
            lamstart = surfacelam(1);
            lamend   = surfacelam(end);
            result{test}.E{1} = zeros(size(surfaces{test}.mesh.patch_area,1),size(lamstart:lstep:lamend,2));
            result{test}.L{1} = zeros(size(surfaces{test}.mesh.patch_area,1),size(lamstart:lstep:lamend,2));
            result{test}.lambda = zeros(size(lamstart:lstep:lamend));
        end
    end
    
    % PART 2.2 - ARTIFICIAL LIGHTING
    
    % for all surfaces
    for s = 1:numel(surfaces)
        % check cancel button
        if getappdata(wbh,'canceling')
            break
        end
        
        % waitbar update
        step = step + 1;
        waitbar(step/steps,wbh,['Artificial lighting: surface ',num2str(s),'/',num2str(numel(surfaces))]);
        
        % skip windows
        if strcmp(surfaces{s}.type,'window')
            continue
        end
        % don't consider luminaire surfaces
        if strcmp(surfaces{s}.type,'luminaire')
            continue
        end
        
        % area matrices
        ACS = surfaces{s}.mesh.patch_area;
        
        % surface coordinate matrices
        csx = surfaces{s}.mesh.patchcenter(:,1);
        csy = surfaces{s}.mesh.patchcenter(:,2);
        csz = surfaces{s}.mesh.patchcenter(:,3);
        
        %figure
        %plot3(csx,csy,csz,'g*');
        %hold on
        %plot3(osx,osy,osz,'r+');
        
        % loop over all luminaires
        for lum = 1:numel(luminaires) %
            % check canceling
            if getappdata(wbh,'canceling')
                break
            end
            
            c = luminaires{lum}.coordinates;
            g = luminaires{lum}.geometry{1};
            g = g(:,[1 2 3 6]);
            g(:,4) = g(:,4)-min(g(:,3));
            g(:,1:3) = g(:,1:3)-min(g(:,1:3));
            
            %c(1) = c(1)+max(g(:,1))/2;
            %c(2) = c(2)+max(g(:,1))/2;
            % vectors luminaire center to surface patches
            dosx = csx-c(1);
            dosy = csy-c(2);
            dosz = csz-c(3);
            % vecors from patch centers to luminaire
            dcsx = -dosx;
            dcsy = -dosy;
            dcsz = -dosz;
            % luminance to patch distance
            R = sqrt(sum([dosx dosy dosz].^2,2));
            
            % wall normals
            normal = surfaces{s}.normal;
            %sn(1,1,:) = normal;
            snormal = repmat(normal,size(csx,1),size(csx,2));
            
            % luminaire max dimension
            lumrotM = rotMatrix(luminaires{lum}.rotation);
            dim = max(diff(luminaires{lum}.geometry{1}(:,1:3))*lumrotM);
            mdim = max(dim(1:3));
            
            % check distance - dimension ratio criterion
            disdimratio = R./mdim;
            tol = 5;
            N = max(ceil(tol./(R./dim(1))));
            M = max(ceil(tol./(R./dim(2))));
            if isequal(mod(N,2),0)
                N = N+1;
            end
            if isequal(mod(M,2),0)
                M = M+1;
            end
            % max 25 sub luminai
            if M>25
                M = 25;
            end
            if N>25
                N = 25;
            end

            % if disdimratio criterion is violated - use replacement
            % luminaires - same LDC but more point sources
            if sum(disdimratio<tol)>0
                %lumrep = 1;
                [xgrid,ygrid] = DINgrid(dim(1),dim(2),0,'12464',[N M]);
                lumrep = cell(1,N*M);
                lumrepcoord =  [xgrid(:) ygrid(:) zeros(size(xgrid(:)))];
                lumrepcoord(:,1) = lumrepcoord(:,1)-dim(1)/2;
                lumrepcoord(:,2) = lumrepcoord(:,2)-dim(2)/2;
                lumreprotM = rotMatrix(luminaires{lum}.rotation);
                lumrepcoord = (lumreprotM*lumrepcoord')';
                for numb = 1:N*M
                    lumrep{numb} = luminaires{lum};
                    lumrep{numb}.geometry{1} = [0 0 0 0 0 0;0 0 0 0 0 0];
                    lumrep{numb}.coordinates = lumrep{numb}.coordinates + lumrepcoord(numb,:);
                    lumrep{numb}.dimming = luminaires{lum}.dimming/(N*M);
                end
            else
                %lumrep = 0;
                lumrep = {luminaires{lum}};
            end
            
            % other wall normals
            %onormal = luminaires{lum}.normal;
            %osn(1,1,:) = onormal;
            %onormal = repmat(onormal,size(csx,1),size(csx,2));
            
            % emission angle matrices
            %ang1 = acosd(dot([dosx, dosy, dosz], onormal,2)./sqrt(sum(onormal.^2,2))./sqrt(sum([dosx,dosy,dosz].^2,2)));
            %CSPHI = abs(pi/2 - acos(dot([dcsx, dcsy, dcsz], snormal,2)./sqrt(sum(snormal.^2,2))./sqrt(sum([dcsx,dcsy,dcsz].^2,2))));
            
            % loop over luminaire replacements
            for lumnum = 1:size(lumrep,2)
                
                c = lumrep{lumnum}.coordinates;
                g = lumrep{lumnum}.geometry{1};
                g = g(:,[1 2 3 6]);
                g(:,4) = g(:,4)-min(g(:,3));
                g(:,1:3) = g(:,1:3)-min(g(:,1:3));
                
                %c(1) = c(1)+max(g(:,1))/2;
                %c(2) = c(2)+max(g(:,1))/2;
                % vectors luminaire center to surface patches
                dosx = csx-c(1);
                dosy = csy-c(2);
                dosz = csz-c(3);
                % vectors from patch centers to luminaire
                dcsx = -dosx;
                dcsy = -dosy;
                dcsz = -dosz;
                % luminance to patch distance
                R = sqrt(sum([dosx dosy dosz].^2,2));
                
                % incidence angle matrices in degree
                %ang1 = acosd(dot([dosx, dosy, dosz], onormal,2)./sqrt(sum([dosx,dosy,dosz].^2,2)));
                ang2 = abs(90 - acosd(dot([dcsx, dcsy, dcsz], snormal,2)./sqrt(sum([dcsx,dcsy,dcsz].^2,2))));
                
                % patch visibility matrix
                vis = zeros(size(ang2));
                vis(ang2<=90 & ang2>0) = 1;
                % vector with all surfaces except actual two surfaces
                %n = 1:numel(surfaces);
                %n([s lum]) = [];
                
                % 2nd visibility matrix (blocked by other surface)
                VIS = ones(size(vis));
                
                % vector with all surfaces except actual two surfaces
                n = 1:numel(surfaces);
                n(s) = [];
                % check if other surfaces block line of sight
                for nb = n
                    
                    if strcmp(surfaces{nb}.type,'luminaire')
                        continue
                    end
                    
                    
                    % plane - line intersection
                    % https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
                    
                    % size of patches matrix
                    [s1,s2] = size(dosx);
                    % normal vector
                    normal = surfaces{nb}.normal;
                    normal = repmat(normal,s1,s2);
                    % point in plane
                    q = surfaces{nb}.vertices(1,:);
                    % p-matrix
                    %p = dot(normal,cat(3,osx,osy,osz)-repmat(cat(3,q(1),q(2),q(3)),s1,s2,1),3);
                    p = dot(normal,repmat(c,s1,s2)-repmat(q,s1,s2),2);
                    % r-matrix
                    r = dot(normal,[dosx,dosy,dosz],2);
                    % parameter a
                    a = -p./r;
                    % clear some memory
                    clearvars p q r
                    % intersection point
                    I = repmat(c,s1,s2) + repmat(a,1,3).*[dosx,dosy,dosz];
                    
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
                    A = I(:,1);
                    B = I(:,2);
                    C = I(:,3);
                    % rearrange data structure and rotate intersection plane
                    rip = (R1*R2*[A(:) B(:) C(:)]')';
                    % rotate blocking surface vertices
                    polyg = (R1*R2*surfaces{nb}.vertices')';
                    % check if intersection point is inside surface polygon
                    in = inpolygon(rip(:,2),rip(:,3),polyg(:,2),polyg(:,3));
                    %in = reshape(in,size(vis));
                    % ensure intersection point lies between surface 1 and surface 2
                    in(a>1|a<0) = 0;
                    % update 2nd visibility matrix
                    VIS(in) = 0;
                    
                    % debugging plots
                    %{
                         d = surfaces{s}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         hold on
                         d = surfaces{os}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         d = surfaces{nb}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         plot3(A(in),B(in),C(in),'.')
                         dummy = 1
                    %}
                end
                % update visibility matrix
                vis = vis & VIS;
                
                % luminaire rotation in rad
                [~,Lum_el] = cart2sph(lumrep{lumnum}.normal(1),lumrep{lumnum}.normal(2),lumrep{lumnum}.normal(3));
                Lum_az = lumrep{lumnum}.rotation(3);
                % luminaire rotation in degree
                %Lum_az = rad2deg(Lum_az);
                if Lum_az<0
                    Lum_az = 360-Lum_az;
                end
                Lum_el = rad2deg(Lum_el)+90;
                % angles from luminaire to patches
                [Iaz,Iel] = cart2sph(dosx,dosy,dosz);
                Iaz = rad2deg(Iaz);
                % adjust to luminaire rotation
                Iaz = Iaz + Lum_az;
                while sum(Iaz<0)>0
                    Iaz(Iaz<0) = 360+Iaz(Iaz<0);
                end
                while sum(Iaz>360)>0
                    Iaz(Iaz>360) = Iaz(Iaz>360)-360;
                end
                Iel = rad2deg(Iel);
                % ensure azimuth angles are within data grid
                if isempty(lumrep{lumnum}.ldt)
                    continue
                end
                Iaz(Iaz>max(lumrep{lumnum}.ldt.anglesC(:))) = 360-Iaz(Iaz>max(lumrep{lumnum}.ldt.anglesC(:)));
                Iel = Iel + Lum_el;
                while sum(Iel<-90)
                    Iel(Iel<-90) = -180+abs(Iel(Iel<-90));
                end
                while sum(Iel>90)
                    Iel(Iel>90) = 180-Iel(Iel>90);
                end
                % interpolate the luminaire's light intensities for patch angles
                Cangle = lumrep{lumnum}.ldt.anglesC;
                Gangle = lumrep{lumnum}.ldt.anglesG-90;
                Iangle = lumrep{lumnum}.ldt.I;
                I = griddata(Cangle,Gangle,Iangle,Iaz,Iel,'cubic');
                I = I.*lumrep{lumnum}.dimming;
                I(isnan(I)) = 0;
                
                %{
                comeback('luminaire I...')
                figure(2)
                
                h = sind(lumrep{lumnum}.ldt.anglesG).*lumrep{lumnum}.ldt.I.*lumrep{lumnum}.dimming;
                X = cosd(lumrep{lumnum}.ldt.anglesC).*h;
                Y = sind(lumrep{lumnum}.ldt.anglesC).*h;
                Z = -cosd(lumrep{lumnum}.ldt.anglesG).*lumrep{lumnum}.ldt.I.*lumrep{lumnum}.dimming;
                
                h = sind(Iel).*I;
                x = cosd(Iaz).*h;
                y = sind(Iaz).*h;
                z = -cosd(Iel).*I;
                
                %Ie = sqrt(x.^2+y.^2+z.^2);
                
                surf(X,Y,Z,'EdgeColor',[0.5 1 0.5],'FaceColor','none')
                hold on
                plot3(X,Y,Z,'y.')
                plot3(x,y,z,'r.')
                axis equal
                grid on
                hold off
                dummy = 1;
                %}
                %comeback('test luminaire rep position')
                %[lum lumnum Iaz(1) Iel(1) I(1) c]
                
                lumlam = luminaires{lum}.lambda;
                % lambda parity
                lamstart = max([surfacelam(1) lumlam(1)]);
                lamend   = min([surfacelam(end) lumlam(end)]);
                % luminaire lambda start & stop
                %first = find(lumlam==lamstart);
                %last  = find(lumlam==lamend);
                
                % indices
                %wallind = find(surfaces{lum}.material.data(1,:)==lamstep);
                %lumind  = find(lumlam==lamstep);
                
                % create factors to adjust luminaire spectrum to light intensity
                spec = luminaires{lum}.spectrum.data(2,:);
                lambda = luminaires{lum}.spectrum.data(1,:);
                specY = ciespec2Y(lambda,spec);
                f = repmat(I./specY,1,size(spec,2));
                % adjust luminaire spectrum to light intensities
                lumspec = repmat(spec,size(I,1),1).*f;
                
                
                % loop over spectrum
                ind = 1;
                for lamstep = lamstart:lstep:lamend
                    
                    % cancel check
                    if getappdata(wbh,'canceling')
                        break
                    end
                    
                    lumidx = lumlam==lamstep;
                    % irradiance
                    E = vis.* lumspec(:,lumidx).*(sind(ang2))./(R.^2).*ACS;
                    E(isnan(E)) = 0;
                    % radiance
                    %L = E.*room{r}.walls{wall}.material.data(2,wallind);
                    
                    % save results
                    result{s}.E{1}(:,ind) = result{s}.E{1}(:,ind) + E;
                    
                    % increase index
                    ind = ind+1;
                end
            end
            
            % spectrum
            result{s}.lambda = lamstart:lstep:lamend;
            
        end
        
        
        % SI units E_e & L_e
        try
            idx = ismember(surfaces{s}.material.data(1,:),LAMBDA);
            result{s}.E{1} = result{s}.E{1}./surfaces{s}.mesh.patch_area;
            result{s}.E{1}(isnan(result{s}.E{1})) = 0;
            result{s}.E{1}(isinf(result{s}.E{1})) = 0;
            result{s}.L{1} = result{s}.E{1}.*surfaces{s}.material.data(2,idx)./(pi);
        catch me
            catcher(me)
        end
        % end wall loop
    end
    
    
    % test for result, if not available set to zero
    for test = 1:numel(surfaces)
        if isempty(result{test}.E{1})
            %idx = ismember(surfaces{test}.material.data(1,:),surfacelam);
            result{test}.E{1} = zeros(size(surfaces{test}.mesh.patch_area,1),size(lamstart:lstep:lamend,2));
            result{test}.L{1} = zeros(size(surfaces{test}.mesh.patch_area,1),size(lamstart:lstep:lamend,2));
            result{test}.lambda = zeros(size(lamstart:lstep:lamend));
        end
    end
    
    % PART 2.3 - REFLECTION SIMULATION
    
    for refl = 1:reflections
        if getappdata(wbh,'canceling')
            break
        end
        
        % simulation surface loop
        for s = 1:numel(surfaces)
            if getappdata(wbh,'canceling')
                break
            end
            
            waitbar(step / steps,wbh,['Reflection: ',num2str(refl),'/',num2str(reflections),' - surface: ',num2str(s),'/',num2str(numel(surfaces))]);
            step = step + 1;
            
            if strcmp(surfaces{s}.type,'window')
                continue
            end
            
            % loop over other walls in room
            othersurfaces = 1:numel(surfaces);
            othersurfaces(s) = [];
            
            % initialize E and L values
            result{s}.E{refl+1} = zeros(size(result{s}.E{1}));
            result{s}.L{refl+1} = zeros(size(result{s}.E{1}));
            
            for os = othersurfaces % other walls in room
                if getappdata(wbh,'canceling')
                    break
                end
                
                if strcmp(surfaces{os}.type,'window')
                    continue
                end
                
                % wall coordinate matrices
                csx = repmat(surfaces{s}.mesh.patchcenter(:,1),1,size(surfaces{os}.mesh.patchcenter,1));
                csy = repmat(surfaces{s}.mesh.patchcenter(:,2),1,size(surfaces{os}.mesh.patchcenter,1));
                csz = repmat(surfaces{s}.mesh.patchcenter(:,3),1,size(surfaces{os}.mesh.patchcenter,1));
                
                osx = repmat(surfaces{os}.mesh.patchcenter(:,1),1,size(surfaces{s}.mesh.patchcenter,1))';
                osy = repmat(surfaces{os}.mesh.patchcenter(:,2),1,size(surfaces{s}.mesh.patchcenter,1))';
                osz = repmat(surfaces{os}.mesh.patchcenter(:,3),1,size(surfaces{s}.mesh.patchcenter,1))';
                
                % delta coordinate matrices
                dcsx = osx-csx;
                dcsy = osy-csy;
                dcsz = osz-csz;
                
                dosx = csx-osx;
                dosy = csy-osy;
                dosz = csz-osz;
                
                % wall normal
                normal = surfaces{s}.normal;
                sn(1,1,:) = normal;
                snormal = repmat(sn,size(csx,1),size(csx,2));
                
                % other wall normal
                onormal = surfaces{os}.normal;
                osn(1,1,:) = onormal;
                onormal = repmat(osn,size(csx,1),size(csx,2));
                
                % Angles matrices: line to/from patch
                %OSPHI = abs(90 - acosd(dot(cat(3,dosx, dosy, dosz), onormal,3)./sqrt(sum(cat(3,dosx,dosy,dosz).^2,3))));
                %CSPHI = abs(90 - acosd(dot(cat(3,dcsx, dcsy, dcsz), snormal,3)./sqrt(sum(cat(3,dcsx,dcsy,dcsz).^2,3))));
                % distance matrix: rows current wall, columns other wall
                DIS = sqrt(dcsx.^2 + dcsy.^2 + dcsz.^2);
                
                % area matrices
                ACS = repmat(surfaces{s}.mesh.patch_area,1,size(surfaces{os}.mesh.patch_area,1));
                AOS = repmat(surfaces{os}.mesh.patch_area,1,size(surfaces{s}.mesh.patch_area,1))';
                
                % correction factor for edge patches, patches are simplified as circles
                v = DIS./sqrt(abs(AOS./pi));
                f = ones(size(AOS));
                tol = 2.5;
                f(v<tol) = 1./(1+(1./v(v<tol)));
                 
                % emission angle matrix in degree
                ang1 = acosd(dot(cat(3,dosx, dosy, dosz), onormal,3)./sqrt(sum(cat(3,dosx,dosy,dosz).^2,3)));
                % incidence angle matrix in degree
                ang2 = acosd(dot(cat(3,dcsx, dcsy, dcsz), snormal,3)./sqrt(sum(cat(3,dcsx,dcsy,dcsz).^2,3)));
                
                % visibility
                vis = visibility(surfaces,s,os,ang1,ang2,osx,osy,osz,dosx,dosy,dosz);
                %
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
                        [bs1,bs2] = size(surfaces{nb}.blank{b}.vertices);
                        [os1,os2] = size(surfaces{os}.vertices);
                        if bs1==os1 && bs2==os2
                            if sum(sum(surfaces{nb}.blank{b}.vertices == surfaces{os}.vertices)) == s1*s2
                                abort = 1;
                            end
                        end
                    end
                    if abort
                        continue
                    end
                    
                    % plane - line intersection
                    % https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
                    
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
                            rotax = cross(normal,[0 0 1]);
                            R1 = rotMatrix([0 rad2deg(-elevation) 0]);
                            
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
                    % rearange data structure and rotate intersection plane
                    rip = (R1*R2*[A(:) B(:) C(:)]')';
                    % rotate blocking surface vertices
                    polyg = (R1*R2*surfaces{nb}.vertices')';
                    polyg = unique(polyg,'rows','stable');
                    % check if intersection point is inside surface polygon
                    in = inpolygon(rip(:,2),rip(:,3),polyg(:,2),polyg(:,3));
                    in = reshape(in,size(vis));
                    % ensure intersection point lies between surface 1 and surface 2
                    in(a>1|a<0) = 0;
                    % update 2nd visibility matrix
                    VIS(in) = 0;
                    
                    % debugging plots
                    %{
                         d = surfaces{s}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         hold on
                         d = surfaces{os}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         d = surfaces{nb}.vertices;
                         plot3(d(:,1),d(:,2),d(:,3))
                         plot3(A(in),B(in),C(in),'.')
                         dummy = 1
                    %}
                end
                % update visibility matrix
                vis = vis & VIS;
                %}
                
                %{
                comeback('vis check')
                vischeck = size(vis,1)*size(vis,2)-sum(sum(vis));
                if ~isequal(vischeck,0)
                   dummy = 1; 
                end
                %}
                
                % loop over spectrum
                ind = 1;
                for lamstep = lamstart:lstep:lamend
                    % check canceling
                    if getappdata(wbh,'canceling')
                        break
                    end
                    
                    % wall spectral index
                    %wallind = find(surfacelam==lamstep);
                    
                    % luminances of other wall patches...
                    OL = repmat(result{os}.L{refl}(:,ind)',size(ACS,1),1);
                    
                    % irradiance
                    if ~isequal(size(surfaces{os}.vertices,1),3)
                        E = sum(vis.*OL.*f.*ACS.*(cosd(ang2)).*AOS.*(cosd(ang1))./DIS.^2 ,2);
                    else
                        E = zeros(size(result{s}.E{refl+1}(:,ind)));
                    end
                    %check = sum(sum(E));
                    %if isnan(check)
                    %    dummy = 1;
                    %end
                    try
                        % save results
                        result{s}.E{refl+1}(:,ind) = result{s}.E{refl+1}(:,ind) + E;
                        %room{r}.results{s}.walls{wall}.L{refl+1}(:,ind) = room{r}.results{s}.walls{wall}.L{refl+1}(:,ind) + L;
                        
                    catch me
                        catcher(me)
                    end
                    
                    % increase index
                    ind = ind+1;
                    
                end
                % end of other wall loop
            end
            % SI lx and cd/m^2
            
            %wallstart = find(surfacelam==lamstart);
            %wallend = find(surfacelam==lamend);
            idx = ismember(surfaces{s}.material.data(1,:),LAMBDA);
            result{s}.E{refl+1} = result{s}.E{refl+1}./surfaces{s}.mesh.patch_area;
            %try
            result{s}.L{refl+1} = result{s}.E{refl+1}.*surfaces{s}.material.data(2,idx)./(pi);
            %catch
            %    dummy = 1
            %end
            result{s}.lambda = lamstart:lstep:lamend;
            %room{r}.results{s}.walls{wall}.E{refl+1} = room{r}.results{s}.walls{wall}.E{refl+1}./room{r}.walls{wall}.mesh.patch_area;
            %room{r}.results{s}.walls{wall}.L{refl+1} = room{r}.results{s}.walls{wall}.L{refl+1}./room{r}.walls{wall}.mesh.patch_area;
            
            result{s}.E{refl+1}(isnan(result{s}.E{refl+1})) = 0;
            result{s}.E{refl+1}(isinf(result{s}.E{refl+1})) = 0;
            
            result{s}.L{refl+1}(isnan(result{s}.L{refl+1})) = 0;
            result{s}.L{refl+1}(isinf(result{s}.L{refl+1})) = 0;
            % end of wall loop
        end
        
        
        
        %waitbar(step / steps,wbh,['Calculating: ',room{r}.name]);
        %step = step + 1;
        
        % cancel check
        %if getappdata(wbh,'canceling')
        %    break
        %end
        
        % end room reflection loop
    end
    
    
    %waitbar(step / steps,wbh,'Radiosity calculation finished.');
    
    % sum up E and L results
    maxL = 0;
    minL = inf;
    maxE = 0;
    minE = inf;
    % loop over skies
    %for s = 1:size(sky,2)
    % loop over rooms
    %for r = 1:size(room,2)
    % loop over walls
    for s = 1:numel(surfaces)
        % try to sum up
        try
            L = zeros(size(result{s}.L{1}));
            E = zeros(size(result{s}.L{1}));
            % loop over reflections
            for ref = 1:size(result{s}.E,2)
                %L = L + result{s}.L{ref};
                E = E + result{s}.E{ref};
            end
            %E = E + room{r}.results{s}.walls{wall}.E{1};
            %E = E./room{r}.walls{wall}.mesh.patch_area;
            %E(isnan(E)) = 0;
            %E(isinf(E)) = 0;
            
            %L = E.* room{r}.walls{wall}.material.data(2,lamstart:lstep:lamend);
            %L = L + room{r}.results{s}.walls{wall}.L{1};
            %L = L./room{r}.walls{wall}.mesh.patch_area;
            %L(isnan(L)) = 0;
            %L(isinf(L)) = 0;
            
            %room{r}.walls{wall}.L{s} = L;
            %wallstart = find(surfaces{s}.material.data(1,:)==lamstart);
            %wallend = find(surfaces{s}.material.data(1,:)==lamend);
            idx = ismember(surfaces{s}.material.data(1,:),LAMBDA);
            %surfaces{s}
            surfaces{s}.E = real(E);
            surfaces{s}.L = real(E.*surfaces{s}.material.data(2,idx)./pi);
            surfaces{s}.lambda = result{s}.lambda;
            
        catch me
            catcher(me)
        end
    end
    %end
    %end
    
    
    calculation = surfaces;
    
    
    % observer calculations
    %for r = 1:max(size(room))
    %for s = 1:max(size(sky))
    %try
    %    dummy = room{r}.results{s};
    %    clear dummy
    %catch
    %    room{r}.results{s} = [];
    %end
    %if ~isempty(room{r}.results{s})
    try
        for o = 1:numel(measurements)
            if getappdata(wbh,'canceling')
                break
            end

            
            step = step+1;
            waitbar(step / steps,wbh,['metric ',num2str(o),'/',num2str(numel(measurements))]);
            
            
            if strcmp(measurements{o}.type,'point') 
                measurements{o}.E = [];
                measurements{o}.L = [];
                measurements{o}.lambda = [];
                point = point_evaluation(measurements{o},surfaces,sky,ground,LAMBDA,information.nord_angle,TR,pnt,luminaires,0);
                measurements{o}.E = point.E;
                measurements{o}.lambda = point.lambda;
                %lam = intersect(ground.lambda,point.lambda);
                %idx = ground.lambda == lam;
                %measures{o}.DF = ciespec2Y(lam,point.E)./ciespec2Y(lam,ground.irradiance(idx));
                
            elseif strcmp(measurements{o}.type,'DF') 
                measurements{o}.E = [];
                measurements{o}.L = [];
                measurements{o}.lambda = [];
                point = point_evaluation(measurements{o},surfaces,sky,ground,LAMBDA,information.nord_angle,TR,pnt,luminaires,1);
                measurements{o}.E = point.E;
                measurements{o}.lambda = point.lambda;
                lam = intersect(ground.lambda,point.lambda);
                lam = intersect(lam,ground.lambda);
                idx = ismember(lam,ground.lambda);
                measurements{o}.DF = 100*ciespec2Y(lam,point.E)./ciespec2Y(lam,ground.irradiance(idx));
            
            elseif strcmp(measurements{o}.type,'area')
                Epoint = [];
                for n = 1:numel(measurements{o}.grid)
                    step = step+1;
                    waitbar(step / steps,wbh,['metric ',num2str(o),'/',num2str(numel(measurements))]);
          
                    measurements{o}.E = [];
                    measurements{o}.L = [];
                    measurements{o}.lambda = [];
                    point = point_evaluation(measurements{o}.grid{n},surfaces,sky,ground,LAMBDA,information.nord_angle,TR,pnt,luminaires,0);
                    Epoint = [Epoint; point.E];
                end
                measurements{o}.E = Epoint;
                measurements{o}.lambda = point.lambda;
                
            elseif strcmp(measurements{o}.type,'observer')
                
                measurements{o}.E = [];
                measurements{o}.J = [];
                measurements{o}.lambda = LAMBDA;
                
                %bookmark('delete waitbar for testing')
                %delete(wbh)
                
                %[E,J] = spatial_observer(surfaces,sky,luminaires,ground,information,measurements{o},TR,pnt,LAMBDA);
                IM = hyperspecfisheye(surfaces,sky,luminaires,ground,information,measurements{o},LAMBDA,500,180);
                
                %measurements{o}.E = E;
                %measurements{o}.J = J;
                measurements{o}.IM = IM;
                
            end

        end
    catch me
        catcher(me)
    end
    %end
    %end
    %end
    
    waitbar(step / steps,wbh,'Radiosity calculation finished.');
    
    % end of simulation try
catch ERROR
    % close waitbar
    delete(wbh)
    % show ERROR
    catcher(ERROR)
    result = surfaces;
end

% clear waitbar
try
    delete(wbh)
catch
end

% end of simulation function
end


% waitbar cancel / close button callback - sets canceling attribute to true
function button_callback
setappdata(hObject,'canceling',1);
end
