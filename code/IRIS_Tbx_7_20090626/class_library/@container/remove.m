function remove(x,varargin)
%
% The IRIS Toolbox 2008/03/18. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

if ~iscellstr(varargin)
   error('Incorrect type of input argument(s).');
end

notfound = {};
locked = {};
for i = 1 : length(varargin)
   [flag1,flag2] = repository_('remove',varargin{i});
   if ~flag1
      notfound{end+1} = varargin{i};
   elseif ~flag2
      locked{end+1} = varargin{i};
   end
end

if ~isempty(notfound)
   multierror('Cannot find an entry named "%s" in container.',notfound,'iris:container');
end

if ~isempty(locked)
   multierror('The entry "%s" is locked. Cannot remove the entry from container.',locked,'iris:container');
end

end
% end of primary function