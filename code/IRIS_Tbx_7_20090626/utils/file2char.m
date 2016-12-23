function [text,flag] = file2char(fname,type)

if nargin < 2
   type = 'char';
end

flag = true;
fid = fopen(fname,'r');
if fid == -1
   if ~exist(fname,'file')
      error('Unable to find file "%s".',fname);
   else
      error('Unable to open file "%s" for reading.',fname);
   end
end

text = char(transpose(fread(fid,type)));

if fclose(fid) == -1
   warning('iris:utils','Unable to close file "%s" after reading.',fname);
end

end