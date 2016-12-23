function d = dboverlay(varargin)
%
% <a href="matlab: edit dboverlay">DBOVERLAY</a>  Splice databases overlaying field by field.
%
% Syntax:
%   d = dboverlay(d1,d2,...)
% Output arguments:
%   d [ struct ] Output database.
% Required input arguments:
%   d1,d2,... [ struct ] Input databases. Fields of d2 superimpose fields of d1, etc.
%
% The IRIS Toolbox 2007/10/04. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

if nargin == 0
  d = struct();
else
  d = varargin{1};
end

for k = 2 : nargin
  list = fieldnames(varargin{k});
  for m = 1 : length(list)
    try
      if istseries(d.(list{m})) && istseries(varargin{k}.(list{m}))
        d.(list{m}) = [d.(list{m});varargin{k}.(list{m})];
      else
        d.(list{m}) = varargin{k}.(list{m});
      end
    catch
      d.(list{m}) = varargin{k}.(list{m});
    end
  end
end

end

%% end of primary function ----------------------------------------------------------------------------------