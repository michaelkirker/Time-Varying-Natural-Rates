function [X,index,selection,notfound] = select(X,descriptor,selection)
% SELECT  Retrieve submatrix (covariance, correlation, power spectrum or spectral density) corresponding to a selection of variables.
%
% Syntax
%   [X,selection,index,notfound] = select(X,descriptor,selection)
% Output arguments:
%   X [ numeric ] Requested submatrix.
%   selection [ cellstr ] Actually selected variables.
%   index [ numeric ] Index of actually selected rows and columns.
%   notfound [ cellstr ] Variables requested but not found.
% Required input arguments:
%   X [ numeric ] Matrix from which a submatrix will be retrieved.
%   descriptor [ cellstr ] List of variables in rows and columns of matrix X.
%   selection [ char | cellstr ] List of requested variables.
%
% See also MODEL/ACF, MODEL/XSF, VAR/ACF, VAR/XSF.

% The IRIS Toolbox 2009/04/09.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

if ischar(selection)
   selection = charlist2cellstr(selection);
end

if iscellstr(descriptor)
   descriptor = regexprep(descriptor,'@?log\((.*?)\)','$1');
else
   descriptor{1} = regexprep(descriptor{1},'@?log\((.*?)\)','$1');
   descriptor{2} = regexprep(descriptor{2},'@?log\((.*?)\)','$1');
end
selection = regexprep(selection,'@?log\((.*?)\)','$1');

if isnumeric(X) || iscell(X)
   s = struct();
   s.type = '()';
   if iscellstr(descriptor) && size(X,1) == size(X,2)
      if size(X,1) == length(descriptor)
         [index,notfound] = findnames(descriptor,selection);
         index(isnan(index)) = [];
         selection = descriptor(index);
         s.subs = {index,index};
      else
         error('Size of matrix and length of descriptor must match.');
      end
   elseif iscell(descriptor) && length(descriptor) == 2 && iscellstr(descriptor{1}) && iscellstr(descriptor{2})
      if size(X,1) == length(descriptor{1}) && size(X,2) == length(descriptor{2})
         index = cell([1,2]);
         if iscell(selection) && length(selection) == 2 && iscellstr(selection{1}) && iscellstr(selection{2})         
            [index{1},notfound1] = findnames(descriptor{1},selection{1});
            [index{2},notfound2] = findnames(descriptor{2},selection{2});      
         elseif iscellstr(selection)
            [index{1},notfound1] = findnames(descriptor{1},selection);
            [index{2},notfound2] = findnames(descriptor{2},selection);
         end
         notfound = [notfound1,notfound2];
         index{1}(isnan(index{1})) = [];
         index{2}(isnan(index{2})) = [];
         s.subs = index;
         selection = {descriptor{1}(index{1}),descriptor{2}(index{2})};
      else
         error('Size of matrix and length of descriptors must match.');
      end
   else
      error('Incorrect type of input argument(s).')
   end
   s.subs(end+1:ndims(X)) = {':'};
   X = subsref(X,s);
elseif isstruct(X)
   [index,notfound] = findnames(descriptor,selection);
   index(isnan(index)) = [];
   list = fieldnames(X);
   for i = 1 : length(list)
      if istseries(X.(list{i}))
         X.(list{i}) = X.(list{i}){:,index};
      end
   end
end

if ~isempty(notfound)
   warning('\nName "%s" not found in the list.',notfound{:});
end

end
% End of primary function.