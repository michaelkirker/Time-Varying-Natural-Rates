function x = begingraph(x,varargin)
%
% BEGINGRAPH  Open Matlab figure with recommended settings for report graphs.
%
% Syntax:
%   [p,h] = begingraph(p,...)
% Required input arguments:
%   p report; h numeric
% Options (only begingraph specific options):
%   'close' logical (true)
%   'color' logical (false)
%   'dateformat' char (irisget('plotdateformat'))
%   'fontsize' numeric (11)
%   'visible' logical (true)
%   'plotbox' numeric ([1.6,1])
%   'scale' numeric (0.90)
%
% See also reportoptions.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

% function body ---------------------------------------------------------------------------------------------

chksyntax_(x.parenttype{end},'begingraph');

aux = reportobject_('begingraph',NaN,x.parentoptions{end},varargin{:});
if ~isnumeric(aux.options.fontsize), aux.options.fontsize = 11; end
aux.spec = opengraph(aux.options.fontsize,aux.options.graphvisible,aux.options.plotbox);
x.contents{end+1} = aux;
x.parenttype{end+1} = 'begingraph';
x.parentoptions{end+1} = x.contents{end}.options;
x.parentspec{end+1} = aux.spec;

end % of primary function -----------------------------------------------------------------------------------