function [dpack,naninit] = db2dp(me,d,range,include,type,loglin)
%
% <a href="struct/db2dp">DB2DP</a>  Convert database to model-specific datapack.
%
% Syntax:
%   dp = db2dp(m,db,range)
% Output arguments:
%   dp [ cell ] Output datapack.
% Required input arguments:
%   m [ model | struct ] Model or meta information struct.
%   db [ struct ] Input database.
%   range [ numeric ] Time range (<a href="dates.html">IRIS serial date numbers</a>).
%
% The IRIS Toolbox 2007/09/26. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%%

if ~isstruct(me) || ~isstruct(d) || ~isnumeric(range)
  error('Incorrect type of input argument(s).');
end

if nargin < 5
  type = 1 : 3;
end

if nargin < 6
  loglin = true;
end

% ===========================================================================================================
%% function body

% always include initial condition

range = range(1)-1:range(end);
nper = length(range);

ny = length(me.id{1});
nx = length(me.id{2});
nb = size(me.U,1);
nf = nx - nb;
ne = length(me.id{3});
ndata = NaN;
nalt = size(me.U,3);

notfound = {};
invalid = {};

dpack = cell([1,5]);
dpack{4} = range;
dpack{5} = setfield(me,'mse',false);

% ===========================================================================================================
% transition variables

if any(type == 2)
  [dpack{2},notfound_,invalid_] = db2mat(d,range,me.name(real(me.id{2})),imag(me.id{2}));
  if loglin
    dpack{2}(me.log(real(me.id{2})),:,:) = log(dpack{2}(me.log(real(me.id{2})),:,:));
  end
  notfound = [notfound,notfound_];
  invalid = [invalid,invalid_];
  % expand data in 3rd dimension if needed
  ndata = size(dpack{2},3);
  nloop = max([ndata,nalt]);
  if nloop > 1 && ndata == 1
    dpack{2} = dpack{2}(:,:,ones([1,nloop]));
    ndata = nloop;
  end
  % check for NaN initial conditions
  naninit = false([1,nb]);
  for iloop = 1 : nloop
    if iloop <= nalt
      icondixi = me.icondix(1,:,iloop);
    end
    naninit = naninit | ( icondixi & vech(any(isnan(dpack{2}(nf+1:end,1,iloop)),3)) );
  end
else
  dpack{2} = nan(nan([nx,nper,nalt]),me.precision);
  naninit = {};
end
% end of transition variables

% ===========================================================================================================
% measurement variables

if any(type == 1) && ny > 0
  [dpack{1},notfound_,invalid_] = db2mat(d,range,me.name(real(me.id{1})),imag(me.id{1}));
  if loglin
    dpack{1}(me.log(real(me.id{1})),:,:) = log(dpack{1}(me.log(real(me.id{1})),:,:));
  end
  % set initial condition to NaN for measurement variables
  dpack{1}(:,1,:) = NaN;
  notfound = [notfound,notfound_];
  invalid = [invalid,invalid_];
  % expand data in 3rd dimension if needed
  ndata = size(dpack{1},3);
  nloop = max([ndata,nalt]);
  if nloop > 1 && ndata == 1
    dpack{1} = dpack{1}(:,:,ones([1,nloop]));
    ndata = nloop;
  end
else
  if isnan(ndata)
    dpack{1} = nan(0,me.precision);
  else
    dpack{1} = nan([ny,nper,ndata],me.precision);
  end
end
% end of measurement variables

% ===========================================================================================================
% residuals

if any(type == 3) && ne > 0
  [dpack{3},notfound_,invalid_] = db2mat(d,range,me.name(real(me.id{3})),imag(me.id{3}));
  % set initial condition to NaN for residuals
  dpack{3}(:,1,:) = NaN;
  notfound = [notfound,notfound_];
  invalid = [invalid,invalid_];
  % expand data in 3rd dimension if needed
  ndata = size(dpack{3},3);
  nloop = max([ndata,nalt]);
  if nloop > 1 && ndata == 1
    dpack{3} = dpack{3}(:,:,ones([1,nloop]));
    ndata = nloop;
  end
else
  if isnan(ndata)
    dpack{3} = nan(0,me.precision);
  else
    dpack{3} = nan([ne,nper,ndata],me.precision);
  end
end
% end of residuals

% ===========================================================================================================
%% backmatter

if ~isempty(invalid)
  error('Incorrect size of multivariate time series: %s.\n',invalid{:});
end

if ~isnan(nloop)
  % expand data in 3rd dimension if needed
  if nloop > 1 && ndata == 1
    for i = 1 : 3
      dpack{i} = dpack{i}(:,:,ones([1,nloop]));
    end
  end  
  % convert xb vector into alpha vector
  if ~isempty(dpack{2})
    xb2alpha_();
  end

end
% end of function body

% ===========================================================================================================
%% nested function xb2alpha_()

  function xb2alpha_()
  nloop = size(dpack{2},3);
  for iloop = 1 : nloop
    if iloop <= nalt
      Ui = dpack{5}.U(:,:,iloop);
      icondixi = me.icondix(1,:,iloop);
    end
    xb = dpack{2}(nf+1:end,1,iloop);
    xb(~icondixi,1) = 0;
    dpack{2}(nf+1:end,1,iloop) = xb;
    dpack{2}(nf+1:end,:,iloop) = Ui\dpack{2}(nf+1:end,:,iloop);
  end
  end
  % end of nested function xb2alpha_()

end
% end of primary function