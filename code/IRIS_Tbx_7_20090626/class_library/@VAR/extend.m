function x = extend(w,x,nproj,varargin)
%
% <a href="matlab: edit VAR/extend">EXTEND</a>  Extend VAR data with optimal linear projection forward and/or backward.
%
% Syntax:
%   data = extend(w,data,nproj,...)
% Required input arguments:
%   w [ VAR ] VAR model.
%   data [ tseries] Data associated with VAR.
%   nproj [ numeric ] Number of periods.
% <a href="options.html">Optional input arguments:</a>
%   'backward' [ <a href="default.m">true</a> | false ] Extend data backwards.
%   'deviation' [ true | <a href="default.m">false</a> ]  Data are deviations from asymptotic mean.
%   'forward' [ <a href="default.m">true</a> | false ] Extend data forwards.
%
% The IRIS Toolbox 2008/02/19. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

default = {...
  'backward',true,@islogical,...
  'deviation',false,@islogical,...
  'forward',true,@islogical,...
};
options = passvalopt(default,varargin{:});

% ###########################################################################################################
%% function body

[ny,p,nalt] = size(w);
if ~any(size(x,2) == [2*ny,ny])
  error_(16);
end

[data,range] = double(x,'min');
newstart = range(1);

ndata = size(data,3);
nloop = max([nalt,ndata]);
if nloop > ndata
  data = data(:,:,[1:end,end*ones([1,nloop-ndata])]);
end

% fetch y and e from data
y = data(:,1:ny,:);
if size(data,2) == 2*ny
  e = data(:,ny+1:end,:);
else
  e = nan(size(y));
end
nper = size(y,1);

% insuffiecient number of observations
if nper < p
  warning_(11);
  return
end

% forward projection
if options.forward
  extend_();
  e = [e;zeros([nproj,ny,nloop])];
end

% backward projection
if options.backward
  w = reverse(w);
  y = y(end:-1:1,:,:);
  extend_();
  y = y(end:-1:1,:,:);
  e = [zeros([nproj,ny,nloop]);e];
  newstart = newstart - nproj;
end

x = replace(x,[y,e],newstart);

% end of function body

% ###########################################################################################################
%% nested function extend_()

function extend_()
  y = permute(y,[2,1,3]);
  last = size(y,2);
  y(:,end+(1:nproj),:) = NaN;
  for iloop = 1 : nloop
    if iloop <= nalt
      Ai = w.A(:,:,iloop);
      Ki = w.K(:,iloop);
    end
    for t = last + (1 : nproj)
      y(:,t,iloop) = Ai*vec(y(:,t-1:-1:t-p,iloop));
      if ~options.deviation
        y(:,t,iloop) = y(:,t,iloop) + Ki;
      end
    end
  end
  y = permute(y,[2,1,3]);
end
% end of nested function extend_()

end
% end of primary function