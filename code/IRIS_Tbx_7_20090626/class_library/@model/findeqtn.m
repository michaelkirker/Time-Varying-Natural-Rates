function varargout = findeqtn(m,varargin)
% <a href="model/findeqtn">FINDEQTN</a>  Find equations by matching equation labels.
%
% Syntax:
%    [list,list,...] = findeqtn(m,rexp,rexp,...)
% Output arguments:
%    list [ cellstr ] List of equations that match regular expression.
% Required input arguments:
%    m [ model ] Model.
%    rexp [ char ] Labels to be found or regular expressions to be matched.

% The IRIS Toolbox 2009/06/12.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

for i = 1 : length(varargin)
   index = regexp(m.eqtnlabel,sprintf('^%s$',varargin{i}));
   index = find(~cellfun(@isempty,index));
   if isempty(index)
      varargout{i} = '';
   elseif length(index) == 1
      varargout{i} = m.eqtn{index};
   else
      varargout{i} = m.eqtn(index);
   end
end

end
% End of primary function.