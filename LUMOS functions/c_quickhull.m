% quickhull 2D convexhull function using "divide and conquer" concept
%
% example:
% xy = rand(50,2);
% ch = c_quickhull(xy);
% plot(xy(:,1),xy(:,2),'*r')
% hold on
% plot(xy(ch,1),xy(ch,2),'k')
%
% Author: Frederic Rudawski
% Date: 07.05.2019 - edited: 22.04.2020, 21.12.2021
%
% Based on: Computational Geometry - Algorithms and Applications (2008),
% Mark de Berg and Otfried Cheong and Mark van Kreveld and Mark Overmars,
% Springer, 3rd Edition, DOI: 10.1007/978-3-540-77974-2,
% ISBN: 978-3-540-77973-5

function conh = c_quickhull(c)

% round to avoid errors
c = ltfround(c.*12^12)./12^12;

% look for convex hull - if not existing, create 2 point hull
% utmost left and right point
[~,p1] = min(c(:,1));
% test for min x values
[~,p2] = max(c(:,1));
% smallest 2 point convex hull
conh = [p1;p2;p1];

% recursiv quickhull call
try
    coder.varsize('conh');
catch
end
conh = requickhull(c,conh);

end


function conh = requickhull(c,conh)
try
    coder.varsize('nconh')
catch
end
% tolerance value
tol = 1e-10;
% loop over convex hull edges and look for additional points
v = 1;
while v < size(conh,1)

    % gradient
    g = (c(conh(v+1),2)-c(conh(v),2))/(c(conh(v+1),1)-c(conh(v),1));
    gy = ((c(:,1)-c(conh(v),1)).*g)+c(conh(v),2);
    
    % from left to right or from right to left
    if  (c(conh(v),1)-c(conh(v+1),1)) < 0
        % find points "on one side" from edge line
        ind = find(c(:,2)+tol >= gy);
        % remove convex hull points from candidates
        ind(ismember(ind,conh)) = [];
        % limit x range to triangle vertices
        xrange = c(ind,1) >= c(conh(v),1) & c(ind,1) <= c(conh(v+1),1);
    elseif isequal((c(conh(v),1)-c(conh(v+1),1)),0)
        % find points on y-line
        ind = find(isnan(gy));%find(c(:,2) <= gy);
        % remove convex hull points from candidates
        ind(ismember(ind,conh)) = [];
        %yrange = [c(conh(v+1),2) c(conh(v),2)];
        %cand = c(ind,2)>min(yrange) & c(ind,2)<max(yrange);
        [~,cand] = min(abs(c(ind,2)-c(conh(v),2)));
        xrange = logical(find(cand));
        if isempty(xrange)
            v = v+1;
            continue
        end
        P = ind(xrange);
        y1  =c(conh(v),2)-c(P,2);
        y2 = c(conh(v+1),2)-c(P,2);
        % check that point lies between the two considered points
        if ~isempty(xrange)
            if y1 > 0 && y2 > 0
                v = v+1;
                continue
            elseif y1 < 0 && y2 < 0
                v = v+1;
                continue
            end
        end
    else
        % find points "on one side" from edge line
        ind = find(c(:,2) <= gy);
        % remove conve hull points from candidates
        ind(ismember(ind,conh)) = [];
        % limit x range to triangle vertices
        xrange = c(ind,1) <= c(conh(v),1) & c(ind,1) >= c(conh(v+1),1);
    end
    ind = ind(xrange);
    % if points are found add a point to convex hull
    if ~isempty(ind)%size(ind,1)>2
        % varianz
        var = 1e-6;
        % triangle edges
        e1 = sqrt((c(ind,1)-var-c(conh(v),1)).^2 + (c(ind,2)-c(conh(v),2)).^2);
        e2 = sqrt((c(conh(v+1),1)-c(ind,1)-var).^2 + (c(conh(v+1),2)-c(ind,2)).^2);
        e3 = sqrt((c(conh(v),1)-c(conh(v+1),1)).^2 + (c(conh(v),2)-c(conh(v+1),2)).^2);
        % triangle areas - heron's formula
        s = (e1+e2+e3)./2;
        area = sqrt(real(s.*(s-e1).*(s-e2).*(s-e3)));
        % maximum area = point furthest away from current convex hull edge
        %i = area==max(area);
        [~,i] = max(area);
        ind = ind(i);
        % distance
        d = sqrt((c(ind,1)-c(conh(v),1)).^2 + (c(ind,2)-c(conh(v),2)).^2);
        [~,i] = max(d);
        % add point to convex hull
        conh = [conh(1:v);ind(i);conh(v+1:end)];
        % increase loop iteration index
        v = v+1;
        
        %figure(2)
        %test_plot(c,conh,ind)

        conh = requickhull(c,conh);
    end
    
    % increase loop iteration variable
    v = v+1;
    
end

% end of function
end


function test_plot(c,conh,ind)
% x and y coordinates
x = c(:,1);
y = c(:,2);
% plot
plot(x,y,'r*')
hold on
plot(x([conh;conh(1)]),y([conh;conh(1)]))
plot(c(ind,1),c(ind,2),'*b')
%plot(x(outside),y(outside),'b*')
for i = 1:size(x,1)
    text(x(i),y(i),num2str(i))
end
hold off
end
%}