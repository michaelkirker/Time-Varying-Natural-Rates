function [mloglik,Score,Info,se2] = diffloglik(this,data,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.diffloglik">idoc model.diffloglik</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/02/13.
% Copyright (c) 2007-2009 Jaromir Benes.

[data,range,varargin] = loglikdata_(this,data,varargin{:});

plist = varargin{1};
if ischar(plist)
   plist = charlist2cellstr(plist);
end
varargin(1) = [];

default = {...
   'display',false,@islogical,...
   'epspower',1/2,@isnumeric,...   
   'refresh',true,@islogical,...
   'solve',true,@islogical,...
   'sstate',false,@(x) islogical(x) || isempty(x) || isa(x,'function_handle'),...
};
[options,varargin] = extractopt(default(1:3:end),varargin{:});
options = passvalopt(default,options{:});
logliktoptions = loglikopt_(this,range,'t',varargin{:});

%********************************************************************
%! Function body.

% Multiple parameterizations are not allowed.
if size(this.assign,3) > 1
   error_(47,'DIFFLOGLIK');
end

% Find parameter names and create parameter index.
pindex = findnames(this.name(this.nametype == 4),plist);
tmpisnan = isnan(pindex);
if any(tmpisnan)
   error_(68,plist(tmpisnan));
end
pindex = pindex + sum(this.nametype < 4);

[mloglik,Score,Info,se2] = diffloglik_(this,data,range,plist,pindex,options,logliktoptions);

end
% End of primary function.