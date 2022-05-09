function plotChromaticityCIE1931(handles,surface,axh,input)
% based on a script

axes(axh)

lambda =surface.lambda;

% rotate in y-z axis
[vertices,blank,mesh] = yz_plane_rotation(surface);
mesh_coordinates = mesh.patchcenter;

fix = 0;
if (max(mesh_coordinates(:,2)) - min(mesh_coordinates(:,2))) < 1e-10
    mesh_coordinates(:,2) = mesh_coordinates(:,1)-min(mesh_coordinates(:,1));
    fix = 1;
end
% DIN EN 12464-1 point grid

%check = max(vertices(:,2))-min(vertices(:,2))>2 && max(vertices(:,3))-min(vertices(:,3))>2;
check = 0;
if check
    d = max(vertices(:,2))-min(vertices(:,2))-1;
    b = max(vertices(:,3))-min(vertices(:,3))-1;
else
    d = max(vertices(:,2))-min(vertices(:,2));
    b = max(vertices(:,3))-min(vertices(:,3));
end

d = round(d,12);
b = round(b,12);
p = 0.2*5^(log10(d));
p = real(p);

if p > 10
    p = 10;
end
dn = ceil(d/p);
if isequal(mod(dn,2),0)
    dn  = dn+1;
end
bn = ceil(b/p);
if isequal(mod(bn,2),0)
    bn = bn+1;
end
if d/dn > p
    dw = p;
else
    dw = d/dn;
end
if b/bn > p
    bw = p;
else
    bw = b/bn;
end

% interpolation grid
check = 0;
if check
    rgrid = linspace(0.5+dw/2,d+0.5-dw/2,dn);
    rgrid = [0.5 rgrid 0.5+d];
    zgrid = linspace(0.5+bw/2,b+0.5-bw/2,bn);
    zgrid = [0.5 zgrid 0.5+b];
else
    rgrid = linspace(dw/2,d-dw/2,dn);
    zgrid = linspace(bw/2,b-bw/2,bn);
end
[xq,yq] = meshgrid(rgrid,zgrid);


% data values
switch input
    case 'E'
        unit = 'spectral irradiance E_{e,\lambda} in W m^{-2} nm^{-1}';
        data = surface.E;
    case 'L'
        unit = 'spectral radiance L_{e,\lambda} in W m^{-2} sr^{-1} nm^{-1}';
        data = surface.L;
end



% allocate empty 3D matrix
if check
    value_inter = zeros((size(xq,1)-2),(size(xq,2)-2),size(data,2));
else
    value_inter = zeros((size(xq,1)),(size(xq,2)),size(data,2));
end
ind = 1;
for lam = 1:size(lambda,2)
    % interpolate spectra for grid points
    if check
        value_inter(:,:,lam) = griddata(mesh_coordinates(:,2),mesh_coordinates(:,3)',data(:,lam),rgrid(2:end-1)',zgrid(2:end-1));
    else
        value_inter(:,:,lam) = griddata(mesh_coordinates(:,2),mesh_coordinates(:,3)',data(:,lam),rgrid',zgrid);
        value_inter(:,:,lam) = fillmissing(value_inter(:,:,lam),'linear',2,'EndValues','nearest');
        value_inter(:,:,lam) = fillmissing(value_inter(:,:,lam),'linear',1,'EndValues','nearest');

    end
    ind = ind+1;
end

%if isequal(flip,0)%~isequal(size(xq,1),size(xq,2))
%    value_inter = fliplr(rot90(value_inter,1));
%end
%bookmark('chromaticity')
if contains(surface.name,'floor')
    rotn = 1;
    value_inter = rot90(value_inter,-rotn);
    value_inter = fliplr(value_inter);
    %a.View = [90 90];
elseif contains(surface.name,'wall')
    value_inter = fliplr(flipud(value_inter));
    rotn = 1;
    value_inter = rot90(value_inter,-rotn);
    %a.View = [180 90];
elseif contains(surface.name,'ceiling')
    rotn = 1;
    value_inter = rot90(value_inter,-rotn);
    value_inter = fliplr(value_inter);
    %a.View = [90 90];
elseif contains(surface.name,'object')
    rotn = 2;
end

% reshape matrix
data = [];
if check
    data = reshape(value_inter,(size(xq,1)-2)*(size(xq,2)-2),size(lambda,2));
else
    data = reshape(value_inter,(size(xq,1))*(size(xq,2)),size(lambda,2));
end
data(isnan(data)) = 0;

% blank areas?
try
    for w = 1:size(surface.blank,2)
        x = blank{w}.vertices(:,2);
        y = blank{w}.vertices(:,3);
        % erase points in windows from table
        %in = inpolygon(xq(2:end-1,2:end-1)',yq(2:end-1,2:end-1)',x,y);
        in = inpolygon(fliplr(xq),yq,x,y);
        in = in';
        data(in(:),:) = 0;
    end
catch
    % no blank areas
end


%comeback('CIE 1931 chromaticity')
[xyz,Yint] = CIExyz(lambda,data);
plot_x = xyz(:,1)';
plot_y = xyz(:,2)';
Tc = CCT('x',plot_x,'y',plot_y,'warning','off');

cie1931(plot_x,plot_y,'Planck','on','Marker','.','MarkerSize',10,'MarkerColor',[1 1 1])

%Tc = round(CCT('x',plot_x','y',plot_y));
data = [plot_x' plot_y' Tc' round(Yint,1)];
% set gui table
set(handles.topview_point_table,'Data',[]);
set(handles.topview_point_table,'ColumnName',{'x','y','CCT',input})
set(handles.topview_point_table,'RowName','numbered')
set(handles.topview_point_table,'ColumnEditable',false(1,4))
set(handles.topview_point_table,'Data',data);