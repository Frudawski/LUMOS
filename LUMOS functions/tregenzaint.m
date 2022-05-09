% Tregenza interpolation
%
% Author: Frederic Rudawski
% Date: 29.11.2021

function [meanaz,meanel,meanin] = tregenzaint(L,az,el,it)

% tregenza patch angles
%pnt = [6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 42 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 66 66 66 66 66 66 66 66 66 66 66 66 78 78 78 78 78 78 90;180 192 204 216 228 240 252 264 276 288 300 312 324 336 348 0 12 24 36 48 60 72 84 96 108 120 132 144 156 168 168 156 144 132 120 108 96 84 72 60 48 36 24 12 0 348 336 324 312 300 288 276 264 252 240 228 216 204 192 180 180 195 210 225 240 255 270 285 300 315 330 345 0 15 30 45 60 75 90 105 120 135 150 165 165 150 135 120 105 90 75 60 45 30 15 0 345 330 315 300 285 270 255 240 225 210 195 180 180 200 220 240 260 280 300 320 340 0 20 40 60 80 100 120 140 160 150 120 90 60 30 0 330 300 270 240 210 180 180 240 300 0 60 120 0;1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];

if size(az,1) < size(az,2)
    az = az';
    el = el';
end
if size(L,1)~=145
    L = L';
end


% angular distance for patch interpolation 
ang = 18;


% horizont
if min(el)>0
    minel = min(el);
    idx = ismember(el,minel);
    el = [el;-ones(size(el(idx))).*6];
    az = [az;az(idx)];
    L = [L;L(idx,:)];
end

% loop over iterations, each time the tregenza hemisphere is interpolated with a finer mesh
for r = 1:it
    % initialize
    meanel = [];
    meanaz = [];
    meanint = [];
    % loop over patches
    for n = 1:size(L,1)
        % closest patches
        [d,p] = sorthemdistd(az(n),el(n),az(:),el(:));
        % angular distance less than 18 degree
        p = p(d<ang);
        % average angles and luminance
        for m = 1:numel(p)
            meanel = [meanel;mean([el(n) el(p(m))])];
            if abs(az(n)-az(p(m))) > ang
                meanaz = [meanaz;mean([az(n) 360])];
            else
                meanaz = [meanaz;mean([az(n) az(p(m))])];
            end
            meanint = [meanint;mean([L(n,:);L(p(m),:)])];
        end
    end
    % add interpolated values
    el = [el;meanel];
    az = [az;meanaz];
    L = [L;meanint];
    % adapt angular distance
    ang = ang/2;
end

% remove duplicate points
u = unique([az el L],'rows');
[~,idx] = unique(u(:,1:2),'rows');

%  return values
meanaz = u(idx,1);
meanel = u(idx,2);
meanin = u(idx,3:end);

