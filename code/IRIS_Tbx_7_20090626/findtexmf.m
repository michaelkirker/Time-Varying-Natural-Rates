function varargout = findtexmf(varargin)
% Find the location of TeX executables. Called from within irisconfig().

% The IRIS Toolbox 2009/02/12.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

varargout = cell(size(varargin));
varargout(:) = {''};
for i = 1 : length(varargin)
   % Try to run KPSEWHICH.
   [flag,output] = system(sprintf('kpsewhich --file-type=exe %s',varargin{i}));
   if flag == 0
      % Use the correctly spelled path and the right file separators.
      [fpath,fname,fext] = fileparts(strtrim(output));
      varargout{i} = fullfile(fpath,[fname,fext]);
   end
end

end
% End of primary function.