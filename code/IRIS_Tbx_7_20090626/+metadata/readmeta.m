function this = readmeta(fname)

if ischar(fname)
   fname = charlist2cellstr(fname);
end

% =======================================================================================
%! Function body.

text = '';
for i = 1 : length(fname)
   text = [text,char(10),file2char(fname{i})];
end

% Only entire line comments allowed.
text = removecomments(text,'(?m)^\s*%','(?m)^\s*//');
text = strrep(text,char(13),'');

match = regexp(text,'key\s*=.*?(?=key|$)','match');

this = struct();
this.key = {};
this.data = {};
for i = 1 : length(match)
   [this.key{end+1},this.data{end+1}] = evalentry_(match{i});
end

% Check uniqueness of keys.
list = nonunique(this.key);
if ~isempty(list)
   multierror('This key is not unique: "%s".',list);
end

end
% End of primary function.

% =======================================================================================
%! Subfunction evalentry_().

function [key,data] = evalentry_(text)

s = regexp(text,'(?<field>[A-Za-z]\w*)\s*=\s*(?<quote>[''"])?(?<value>.*?)\2;','names');
meta = struct();
for i = 1 : length(s)
   if strcmp(s(i).field,'key')
      key = strtrim(s(i).value);
   else
      if ~isempty(s(i).quote)
         data.(s(i).field) = s(i).value;
      else
         try
            data.(s(i).field) = eval(s(i).value);
         catch
            data.(s(i).field) = NaN;
         end         
      end
   end
end

end
% End of subfunction evalentry_().