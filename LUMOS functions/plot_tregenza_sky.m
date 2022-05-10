function plot_tregenza_sky(data,color,mode)

cla
colorbar('off')
legend off;

% indcator for color or bw plot
if color == 1
    plot_rgb = 1;
else
    plot_rgb = 0;
end

if size(L,1)<size(L,2)
    L = L';
end
clr = [L./max(L) L./max(L) L./max(L)];

% Tregenza table
tt = [1 30 6 12; 2 30 18 12; 3 24 30 15; 4 24 42 15; 5 18 54 20; 6 12 66 30; 7 6 78 60; 8 1 90 0];
% patch numbers and angles
% line 1: almucantars
% line 2: azimuths
% line 3: Patchnumber
pnt = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 66 66 66 66 66 66 66 66 66 66 66 66 78 78 78 78 78 78 90;180 192 204 216 228 240 252 264 276 288 300 312 324 336 348 0 12 24 36 48 60 72 84 96 108 120 132 144 156 168 168 156 144 132 120 108 96 84 72 60 48 36 24 12 0 348 336 324 312 300 288 276 264 252 240 228 216 204 192 180 180 195 210 225 240 255 270 285 300 315 330 345 0 15 30 45 60 75 90 105 120 135 150 165 165 150 135 120 105 90 75 60 45 30 15 0 345 330 315 300 285 270 255 240 225 210 195 180 180 200 220 240 260 280 300 320 340 0 20 40 60 80 100 120 140 160 150 120 90 60 30 0 330 300 270 240 210 180 180 240 300 0 60 120 NaN;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];

CLR = data.RGB;

r = 1;
els = 0;
hold on
if plot_rgb == 1
    clr = CLR;
end

% 3D mode
if strcmp(mode,'3D') == 1
    for al = 1:size(tt,1)-1
        % plot almucantar
        ps = tt(al,4)/2;
        for patch = 1:tt(al,2)
            az = -deg2rad([linspace(ps,ps+tt(al,4),50) linspace(ps+tt(al,4),ps,50) ps]-tt(al,4)-90);
            el = deg2rad([ones(1,50).*els ones(1,50).*(els+12) els]);
            [x,y,z] = sph2cart(az,el,r);
            % patchnumber
            pp = find(pnt(1,:)==tt(al,3));
            p  = find(pnt(2,pp)==ps-tt(al,4)/2);
            patchn = pnt(3,pp(p));
            if L(patchn)>0
                fill3(x,y,z,clr(patchn,:))
            else
                fill3(x,y,z,[1 0 0])
            end
            ps = ps+tt(al,4);
        end
        els = els + 12;
    end
    % zenith
    az = deg2rad(linspace(0,360,101));
    el = deg2rad(ones(1,101).*84);
    [x,y,z] = sph2cart(az,el,r);
    fill3(x,y,z,clr(patchn,:))
    title('sky')
    % set North South West East Markers
    text(0,100,0,'N','HorizontalAlignment','center','FontSize',12)
    text(0,-100,0,'S','HorizontalAlignment','center','FontSize',12)
    text(100,0,0,'E','HorizontalAlignment','center','FontSize',12)
    text(-100,0,0,'W','HorizontalAlignment','center','FontSize',12)
    
    % end mode 3D -> 2 D mode
elseif strcmp(mode,'2D') == 1
    r = 90;
    for al = 1:size(tt,1)-1
        % plot almucantar
        ps = tt(al,4)/2;
        for patch = 1:tt(al,2)
            az = -deg2rad([linspace(ps,ps+tt(al,4),50) linspace(ps+tt(al,4),ps,50) ps]-tt(al,4)-90);
            el = deg2rad([ones(1,50).*els ones(1,50).*(els+12) els]);
            [x,y] = pol2cart(az,[ones(1,50).*r ones(1,50).*(r-12) r]);
            % patchnumber
            pp = find(pnt(1,:)==tt(al,3));
            p  = find(pnt(2,pp)==ps-tt(al,4)/2);
            patchn = pnt(3,pp(p));
            if L(patchn)>0
                fill3(x,y,zeros(size(x)),clr(patchn,:))
                
            else
                fill3(x,y,zeros(size(x)),[1 0 0])
            end
            text(mean(x),mean(y),num2str(pp(p)),'FontSize',5,'HorizontalAlignment','center');
            hold on
            ps = ps+tt(al,4);
        end
        r = r-12;
    end
    % zenith
    az = deg2rad(linspace(0,360,101));
    patchn = 145;
    [x,y] = pol2cart(az,r);
    try
        fill3(x,y,zeros(size(x)),clr(patchn,:))
    catch
        fill3(x,y,zeros(size(x)),[1 0 0])
    end
    text(mean(x),mean(y),num2str(patchn),'FontSize',5,'HorizontalAlignment','center');
    
    title('')
    axis auto
    axis equal
    % set North South West East Markers
    text(0,100,'N','HorizontalAlignment','center','FontSize',12)
    text(0,-100,'S','HorizontalAlignment','center','FontSize',12)
    text(100,0,'E','HorizontalAlignment','center','FontSize',12)
    text(-100,0,'W','HorizontalAlignment','center','FontSize',12)
    
    % end of 2D mode -> explosion mode
