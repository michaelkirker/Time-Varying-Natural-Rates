function varargout = variableEditor_(action,this,varargin)
% VARIABLEEDITOR_  Implement size, subsref, subsasgn for calls from Variable Editor 2009a or higher.

% The IRIS Toolbox 2009/01/16.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

switch action
case 'size'
   data = this.data(:,:);
   data = [nan([size(data,1),2]),data];
   [varargout{1:nargout}] = size(data,varargin{:});
case 'subsref'
   [y,p,f] = dat2ypf(get(this,'range'));
   data = [y(:),p(:),this.data(:,:)];
   [varargout{1:nargout}] = subsref(data,varargin{:});
case 'subsasgn'
   start = get(this,'start');
   nper = size(this.data,1);
   % If all rows are selected in Variable Editor,
   % call ':' instead of 1 : end. This enables deletion
   % of whole columns, because x(:,...) = [] works,
   % but x(1:end,...) = [] does not in Matlab.
   if all(vech(varargin{1}.subs{1}) == (1 : nper))
      varargin{1}.subs{1} = ':';
   else
      varargin{1}.subs{1} = start + varargin{1}.subs{1} - 1;
   end
   varargin{1}.subs{2} = varargin{1}.subs{2} - 2;
   if varargin{1}.subs{2} <= 0
      warning('Cannot change tseries dates in Variable Editor.');
   else
      this = subsasgn(this,varargin{:});
   end
   varargout{1} = this;
end

end
% End of primary function.