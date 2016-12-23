function this = subsref(this,s)
% SUBSREF  Subscripted reference for VAR objects.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if length(s) == 1 && strcmp(s.type,'()') && length(s.subs) == 1
   nalt = size(this.A,3);
   if ischar(s.subs) && strcmp(s.subs{1},':');
      index = 1 : nalt;
   else
      index = s.subs{1};
   end
   this.A = this.A(:,:,index);
   this.K = this.K(:,index);
   this.Omega = this.Omega(:,:,index);
   this.aic = this.aic(1,index);
   this.sbc = this.sbc(1,index);
   this.eigval = this.eigval(1,:,index);
   this.T = this.T(:,:,index);
   this.U = this.U(:,:,index);
   if ~isempty(this.Sigma)
      % Cov of parameters.
      this.Sigma = this.Sigma(:,:,index);
   end
   if ~isempty(this.B)
      % Structural VAR.
      this.B = this.B(:,:,index);
      this.std = this.std(1,index);
   end
else
   error('Invalid subscripted reference to VAR object.');
end

end
% End of function body.