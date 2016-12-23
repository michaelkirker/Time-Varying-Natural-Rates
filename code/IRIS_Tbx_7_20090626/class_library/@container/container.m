function this = container(varargin)
%
% <a href="matlab: edit container/container">CONTAINER</a>  Create a handle to IRIS container.
%
% Syntax
%   this = container()
% Output arguments:
%   this [ container ] Handle through which IRIS container can be accessed.
%
% The IRIS Toolbox 2008/03/18. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

%********************************************************************
%! Function body.

this = struct();
this.name = [];
this.data = [];
this.lock = [];
this = class(this,'container');

if nargin == 0
  repository_('init');
  return 
end

if nargin == 1 && isstruct(varargin{1})
   list = repository_('locked');
   if ~isempty(list)
      error([...
         'Cannot overwrite container from a disk file because the following entries are locked: ',...
         sprintf('\n'),sprintf(' "%s"',list{:})...
      ]);
   end
   repository_('load',varargin{1}.name,varargin{1}.data,varargin{1}.lock);
end

end
% End of primary function.