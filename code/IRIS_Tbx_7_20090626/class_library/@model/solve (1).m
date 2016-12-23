function [m,npath,eigval] = solve(m,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.solve">idoc model.solve</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/10/15.
% Copyright (c) 2007-2008 Jaromir Benes.

persistent logbook;

% return and clear logbook
if ~isempty(varargin) && strcmp(varargin{1},'logbook')
  if isempty(logbook)
    initlogbook_();
  end
  m = logbook;
  initlogbook_();
  return
end

default = {...
  'alt',inf,@(x) isnumeric(x) || islogical(x),...
  'double',true,@islogical,...
  'expand',0,@(x) isnumeric(x) && length(x) == 1,...
  'logbook',false,@islogical,...
  'forward',0,@(x) isnumeric(x) && length(x) == 1,...
  'refresh',true,@islogical,...
  'select',true,@islogical,...
  'system',[],@(x) isempty(x) || isstruct(x),...
  'tolerance',getrealsmall(),@(x) isnumeric(x) && length(x) == 1,...
};
options = passvalopt(default,varargin{1:end});

if options.forward > 0 && options.expand == 0
   options.expand = options.forward;
end

%********************************************************************
%! Function body.

% No parameterisations.
if isempty(options.alt) || (islogical(options.alt) && ~any(options.alt))
  return
end

% Refresh dynamic links.
if options.refresh && ~isempty(m.refresh)
   m = refresh(m,options.alt);
end

% Warning if some parameters are not assigned.
[flag,list] = isnan(m,'parameters');
if flag
  warning_(2,list);
end

alt = vech(options.alt);
if isnumeric(alt) && any(isinf(alt))
  alt = 1 : size(m.assign,3);
end

% Warning if some log-lin variables have non-positive steady state.
chklog_(m,alt);

[m,npath] = solve_(m,options.expand,options.tolerance,options.alt,options.select,options.system);

if iswarning('model')
  % no stable solution
  index = npath == 0;
  if any(index)
    warning_(26,{sprintf(' #%g',find(index))});
  end
  % infinitely many stable solutions
  index = isinf(npath);
  if any(index)
    warning_(27,{sprintf(' #%g',find(index))});
  end
  % complex derivatives
  index = imag(npath) ~= 0;
  if any(index)
    warning_(29,{sprintf(' #%g',find(index))});
  end
  % NaN derivatives
  index = isnan(npath);
  if any(index)
    warning_(33,{sprintf(' #%g',find(index))});
  end
  % singularity in state space
  index = npath == -1;
  if any(index)
    warning_(32,{sprintf(' #%g',find(index))});
  end
  index = npath ~= 1;
  if options.logbook
    if isempty(logbook)
      initlogbook_();
    end
    try
      logbook.npath(1,end+(1:sum(index))) = vech(npath(index));
      logbook.assign(end+(1:sum(index)),1:max([size(logbook.assign,2),size(m.assign,2)])) = permute(m.assign(1,:,index),[3,2,1]);
    end
  end
end

if nargout > 2
   eigval = m.eigval;
end

% End of function body.

%********************************************************************
%! Nested function initlogbook_().

function initlogbook_()
   logbook = struct();
   logbook.npath = [];
   logbook.assign = [];
end
% End of nested function initlogbook_().

end
% End of primary function.