function [this,data] = integrate(this,data,varargin)
% <a href="matlab: edit var/integrate">INTEGRATE</a>  Integrate VAR variables.
%
% Syntax:
%   this = integrate(this)
%   [this,data] = integrate(this,data,...)
% Output arguments:
%   this [ VAR ] Intergrated VAR model.
%   data [ tseries ] Integrated data associated with VAR model.
% Required input arguments:
%   this [ VAR ] VAR model to be integrated.
%   data [ tseries ] Data associated with VAR model.
% <a href="options.html">Optional input arguments:</a>
%   'applyto' [ logical | numeric | <a href="default.html">true([1,ny])</a> ] Index of variables to be integrated.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

[ny,p,nalt] = size(this);

default = {
  'applyto',true([1,ny]),@(x) (islogical(x) && length(x) == ny) || (isnumeric(x) && length(x) <= ny),...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

%TODO: Replace with time_domain.function.
import('time_domain.*');

% make options.applyto logical index
if isnumeric(options.applyto)
   if any(isinf(options.applyto))
      options.applyto = true([1,ny]);
   else
      aux = options.applyto;
      options.applyto = false([1,ny]);
      options.applyto(aux) = true;
   end
else
   options.applyto = logical(options.applyto(1:ny));
end

% Integrate model.
if any(options.applyto)
   D = cat(3,eye(ny),-eye(ny));
   D(~options.applyto,~options.applyto,2) = 0;
   A = this.A;
   this.A(:,end+1:end+ny,:) = NaN;
   for ialt = 1 : nalt
      % Call Time Domain package.
      a = polyprod(var2poly(A(:,:,ialt)),D);
      this.A(:,:,ialt) = poly2var(a);
   end
   this = schur_(this);
end

% Integrate datapack series.
if nargin > 1 && nargout > 1 && istseries(data) && ~isempty(data)
   [start,finish] = get(data,'start','end');
   options.applyto = find(options.applyto);
   data(start-1,options.applyto,:) = 0;
   data(start-1:finish,options.applyto,:) = cumsum(data(start-1:finish,options.applyto,:),1);
else
   data = tseries([],zeros([0,2*ny]));
end

end
% End of primary function.