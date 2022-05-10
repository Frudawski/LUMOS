% force edges in delaunaytri triangulation
%
% Author: Frederic Rudawski
% Date: 25.04.2019

function triang = force_edge(triang,edges)

% shorty
T = triang.ConnectivityList;

% loop over to be enforced edges
for i = 1:size(edges,1)
    % search for edge
    triNr = find(sum(T==edges(i,1) | T==edges(i,2),2)==2, 1);
    if isempty(triNr)
        % triangle candidates
        T1c = T(sum(T==edges(i,1),2)==1,:);
        T2c = T(sum(T==edges(i,2),2)==1,:);
        % triangles to be switched
        T1 = T1c(sum(ismember(T1c,T2c),2)==2,:);
        T2 = T2c(sum(ismember(T2c,T1c),2)==2,:);
        % triangle switch cases
        if isempty(T1) && isempty(T2) % more than two triangles to be switched
            %dummy = 1;
            % NOT FINISHED... maybe obsolete
            % idea was to delete triangles and make a new triangulation with
            % a forced triangle that contain the forced edge
            
            %{
            % new vertices
            ind = find(ismember(T1c,T2c));
            nv1 = T1c(ind);
            nv1 = nv1(1);
            % find all triangles with identified vertice
            TriNr = find(sum(T==nv1,2));
            % triangle vertices
            vs = T(TriNr,:);
            vs = unique(vs);
            % new triangles
            nT1 = sort([edges(i,:) nv1]);
            % rearange coordinates so that forced triangle vertices are the
            % first 3 points
            %vs = [nT1';vs(~ismember(vs,nT1))];
            % delete all triangles with identified vertice
            %T(TriNr,:) = [];
            
            % sort coordinates that forced triangle vertices are the first 3
            % and call re-triangulate function
            %cs = triang.Points(vs,:);
            %cs(1:3,1) = cs(1:3,1)-100;
            %nT = delaunaytri(triang.Points(vs,:))
            %}
            
        else % 2 triangles switching       
            % new vertices
            vs1 = T1(~ismember(T1,edges(i,:)));
            %vs2 = T2(~ismember(T2,edges(i,:)));
            if isempty(vs1)
                continue
            end
            % new triangles
            nT1 = sort([edges(i,1) edges(i,2) vs1(1)]);
            nT2 = sort([edges(i,1) edges(i,2) vs1(2)]);
            % to be updated triangle indices
            [~,ind1] = ismember(T1,T,'rows');
            [~,ind2] = ismember(T2,T,'rows');
            if isequal(numel(ind1),1) && isequal(numel(ind2),1)
                T(ind1,:) = nT1;
                T(ind2,:) = nT2;
            else
                dummy = 1;
            end
        end
    end
end
% update triangulation
dt.Points = triang.Points;
dt.ConnectivityList = T;
%tri.ConnectivityList = T;
triang = dt;

% end of function
end



% re-triangulate area part
function [retri] =  retri(coordinates)

% clean up and sort point list
c = coordinates;
%c = unique(c,'stable');
c = round(c,10);
c(1:3,1) = c(1:3,1)-100; 
% tolerance value
tol = 1e-16;

% convex hull at start:
ch = quickhull(c(1:3,:));
ch = ch(1:end-1);
% first triangle
T = sort(ch');

% loop over points and add them to triangulation
for cp = 4:size(c,1)
    
    % initialize not visible vector
    nv = [];
    
    % loop over convex hull vertices and test visibility
    for j = 1:size(ch,1)
        
        tv = ch(j);
        % convex hull edges
        che = [ch [ch(end);ch(1:end-1)]];
        % regard only edges without test vertice tv
        d = any(che==tv,2);
        che(d,:) = [];
        
        % loop over convex hull edges
        for e = 1:size(che,1)
            % edge line coordinates: a->b & u->v
            xa = c(che(e,1),1);
            ya = c(che(e,1),2);
            xb = c(che(e,2),1);
            yb = c(che(e,2),2);
            xu = c(tv,1);
            yu = c(tv,2);
            xv = c(cp,1);
            yv = c(cp,2);
            
            % calculate if vectors cross between a->b
            
            % define determinant ratio A
            A = det([xu-xa xu-xv; yu-ya yu-yv])/det([xb-xa xu-xv; yb-ya yu-yv]);
            % define determinant ratio B
            B = det([xb-xa xu-xa; yb-ya yu-ya])/det([xb-xa xu-xv; yb-ya yu-yv]);
            if abs(A)<tol
                A = 0;
            end
            if abs(B)<tol
                B = 0;
            end
            % if A and B are between 0 and 1 -> not visible
            if (B >= 0 && B <= 1) && (A >= 0 && A <= 1)
                % not visible
                nv = [nv;tv];
                break
            end
            
        end
    end
    
    % make sure each new vertice is only once in vector
    nv = unique(nv,'stable');
    v = ch;
    [~,in] = ismember(nv,ch);
    v(in) = [];
    % add new triangles to list
    nt = [];
    for t = 1:length(v)-1
        nt = [nt;sort([v(t) v(t+1) cp])];
    end
    
    if isempty(nt)
        continue
    end
    
    % add new triangles
    T = [T; nt];
    % get current triagulation polygon points: polyp
    polyp = unique(T);
    % get new convex hull of triangulated polygon
    ch = quickhull(c(polyp,:));
    ch = ch(1:end-1);
    % new triangle edges
    newedges = [nt(:,1:2) nt(:,2:3) nt(:,1) nt(:,3)];
    newedges = (reshape(newedges',[2 size(newedges,1)*3]))';
    newedges = unique(newedges,'rows');
end

% return point connection list
T = unique(T,'rows');
retri.Points = coordinates;
retri.ConnectivityList = T;
retri.Constraints = [];

% end of retri function
end




