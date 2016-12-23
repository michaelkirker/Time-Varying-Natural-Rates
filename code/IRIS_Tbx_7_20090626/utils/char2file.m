function char2file(char,fname,type)
% CHAR2FILE  Write character string to text file.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

if nargin < 3
   type = 'char';
end

%********************************************************************
%! Function body.

fid = fopen(fname,'w+');
if fid == -1
  error('IRIS:filewrite:cannotOpenFile','Cannot open file "%s" for writing.',fname);
end

count = fwrite(fid,char,type);
if count ~= length(char)
   fclose(fid);
   error('IRIS:filewrite:cannotWrite','Cannot write character string to file "%s".',fname);
end

fclose(fid);

end
% End of primary function.