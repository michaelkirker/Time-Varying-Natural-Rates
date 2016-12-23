function lock(this,varargin)
%
% The IRIS Toolbox 2008/03/18. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if nargin > 1 && ~iscellstr(varargin)
   error('Incorrect type of input argument(s).');
end

% ###########################################################################################################
%% function body

if nargin == 1
   % lock all
   repository_('lock');
   return
end

invalid = {};
for i = 1 : length(varargin)
   if ~repository_('lock',varargin{i});
      invalid{end+1} = varargin{i};
   end
end

if ~isempty(invalid)
   multierror('Cannot find an entry named "%s" in container.',invalid,'iris:container');
end

end
% end of primary function