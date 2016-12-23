function varargout = islocked(this,varargin)
%
% The IRIS Toolbox 2008/03/18. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if ~iscellstr(varargin) || length(varargin) > 1
   error('Incorrect type of input argument(s).');
end

% ###########################################################################################################
%% function body

invalid = {};
for i = 1 : length(varargin)
   [flag,varargout{i}] = repository_('islocked',varargin{i});
   if ~flag
      invalid{end+1} = varargin{i};
   end
end

if ~isempty(invalid)
   error('Cannot find an entry named "%s" in the repository.\n',invalid{:});
end

end
% end of function body