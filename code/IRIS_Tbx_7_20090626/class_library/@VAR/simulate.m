function x = simulate(w,source,range,varargin)
% <a href="matlab: edit rvar/simulate">SIMULATE</a>  Simulate RVAR model.
%
% Syntax:
%   output = simulate(w,source,range,...)
% Output arguments:
%   output [ tseries ] Output data as multivariate time series.
% Required input arguments:
%   w [ rvar ] RVAR model to be simulated.
%   source [ tseries ] Input data as multivariate time series.
%   range [ numeric ] Simulation range.
% <a href="options.html">Optional input arguments:</a>
%   'contributions' [ true | <a href="default.html">false</a> ] Decompose simulation into contributions of individual shocks.
%   'deviation' [ true | <a href="default.html">false</a> ] Input and output data are deviations from steady state.

% The IRIS Toolbox 2009/05/21.
% Copyright 2007 Jaromir Benes.

% Validate required input arguments.
p = inputParser();
p.addRequired('w',@isvar);
p.addRequired('source',@istseries);
p.addRequired('range',@isnumeric);
p.parse(w,source,range);

[ny,p,nalt] = size(w);

default = {
   'contributions',false,@islogical,...
   'deviation',false,@islogical,...
};
options = passvalopt(default,varargin{1:end});

if ~any(size(source,2) == [2*ny,ny])
   error_(16);
end

%********************************************************************
%! Function body.

ndata = size(source,3);
nloop = max([nalt,ndata]);

if options.contributions
   if nloop > 1
      error_(17,'SIMULATE');
   else
      % Simulation of contributions.
      nloop = ny + 1;
   end
end

sourcerange = get(source{:,1:ny,:},'min');

if any(isinf(range))  
   range = sourcerange(1+p:end);
end

if isempty(range) || isempty(sourcerange) || floor(range(1)) < floor(sourcerange(1) + p) || floor(range(1)) > floor(sourcerange(end) + 1)
   x = tseries([],zeros([0,2*ny,nloop]));
   return
end

nper = length(range);
xrange = range(1)-p:range(end);

% Fetch source data.
x = rangedata(source,xrange);
if size(source,2) == 2*ny
   % Input data include residuals.
   e = x(:,ny+1:2*ny,:);
   e(isnan(e)) = 0;
else
   % Input data do not include residuals.
   e = zeros([nper+p,ny,size(source,3)]);
end
x = x(:,1:ny,:);

if ndata < nloop
   x = cat(3,x,x(:,:,end*ones([1,nloop-ndata])));
   e = cat(3,e,e(:,:,end*ones([1,nloop-ndata])));
end

% Transpose. Will be reversed at the end.
x = permute(x,[2,1,3]);
e = permute(e,[2,1,3]);

x0 = x;
for iloop = 1 : nloop
   if iloop <= nalt
      Ai = w.A(:,:,iloop);
      Ki = w.K(:,iloop);
      if isempty(w.B)
         Bi = [];
      else
         Bi = w.B(:,:,iloop);
      end
   end
   for t = p + (1 : nper)
      x(1:ny,t,iloop) = Ai*vec(x(1:ny,t-(1:p),iloop));
      if isempty(Bi)
         x(1:ny,t,iloop) = x(1:ny,t,iloop) + e(:,t,iloop);
      else
         x(1:ny,t,iloop) = x(1:ny,t,iloop) + Bi*e(:,t,iloop);
      end
      if ~options.deviation
         x(1:ny,t,iloop) = x(1:ny,t,iloop) + Ki;
      end
   end
end

% Reverse transpose.
x = permute(x,[2,1,3]);
e = permute(e,[2,1,3]);
e(1:p,:,:) = NaN;

x = tseries(range(1)-p:range(end),[x,e]);

end
% End of primary function.