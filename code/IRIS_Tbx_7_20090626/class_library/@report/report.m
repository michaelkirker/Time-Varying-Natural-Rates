function x = report(varargin)
%
% REPORT  Create new report object.
%
% x = report(...)
% Required input arguments:
%   x report
% <a href="options.html">Optional input arguments:</a>
%   'centering' logical (true)
%   'heading' char (empty)
%   'irisstamp' logical (false)
%   'fontname' char ('times')
%   'fontsize' numeric (11)
%   'orientation' char ('landscape')
%   'pagenumber' logical (true)
%   'papersize' char ('a4')
%   'preamble' char ('preamble.tex')
%   'textscale' numeric (0.75)
%   'timestamp' logical (true)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

x = empty_();
x = class(x,'report');

x.parenttype{end+1} = 'report';
x.parentoptions{end+1} = readoptions_([],varargin{:});
x.parentspec{end+1} = NaN;

end % of primary function -----------------------------------------------------------------------------------

  function x = empty_() % subfunction -----------------------------------------------------------------------

  x.contents = {};
  x.parenttype = {};
  x.parentoptions = {};
  x.parentspec = {};

  end % of subfunction --------------------------------------------------------------------------------------