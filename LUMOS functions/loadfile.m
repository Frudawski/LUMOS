function file = loadfile(fname,ftype)
% savefile opens save file GUI and gives the absolut filename as return
% value.
% usage: file = loadfile('filename','fileformat')
% 'filename' and 'fileformat' or optional
%
% If save GUI is aborted, loadfile returns an  empty vector
%
% Author: Frederic Rudawski
% Date: 13.04.2020 (easter monday)

% check filename suggestion
if ~exist('fname','var')
    fname = '';
end
% check filetype suggestion
if ~exist('ftype','var')
    ftype = '';
end

% select save path
[filename,path] = uigetfile(['*.',ftype],'open file...',fname);
% aborted ?
if filename == 0
    % empty
    file = [];
else
    % absolute filepath
    file = [path, filename];
end

% end of function
end