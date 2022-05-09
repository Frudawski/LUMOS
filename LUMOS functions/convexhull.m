% convexhull determines the points that form a convex hull polygon for a
% given point set. The result order is given clockwise.
%
% usage: ch = convexhull(xy)
% with xy as nx2 Matrix with x and y coordinates, if x and y vectors are
% given: ch = convexhull([x y])
%
% e.g.:
% xy = rand(50,2);
% ch = convexhull(xy);
% plot(xy(:,1),xy(:,2),'*r')
% hold on
% plot(xy(ch,1),xy(ch,2),'k')
%
% Author: Frederic Rudawski
% Date: 29.03.2019 


function plist = convexhull(c) 

% check number of points
if size(c,1)<3
    % minimum of three points needed for convex polygon
    error('Not enough points in input data.')
end
% find startpoint sp: utmost left coordinate = min(x)
[~,sp] = min(c(:,1));
p = c(sp,:);
% initialize new point: np = 0
np = 0;
% connect points until start point is reached again
index = 1;
% initialie convex hull point list
plist = sp;
% direction indicator: from left to right
fltr = 1;
% loop over convex hull vertices
while ~isequal(np,sp)
    % set np to sp in first loop
    if isequal(np,0)
        % set new point to start point
        np = sp;
    end
    % center to current point
    ps = c - p;
    % define tolerance to zero
    tol = 1e-10;
    % set values almost zero to zero
    ps(abs(ps)<tol) = 0;
    % calculate slope to all other points
    slope = ps(:,2)./ps(:,1);
    % when list has more than 1 entry: 
    if size(plist,1)>1
        % find points in convex hull list - except start point
        ex = unique(plist(2:end,:));
        % all points as a column vector, specially if only one entry is valid
        ex = ex(:);
        % exclude NaN value
        ex(isnan(ex)) = [];
        % if ex is not empty
        if ~isempty(ex)
            % exclude points already in convex hull list in slope
            slope(ex) = NaN;
        end
    end
    % check direction: left to right or right to left
    if isequal(fltr,1)
        % exclude points left from current point
        left = c(:,1)<p(1);
        slope(left) = NaN;
        % find max slope value
        ind = find(slope==max(slope));
        ind2 = [];
        for k = 1:size(ind)
           ind2 = [ind2;find(abs(slope-slope(ind(k)))<tol)];
        end
        ind = unique([ind;ind2]);
    else
        % exclude points right from current point
        right = c(:,1)>p(1);
        slope(right) = NaN;
        % set point slopes left from current point to negative
        neg = ps(:,1)<0;
        slope(neg) = slope(neg).*-1;
        % find max slope value
        ind = find(slope==min(slope));
        ind2 = [];
        for k = 1:size(ind)
           ind2 = [ind2;find(abs(slope-slope(ind(k)))<tol)];
        end
        ind = unique([ind;ind2]);
    end
    % create distance vector to current point with all entries as inf
    d = ones(size(slope)).*inf;
    % calculate distance for points with max slope
    d(ind) = sqrt(ps(ind,1).^2+ps(ind,2).^2);
    % find nearest point with maximum slope
    [~,np] = min(d);
    % increase convex hull list index
    index = index+1;
    % save current point to convex hull list
    plist(index,1) = np;
    % actualize current point
    p = c(np,:);
    % test if current point is utmost right point
    if isequal(c(np,1),max(c(:,1)))
        % change direction indicator
        fltr = 0;
    end
end
% delete last = first point from list
plist(end) = [];

