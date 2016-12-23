function [this,labels] = readcode(fname,assign,labels)
% Read and pre-parse any code files.

% The IRIS Toolbox 2009/06/22.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

this = file2char(fname);

% Remove #13 characters.
this = strrep(this,char(13),'');

% Read labels 'xxx' and "xxx" and replace them with #00.
[this,labels] = readlabels_(this,labels);

% Remove line and block comments.
this = removecomments(this,{'/*','*/'},{'%{','%}'},{'<!--','-->'},'%','//');

% Remove "..." and "!!!"
this = strrep(this,'...','');
this = strrep(this,'!!!','');

% Characters beyond char(highcharcode) not allowed except comments.
% Default is 1999.
highCharCode = irisget('highcharcode');
if any(this > char(highCharCode))
   irisparser.error(68,fname,{},highCharCode);
end

% Replace !keywords with @keywords.
this = prefix_(this);

% Discard everything after @stop.
index = strfind(this,'@stop');
if ~isempty(index)
  this = this(1:index(1)-1);
end

% Replace obsolete @ifversion with @if.
this = strrep(this,'@ifversion','@if');

% Evaluate @if .. @else .. @end and @for .. @do .. @end.
invalid = cell([1,0]);
patt = {...
  '@if([^\n;]+)[\n;]+([^@if@for]*?)(@else)?(?(3)[^@if@for]*?|)@end',...
  '@for([^@if@for]*?)@do([^@if@for]*?)@end'};
patt = convert_(patt,'>');
this = convert_(this,'>');
[i,tokens,start,finish] = findblock_(this,patt);
while ~isempty(tokens)
   switch i
   case 1
      [this,invalid] = ifblock_(this,tokens,start,finish,assign,invalid);
   case 2
      this = forblock_(this,tokens,start,finish,assign);
   end
   [i,tokens,start,finish] = findblock_(this,patt);
end
this = convert_(this,'<');
if ~isempty(invalid)
   % Cannot evaluate !for expressions. FALSE used instead.
   irisparser.warning(1,fname,invalid);
end

% Import/include/input external files.
[this,labels] = input_(this,labels,assign);

% Handle multiple or obsolete syntax options.
this = multiple_(this);

%{
% expand dot(...) and diff(...)
this = expand_(this);
%}

end
% End of primary function.

%********************************************************************
%! Subfunction convert_().
% convert @if, @else, @for, @do, @end to char(0) to char(4)

function this = convert_(this,direction)

list = {'end','if','else','for','do'};
if direction == '>'
   for i = 1 : length(list) 
      this = strrep(this,sprintf('@%s',list{i}),char(255+i));
   end
else
   for i = 1 : length(list) 
      this = strrep(this,char(255+i),sprintf('@%s',list{i}));
   end
end

end
% End of subfunction convertif_().

%********************************************************************
%! Subfunction findblock_().
% find first @if or @for block with no other nested block in it

function [i,tokens,start,finish] = findblock_(this,patt)

for i = 1 : length(patt)
    [tokens,start,finish] = regexp(this,patt{i},'tokens','start','end','once');
   if ~isempty(tokens)
      break
   end
end

if ~isempty(tokens) && iscell(tokens)
   tokens{1} = strtrim(tokens{1});
end

end
% End of subfunction findblock_().

%********************************************************************
%! Subfunction ifblock_().

function [this,invalid] = ifblock_(this,tokens,start,finish,assign,invalid)

[value,valid] = ifexpression_(assign,tokens{1});
if ~valid
   invalid{end+1} = convert_(tokens{1},'<');
   value = false;
end
if value
   replace = tokens{2};
else
   replace = tokens{4};
end
this = [this(1:start-1),replace,this(finish+1:end)];

end
% End of subfunction ifblock_().

%********************************************************************
%! Subfunction forblock_().

function this = forblock_(this,tokens,start,finish,assign)

list = tokens{1};
list = input_(list,assign);
list = charlist2cellstr(list);
llist = lower(list);
ulist = upper(list);
template = tokens{2};
replace = '';
for i = 1 : length(list)
   templatei = template;
   templatei = strrep(templatei,'<lower(?)>',llist{i});
   templatei = strrep(templatei,'<upper(?)>',ulist{i});
   templatei = strrep(templatei,'<-?>',llist{i});
   templatei = strrep(templatei,'<+?>',ulist{i});
   templatei = strrep(templatei,'<?>',list{i});
   templatei = strrep(templatei,'?',list{i});
   templatei = strrep(templatei,'lower(?)',llist{i});
   templatei = strrep(templatei,'upper(?)',ulist{i});
   replace = [replace,templatei,char(10)];
end
this = [this(1:start-1),replace,this(finish+1:end)];

end
% End of subfunction forblock_().

%********************************************************************
%! Subfunction ifexpression_().
% Evaluate an !if expression within assign database.

