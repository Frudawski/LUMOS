function file = savefile(fname,ftype)
% savefile opens save file GUI and gives the absolut filename as return
% value.
% usage: file = savefile('filename','fileformat')
% 'filename' and 'fileformat' or optional
%
% If save GUI is aborted, savefile returns an  empty vector
%
% Author: Frederic Rudawski
% Date: 27.3.2017

% check filename suggestion
if ~exist('fname','var')
    fname = '';
end
% check filetype suggestion
if ~exist('ftype','var')
    ftype = '';
end

% select save path
[filename,path] = uiputfile(['*.',ftype],'Save as...',fname);
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