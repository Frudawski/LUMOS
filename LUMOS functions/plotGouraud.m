function L = plotGouraud(surfaces,handle3D,handle2D,hide,vis,colour,cbar,ambient,sky,ground,pos)
% gouraud plot of luminance calculation

if ~exist('hide','var')
    hide = 1;
end
if ~exist('vis','var')
    vis = 1;
end
if ~exist('colour','var')
    colour = 'visual';
end
if ~exist('cbar','var')
    cbar = 1;
end
if ~exist('ambient','var')
    ambient = 0;
end
if ~exist('sky','var')
    sky = [];
end
if ~exist('ground','var')
    ground = [];
end
if ~exist('pos','var')
    pos = [0 0 0];
end
if vis
    axes(handle3D)
end
%figure
cla
set(gca,'SortMethod','depth');
%reset(handle3D)
legend off
colorbar off
axis off
title('')
% show rendering text
text(0.5,0.5,0.5,'rendering ...','HorizontalAlignment','center');
drawnow
cla

plot(NaN,NaN)
hold on

%set(gcf, 'Renderer', 'OpenGL');

% parameter for all faces
[L,lum,lumind,rgb,RGB,FaceNormal,VertexNormal,Vertices,Faces] = deal([]);

% Surfaces
for s = 1:numel(surfaces)
    if ~strcmp(surfaces{s}.type,'window')
        % patch points
        points = surfaces{s}.mesh.points;
        list = surfaces{s}.mesh.list;
        
        % face normal
        %if strcmp(surfaces{s}.type,'object')
            wn = surfaces{s}.normal;
        %else
        %    wn = surfaces{s}.normal;
        %end
        
        % collect data for plot
        FaceNormal = [FaceNormal;repmat(wn,size(surfaces{s}.mesh.list,1),1)];
        VertexNormal = [VertexNormal;repmat(wn,size(surfaces{s}.mesh.points,1),1)];
        Faces = [Faces;surfaces{s}.mesh.list+size(Vertices,1)];
        Vertices = [Vertices;surfaces{s}.mesh.points];
        
        % vertex color -> interpolated from patch color
        for v = 1:size(surfaces{s}.mesh.points,1)
            [idx,~] = find(surfaces{s}.mesh.list==v);
            switch colour
                case 'false-colours_E'
                    [vertex_xyz,vertex_L] = CIExyz(surfaces{s}.lambda,sum(surfaces{s}.E(idx,:),1)./numel(idx));
                case 'false-colours_L'
                    [vertex_xyz,vertex_L] = CIExyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                case 'visual'
                    [vertex_xyz,vertex_L] = CIExyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                case 'false-colours_sc'
                    vertex_xyz = ciespec2xyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                    vertex_L = ciespec2unit(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx),'sc');
                case 'false-colours_mc'
                    vertex_xyz = ciespec2xyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                    vertex_L = ciespec2unit(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx),'mc');
                case 'false-colours_lc'
                    vertex_xyz = ciespec2xyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                    vertex_L = ciespec2unit(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx),'lc');
                case 'false-colours_rh'
                    vertex_xyz = ciespec2xyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                    vertex_L = ciespec2unit(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx),'rh');
                case 'false-colours_mel'
                    vertex_xyz = ciespec2xyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
                    vertex_L = ciespec2unit(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx),'mel');
            end
            %[vertex_xyz,vertex_L] = CIExyz(surfaces{s}.lambda,sum(surfaces{s}.L(idx,:),1)./numel(idx));
            
            % bright luminaire appearance
            if strcmp(surfaces{s}.type,'luminaire')
                lumind = [lumind;(length(L)+1:length(L)+length(vertex_L))'];
            end
            
            L = [L;vertex_L];
            rgb = [rgb;xyz2srgb(vertex_xyz)];
            
            
        end
        try
            %xyz = CIExyz(surfaces{s}.lambda,surfaces{s}.L);
            %RGB = [RGB;xyz2srgb(xyz)];
            
        catch me
            catcher(me)
        end
        %
        % plot borders
        c = surfaces{s}.vertices;
        line('XData',c(:,1),'YData',c(:,2),'ZData',c(:,3),'Color','k');
        try
            for b = 1:numel(surfaces{s}.blank)
                c = surfaces{s}.blank{b}.vertices;
                line('XData',c(:,1),'YData',c(:,2),'ZData',c(:,3),'Color','k');
            end
        catch
        end
        %}
    end
