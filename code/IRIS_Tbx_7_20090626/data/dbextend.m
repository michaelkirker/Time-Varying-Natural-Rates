function d = dbextend(d,varargin)
% <a href="matlab: edit dbextend">DBEXTEND</a>  Extend/overwrite time series in one database with observations available from another database(s).
%
% Syntax:
%    d = dbextend(d1,d2,...)
% Output arguments:
%    d [ struct ] Primary database.
% Required input arguments:
%    dn [ struct ] Database(s) whose time series observations will be used to extend the primary database.

% The IRIS Toolbox 2009/04/22.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

list = fieldnames(d);
for i = 1 : length(varargin)   
   for j = 1 : length(list)
      % Check if the secondary database has this entry and if it is a time series.
      if ~istseries(d.(list{j})) || ~isfield(varargin{i},list{j}) || ~istseries(varargin{i}.(list{j}))
         continue
      end
      % Check if the primary and secondary time series frequencies are the same.
      if get(d.(list{j}),'freq') ~= get(varargin{i}.(list{j}),'freq')
         continue
      end
      d.(list{j}) = [d.(list{j});varargin{i}.(list{j})];
   end
end      

end
% End of primary function.