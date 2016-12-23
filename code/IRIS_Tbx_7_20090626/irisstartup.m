function irisstartup(varargin)
% Start a new IRIS session.

% The IRIS Toolbox 2009/01/27.
% Copyright (c) 2007-2009 Jaromir Benes.

display = ~any(strcmpi(varargin,'-nodisplay'));

if exist('display','var') ~= 1
   display = true;
end

%********************************************************************
%! Function body.

%
% Detect Matlab versions that do not support packages and new class definitions.
%
oldMatlab = 0;%sscanf(version(),'%g',1) < 7.6;
packagesNotKnown = sscanf(version(),'%g',1) < 7.5;

%
% Get the whole iris folder structure. This must be done before irisremove(...) otherwise genpathcell(...) will not be found.
% Exclude the following directories:
% * +mht
% * __history
% * any directory starting with a minus sign
%
root = fileparts(which('irisstartup.m'));
[add,pkg,cls,usr] = genpathcell(root,true,'^-|^\+mht|__history');

%
% If Matlab version is lower than 7.6, add package directories to the search path.
% In version 7.6 and higer, package directories are accessible.
%
if packagesNotKnown
   add = [add,pkg];
end

% Remove all existing IRIS folder structures from the search path.
unused = irisremove('removeroot',true,'display',false);

% Add all IRIS folders to the search path.
addpath(add{:},'-begin');

% Initiate the config file.
rehash();
irisconfig();
config = irisconfig();

% Add model extensions to Matlab preferences.
irisassociate();

%********************************************************************
%! Display messages.

% Intro message.
disp(' ');
disp(['  ',irisping()]);
disp('  Check out <a href="http://groups.google.com/group/iris-toolbox">The IRIS Toolbox discussion group</a>.');
disp(sprintf('  Copyright (c) 2007-%s Jaromir Benes.',datestr(now,'YYYY')));
disp(' ');

% IRIS root folder.
disp(sprintf('  IRIS root: <a href="file:///%s">%s</a>.',root,root));

% (La)TeX executables.
if isempty(config.latexpath)
   tmpMessage = '<a href="matlab: edit LaTeXlink.m">No TeX/LaTeX installation found</a>';
else
   tmpPath = fileparts(config.latexpath);
   tmpMessage = sprintf('<a href="file:///%s">%s</a>',tmpPath,tmpPath);
end
disp(sprintf('  (La)TeX binary files: %s.',tmpMessage));
separate = false;

% Old Matlab.
if oldMatlab
   disp(' ');
   disp('  Warning: This version of IRIS is not fully compatible with your obsolete version of Matlab.');
   disp('           We recommend that you upgrade Matlab to 7.6 (R2008a) or higher.');
end

% Unused IRIS folders removed.
if ~isempty(unused)
   disp(' ');
   for i = 1 : length(unused)
      disp(sprintf('  Warning: An unused IRIS found in <a href="file:///%s">%s</a> has been temporarily removed from Matlab.',unused{i},unused{i}));
   end
   separate = true;
end

disp(' ');

end
% End of primary function.