function [value,valid] = ifexpression_(assign,expr) 

expr = strtrim(expr);
expr = strrep(expr,'@','');
expr = regexprep(expr,'\<inf\>','inf()','ignorecase');
expr = regexprep(expr,'\<nan\>','nan()','ignorecase');
expr = regexprep(expr,'\<true\>','true()','ignorecase');
expr = regexprep(expr,'\<false\>','false()','ignorecase');

% Replace x == y with isequal(x,y) and x ~= y with ~isequal(x,y).
% This allows comparing strings without using STRCMP.
% expr = regexprep(expr,'^\s*(.*?)\s*==\s*(.*?)\s*$','isequal($1,$2)');
% expr = regexprep(expr,'^\s*(.*?)\s*~=\s*(.*?)\s*$','not(isequal($1,$2))');

% Add 'assign.' to words not followed by round brackets.
expr = regexprep(expr,'([A-Za-z]\w*)(?![\w\(])','assign.$1');

try
	value = eval(expr);
catch
   value = NaN;
end
if ~islogical(value) || length(value) ~= 1
   valid = false;
   value = false;
else
   valid = true;
end

end
% End of subfunction ifexpression_().

%********************************************************************
%! Subfunction prefix_().
% Replace !keywords with @keywords.

function this = prefix_(this) 
   this = regexprep(this,'!([a-z]\w*)','@$1');
end
% End of subfunction prefix_().

%********************************************************************
%! Subfunction multiple_().
% Handle multiple or obsolete syntax options.

function this = multiple_(this)
   this = strrep(this,'@coefficients','@parameters');
   this = strrep(this,'@variables:residual','@shocks');
   this = strrep(this,'@variables:innovation','@shocks');
   this = strrep(this,'@residuals','@shocks');
   this = strrep(this,'@nonlinear:','');
   this = strrep(this,'@nonlinear','');
   % this = strrep(this,'ln(','log(');
   this = strrep(this,'@outside','@equations:reporting');
   this = strrep(this,'@equations:dtrends','@dtrends:measurement');
   % Replace single quotes with double quotes.
   this = strrep(this,'''','"');
end
% End of subfunction mutliple_().

%********************************************************************
%! Subfunction input_().
% read external file

function [this,labels] = input_(this,labels,assign)
   % import/include/input files with replacement
   pattern = '(?:@include|@input|@import)\((.*?)\)';
   [tokens,start,finish] = regexp(this,pattern,'tokens','start','end','once');
   while ~isempty(tokens)
      fname = strtrim(tokens{1});
      if ~isempty(fname)
         [replace,labels] = irisparser.readcode(fname,assign,labels);
         this = [this(1:start-1),replace,this(finish+1:end)];
      end
      [tokens,start,finish] = regexp(this,pattern,'tokens','start','end','once');
   end
end
% End of subfunction input_().

%{
%********************************************************************
%! Subfunction expand_().
% expand dot() and diff()

function this = expand_(this)

   % Expand dot(x) as diff(log(x)).
   this = dot_(this);
   % Expand diff(x) as (x)-x({-1}).
   this = diff_(this);

end
% End of subfunction expand_().

%********************************************************************
%! Subfunction dot_().
% expand dot[x*y] as diff[log(x*y)]

function this = dot_(this)

   % Cannot re-use diff_() because round brackets are not allowed inside.
   replace_ = @(match,tokens) sprintf('(log(%s)-log(%s))',tokens{1},shift_(tokens{1},-1));
   this = regexpreponce(this,'@?dot\((.*?)\)',replace_);

end

%********************************************************************
%! Subfunction diff_().
% expand diff[log(x)*y] as (log(x)*y)-(log(x{-1})*y{-1})

function this = diff_(this)

   replace_ = @(match,tokens) sprintf('((%s)-(%s))',tokens{1},shift_(tokens{1},-1));
   this = regexpreponce(this,'@?diff\((.*?)\)',replace_);

end

%********************************************************************
%! Subfunction diff_().
% lag or lead of each variable in expression

function this = shift_(this,shift)

   % Note that names may consist of \w and \. because reporting equations may contain references to sub-databases.
   replace_ = @(match,tokens) sprintf('%s{%+g}',tokens{1},shift);
   this = regexpreponce(this,'(\<[a-zA-Z][\w\.]*\>(\{.*?\})?\s*)(?!\()',replace_);

end
%}

%********************************************************************
%! Subfunction readlabels_().
function [this,labels] = readlabels_(this,labels)
      function out = processLabel_(text)
         labels{end+1} = text;
         out = sprintf('#%g',length(labels));
      end
   % Create a handle to processLabel_.
   % ${} in regexprep cannot handle nested function, but can handle
   % anonymous functions.
   processLabelHandle_ = @processLabel_;
   this = regexprep(this,'([''"])(.*?)\1','${processLabelHandle_($2)}');
end
% End of subfunction readlabels_().
