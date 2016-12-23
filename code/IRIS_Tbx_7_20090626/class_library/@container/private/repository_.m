function varargout = repository_(action,varargin)

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.

mlock();
persistent NAME DATA LOCK;
 
%********************************************************************
%! Function body.

switch action
case 'clear'
   clear_();
case 'init'
   if isnumeric(NAME) && isempty(NAME)
      clear_();
   end
case 'NAME'
   varargout{1} = NAME;
case 'DATA'
   varargout{1} = DATA;
case 'LOCK'
   varargout{1} = LOCK;
case 'locked'
   varargout{1} = NAME(LOCK);
case 'load'
   NAME = varargin{1};
   DATA = varargin{2};
   LOCK = varargin{3};
case 'isin'
   varargout{1} = any(strcmp(NAME,varargin{1}));
case 'put'
   [found,locked,index] = find_(varargin{1});
   if ~found
      NAME{end+1} = varargin{1};
      DATA{end+1} = varargin{2};
      LOCK(end+1) = false;
      varargout{1} = true;
      return
   end
   if locked
      varargin{1} = false;
      return
   end
   varargout{1} = true;
   DATA{index} = varargin{2};
case 'get'
   index = strcmp(NAME,varargin{1});
   if any(index)
      index = find(index,1);
      varargout{1} = true;
      varargout{2} = DATA{index};
   else
      varargout{1} = false;
      varargout{2} = [];
   end
case 'remove'
   [found,locked,index] = find_(varargin{1});
   if ~found
      varargout{1} = false;
      varargout{2} = NaN;
      return
   end
   if locked
      varargout{1} = true;
      varargout{2} = false;
      return
   end
   varargout{1} = true;
   varargout{2} = true;
   NAME(index) = [];
   DATA(index) = [];
   LOCK(index) = [];         
case {'lock','unlock'}
   if nargin == 1
      LOCK(:) = strcmp(action,'lock');
      return
   end
   index = strcmp(NAME,varargin{1});
   if any(index)
      varargout{1} = true;
      index = find(index);
      LOCK(index) = strcmp(action,'lock');
   else
      varargout{1} = false;
   end
case 'islocked'
   index = strcmp(NAME,varargin{1});
   if any(index)
      index = find(index,1);
      varargout{1} = true;
      varargout{2} = LOCK(index);
   else
      varargout{1} = false;
      varargout{2} = NaN;
   end   
case 'list'
   varargout{1} = NAME;
end

%********************************************************************
%! Nested function clear_().

   function clear_()
      NAME = {};
      DATA = {};
      LOCK = false([1,0]);      
   end
% End of nested function clear_().

%********************************************************************
%! Nested function find_().

   function [found,locked,index] = find_(name)
      index = find(strcmp(NAME,name),1);
      found = ~isempty(index);
      locked = LOCK(index);
   end
% End of nested function find_().

end
% End of primary function.