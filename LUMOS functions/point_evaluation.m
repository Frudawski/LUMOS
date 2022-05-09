% evaluate measurement point in LUMOS
%
% Author: Frederic Rudawski
% Date: 16.05.2020, last edited: 14.02.2021

function point = point_evaluation(P,surfaces,sky,ground,lambda,nord_angle,TR,pnt,luminaires,DF)
% initialitze return value
point = [];
% point normal
%p.normal = [cosd(p.elevation)*cosd(p.azimuth+90) cosd(p.elevation)*sind(p.azimuth+90) sind(p.elevation)];

E = zeros(1,size(surfaces{1}.L,2));
% DAYLIGHT
% loop over surfaces
for s = 1:numel(surfaces)
    % other surfaces index
    o = 1:numel(surfaces);
    o = o(~(o==s));
    % patch visibility matrix, incidence angles, emission angles, distance R
    [vis,ina,ema,R] = pointVisibilityMatrix(P,surfaces{s},surfaces(o));
    
    % differentiate between surface and window
    
    if strcmp(surfaces{s}.type,'window')
        if ~isempty(sky)
            % sky lambda index
            sidx = ismember(sky.spectrum(1,:),lambda);
            % ground lambda index
            %midx = ismember(ground.lambda,lambda);
            % vector from point to window patches
            vec1 = surfaces{s}.mesh.patchcenter-P.coordinates;
            
            
            % azimuth and eleveation angles to window patch
            [a,e,~] = cart2sph(vec1(:,1),vec1(:,2),vec1(:,3));
            az = a./(pi/180)-90; % azimuth in degree
            el = e./(pi/180);    % elevation in degree
            
            % nord angle modification - clockwise
            az = az - nord_angle;
            az(az>=360) = az(az>=360)-360;
            az(az<0) = az(az<0)+360;
            
            % find corresponding sky patches
            patch = zeros(size(surfaces{s}.mesh.list,1),1);
            %comeback('sort sky patches over 145 nonsense 1')
            patch(el<0) = 146; % 146 = ground
            % almucantar loop
            for i = 1:size(TR,1)
                
                ind1 = el > TR(i,3)-6 & el <= TR(i,3)+6;
                center = 0;
                % azimuth loop
                if sum(sum(ind1)) > 0
                    for j = 1:TR(i,2)
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
            %comeback('check irradiance calculation I = L*A*cos(alpha)')
            widx = ismember(surfaces{s}.material.data(1,:),lambda);
            % window transmission angle dependend according to CIE
            % TR 171 sec 5.5
            if ~strcmp(surfaces{s}.material.name,'blank')
                % spectral factor: fresnel simplification by Schlick 1993, A Customizable Reflectance Model for Everyday Rendering
                %ang = abs(asind((sind(90-ema)./1.52)));
                %T1 = 1-(1-surfaces{s}.material.data(2,widx)+(surfaces{s}.material.data(2,widx).*(cosd(ema)).^5));
                R0 = 1-surfaces{s}.material.data(2,widx);
                T1 = 1-(R0+(1-R0).*(1-cosd(ema)).^5);

                % glazing factor: Littefair 1982, Effective glass transmission factors under a CIE sky
                % T2 = ...
                % glazing factor: Mitalas and Arseneault 1972, Fortran IV program to calculate absorption and transmission of thermal radiation by single and double-glazed windows
                % T2 = -0.028378 + 3.156075.*cosd(abs(ema))-3.058376.*cosd(abs(ema)).^2-1.428919.*cosd(abs(ema)).^3+4.014235.*cosd(abs(ema)).^4-1.775827.*cosd(abs(ema)).^5;
                
                T = T1./surfaces{s}.material.data(2,widx);
            else
                T = ones(size(ema,1),sum(widx));
            end
            
            %idx = patch==146;
            %grounddistance = zeros(size(el));
            %grounddistance(idx) = (ground.height+surfaces{s}.mesh.patchcenter(idx,3))./(sind(abs(el(idx))));
            
            % solid angle correction for external ground surface plane patches
            %om = (surfaces{s}.mesh.patch_area).*cosd(ema)./(R.^2);
            % external ground surface emission angle correction
            %gema = zeros(size(ema));
            %gema(idx) = 90-abs(el(idx));
            % external ground area
            %corf = ones(size(el))+(surfaces{s}.mesh.patch_area./(grounddistance+R)).^2;
            %surfaces{s}.mesh.patch_area(idx) = om(idx).*((grounddistance(idx)+R(idx)).^2)./(cosd(abs(ema(idx))));
            
            
            %comeback('ground luminance adaptation')
            % specral irradiance from sky
            ir = repmat(vis.*cosd(abs(ina)).*cosd(abs(ema))./((R).^2),1,size(surfaces{s}.L,2))...
                .*sky.spectrum(patch+1,sidx)...
                .*T...
                .*repmat(surfaces{s}.mesh.patch_area,1,sum(sidx))...
                .*repmat(surfaces{s}.material.data(2,widx),...
                size(surfaces{s}.mesh.patch_area,1),1);
            
            %S = sky.spectrum(patch+1,sidx);
            
            %ir(idx,:) = repmat(vis(idx).*cosd(abs(ina(idx))).*om(idx),1,size(surfaces{s}.L,2)).*...
            %    S(idx,:).*repmat(T(idx),1,sum(sidx));
            
            % ground patches
            % irradiance
            %grir = repmat(ground.radiance(sidx)./2./pi.*surfaces{s}.material.data(2,widx),size(vis,1),1) .* repmat(vis.*T.*(cosd(ina)).*(sind(abs(el)))./((grounddistance+R).^2), 1, sum(sidx));
            %ir(idx,:) = grir(idx,:);
            
            
            E = E+sum(ir);
            
        end
    else
        %if ~DF
            % spectral irradiance from surrounding surfaces
            %sum(ciespec2Y(360:10:830,surfaces{s}.L))
            % spectral irradiance
            %surfaces{s}
            ir = repmat(vis.*cosd(ina)./R.^2,1,size(surfaces{s}.L,2)).*surfaces{s}.L.*repmat(surfaces{s}.mesh.patch_area.*cosd(ema),1,size(surfaces{s}.L,2));
            %ir = repmat(vis.*cosd(ina)./R.^2,1,size(surfaces{s}.L,2)).*surfaces{s}.L.*repmat(cosd(ema),1,size(surfaces{s}.L,2));
            
            % integration over surfaces
            ir(isnan(ir)) = 0;
            E = E+sum(ir);
            %E
            %dummy = 1;
        %end
    end