end

if ambient
    
    % SKY
    
    % the vector clr is a 145 x 3 matrix containing the colors of the 145
    % Tregenza patches row-wise.
    
    % Tregenza table
    tt = [1 30 6 12; 2 30 18 12; 3 24 30 15; 4 24 42 15; 5 18 54 20; 6 12 66 30; 7 6 78 60; 8 1 90 0];
    % patch numbers and angles
    % line 1: almucantars
    % line 2: azimuths
    % line 3: Patchnumber
    pnt = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 66 66 66 66 66 66 66 66 66 66 66 66 78 78 78 78 78 78 90;180 192 204 216 228 240 252 264 276 288 300 312 324 336 348 0 12 24 36 48 60 72 84 96 108 120 132 144 156 168 168 156 144 132 120 108 96 84 72 60 48 36 24 12 0 348 336 324 312 300 288 276 264 252 240 228 216 204 192 180 180 195 210 225 240 255 270 285 300 315 330 345 0 15 30 45 60 75 90 105 120 135 150 165 165 150 135 120 105 90 75 60 45 30 15 0 345 330 315 300 285 270 255 240 225 210 195 180 180 200 220 240 260 280 300 320 340 0 20 40 60 80 100 120 140 160 150 120 90 60 30 0 330 300 270 240 210 180 180 240 300 0 60 120 NaN;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];
    %cla
    r = max(abs(Vertices(:)))*3;
    zoff = -0.01;
    els = 0;
    hold on

    try
    for al = 1:size(tt,1)-1
        % plot almucantar
        ps = tt(al,4)/2;
        for patchn = 1:tt(al,2)
            
            %az = deg2rad([linspace(ps,ps+tt(al,4),x) linspace(ps+tt(al,4),ps,x) ps]);
            %el = deg2rad([ones(1,x).*els ones(1,x).*(els+12) els]);

            % patchnumber
            pp = find(pnt(1,:)==tt(al,3));
            p2  = find(pnt(2,pp)==ps-tt(al,4)/2);
            patchn = pnt(3,pp(p2));
            
            %patch(x,y,z,clr(patchn,:),'EdgeColor','none')
                        
            az = deg2rad([ps ps+tt(al,4) ps+tt(al,4)]);
            el = deg2rad([tt(al,3)-6 tt(al,3)-6 tt(al,3)+6]);
            [x,y,z] = sph2cart(az,el,r);
            x = x+pos(1);
            y = y+pos(2);
            z = z+zoff;
            
            Faces = [Faces; size(Vertices,1)+1 size(Vertices,1)+2 size(Vertices,1)+3];
            Vertices = [Vertices; [x' y' z']];
                        
            az = deg2rad([ps ps ps+tt(al,4)]);
            el = deg2rad([tt(al,3)-6 tt(al,3)+6 tt(al,3)+6]);
            [x,y,z] = sph2cart(az,el,r);
            x = x+pos(1);
            y = y+pos(2);
            z = z+zoff;
            
            Faces = [Faces; size(Vertices,1)+1 size(Vertices,1)+2 size(Vertices,1)+3];
            Vertices = [Vertices; [x' y' z']];
            
            switch colour
                case 'false-colours_E'
                    L = [L;zeros(6,1)];
                case 'false-colours_L'
                    if ~isempty(sky)
                        L = [L;repmat(sky.L(patchn),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
                case 'visual'
                    if ~isempty(sky)
                        L = [L;repmat(sky.L(patchn),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
                case 'false-colours_sc'
                    if ~isempty(sky)
                        L = [L;repmat(ciespec2unit(sky.spectrum(1,:),sky.spectrum(patchn+1,:),'sc'),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
                case 'false-colours_mc'
                    if ~isempty(sky)
                        L = [L;repmat(ciespec2unit(sky.spectrum(1,:),sky.spectrum(patchn+1,:),'mc'),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
                case 'false-colours_lc'
                    if ~isempty(sky)
                        L = [L;repmat(ciespec2unit(sky.spectrum(1,:),sky.spectrum(patchn+1,:),'lc'),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
                case 'false-colours_rh'
                    if ~isempty(sky)
                        L = [L;repmat(ciespec2unit(sky.spectrum(1,:),sky.spectrum(patchn+1,:),'rh'),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
                case 'false-colours_mel'
                    if ~isempty(sky)
                        L = [L;repmat(ciespec2unit(sky.spectrum(1,:),sky.spectrum(patchn+1,:),'mel'),6,1)];
                    else
                        L = [L;zeros(6,1)];
                    end
            end
            try
               rgb = [rgb; repmat(sky.RGB(patchn,:),6,1)];
            catch
               rgb = [rgb; zeros(6,3)]; 
            end
            ps = ps+tt(al,4);
        end
        els = els + 12;
    end
    catch 
    end
    % zenith
    %{
    az = deg2rad(linspace(0,360,x+1));
    el = deg2rad(ones(1,x+1).*84);
    [x,y,z] = sph2cart(az,el,r);
    %patch(x,y,z,clr(patchn,:),'EdgeColor','none','FaceVertexCData',clr)
    Faces = [Faces; size(Vertices,1)+1 size(Vertices,1)+2 size(Vertices,1)+3];
    Vertices = [Vertices; [x' y' z']];
    L = [L;sky.L(patchn);sky.L(patchn);sky.L(patchn)];
    rgb = [rgb; sky.RGB(patchn,:); sky.RGB(patchn,:); sky.RGB(patchn,:)];
    %}
    
    % ground
    %patch([-50 50 50 -50],[-50 -50 50 50],[0 0 0 0],groundclr,'EdgeColor','none','FaceVertexCData',clr)

    % GROUND
    Faces = [Faces; size(Vertices,1)+1 size(Vertices,1)+2 size(Vertices,1)+3];
    x = 1.*[-r r r]+pos(1);
    y = 1.*[-r -r r]+pos(2);
    z = [zoff zoff zoff];
    Vertices = [Vertices; [x' y' z']];
    
    Faces = [Faces; size(Vertices,1)+1 size(Vertices,1)+2 size(Vertices,1)+3];
    x = 1.*[-r -r r]+pos(1);
    y = 1.*[-r r r]+pos(2);
    z = [zoff zoff zoff];
    Vertices = [Vertices; [x' y' z']];
    
    switch colour
        case 'visual'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'VL'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_L'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'VL'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_E'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.irradiance,'VL'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_sc'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'sc'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_mc'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'mc'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_lc'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'lc'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_rh'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'rh'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
        case 'false-colours_mel'
            if ~isempty(ground)
                L = [L;repmat(ciespec2unit(ground.lambda,ground.radiance,'mel'),6,1)];
            else
                L = [L;zeros(2,1)];
            end
    end
    try
        xyz = ciespec2xyz(ground.lambda,ground.radiance);
        srgb = xyz2srgb(xyz);
        rgb = [rgb; repmat(srgb,6,1)];
    catch
        rgb = [rgb; zeros(6,3)];
    end
    
end


%L(unique(lumind)) = max(L);
switch colour
    case 'visual'
        % luminance factor
        fa = (L./max(L)).*100;
        fa(fa>(24/116)^3) = (fa(fa>(24/116)^3)).^(1/3);
        fa(fa<=(24/116)^3) = (fa(fa<=(24/116)^3)).*841./108 + 16/116;
        L = 116.*fa-16;
        % gamma correctiom
        L = real((L./max(L)).^(1/2));
        % bright luminaire appearance
        L(unique(lumind)) = max(L);
        % white balancing
        wb = max(L)/max(mean(rgb(rgb~=0),'omitnan'));
        % ensure displayable color values
        col = (rgb.*L.*wb);
        col(col<0) = 0;
        col(col>1) = 1;
        col(isnan(col)) = 0;
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',col,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
    case 'false-colours_E'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        if cbar
            c = colorbar;
            unit = 'E in lx';
            c.Label.String = unit;
        end
        %cbar = copyobj(c);
    case 'false-colours_L'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        if cbar
            c = colorbar;
            unit = 'L in cd m^{-2}';
            c.Label.String = unit;
        end
    case 'false-colours_sc'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        if cbar
            c = colorbar;
            unit = 'L in cd m^{-2}';
            c.Label.String = unit;
        end
    case 'false-colours_mc'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        if cbar
            c = colorbar;
            unit = 'L in cd m^{-2}';
            c.Label.String = unit;
        end
    case 'false-colours_lc'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        if cbar
            c = colorbar;
            unit = 'L in cd m^{-2}';
            c.Label.String = unit;
        end
    case 'false-colours_rh'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        if cbar
            c = colorbar;
            unit = 'L in cd m^{-2}';
            c.Label.String = unit;
        end
    case 'false-colours_mel'
        col = colormap(parula(size(L,1)));
        % plot patches
        p = patch('Vertices',Vertices,'Faces',Faces,...
            'EdgeColor','none',...
            'FaceVertexCData',L.*1000,...
            'FaceNormals',FaceNormal,...
            'VertexNormals',VertexNormal,...
            'FaceColor','interp',...
            'BackFaceLighting','unlit',...
            'FacesMode','auto');
        
        if cbar
            c = colorbar;
            unit = 'L_{e,mel} in W m^{-2} sr-1}';
            c.Label.String = unit;
        end
end


%set(p,'HitTest','on','PickableParts','all','ButtonDownFcn',{@specplot,handle2D})


axis equal
axis off
view([315 30])
set(gca,'SortMethod','depth');
if hide
    % hide surfaces if normal points in viewing direction
    a = handle3D;
    pos = a.CameraPosition;
    target = a.CameraTarget;
    v = target-pos;
    v = v./norm(v);
    % get all patches
    o = findall(a,'Type','patch');
    % set patches visible
    %set(o,'FaceAlpha',1,'PickableParts','all')
    % get facenormals
    fn = get(o,'VertexNormals');
    % get angles between camera view vector and facenormals
    ang = rad2deg(abs(acos(fn*v')));
    vis = ang>90;
    % set patches invisible
    set(o,'FaceAlpha','interp','FaceVertexAlphaData',double(vis))
    
end

drawnow
hold off




%{
function specplot(~,eventdata,handle2D)
% try ploting spectrum of patch

room = getappdata(gcf,'room');
room = room{r};

%try
if wall(1) > 0
    % WALL CASE
    x = 0;
    for i=1:wall-1
        x = x+size(room.walls{i}.mesh.list,1);
    end
    number = eventdata.Source.CData - x;
    Lspec = room.walls{wall}.L{sky}(number,:);
    Espec = room.walls{wall}.E{sky}(number,:);
    
    [Lxyz,L] = CIExyz(room.walls{wall}.lambda{sky},Lspec);
    [Exyz,E] = CIExyz(room.walls{wall}.lambda{sky},Espec);
    
    %E = E/room.walls{wall}.mesh.patch_area(number);
    %L = L/room.walls{wall}.mesh.patch_area(number);
    
    Lcct = CCT('x',Lxyz(1),'y',Lxyz(2));
    Ecct = CCT('x',Exyz(1),'y',Exyz(2));
    
    % plot E and L spectrum
    axes(handle2D)
    spec_ploting(room.walls{wall}.lambda{sky}, Espec, Lspec, E, L, Ecct, Lcct, Exyz, Lxyz)
    
elseif wall(1) == 0
    % FLOOR CASE
    x = 0;
    for i=1:size(room.walls,2)
        x = x+size(room.walls{i}.mesh.list,1);
    end
    number = eventdata.Source.CData - x;
    
    Lspec = room.floor.L{sky}(number,:);
    Espec = room.floor.E{sky}(number,:);
    
    [Lxyz,L] = CIExyz(room.floor.lambda{sky},Lspec);
    [Exyz,E] = CIExyz(room.floor.lambda{sky},Espec);
    
    %E = E/room.floor.mesh.patch_area(number);
    %L = L/room.floor.mesh.patch_area(number);
    
    Lcct = CCT('x',Lxyz(1),'y',Lxyz(2));
    Ecct = CCT('x',Exyz(1),'y',Exyz(2));
    
    % plot E and L spectrum
    axes(handle2D)
    spec_ploting(room.floor.lambda{sky}, Espec, Lspec, E, L, Ecct, Lcct, Exyz, Lxyz)
    
elseif wall(1) == -1
    % CEILING CASE
    
    % number of patch
    x = size(room.floor.mesh.list,1);
    for i=1:max(size(room.walls))
        x = x+size(room.walls{i}.mesh.list,1);
    end
    c = wall(2);
    for j = 1:c-1
        x = x + size(room.ceiling{j}.mesh.list,1);
    end
    
    number = eventdata.Source.CData - x;
    
    Lspec = room.ceiling{c}.L{sky}(number,:);
    Espec = room.ceiling{c}.E{sky}(number,:);
    
    [Lxyz,L] = CIExyz(room.ceiling{c}.lambda{sky},Lspec);
    [Exyz,E] = CIExyz(room.ceiling{c}.lambda{sky},Espec);
    
    %E = E/room.ceiling{c}.mesh.patch_area(number);
    %L = L/room.ceiling{c}.mesh.patch_area(number);
    
    Lcct = CCT('x',Lxyz(1),'y',Lxyz(2));
    Ecct = CCT('x',Exyz(1),'y',Exyz(2));
    
    % plot E and L spectrum
    axes(handle2D)
    spec_ploting(room.ceiling{c}.lambda{sky}, Espec, Lspec, E, L, Ecct, Lcct, Exyz, Lxyz)
    
    
end
%catch ME
%    comeback('ERROR:')
%    ME
%end
%}
%{
function spec_ploting(lambda, Espec, Lspec, E, L, Ecct, Lcct, Exyz, Lxyz)
%figure
% plot E and L spectrum
if lambda(2)-lambda(1) == 1
    plot(lambda,Espec,lambda,Lspec)
elseif lambda(2)-lambda(1) > 1
    stairs(lambda,Espec)
    hold on
    stairs(lambda,Lspec)
    hold off
else
    plot(lambda,Espec,lambda,Lspec)
end

grid on
xlabel('\lambda in nm')
ylabel('E_{e,\lambda} in W/m^2/nm , L_{e,\lambda} in W/m^2/sr/nm')
a=axis;
axis([lambda(1) lambda(end) a(3) a(4)])
% legend
[~,hObj] = legend(['E_{e,\lambda}',10,'E = ',num2str(round(E)),' lx',10,'T_{c} = ',num2str(round(Ecct)),' K',10,'x = ',num2str(round(Exyz(1),4)),10,'y = ',num2str(round(Lxyz(2),4))],...
    ['L_{e,\lambda}',10,'L = ',num2str(round(L)),' cd/m^2',10,'T_{c} = ',num2str(round(Lcct)),' K',10,'x = ',num2str(round(Lxyz(1),4)),10,'y = ',num2str(round(Lxyz(2),4))],...
    'Location','northoutside','Orientation','horizontal');
legend('boxoff')
hL=findobj(hObj,'type','line');  % get the lines, not text
set(hL,'linewidth',3)            % set their width property

%}

