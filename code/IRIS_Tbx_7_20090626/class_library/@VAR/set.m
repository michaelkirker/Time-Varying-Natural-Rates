function this = set(this,varargin)
%
% <a hraf="matlab: edit VAR/set">SET</a>  Set VAR attributes.
%
% Syntax:
%   this = set(this,...)
% Required input arguments:
%   this [ VAR ] VAR object.
% <a href="options.html">Optional input arguments:</a>
%   'A' [ numeric ] Transition matrix.
%   'B' [ numeric ] Innovation multiplier matrix.
%   'K' [ numeric ] Constant.
%   'comment' [ any ] Comments.
%
% The IRIS Toolbox 2008/02/20. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

if ~iscellstr(varargin(1:2:end))
   error('Incorrect type of input argument(s).');
end

% ===========================================================================================================
%! function body

invalid = {};

for i = 1 : 2 : length(varargin)
   name = strtrim(varargin{i});
   value = varargin{i+1};
   [this,flag] = set_(this,name,value);
   if ~flag
      invalid{end+1} = name;
   end
end

if ~isempty(invalid)
   multierror('Unrecognised attribute: "%s".',unrecognized);
end

end
% end of primary function

% ===========================================================================================================
%! subfunction set_()

function [this,invalid] = set_(this,invalid,name,value)

   try
      % Try to import Time Domain package directory.
      import('time_domain.*');
   end

  flag = true;
  realsmall = getrealsmall();
  [ny,p,nalt] = size(this);

  switch lower(name)
  case 'a'
    this.A(:) = varargin{i+1}(:);
    this = schur_(this);
  case 'b'
    this.B = varargin{i+1}(:);
    if nalt > 1 && size(this.B,3) == 1
      this.B = this.B(:,:,ones([1,nalt]));   
   end
  case {'const','c','k'}
    this.K(:) = varargin{i+1}(:);
  case 'comment'
    this.comment = varargin{i+1};
  case 'mean'
    nonstat = [];
    eigval = eig(this);
    mean_ = mean(this);
    x = varargin{i+1};
    if nalt > 1 && size(x,3) == 1
      x = x(:,1,ones([1,nalt]));
    end
    for ialt = 1 : nalt
      index = isnan(x(:,1,ialt));
      if any(index)
        x(index,1,ialt) = mean_(index,1,ialt);
      end
      if any(abs(eigval(1,:,ialt)) > 1-realsmall)
        nonstat(end+1) = ialt;
      else
        this.K(:,ialt) = sum(var2poly(this.A(:,:,ialt)),3)*x(:,1,ialt);
      end
    end
    if ~isempty(nonstat)
      warning_(7,sprintf(' #%g',nonstat));
    end
  otherwise
    flag = false;
  end

end
% end of subfunction set_()