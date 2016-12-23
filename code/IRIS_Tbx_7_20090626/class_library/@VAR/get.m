function varargout = get(this,varargin)
% <a href="matlab: edit VAR/get">GET</a>  Access/query VAR object attributes and properties.
%
% Syntax:
%   [value,value,...] = get(this,attrib,attrib,...)
% Output arguments:
%   value [ any ] Value of requested attribute.
% Required input arguments:
%   m [ VAR ] VAR object.
%   attrib [ char ] Requested attribute.
% Attributes:
%   'A' [ numeric ] Matrix polynomial A from A(L) x(t) = K + B e(t).
%   'A*' [ numeric ] Matrix polynominal A* from x(t) = A*(L) x(t-1) + K + B e(t).
%   'AIC' [ numeric ] Akaike information criterion.
%   'B' [ numeric ] Matrix B from "A(L) x(t) = K + B e(t)".
%   'Comment' [ char | cellstr ] User comments attached to VAR model.
%   'CumLongRun' [ numeric ] Asymptotic cumulative shock responses.
%   'EigVal' [ numeric ] All eigenvalues.
%   'K' [ numeric ] Constant term K from "A(L) x(t) = K + B e(t)".
%   'NHyper' [ numeric ] Number of estimated hyperparameters.
%   'NPer' [ numeric ] Length of effective estimation sample.
%   'Omega' [ numeric ] Residual (shock) covariance matrix.
%   'Order' [ numeric ] Order of VAR model.
%   'Roots' alias for 'eigval'.
%   'Sample' [ numeric ] Effective estimation sample, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%   'StableRoots'  Eigenvalues smaller than 1 in magnitude.
%   'SBC' [ numeric ] Schwarz Bayesian criterion.
%   'ExplosiveRoots' [ numeric ] Eigenvalues greater than 1 in magnitude.
%   'UnitRoots' [ numeric ] Eigenvalues indistinguishable from 1 in magnitude.

% The IRIS Toolbox 2008/10/10.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

invalid = {};
varargout = {};
for i = 1 : length(varargin)
   attrib = strtrim(varargin{i});
   [varargout{i},flag] = get_(this,lower(attrib));
   if ~flag
      invalid{end+1} = attrib;
   end
end
if ~isempty(invalid)
   multierror('Unrecognised attribute: "%s".',invalid);
end

end
% End of primary function.

% =======================================================================================
%! Subfunction get_().

function [x,flag] = get_(this,attrib)

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

[ny,p,nalt] = size(this);
realsmall = getrealsmall();
flag = true;
switch attrib
case 'parameters'
   x = struct();
   x.A = get(this,'A');
   x.B = get(this,'B');
   x.K = get(this,'K');
   x.Omega = get(this,'Omega');
case {'a','a*'}
   if all(size(this.A) == 0)
      x = [];
   else
      x = var2poly(this.A);
      if strcmp(attrib,'a*')
         x = -x(:,:,2:end,:);
      end
   end
case 'b'
   x = this.B;
case 't'
   x = this.T;
case 'u'
   x = this.U;
case {'const','c','k'}
   x = this.K;
case {'omega','cove','covresiduals'}
   if isempty(this.B)
      % reduced-form VAR
      x = this.Omega;
   else
      % structural VAR
      x = somega_(this);
   end
case {'sigma','covp','covparameters'}
   x = this.Sigma;
case 'aic'
   x = this.aic;
case 'sbc'
   x = this.sbc;
case {'eig','eigval','roots'}
   x = this.eigval;
case {'stableroots','explosiveroots','unitroots'}
   switch attrib
   case 'stableroots'
      test = @(x) abs(x) < (1 - realsmall);
   case 'explosiveroots'
      test = @(x) abs(x) > (1 + realsmall);
   case 'unitroots'
      test = @(x) abs(abs(x) - 1) <= realsmall;
   end
   x = nan(size(this.eigval));
   for ialt = 1 : nalt
      index = test(this.eigval(1,:,ialt));
      x(1,1:sum(index),ialt) = this.eigval(1,index,ialt);
   end
   index = all(isnan(x),3);
   x(:,index,:) = [];
case 'nhyper'
   x = this.nhyper;
case 'nper',
   x = length(this.sample);
case {'order','p'}
   x = p;
case 'sample'
   x = this.sample;
case 'comment'
   x = this.comment;
case 'cumlongrun'
   C = sum(var2poly(this.A),3);
   x = nan([ny,ny,nalt]);
   for ialt = 1 : nalt
      if rank(C(:,:,1,ialt)) == ny
         x(:,:,ialt) = C(:,:,1,ialt)\this.B(:,:,ialt);
      else
         x(:,:,ialt) = pinv(C(:,:,1,ialt))*this.B(:,:,ialt);
      end
   end
case {'constraints','restrictions'}
   x = w.Rr;
otherwise
   x = [];
   flag = false;
end

end
% End of subfunction get_().