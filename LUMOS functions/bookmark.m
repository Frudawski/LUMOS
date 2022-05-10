function bookmark(string)
% 
% bookmark displays the current linenumber in the m.file with hypertext function and input string.
%
% How to use:
% bookmark('String')
%
% Author: Frederic Rudawski
% Original Date: 01.12.2016 - edited 06.10.2020
% Version 1.0

try
    % get stack
    Stack  = dbstack('-completenames');
    LineNr = Stack(2).line;   % the line number of the calling function
    % Display hypertext linenumber
    % Stack(2).file -> absolute path + filename of calling function
    disp(['<a href="matlab: opentoline(''',Stack(2).file,''',',num2str(LineNr),')">Bookmark at line ',num2str(LineNr),' in ',Stack(2).name,'.m:</a> ',string])
catch
    warning('bookmark(string) is intended for use in scripts. Use it in the editor as bookmark.')
end

end
