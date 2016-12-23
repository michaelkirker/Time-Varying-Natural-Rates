function varargout = isstationary(this,varargin)
% ISSTATIONARY  True if there are no unit roots in model transition matrix.
%
% Syntax:
%   flag = isstationary(this)
%   [flag,flag,...] = isstationary(this,expression,expression,...)
% Output arguments:
%   this [ model ] Queried model.
%   flag [ true | false ] Tue if model or combination of variables is stationary.
% Required input arguments:
%   expression [ char ] Combination of transition variables to be tested.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if isempty(varargin)
   % Called flag = isstationary(model).
   if isempty(this.solution{1})
      varargout{1} = NaN;
   else
      nb = size(this.solution{1},2);
      realsmall = getrealsmall();
      varargout{1} = permute(all(abs(this.eigval(1,1:nb,:)) < 1-realsmall,2),[1,3,2]);
   end
else
   % Called [flag,...] = isstationary(model,expression,...).
   [varargout{1:length(varargin)}] = ...
      iscointegrated_(this,varargin{:});
end

end
% End of primary function.

%********************************************************************
%! Subfunction iscointegrated_().

function varargout = iscointegrated_(this,varargin)

realsmall = getrealsmall();
xvector = get(this,'xvector');
xvector = strrep(xvector,'(','\(');
xvector = strrep(xvector,')','\)');
nxvector = length(xvector);

varargout = cell([1,length(varargin)]);
for iarg = 1 : length(varargin)
   flag = thisargin_(varargin{iarg});
   varargout{iarg} = thisargin_(varargin{iarg});
end

%********************************************************************
% Nested function thisargin_().

   function flag = thisargin_(comb)
      present = false(size(xvector));
      comb = regexprep(comb,'\s+','');
      for j = 1 : nxvector
         pattern = ['\<',xvector{j},'\>'];
         present(j) = ~isempty(regexp(comb,pattern,'once'));
         if present(j)
            replace = sprintf('x(%g)',j);
            comb = regexprep(comb,pattern,replace);
         end
      end
      w = evalcomb_(comb,present);
      [nx,nb,nalt] = size(this.solution{1});
      nf = nx - nb;
      flag = false([1,nalt]);
      for iloop = 1 : nalt
         Tf = this.solution{1}(1:nf,:,iloop);
         U = this.solution{7}(:,:,iloop);
         nunit = sum(abs(abs(this.eigval(1,1:nb,iloop)) - 1) <= realsmall);
         test = w*[Tf(:,1:nunit);U(:,1:nunit)];
         flag(iloop) = all(abs(test) <= realsmall);
      end
   end
% End of nested function thisargin_().

end
% End of subfunction iscointegrated_().

%********************************************************************
%! Subfunction evalcomb_().

function coeff = evalcomb_(expr,present)
   nxvector = length(present);
   x = zeros([1,nxvector]);
   const = eval(expr);
   coeff = zeros([1,nxvector]);
   for i = find(present)
      x(i) = 1;
      tmp = eval(expr);
      coeff(i) = tmp - const;
      x(i) = 0;
   end
end
% End of subfunction evalcomb_().