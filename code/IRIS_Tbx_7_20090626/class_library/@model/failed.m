function varargout = failed(m,npath,fname)
% FAILED  Throw error if model fails to solve in iterative functions, and give access to failed model object.

% The IRIS Toolbox 2009/05/07.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

persistent store;

if nargin == 1
   varargout{1} = store;
   return
end

store = m;

if npath == 0
   msg = 'no stable solution';
elseif npath == Inf
   msg = 'multiple stable solutions';
elseif imag(npath) ~= 0
   msg = 'complex derivatives';
elseif isnan(npath)
   msg = 'NaN derivatives';
elseif npath == -1
   msg = 'singularity in the state-space form';
end

error([...
   '%s failed because currently processed parameterisation is a region with %s.\n',...
   'Type <a href="matlab: x = failed(model);">x = failed(model);</a> to get the model object that failed to solve.',...
   ],upper(fname),msg);

end