function idoc(varargin)
% IDOC  The IRIS Toolbox documentation.
%
% Syntax:
%   idoc
%   idoc class_name
%   idoc class_name.function_name
%
% IDOC opens the HTML documentation page for a specific topic. The name of the class,
% class_name, can be one of the following:
%    <a href="matlab: idoc model">model</a>, <a href="matlab: idoc tseries">tseries</a>, <a href="matlab: idoc model_code">model_code</a>

% The IRIS Toolbox 2008/10/07.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

helppath = fullfile(irisget('irisroot'),'-help');
tokens = {'',''};
if ~isempty(varargin)
   tokens = regexp(varargin{1},'(.*?)(?:[/\\\.]|$)(.*)','tokens','once');
   tokens = lower(strtrim(tokens));
   if ~isempty(tokens{2})
      tokens{2} = ['#',tokens{2}];
   end
end

switch tokens{1}
case {'model','tseries'}
   web(fullfile(helppath,sprintf('%s-functions.html%s',tokens{1:2})));   
case {'model_code'}
   web(fullfile(helppath,sprintf('model-code-language.html%s',tokens{2})));   
otherwise
   web(fullfile(helppath,'index.html'));
end

end
% End of primary function.