function savestruct(fname,x)
% <a href="matlab: edit utils/io/savestruct">SAVESTRUCT</a>  Save struct-convertible object as struct. 
%
% Syntax:
%   savestruct(fname,x)
%   savestruct(x,fname)
% Required input arguments:
%   fname [ char ] File name.
%   x [ model | tseries | VAR ] Object to save.

% The IRIS Toolbox 2007/10/23.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! Function body.

% allow both savestruct(fname,d) and savestruct(d,fname)
if (isobject(fname) || isstruct(fname) || iscell(fname)) && ischar(x)
   [fname,x] = deal(x,fname);
end

c = class(x);

switch c
case 'model'
   x = struct(x);
   % Convert symbolic derivative function handles to char.
   for i = 1 : length(x.deqtnF)
      for j = 1 : length(x.deqtnF{i})
         if isa(x.deqtnF{i}{j},'function_handle')
            x.deqtnF{i}{j} = func2str(x.deqtnF{i}{j});
         end
      end
   end
   % Convert full-equation function handle to char.
   for i = 1 : length(x.eqtnF)
      if isa(x.eqtnF{i},'function_handle')
         x.eqtnF{i} = func2str(x.eqtnF{i});
      end
   end
case {'VAR','tseries','container','struct'}
   x = struct(x);
otherwise
   error('Objects of class %s cannot be saved using SAVESTRUCT.',class(x));
end

x.SAVESTRUCT_CLASS = c;

% Save individual fields of underlying struct.
save(fname,'-struct','x','-mat');

end 
% End of primary function.
