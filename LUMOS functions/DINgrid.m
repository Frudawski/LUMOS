 % DINgrid returns a mesurement grid according to DIN 5035-6 or DIN 12464,
% with the corresponding measurement points for a given measurement area.
%
% usage: [x,y,numx,numy] = DINgrid(width,length,border,mode,[numx numy])
%
% where: - x and y are the meshpoints coordinates matrices in m
%        - numx and numy are the number of points in x and y dimension
%          can also be used as input arguments (ignoring mode setting)
%        - width is the length of the meshgrid in x dimension in m
%        - length is the length of the meshgrid in y dimension in m
%        - border defines a peripheral zone which is not considered for the
%          meshgrid
%        - mode defines the grid resolution:
%           - '5035' creates a meshgrid according to DIN 5035 with odd
%             numbers of measurement points (default)
%           - '12464' creates a meshgrid according to DIN 12464 (part 1 & 2)
%              with odd and/or even numbers of measurement points
%
% Author: Frederic Rudawski
% Date: 10.06.2020 - last edited: 16.07.2020

function [xq,yq,dn,bn] = DINgrid(d,b,border,mode,sizexy)

if ~exist('mode','var')
    mode = '5035';
end

if exist('border','var')
    if strcmp(border,'border')
        borderzone = 1;
    else
        borderzone = 0;
    end
else
    borderzone = 0;
end

d = d-2*borderzone;
b = b-2*borderzone;

[v,idx] = sort([d b]);

if isequal(idx(2),2)
    x = b;
    if v(2)/v(1)>=2
        x = d;
    end
else
    x = d;
    if v(2)/v(1)>=2
        x = b;
    end
end

if isequal(x,0)
    xq = NaN;
    yq = NaN;
    dn = 0;
    bn = 0;
    return
end

p = 0.2*5^(log10(d));
p = real(p);

if p > 10
    p = 10;
end

dn = ceil(d/p);

switch mode
    case '5035'
        if isequal(mod(dn,2),0)
            dn  = dn+1;
        end
    case '12464'
end

bn = ceil(b/p);

switch mode
    case '5035'
        if isequal(mod(bn,2),0)
            bn = bn+1;
        end
    case '12464'
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

%{
if exist('sizexy','Var')
    if borderzone
        bn = sizexy(1);
        bw = (b-1)/bn;
        dn = sizexy(2);
        dw = (d-1)/dn;
    else
        bn = sizexy(1);
        bw = b/bn;
        dn = sizexy(2);
        dw = d/dn;
    end
end

if borderzone
    rgrid = linspace(0.5+dw/2,d-0.5-dw/2,dn);
    %rgrid = [0.5 rgrid 0.5+d];
    zgrid = linspace(0.5+bw/2,b-0.5-bw/2,bn);
    %zgrid = [0.5 zgrid 0.5+b];
else
    rgrid = linspace(dw/2,d-dw/2,dn);
    zgrid = linspace(bw/2,b-bw/2,bn);
end
%}

if exist('sizexy','var')
        bn = sizexy(2);
        bw = b/bn;
        dn = sizexy(1);
        dw = d/dn;
end

rgrid = linspace(dw/2,d-dw/2,dn)+borderzone;
zgrid = linspace(bw/2,b-bw/2,bn)+borderzone;

[xq,yq] = meshgrid(rgrid,zgrid);
