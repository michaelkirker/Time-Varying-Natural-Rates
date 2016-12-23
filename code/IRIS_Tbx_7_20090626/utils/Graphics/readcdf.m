function [this,sub] = readcdf(fname)
% Read contents definition file.

% The IRIS Toolbox 22009/02/20.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

code = file2char(char(fname));

% Replace old syntax.
code = strrep(code,'?--','!--');
code = strrep(code,'<<-->>','!++');

% remove char(13)
code = strrep(code,char(13),'');
% remove line and block comments
code = removecomments(code,{'/*','*/'},{'%{','%}'},{'<!--','-->'},'(?<!\\)%','//');
code = strrep(code,'\%','%');
% replace single quotes with double quotes
code = strrep(code,'''','"');

% Read panels !-- and pages !++
%{
tmp = regexp(code,'!--(?<title>.*?)\n(?<series>.*?)\s*(?<break>!\+\+)?\s*(?=!--|$)','names');
this = struct();
% break down graphs into formulas and labels
for i = 1 : length(tmp)
   this(i).break = ~isempty(tmp(i).break);
   this(i).title = strtrim(tmp(i).title);
   [this(i).formula,this(i).legend] = charlist2cellstr(tmp(i).series);
end
%}

% Find page tags !++ and panel tages !-- !::
this = regexp(code,'(?<tag>#|!\+\+|!\-\-|!::|!\*\*)s*(?<title>.*?)\s*\n\s*(?<body>.*?)\s*(?=!\+\+|!\-\-|!::|!\*\*|$)','names');

% Find first non-# tag. If it is not !++, add !++.
count = 1;
while count <= length(this) && strncmp(this(count).tag,'#',1)
   count = count + 1;
end

if count <= length(this) && ~strcmp(this(1).tag,'!++')
   this = [this(1:count-1),struct('tag','!++','title','','body',''),this(count:end)];
end

% Remove two consecutive page tags
flag = cellfun(@(x) strcmp(x,'!++'),{this.tag});
this(flag & [flag(2:end),true]) = [];

% Remove !++ at the end of the file
if ~isempty(this) && strcmp(this(end).tag,'!++')
   this(end) = [];
end

% Replace commas outside any brackets with &'s
for i = 1 : length(this)
   if isempty(this(i).body)
      continue
   end
   open = {(this(i).body == '('),(this(i).body == '['),(this(i).body == '{')};
   close = {(this(i).body == ')'),(this(i).body == ']'),(this(i).body == '}')}; 
   comma = find((this(i).body == ','));
   for j = comma      
      flag = true;
      for k = 1 : length(open)
         % Number of opening and closing brackets before this comma
         % are the same for the k-th type of brackets.
         flag = flag && sum(open{k}(1:j)) == sum(close{k}(1:j));
      end
      if flag
         this(i).body(j) = '&';
      end
   end
end

end
% End of primary function.

%********************************************************************
%! CDF syntax

%{ 
   #NxN
   !++ new figure/table
   !-- new line graph
   !:: new bar graph
   !** void panel
%}
