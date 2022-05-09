% function rotate surface
%
% M = rotMatrix(angles)
%
%      where: M is the rotation matrix             
%             angles is a 1x3 rotation angles vector in degrees for [x y z] axis
%
% see: https://en.wikipedia.org/wiki/Rotation_matrix
%
% original Source: Taylor, Camillo J.; Kriegman, David J. (1994).
% "Minimization on the Lie Group SO(3) and Related Manifolds" (PDF).
% Technical Report No. 9405. Yale University.
% https://www.cis.upenn.edu/~cjtaylor/PUBLICATIONS/pdfs/TaylorTR94b.pdf
%
% Author: Frederic Rudawski
% Date: 11.05.2020

function rot = rotMatrix(alpha)
% rotate around axis
Rz = [cosd(alpha(3)) -sind(alpha(3)) 0;...
      sind(alpha(3))  cosd(alpha(3)) 0;...
      0              0             1];
Ry = [ cosd(alpha(2)) 0 sind(alpha(2));...
       0             1 0;...
      -sind(alpha(2)) 0 cosd(alpha(2))];
Rx = [1 0              0;...
      0 cosd(alpha(1)) -sind(alpha(1));...
      0 sind(alpha(1))  cosd(alpha(1))];
  
rot = Rz*Ry*Rx;


