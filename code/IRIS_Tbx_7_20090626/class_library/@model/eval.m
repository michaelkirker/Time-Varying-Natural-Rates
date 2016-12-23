function [evaleqtn,D,missing] = eval(m,d,range)
%
% EVAL  Use database to evaluate model equations and compute 1st-order accurate residuals.
%
% Syntax:
%   [x,d] = eval(m,d,range)
% Required input arguments:
%   x cell; d struct; m model; range numeric
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if ~isa(d,'struct') || ~isnumeric(range), error('Incorrect type of input argument(s).'); end

% ###########################################################################################################
% function body

nalt = size(m.assign,3);

% number of databases and number of parameterizations must match
if length(d) ~= 1 && length(d) ~= nalt
  error_(44);
end

range = vech(range);
nrange = length(range);

t = m.tzero;
if issparse(m.occur)
  nt = size(m.occur,2)/length(m.name);
else
  nt = size(m.occur,3);
end
maxt = nt - t;
mint = 1 - t;

rangex = (range(1)+mint):(range(end)+maxt);
nrangex = nrange - mint + maxt;

x = nan([nrange,length(m.name),nt]);
missing = {};

evaleqtn = nan([sum(m.eqtntype <= 2),nrange,nalt]);
for ialt = 1 : nalt
  data_();
  for i = 1 : sum(m.eqtntype <= 2)
    aux = m.eqtnF{i}(x,t);
    evaleqtn(i,:,ialt) = permute(aux,[2,1]);
  end
end
evaleqtn = {evaleqtn(m.eqtntype == 1,:,:),evaleqtn(m.eqtntype == 2,:,:)};

if nargout > 1
  D = [];
  d_ = struct;
  realsmall = getrealsmall();
  for ialt = 1 : nalt
    dbase_();
    evalresid = zeros([sum(m.nametype == 3),nrange]);
    eqselect = eqselect_(m,ialt);
    eqselect(m.eqtntype == 3) = false;
    [m,deriv] = deriv_(m,eqselect,ialt);
    [m,system] = system_(m,deriv,eqselect,ialt);
    if any(m.eqtntype == 1)
      ixeqtn = any(abs(system.E{1}) > realsmall,2);
      ixresid = any(abs(system.E{1}) > realsmall,1);
      evalresid(ixresid,:) = -system.E{1}(ixeqtn,ixresid) \ evaleqtn{1}(ixeqtn,:,ialt);
    end
    ixeqtn = any(abs(system.E{2}) > realsmall,2);
    ixresid = any(abs(system.E{2}) > realsmall,1);
    evalresid(ixresid,:) = -system.E{2}(ixeqtn,ixresid) \ evaleqtn{2}(ixeqtn,:,ialt);
    offset = sum(m.nametype <= 2);
    for i = find(m.nametype == 3)
      try
        tmp = d_.(m.name{i})(range);
        tmp(isnan(aux)) = 0;
      catch
        d_.(m.name{i}) = tseries;
        tmp = zeros([nrange,1]);
      end
      d_.(m.name{i})(range) = aux + transpose(evalresid(i-offset,1:end));
    end
    D = [D,d_];
  end % of for
  if nargout > 2, missing = unique(missing); end
end % of if

  function data_() % nested function -----------------------------------------------------------------

  % update parameters
  p = m.assign(1,m.nametype == 4,ialt);
  x(:,m.nametype == 4,t) = p(ones([1,nrange]),:);

  % use same data if only one database passed in
  if ialt > 1 && length(d) == 1, return, end

  x(:,m.nametype <= 3,:) = NaN;
  for i = find(m.nametype <= 3)
    try, aux = d(ialt).(m.name{i})(rangex);
      catch, aux = nan([nrangex,1]); missing{end+1} = m.name{i}; end
    if m.nametype(i) == 3
      aux(isnan(aux)) = 0;
    end
    for j = 1 : nrange
      x(j,i,1:end) = permute(aux((j+t-1)+mint:(j+t-1)+maxt),[2,3,1]);
    end
  end

  end

  function dbase_() % nested function ------------------------------------------------------------------------

  if ialt > 1 && length(d) == 1, d_ = d;
    else d_ = d(ialt); end

  end % of nested function ----------------------------------------------------------------------------------

end % of primary function -----------------------------------------------------------------------------------