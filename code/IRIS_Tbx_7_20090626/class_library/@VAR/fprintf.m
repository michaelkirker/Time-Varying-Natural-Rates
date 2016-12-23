function fprintf(this,fname,varargin)
% <a href="VAR/fprintf">FPRINTF</a>  Write formatted VAR model code to file.
%
% Syntax:
%   fprintf(this,fname,...)
% Required input arguments:
%   this [ VAR ] VAR model.
%   f [ char ] File name.
% <a href="options.html">Optional input arguments:</a>
%   Check <a href="matlab: help VAR/sprintf">help VAR/SPRINTF</a> for optional arguments.

% The IRIS Toolbox 2009/04/17.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

char2file(sprintf(this,varargin{:}),fname);

end
% End of primary function.