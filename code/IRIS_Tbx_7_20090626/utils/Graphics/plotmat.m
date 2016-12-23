function [hp,hn,hx,hs] = plotmat(X,varargin)
% <a href="utils/graphics/plotmat">PLOTMAT</a>  Visualise 2D matrix.
%
% Syntax:
%   [hp,hn,hs] = plotmat(X,...)
% Output arguments:
%   hp [ numeric ] Handles to positive-value or zero discs.
%   hn [ numeric ] Handles to negative-value discs.
%   hx [ numeric ] Handles to NaN or Inf marks.
%   hs [ nuermic ] Handles to frames.
% Input arguments:
%   X [ numeric ] 2D matrix or vector to be visualise.
% <a href="options.html">Optional input arguments:</a>
%   'colnames' [ char | cellstr | <a href="default.m">empty</a> ] Column names.
%   'rownames' [ char | cellstr | <a href="default.m">empty</a> ] Row names.
%   'scale' [ numeric | <a href="default.m">max(max(abs(X)))</a> ] Scale factor (maximum possible displayed value).
%   'frame' [ true | <a href="default.m">false</a> ] Draw maximum-value frame around discs.

% The IRIS Toolbox 2009/04/15.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if ndims(X) > 2
  error('Input matrix must not have 3rd or higher dimensions.');
end

[nrow,ncol] = size(X);

arglist = varargin;
[arglist,rownames] = getoption(arglist,'rownames',{});
[arglist,colnames] = getoption(arglist,'colnames',{});
[arglist,scale] = getoption(arglist,'scale',max(max(abs(X(~isnan(X) & ~isinf(X))))));
[arglist,frame] = getoption(arglist,'frame',false);

radius = 0.45;
X = X/scale * radius;
nanlength = 0.1;
gray = 0.7*[1,1,1];

hp = [];
hn = [];
hx = [];
hs = [];
status = ishold();
for row = 1 : nrow
  for col = 1 : ncol
    x = X(row,col);
    if isnan(x) || isinf(x)
      hx(end+1) = plot(col+[-1,1]*nanlength,1+nrow-row+[1,-1]*nanlength);
      hold('on');
      hx(end+1) = plot(col+[-1,1]*nanlength,1+nrow-row+[-1,1]*nanlength);
    else
      h = plotcircle(col,1+nrow-row,abs(x),'fill',true);
      if x >= 0
        hp(end+1) = h;
      else
        hn(end+1) = h;
      end
      hold('on');
      hs(end+1) = plotcircle(col,1+nrow-row,radius,'color',gray);
    end
  end
end
if ~status
  hold('off');
end

set(hp,'facecolor',[0,0,1],'edgecolor','none');
set(hn,'facecolor',[1,0,0],'edgecolor','none');
if ~frame
  set(hs,'linestyle','none','marker','none');
end
set(hx,'linewidth',1.5,'color',gray);

axis('equal');
set(gca,'xlim',[0,ncol+1],'ylim',[0,nrow+1],'xtick',1:ncol,'ytick',1:nrow,'xlimmode','manual','ylimmode','manual','xtickmode','manual','ytickmode','manual');

if ~isempty(rownames)
  if ischar(rownames)
    rownames = charlist2cellstr(rownames);
  end
  if length(rownames) < nrow
    rownames(end+1:nrow) = {''};
  end
  set(gca,'yticklabel',rownames(nrow:-1:1));
end

if ~isempty(colnames)
  if ischar(colnames)
    colnames = charlist2cellstr(colnames);
  end
  if length(colnames) < ncol
    colnames(end+1:ncol) = {''};
  end
  set(gca,'xticklabel',colnames);
end

set(gca,'xticklabelmode','manual','yticklabelmode','manual');

end
% End of primary function.