end

% ARTIFICIAL LIGHT
% luminaire loop
if ~DF
    for lum = 1:numel(luminaires)
        c = luminaires{lum}.coordinates;
        g = luminaires{lum}.geometry{1};
        g = g(:,[1 2 3 6]);
        g(:,4) = g(:,4)-min(g(:,3));
        g(:,1:3) = g(:,1:3)-min(g(:,1:3));
        
        %c(1) = c(1)+max(g(:,1))/2;
        %c(2) = c(2)+max(g(:,1))/2;
        
        % vector: luminaire center to point
        pc = P.coordinates;
        dosx = pc(1)-c(1);
        dosy = pc(2)-c(2);
        dosz = pc(3)-c(3);
        % vector: point to luminaire center
        %dcsx = -dosx;
        %dcsy = -dosy;
        %dcsz = -dosz;
        % luminance to patch distance
        R = sqrt(sum([dosx dosy dosz].^2,2));
        
        % point normal
        pnormal = P.normal;
        % luminaire normal
        %lnormal = luminaires{lum}.normal;
        
        % luminaire max dimension
        dim = max(diff(luminaires{lum}.geometry{1}));
        mdim = max(dim(1:3));
        
        % check distance - dimension ratio criterion
        disdimratio = R./mdim;
        tol = 5;
        N = ceil(tol/(R/dim(1)));
        M = ceil(tol/(R/dim(2)));
        if ~isequal(mod(N,2),0)
            N = N+1;
        end
        if isequal(mod(M,2),0)
            M = M+1;
        end
        
        %N = 25;
        %M = 25;
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
            lumrepcoord = lumrepcoord*lumreprotM;
            for numb = 1:N*M
                lumrep{numb} = luminaires{lum};
                lumrep{numb}.geometry{1} = [0 0 0 0 0 0;0 0 0 0 0 0];
                lumrep{numb}.coordinates = lumrep{numb}.coordinates + lumrepcoord(numb,:);
                lumrep{numb}.dimming = luminaires{lum}.dimming/(N*M);
                %areasource = 1;
            end
        else
            %lumrep = 0;
            lumrep = {luminaires{lum}};
            %areasource = 0;
        end
        
        % loop over luminaire replacements
        for lumnum = 1:size(lumrep,2)
            
            c = lumrep{lumnum}.coordinates;
            g = lumrep{lumnum}.geometry{1};
            g = g(:,[1 2 3 6]);
            g(:,4) = g(:,4)-min(g(:,3));
            g(:,1:3) = g(:,1:3)-min(g(:,1:3));
            
            %c(1) = c(1)+max(g(:,1))/2;
            %c(2) = c(2)+max(g(:,1))/2;
            % vector: luminaire center to point
            pc = P.coordinates;
            dosx = pc(1)-c(1);
            dosy = pc(2)-c(2);
            dosz = pc(3)-c(3);
            % vector: point to luminaire center
            dcsx = -dosx;
            dcsy = -dosy;
            dcsz = -dosz;
            % luminance to patch distance
            R = sqrt(sum([dosx dosy dosz].^2,2));
            
            
            % emission angle
            %ang1 =  abs(90 - acosd(dot([dosx, dosy, dosz],lnormal)./sqrt(sum([dosx,dosy,dosz].^2))));
            % incidence angle
            ang2 = abs(90 - acosd(dot([dcsx, dcsy, dcsz], pnormal)./sqrt(sum([dcsx,dcsy,dcsz].^2))));
            %acosd(dot([dcsx, dcsy, dcsz], snormal,2)./sqrt(sum([dcsx,dcsy,dcsz].^2,2)));
            
            % patch visibility matrix
            vis = zeros(size(ang2));
            vis(ang2<=90 & ang2>0) = 1;
            % 2nd visibility matrix (blocked by other surface)
            VIS = ones(size(vis));
            % vector with all surfaces
            n = 1:numel(surfaces);
            % check if other surfaces block line of sight
            for nb = n
                
                if strcmp(surfaces{nb}.type,'luminaire')
                    continue
                end
                if strcmp(surfaces{nb}.type,'window')
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
                
            end
            % update visibility matrix
            vis = vis & VIS;
            
            % luminaire rotation in rad
            [~,Lum_el] = cart2sph(luminaires{lum}.normal(1),luminaires{lum}.normal(2),luminaires{lum}.normal(3));
            Lum_az = luminaires{lum}.rotation(3);
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
            while Iaz<0
                Iaz = Iaz+360;
            end
            while Iaz>360
                Iaz = Iaz-360;
            end
            Iel = rad2deg(Iel)+90;
            
            % ensure azimuth angles are within data grid
            Iaz(Iaz>max(lumrep{lumnum}.ldt.anglesC(:))) = 360-Iaz(Iaz>max(lumrep{lumnum}.ldt.anglesC(:)));
            Iel = Iel + Lum_el;
            % interpolate the luminaire's light intensities for patch angles
            Cangle = lumrep{lumnum}.ldt.anglesC;
            Gangle = lumrep{lumnum}.ldt.anglesG;
            Iangle = lumrep{lumnum}.ldt.I;
            I = griddata(Cangle,Gangle,Iangle,Iaz,Iel,'cubic');
            I = I.*lumrep{lumnum}.dimming;
            %[lumnum lumrep{lumnum}.coordinates]
            %[Iaz Iel I]
            
            %{
    comeback('luminaire I...')
    figure(2)
    
    h = sind(luminaires{lum}.ldt.anglesG).*luminaires{lum}.ldt.I.*luminaires{lum}.dimming;
    X = cosd(luminaires{lum}.ldt.anglesC).*h;
    Y = sind(luminaires{lum}.ldt.anglesC).*h;
    Z = -cosd(luminaires{lum}.ldt.anglesG).*lumrep{lumnum}.ldt.I.*lumrep{lumnum}.dimming;
    
    h = sind(Iel).*I;
    x = cosd(Iaz).*h;
    y = sind(Iaz).*h;
    z = -cosd(Iel).*I;
    
    %Ie = sqrt(x.^2+y.^2+z.^2);
    
    surf(X,Y,Z,'EdgeColor',[0.5 1 0.5],'FaceColor','none')
    hold on
    plot3(X,Y,Z,'y.')
    plot3(x,y,z,'r.')
    %axis equal
    grid on
    hold off
    dummy = 1;
            %}
            
            % create factors to adjust luminaire spectrum to light intensity
            spec = luminaires{lum}.spectrum.data(2,:);
            lumlam = luminaires{lum}.lambda;
            %lambda = luminaires{lum}.spectrum.data(1,:);
            specY = ciespec2Y(lumlam,spec);
            f = repmat(I./specY,1,size(spec,2));
            % adjust luminaire spectrum to light intensities
            lumspec = repmat(spec,size(I,1),1).*f;
            % lumnaire lambda
            lumlam = luminaires{lum}.lambda;
            lumidx = ismember(lumlam,lambda);
            % irradiance
            E = E + vis.* lumspec(:,lumidx).*(sind(ang2))./(R.^2);
            %E
            %dummy = 1;
            %ciespec2Y(lumlam(lumidx),E)
        end
    end
end

% point data
point.E = E;
%point.L = E./pi
point.lambda = lambda;
