% calculates a normal vector to the  wall plane and checks if the vector
% points inside the polygon volume.
%
% Author: Frederic Rudawski
% Date: 16.11.2017

function normal = wall_normal(polygon,wall,distance,plot_mode)

% disable inpolygon warning
id = 'MATLAB:inpolygon:ModelingWorldLower';
warning('off',id)


% wall coordinates
try
    wallx = wall.vertices(:,1);
    wally = wall.vertices(:,2);
    wallz = wall.vertices(:,3);
catch 
    % windows
    wallx = wall.data(:,1);
    wally = wall.data(:,2);
    wallz = wall.data(:,3);
end
% wall center point
xcenter = mean(unique(wallx,'rows'));
ycenter = mean(unique(wally,'rows'));
zcenter = mean(unique(wallz,'rows'));


% wall normal vector
try
    normal = cross(wall.vertices(1,:)-wall.vertices(2,:),wall.vertices(1,:)-wall.vertices(3,:));
catch
    % windows
    normal = cross(wall.data(1,:)-wall.data(2,:),wall.data(1,:)-wall.data(3,:));
end
% normalization of normal vector
normal = normal./norm(normal);

try 
    dummy = polygon.walls;
catch
    return
end

% room point list
points = [];

% check vector direction
checkx = 0;
checky = 0;
checkz = 0;
% test point = wall center + normal
p = [xcenter ycenter zcenter] + distance.*normal;
for w = 1:size(polygon.walls,2)
    points = polygon.walls{w}.vertices;
    % room x,y,z sections
    if inpolygon(p(2),p(3),points(:,2),points(:,3))
        checkx = 1;
    elseif inpolygon(p(1),p(3),points(:,1),points(:,3))
        checky = 1;
    elseif inpolygon(p(1),p(2),points(:,1),points(:,2))
        checkz = 1;
    end
end

% if point lies not in the 3 cut sections, the normal vector points in the
% wrong direction
if sum([checkx checky checkz]) < 3    
    normal = -normal;
    
    % check vector direction
    checkx = 0;
    checky = 0;
    checkz = 0;
    % test point = wall center + normal
    p = [xcenter ycenter zcenter] + distance.*normal;
    for w = 1:size(polygon.walls,2)
        %points = [points; polygon.walls{w}.vertices];
        points = polygon.walls{w}.vertices;
        % room x,y,z sections
        if inpolygon(p(2),p(3),points(:,2),points(:,3))
            checkx = 1;
        elseif inpolygon(p(1),p(3),points(:,1),points(:,3))
            checky = 1;
        elseif inpolygon(p(1),p(2),points(:,1),points(:,2))
            checkz = 1;
        end
        
        
        % Test plot
        %{
        try
            if plot_mode
                figure(1)
                subplot(2,2,1)
                fill3(points(:,1),points(:,2),points(:,3),[0.75 0.75 0.75])
                hold on
                title([num2str(checkx),' ',num2str(checky),' ',num2str(checkz)])
                axis equal
                subplot(2,2,2)
                fill(points(:,2),points(:,3),[0.75 0.75 0.75])
                hold on
                plot(ycenter+distance.*normal(2),zcenter+distance.*normal(3),'*')
                subplot(2,2,3)
                fill(points(:,1),points(:,3),[0.75 0.75 0.75])
                hold on
                plot(xcenter+distance.*normal(1),zcenter+distance.*normal(3),'*')
                subplot(2,2,4)
                fill(points(:,1),points(:,2),[0.75 0.75 0.75])
                hold on
                plot(xcenter+distance.*normal(1),ycenter+distance.*normal(2),'*')
            end
        catch
        end
        %}
        
    end
    
end

warning('on',id)

% end of function
end
