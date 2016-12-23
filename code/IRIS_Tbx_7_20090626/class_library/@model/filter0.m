function [this,smooth,se2,delta,pe,F] = filter0(this,data,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.filter">idoc model.filter</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/27.
% Copyright 2007-2009 Jaromir Benes.

% Get array of measurement variables.
[data,range,varargin,outputformat] = loglikdata_(this,data,varargin{:});

% LOGLIKT2_ specific options.
loglikoptions = loglikopt_(this,range,'t',varargin{:});

%********************************************************************
%! Function body.

% Call Kalman filter.
%[mloglik,se2,F,pe,delta,ans,ans,pred,smooth] = loglikt2_(this,data,range,[],loglikoptions);
[mloglik,se2,F,pe,delta,Pdelta,supply,pred,smooth] = loglikt_(this,data,range,[],loglikoptions);

% Dump inverses of FMSE matrices.
F = F{1};

% Make sure model, out-of-lik params and se2 all have the same number of
% alternative parameterisations.
if loglikoptions.relative
   nout = max([size(this.assign,3),size(delta,3),length(se2)]);
else
   nout = max([size(this.assign,3),size(delta,3)]);
end   
if size(this.assign,3) < nout
   this = nalter(this,nout);
end
if ~isempty(delta) && size(delta,3) < nout
   delta(:,:,end+1:nout) = delta(:,:,end);
end
if length(se2) < nout
   se2(end+1:nout) = se2(end);
end

% Assign out-of-lik params in model object.
if ~isempty(delta)
   index = find(strcmp('outoflik',varargin));
   plist = varargin{index+1};
   if ischar(plist)
      plist = charlist2cellstr(plist);
   end
   % assign out-of-lik parameters
   for i = 1 : length(plist)
      index = strcmp(plist{i},this.name);
      this.assign(1,index,:) = delta(1,i,:);
   end
   this = refresh(this);
end

% Scale std devs by estimated factor in model object.
if loglikoptions.relative
   this = stdscale(this,sqrt(se2));
end

% Convert dpack to dbase if requested.
if strcmpi(outputformat,'dbase')
   smooth.mean = dp2db(this,smooth.mean);
   smooth.std = dp2db(this,smooth.mse);
   smooth = rmfield(smooth,'mse');
end

% Create database of out-of-lik parameter estimates.
tmpdelta = delta;
delta = struct();
if nargout > 3 && ~isempty(tmpdelta)
   for i = 1 : length(plist)
      delta.(plist{i}) = vech(tmpdelta(1,i,:));
   end
end

% Create database of time series with prediction errors.
pe = pestruct_(this,pe,range);

end
% End of primary function.