elseif strcmp(mode,'explosion')
    
    %ax(1)=axes;
    %axis equal
    %axis off
    
    hold on
    width = 5;
    width = 90-width;
    axis([0 1 0 1 0 1])
    % normalize L
    f = L./max(L);
    r = 1;
    els = 6;
    hold on
    if plot_rgb == 1
        clr = CLR;
    end
    for al = 1:size(tt,1)-1
        % plot almucantar
        ps = 0;
        for patch = 1:tt(al,2)
            az = -deg2rad(ps-90);
            el = deg2rad(els);
            
            % patchnumber
            pp = find(pnt(1,:)==tt(al,3));
            p  = find(pnt(2,pp)==ps);
            patchn = pnt(3,pp(p));
            
            [x,y,z] = sph2cart(az,el,f(patchn));
            if L(patchn)>0 && ~isnan(clr(patchn,1))
                c = clr(patchn,:);
            else
                c = [1 0 0];
            end
            
            line = plot3([0 x],[0 y],[0 z],'-','Color',[0.35 0.35 0.35],'LineWidth',1);
            
            phi = deg2rad(linspace(0,360,101));
            theta = deg2rad(ones(1,101).*width);
            [x,y,z] = sph2cart(phi,theta,f(patchn));
            face = fill3(x,y,z,c);
            set(face,'EdgeColor',[0.35 0.35 0.35])
            rotate(face,[0 1 0],90-rad2deg(el),[0 0 0]);
            rotate(face,[0 0 1],rad2deg(az),[0 0 0]);
            
            ps = ps+tt(al,4);
        end
        els = els + 12;
    end
    % zenith
    az = deg2rad(0);
    el = deg2rad(90);
    [x,y,z] = sph2cart(az,el,f(145));
    line = plot3([0 x],[0 y],[0 z],'Color',[0.35 0.35 0.35]);
    
    phi = deg2rad(linspace(0,360,101));
    theta = deg2rad(ones(1,101).*width);
    [x,y,z] = sph2cart(phi,theta,f(145));
    face = fill3(x,y,z,c);
    set(face,'EdgeColor',[0.35 0.35 0.35])
    title('')
    axis  auto
    
    % set North arrow
    %plot3([0 0],[0 0.95],[0 0],'k')
    %plot3([-0.05 0 0.05],[0.90 0.95 0.90],[0 0 0],'k')
    %text(0,1.05,0,'N','HorizontalAlignment','center','FontSize',12)
    
    % GLOBUS 
    
    % circle
    a = axis;
    c = 10/1.5;
    
    width = max([abs(a(2)) abs(a(3))])*1.45/10;
    phi = deg2rad(linspace(0,360,101));
    theta = deg2rad(ones(1,101).*width);
    [x,y,z] = sph2cart(phi,theta,width);
    
    %ax(2)=axes;
    %axis equal
    %axis off
    %axis(a)
    %hold on
    
    g1 = plot3(x,y,z,'Color',[0.55 0.55 0.55],'LineWidth',0.5);
    g2 = plot3(x,y,z,'Color',[0.55 0.55 0.55],'LineWidth',0.5);
    g3 = plot3(x,y,z,'Color',[0.55 0.55 0.55],'LineWidth',0.5);
    rotate(g2,[0 1 0],90,[0 0 0]);
    rotate(g3,[1 0 0],90,[0 0 0]);
    g1.XData = g1.XData+width*c;
    g2.XData = g2.XData+width*c;
    g3.XData = g3.XData+width*c;
    g1.YData = g1.YData-width*c;
    g2.YData = g2.YData-width*c;
    g3.YData = g3.YData-width*c;
    [x,y,z] = sphere(50);
    globus = surf(x.*width+width*c, y.*width-width*c, z.*width);
    globus.EdgeColor = 'none';
    colormap(gray)
    %shading interp
    
    %set(globus, 'FaceColor', [0.9 0.9 0.9]);
    % Nord arrow
    f = 2;
    plot3([0 0]+width*c,[-f*width f*width]-width*c,[0 0],'Color',[0.55 0.55 0.55],'LineWidth',0.5)
    plot3([0 0]+width*c,[0 0]-width*c,[-f*width f*width],'Color',[0.55 0.55 0.55],'LineWidth',0.5)
    plot3([-f*width f*width]+width*c,[0 0]-width*c,[0 0],'Color',[0.55 0.55 0.55],'LineWidth',0.5)
    
    % arrowhead
    %{
    [x,y,z] = cylinder([1 0],50);
    z = z*1.5;
    x = x.*width/5;
    y = y.*width/5;
    z = z.*width/5;
    cyl = surf(x+width*c,y-width*c,z+f.*width);
    cyl.EdgeColor = 'none';
    set(cyl, 'FaceColor', [0.55 0.55 0.55]);

    cyl = surf(x,y,z);
    z = z*1.5;
    cyl.EdgeColor = 'none';
    set(cyl, 'FaceColor', [0.55 0.55 0.55]);
    rotate(cyl,[1 0 0],-90,[0 0 0]);
    cyl.XData = cyl.XData+width*c;
    cyl.YData = cyl.YData-width*c+f.*width;
    %}
    %{
    cyl = surf(x,y,z);
    cyl.EdgeColor = 'none';
    set(cyl, 'FaceColor', [0.35 0.35 0.35]);
    rotate(cyl,[0 1 0],90,[0 0 0]);
    cyl.XData = cyl.XData+width*10/2+f.*width;
    cyl.YData = cyl.YData-width*10/2;
    %}
    
    
    %camlight
    %light('Position',[1 0 0],'Style','infinite');
    
    text(width*c,-width*c+1.25*f.*width,0,'N','HorizontalAlignment','Center','VerticalAlignment','middle','Color',[0 0 0])
    text(width*c,-width*c,1.25*f.*width,'Z','HorizontalAlignment','Center','VerticalAlignment','middle','Color',[0 0 0])
    text(width*c,-width*c-1.25*f.*width,0,'S','HorizontalAlignment','Center','VerticalAlignment','middle','Color',[0 0 0])
    
    
    
end

hold off
axis equal
grid on
axis off


% end of function
end