function [this,flag,npath,eigval] = sstate(this,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.sstate">idoc model.sstate</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/01/27.
% Copyright 2007-2009 Jaromir Benes.

% IRIS default options for Optimisation Toolbox.
aux = optimset('display','iter','largescale','off','tolx',1e-12,'tolfun',1e-12,'levenbergmarquardt','off');

default = {
   'algorithm','lsqnonlin',@(x) any(strcmp(x,{'lsqnonlin','fsolve'})),...
   'blocks',true,@islogical,...
   'display','iter',@(x) isempty(x) || islogical(x) || any(strcmp(x,{'iter','final','off','notify'})),...
   'fix',{},@(x) isempty(x) || iscellstr(x) || ischar(x),...
   'fixallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x),...
   'maxiter',1000,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x,...
   'maxfunevals',500,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x,...
   'optimset',struct,@(x) isempty(x) || isstruct(x),...
   'randomise',[1,1],@(x) isnumeric(x) && length(x) == 2,...
   'refresh',true,@islogical,...
   'solve',true,@islogical,...
   'tolx',1e-12,@(x) isnumeric(x) && length(x) == 1 && x > 0,...
   'tolfun',1e-12,@(x) isnumeric(x) && length(x) == 1 && x > 0,...
};
options = passvalopt(default,varargin{1:end});

% rewrite IRIS options with user-supplied OPTIMSET struct
options.optimset = optimset(aux,options.optimset);

% rewrite IRIS options with individually supplied options
if ~isempty(options.display)
   if ischar(options.display)
      options.optimset = optimset(options.optimset,'display',options.display);
   elseif islogical(options.display)
      options.optimset = optimset(options.optimset,'display',iff(options.display,'iter','off'));
   end
end

if ~isempty(options.maxiter)
   options.optimset = optimset(options.optimset,'maxiter',options.maxiter);
end

if ~isempty(options.maxfunevals)
   options.optimset = optimset(options.optimset,'maxfunevals',options.maxfunevals);
end

if ~isempty(options.tolx)
   options.optimset = optimset(options.optimset,'tolx',options.tolx);
end

if ~isempty(options.tolfun)
   options.optimset = optimset(options.optimset,'tolfun',options.tolfun);
end

if ischar(options.fix) && ~isempty(options.fix)
   options.fix = charlist2cellstr(options.fix);
end

if ischar(options.fixallbut) && ~isempty(options.fixallbut)
   options.fixallbut = charlist2cellstr(options.fixallbut);
end

% convert fixallbut to fix
if iscellstr(options.fixallbut) && ~isempty(options.fixallbut)
   list = this.name(this.nametype <= 2);
   index = findnames(list,options.fixallbut);
   list(index) = [];
   options.fix = list;
end

%********************************************************************
%! Function body.

if ~this.linear
   % Refresh dynamic links.
   if options.refresh && ~isempty(this.refresh)
      this = refresh(this);
   end
   % Throw a warning if some parameters are NaN.
   [flag,list] = isnan(this,'parameters');
   if flag
      warning_(2,list);
   end
else
   if options.solve
      [this,npath,eigval] = solve(this,'refresh',options.refresh);
   elseif options.refresh && ~isempty(this.refresh)
      this = refresh(this);
   end
end
[this,flag] = sstate_(this,options);

% Refresh also after sstate because some of the steady states can be
% referred to in dynamic links.
if options.refresh && ~isempty(this.refresh)
   this = refresh(this);
end

end
% End of primary function.