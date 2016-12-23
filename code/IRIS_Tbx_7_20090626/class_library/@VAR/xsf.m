function [S,D] = xsf(w,freq)
% <a href="matlab: edit rvar/xsf">XSF</a>  Power spectrum and spectral density functions.
%
% Syntax:
%   [S,D] = xsf(w,freq)
% Output arguments:
%   S [ numeric ] Power spectrum function.
%   D [ numeric ] Spectral density function.
% Required input arguments:
%   w [ VAR ] VAR model.
%   freq [ numeric ] Frequencies at which XSF is to be evaluated.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

if ~isnumeric(freq)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

try
   % Try to import Freq Domain package.
   import('freq_domain.*');
end

[ny,p,nalt] = size(w);
freq = vech(freq);
nfreq = length(freq);

S = nan([ny,ny,nfreq,nalt]);
for ialt = 1 : nalt
   % Call Freq Domain package.
   % Compute power spectrum function.
   S(:,:,:,ialt) = xsfvar(w.A(:,:,ialt),w.Omega(:,:,ialt),freq);
end
S = S / (2*pi);

if nargout > 1
   % Convert power spectrum to spectral density.
   D = psf2sdf(S,acf(w));
end

end
% End of primary function.