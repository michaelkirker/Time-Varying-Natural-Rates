function string = letterchk_(string,options)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if ischar(string)
  string = {string};
  convert = true;
else
  convert = false;
end

string = strtrim(string);
for i = 1 : length(string)
  % leave text inside curly braces unchanged
  tokens = regexp(string{i},'([^\{]*)(\{.*?\})*','tokens');
  if ~isempty(tokens)
    for j = 1 : length(tokens)
      tokens{j} = [replace_(tokens{j}{1},options),tokens{j}{2}(2:end-1)];
    end
    string{i} = [tokens{:}];
  else
    string{i} = '';
  end
end

if convert == true, string = string{1}; end

end % of primary function

  % -----subfunction----- %

  function string = replace_(string,options);

  string = strrep(string,'#','#hash ');
  string = strrep(string, '&', '#&');
  string = strrep(string, '$', '#$');
  string = strrep(string, '%', '#%');
  string = strrep(string, '_', '#_');
  string = strrep(string, '@pct', '#%');
  string = strrep(string, '@dollar', '#$');

  switch options.language
  case 'es'
    string = strrep(string, 'a~', '#''a');
    string = strrep(string, 'e~', '#''e');
    string = strrep(string, 'i~', '#''#i ');
    string = strrep(string, 'o~', '#''o');
    string = strrep(string, 'u~', '#''u');
    string = strrep(string, 'y~', '#''y');
    string = strrep(string, 'n~', '#~n');
    string = strrep(string, 'A~', '#''A');
    string = strrep(string, 'E~', '#''E');
    string = strrep(string, 'I~', '#''I');
    string = strrep(string, 'O~', '#''O');
    string = strrep(string, 'U~', '#''U');
    string = strrep(string, 'Y~', '#''Y');
    string = strrep(string, 'N~', '#~N');
  end

  end % of subfunction