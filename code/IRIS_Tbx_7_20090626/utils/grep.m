function grep(h,fname,ltitle,ctitle,rtitle,append)
%
% GREP  Fast graphical Postscript report.
%
% Syntax:
%   grep(h,fname,ltitle,ctitle,rtitle,append)
% Arguments:
%   h numeric; fname char; rtitle,ctitle,ltitle char
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin < 3, ltitle = ''; end
if nargin < 4, ctitle = ''; end
if nargin < 5, rtitle = ''; end
if nargin < 6, append = true; end

% function body ---------------------------------------------------------------------------------------------

ftitle(h,ltitle,ctitle,rtitle);
orient('landscape');

if append == true, print('-dpsc',fname,'-append');
  else, print('-dpsc',fname); end

end % of primary function -----------------------------------------------------------------------------------