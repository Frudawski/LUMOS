function catcher(me)
% gives information about error stack.
% input: me from try/catch statement
% output: error stack with hyperlink function
%
% usage: 
% try
%   ...
% catch me
%   catcher(me)
% end
%
% date: 03.02.2018
% author: Frederic Rudawski

disp([10,'']) % newline
disp(me.identifier) % error identifier
disp(me.message) % error message
% loop over error stack
for er = 1:size(me.stack,1)
    % diyplay error hyperlink 
    disp(['<a href="matlab: opentoline(''',me.stack(er,1).file,''',',num2str(me.stack(er,1).line),')">Error at line: ',num2str(me.stack(er,1).line),' in ',me.stack(er,1).name,'.m:</a>'])
end
end