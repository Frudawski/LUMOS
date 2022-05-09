% luminaire radiant intensitiy I_e in observer direction

function [Iv,Ev] = ldc2IE(luminaires,observer)

% luminaire position
c = luminaires.coordinates;
g = luminaires.geometry{1};
g = g(:,[1 2 3 6]);
g(:,4) = g(:,4)-min(g(:,3));
g(:,1:3) = g(:,1:3)-min(g(:,1:3));

% vectors luminaire observer
dosx = observer.coordinates(1)-c(1);
dosy = observer.coordinates(2)-c(2);
dosz = observer.coordinates(3)-c(3);

% luminance to patch distance
R = sqrt(sum([dosx dosy dosz].^2,2));

% wall normals
normal = observer.normal;
%sn(1,1,:) = normal;
snormal = repmat(normal,size(observer.coordinates(1),1),size(observer.coordinates(1),2));

% luminaire max dimension
dim = max(diff(luminaires.geometry{1}));
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

% if disdimratio criterion is violated - use replacement
% luminaires - same LDC but more point sources
if sum(disdimratio<tol)>0
    %lumrep = 1;
    [xgrid,ygrid] = DINgrid(dim(1),dim(2),0,'12464',[N M]);
    lumrep = cell(1,N*M);
    lumrepcoord =  [xgrid(:) ygrid(:) zeros(size(xgrid(:)))];
    lumrepcoord(:,1) = lumrepcoord(:,1)-dim(1)/2;
    lumrepcoord(:,2) = lumrepcoord(:,2)-dim(2)/2;
    lumreprotM = rotMatrix(luminaires.rotation);
    lumrepcoord = lumrepcoord*lumreprotM;
    for numb = 1:N*M
        lumrep{numb} = luminaires;
        lumrep{numb}.geometry{1} = [0 0 0 0 0 0;0 0 0 0 0 0];
        lumrep{numb}.coordinates = lumrep{numb}.coordinates + lumrepcoord(numb,:);
        lumrep{numb}.dimming = luminaires.dimming/(N*M);
    end
else
    %lumrep = 0;
    lumrep = {luminaires};
end

Iv = 0;
Ev = 0;

% loop over luminaire replacements
for lumnum = 1:size(lumrep,2)
    
    c = lumrep{lumnum}.coordinates;
    g = lumrep{lumnum}.geometry{1};
    g = g(:,[1 2 3 6]);
    g(:,4) = g(:,4)-min(g(:,3));
    g(:,1:3) = g(:,1:3)-min(g(:,1:3));
    
    % vectors luminaire center to surface patches
    dosx = observer.coordinates(1)-c(1);
    dosy = observer.coordinates(2)-c(2);
    dosz = observer.coordinates(3)-c(3);
    % vectors from patch centers to luminaire
    dcsx = -dosx;
    dcsy = -dosy;
    dcsz = -dosz;
    % luminance to patch distance
    R = sqrt(sum([dosx dosy dosz].^2,2));
    
    % incidence angle matrices in degree
    ang2 = abs(90 - acosd(dot([dcsx, dcsy, dcsz], snormal,2)./sqrt(sum([dcsx,dcsy,dcsz].^2,2))));
    
    % patch visibility matrix
    vis = zeros(size(ang2));
    vis(ang2<=90 & ang2>0) = 1;
    
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
    Iv = Iv+I;
    E = I/(R.^2).*sind(ang2);
    Ev = Ev+E;
end



end




