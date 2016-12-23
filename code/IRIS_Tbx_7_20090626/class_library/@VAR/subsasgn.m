function this = subsasgn(this,s,x)
% SUBSREF  Subscripted assignment for VAR objects.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if length(s) == 1 && strcmp(s.type,'()') && length(s.subs) == 1 && (isvar(x) || (isnumeric(x) && isempty(x)))
   nalt = size(this.A,3);
   if ischar(s.subs) && strcmp(s.subs{1},':');
      index = 1 : nalt;
   else
      index = s.subs{1};
   end
   if isempty(x)
      assignempty_();
   else
      nx = size(x.A,3);
      if nx == 1
         if islogical(index) && sum(index) > 1
            rhs = ones([1,sum(index)]);
         elseif length(index) > 1
            rhs = ones([1,length(index)]);
         end
      else
         rhs = 1 : nx;
      end   
      assignvar_();
   end
else
   error('Invalid subscripted reference to VAR object.');
end

% End of function body.

%********************************************************************
% Nested function assignvar_().
   function assignvar_()
      this.A(:,:,index) = x.A(:,:,rhs);
      this.K(:,index) = x.K(:,rhs);
      this.Omega(:,:,index) = x.Omega(:,:,rhs);
      this.aic(:,index) = x.aic(:,rhs);
      this.sbc(:,index) = x.sbc(:,rhs);
      this.eigval(:,:,index) = x.eigval(:,:,rhs);
      this.T(:,:,index) = x.T(:,:,rhs);
      this.U(:,:,index) = x.U(:,:,rhs);
      if ~isempty(this.Sigma) && ~isempty(x.Sigma)
         % Cov of parameters.
         this.Sigma(:,:,index) = x.Sigma(:,:,rhs);
      elseif ~isempty(this.Sigma) || ~isempty(x.Sigma)
         error('The VAR objects assigned are incompatible: Covariance matrix for parameter estimates.');
      end
      if ~isempty(this.B) && ~isempty(x.B)
         % Structural VAR.
         this.B(:,:,index) = x.B(:,:,rhs);
         this.std(:,index) = x.std(:,:,rhs);
      elseif ~isempty(this.B) || ~isempty(x.B)
         error('The VAR objects assigned are incompatible: Structural identification matrix.');
      end
   end 
% End of nested function assignvar_().
   
%********************************************************************
% Nested function assignempty_().
   function assignempty_()
      this.A(:,:,index) = [];
      this.K(:,index) = [];
      this.Omega(:,:,index) = [];
      this.aic(:,index) = [];
      this.sbc(:,index) = [];
      this.eigval(:,:,index) = [];
      this.T(:,:,index) = [];
      this.U(:,:,index) = [];
      if ~isempty(this.Sigma)
         % Cov of parameters.
         this.Sigma(:,:,index) = [];
      end
      if ~isempty(this.B)
         % Structural VAR.
         this.B(:,:,index) = [];
         this.std(:,index) = [];
      end
   end 
% End of nested function assignempty_().
   
end
% End of function body.
