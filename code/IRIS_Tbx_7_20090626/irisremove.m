function varargout = irisremove(varargin)
% Remove all IRIS folders from the Matlab search path.
%
% Syntax:
%   irisremove()
%   irisremove('removeroot')

% The IRIS Toolbox 2009/01/23.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {...
  'display',true,@islogical,...
  'removeroot',false,@islogical,...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

% Detect Matlab versions that do not support packages and new class definitions.
oldMatlab = sscanf(version(),'%g',1) < 7.6;

% Remove all IRIS folder structures found on the search path.
% Add the first one found back to the search path if removeroot == false.
status = warning('query','all');
warning('off','MATLAB:rmpath:DirNotFound');
list = which('irisstartup.m','-all');
root = cell(size(list));
for i = 1 : length(list)
   root{i} = fileparts(list{i});
   [tree,packages] = genpathcell(root{i},true);
   if oldMatlab
      tree = [tree,packages];
   end
   rmpath(tree{:});
end
warning(status);

if ~options.removeroot
   % Keep the first IRIS root folder on the search path if requested.
   addpath(root{i},'-begin');
end

if options.display
   if ~options.removeroot
      disp('  The IRIS Toolbox files have been removed temporarily from the Matlab search path.');
      disp(' ');
   else
      disp('  The IRIS Toolbox has been permanently removed from the Matlab search path.');
      disp(' ');
   end
end

if nargout > 0
   varargout{1} = root(2:end);
end

end
% End of primary function.