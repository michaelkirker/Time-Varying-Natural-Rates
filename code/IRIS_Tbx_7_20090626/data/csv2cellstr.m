function x = csv2cellstr(fname,varargin)
% CSV2CELLSTR  Convert CSV file to cell array of strings.

% The IRIS Toolbox 2009/02/24.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'includeemptyrows',false,@islogical,...
   'includeemptycols',false,@islogical,...
};
options = passvalopt(default,varargin{:});

if ischar(options.nan)
   options.nan = charlist2cellstr(options.nan);
end

%********************************************************************
%! Function body.

fid = fopen(fname,'r');
if fid == -1
   if ~exist(fname,'file')
      error('Unable to find file "%s".',fname);
   else
      error('Unable to open file "%s" for reading.',fname);
   end
end

x = {};
while ~feof(fid)
   line = fgetl(fid);
   tokens = regexp(line,'\s*([^",]*?)\s*,|\s*([^",]*?)\s*$|"(.*?)"\s*,|"(.*?)"\s*$','tokens');
   tokens = [tokens{:}];
   if ~options.includeemptyrows && ...
      all(cellfun(@isempty,tokens))
      continue
   end
   if isempty(x)
      x = tokens;
   else
      ntokens = length(tokens);
      ncol = size(x,2);
      if ntokens > ncol
         x(:,end+1:ntokens) = {''};
      else
         tokens(:,end+1:ncol) = {''};
      end
      x(end+1,:) = tokens;
   end
end

if ~options.includeemptycols
   index = all(cellfun(@isempty,x),1);
   x(:,index) = [];
end

if fclose(fid) == -1
   warning('Unable to close file "%s" after reading.',fname);
end

end
% End of primary function.