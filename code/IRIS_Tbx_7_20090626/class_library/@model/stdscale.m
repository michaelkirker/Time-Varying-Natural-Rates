function m = stdscale(m,factor)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.stdscale">idoc model.stdscale</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/10/16.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

factor = vech(factor);
if all(factor == 1)
   return
end

nfactor = length(factor);
nalt = size(m.assign,3);
ne = sum(m.nametype == 3);
index = find(m.nametype == 4);
index(1:end-ne) = [];

if nfactor == 1
   m.assign(1,index,:) = m.assign(1,index,:)*factor;
else
   use = struct();
   for ialt = 1 : nalt
      if ialt <= nfactor
         use.factor = factor(ialt);
      end
      m.assign(1,index,ialt) = m.assign(1,index,ialt)*use.factor;
   end
end

end
% End of primary function.