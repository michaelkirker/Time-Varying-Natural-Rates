function x = printid(name,shift,log)
%
% PRINTID  Write formatted strings for model variables.
%
% Syntax:
%   x = printid(name,shift,log)
% Arguments:
%   x [ cellstr ] Formatted model variables.
%   name [ cellstr ] Variable names.
%   shift [ numeric ] Time shift (lag or lead)
%   log [ logical ] Log-linearised or not.
%
% The IRIS Toolbox 2007/07/11. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%%

if nargin < 2
   shift = zeros(size(name));
end

if nargin < 3,
   log = false(size(name));
end

% ###########################################################################################################
% function body

x = {};
for i = 1 : length(name)
   x{end+1} = sprintf(iff(log(i),'log(%s%s)','%s%s'),name{i},iff(shift(i) ~= 0,sprintf('{%g}',shift(i)),''));
end

end
% end of primary function