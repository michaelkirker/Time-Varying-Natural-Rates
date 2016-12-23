function disp(x,name,disp2d)
% DISPLAY  Display tseries.

% The IRIS Toolbox 2009/04/23.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 2
   name = '';
end

if nargin < 3
   disp2d = @disp2ddefault_;
end

%********************************************************************
%! Function body.

tmpsize = size(x.data);
nper = tmpsize(1);
fprintf('\ttseries object: %g%s\n',nper,sprintf('-by-%g',tmpsize(2:end)));
loosespace();
start = x.start;
data = x.data;
dispnd_(start,data,x.comment,[],name,disp2d);
disp(x.contained);
loosespace();

end
% End of primary function.

%********************************************************************
%! Subfunction dispnd_().

function dispnd_(start,data,comment,position,name,disp2d) 
   tmpsize = size(data);
   ndims = length(tmpsize);
   if length(tmpsize) > 2
      s = struct();
      s.type = '()';
      s.subs = cell([1,ndims]);
      s.subs(1:ndims-1) = {':'};
      for i = 1 : tmpsize(end)
         s.subs(ndims) = {i};
         dispnd_(start,subsref(data,s),subsref(comment,s),[i,position],name,disp2d);
      end
   else
      if ~isempty(position)
         fprintf('%s{:,:%s} =\n',name,sprintf(',%g',position));
         loosespace();
      end
      nper = tmpsize(1);
      if nper > 0
         [dates,data] = disp2d(start,data);
         try
            datastr = num2str(data,irisget('tseriesformat'));
         catch Error
            datastr = num2str(data);
         end
         disp([dates,datastr]);
      end
      disp(comment);
   end
end
% End of subfunction dispnd_().

%********************************************************************
%! Subfunction disp2ddefault_().
function [dates,data] = disp2ddefault_(start,data)
   [nper,nx] = size(data);
   range = start + (0 : nper-1);
   tab = sprintf('\t');
   sep = sprintf(': ');
   dates = [tab(ones([1,nper]),:),strjust(dat2char(range)),sep(ones([1,nper]),:)];
end
% End of subfunction disp2ddefault_().