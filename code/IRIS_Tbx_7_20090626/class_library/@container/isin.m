function varargout = isin(this,varargin)
%
% <a href="matlab: edit container/isin">ISIN</a>  True if container stores queried names.
%
% Syntax:
%   [flag,flag,...] = isin(container,name,name,...)
% Output arguments:
%   flag [ logical ] True if container stores queries names.
% Required input arguments:
%   name [ char ] Names of items.
%
% The IRIS Toolbox 2008/03/18. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if ~iscellstr(varargin)
   error('Incorrect type of input argument(s).');
end

% ###########################################################################################################
%% function body

for i = 1 : length(varargin)
   varargout{i} = repository_('isin',varargin{i});
end

end
% end of primary function