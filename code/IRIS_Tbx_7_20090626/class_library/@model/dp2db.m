function d = dp2db(this,dpack,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.dp2db">idoc model.dp2db</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/03/30.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

d = dp2db(dpack,varargin{:});

% Add parameters to database.
for i = find(this.nametype == 4)
   d.(this.name{i}) = vech(this.assign(1,i,:));
end

% Add comments to time series.
for i = find(this.nametype <= 3)
   if isfield(d,this.name{i}) && istseries(d.(this.name{i}))
      d.(this.name{i}) = comment(d.(this.name{i}),this.namelabel{i});
   end
end

end
% End of primary function.