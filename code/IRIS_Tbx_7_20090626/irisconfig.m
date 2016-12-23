function varargout = irisconfig(action,varargin)
% The IRIS Toolbox master configuration file.

% The IRIS Toolbox 2008/10/05.
% Copyright (c) 2007-2008 Jaromir Benes.

mlock();
persistent config;

%********************************************************************
%! Function body.

if (nargin == 0 && nargout == 0)
   init_();
   return
end

if isempty(config)
   init_();
end

% backward compatibility config = irisconfig();
if nargin == 0 && nargout == 1
   varargout{1} = config;
   return
end

switch lower(action)
case 'get'
   if nargin == 1
      varargout{1} = config;
   else
      for i = 1 : min([nargin-1,nargout])
         try
            varargout{i} = config.(varargin{i});
         catch
            varargout{i} = [];
         end
      end
   end
case 'set'
   for i = 1 : 2 : nargin-1
      if isfield(config,lower(varargin{i}))
         config.(lower(varargin{i})) = varargin{i+1};
      end
   end
otherwise
   error('Obsolete use of IRIS configuration files. Use IRISSET or IRISGET instead.');
end
% End of function body.

%********************************************************************
%! Nested function init_().

function init_()
   config = struct();
   % Default options.
   config.freqletters = 'YZQBM';
   config.dateformat = 'YFP';
   config.plotdateformat = 'Y:P';
   config.figureposition = [0,0,500*[1.7,1]];
   config.tseriesformat = '';
   % IRIS root folder. Make sure it is spelled properly.
   tmp = cd();
   cd(fileparts(which('irisstartup.m')));
   config.irisroot = cd();
   cd(tmp);
   config.irisfolder = config.irisroot;
   config.version = file2char(fullfile(config.irisroot,'irisversion'));
   % Paths to TeX/LaTeX executables.
   % Use kpsewhich to find TeX components.
   config.latexpath = findtexmf('latex');
   config.dvipspath = findtexmf('dvips');
   config.dvipdfmpath  = findtexmf('dvipdfm');
   config.epstopdfpath = findtexmf('epstopdf');
   config.pdflatexpath = findtexmf('pdflatex');
   % Matlab Editor extensions.
   % config.extensions = extensions;
   % Highest character code allowed in model codes.
   config.highcharcode = 1999;
end
% End of nested function init_().

end
% End of primary function,
