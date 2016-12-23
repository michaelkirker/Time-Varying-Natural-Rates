function eqtn = reporting(p)
% REPORTING  Parse reporting equations.

% The IRIS Toolbox 2009/06/22.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

eqtn.lhs = {};
eqtn.rhs = {};
eqtn.label = {};
eqtn.userRHS = {};

p.code = strtrim(p.code);
if isempty(p.code)
   return
end

% Match #xx x = ...|...;
tokens = regexp(p.code,...
   '(?<label>#\d+)?\s*(?<lhs>\w+)\s*=\s*(?<rhs>.*?)\s*(?<nan>\|.*?)?;',...
   'names');

eqtn.label = p.labelstore({tokens(:).label});
eqtn.lhs = {tokens(:).lhs};
eqtn.rhs = {tokens(:).rhs};
eqtn.nan = {tokens(:).nan};
% Preserve the original user-supplied RHS expressions.
% Add a semicolon at the end.
eqtn.userRHS = regexprep(eqtn.rhs,'(.)$','$1;');

% Add (:,t) to names (or names with curly braces) not followed by opening bracket or dot and not preceded by @
eqtn.rhs = regexprep(eqtn.rhs,'(?<!@)(\<[a-zA-Z]\w*\>(\{.*?\})?)(?![\(\.])','$1#');

% Add prefix d. to all names consisting potentially of \w and \. not followed by opening bracket.
eqtn.rhs = regexprep(eqtn.rhs,'\<[a-zA-Z][\w\.]*\>(?!\()','?$0');

eqtn.rhs = strrep(eqtn.rhs,'#','(t,:)');
eqtn.rhs = strrep(eqtn.rhs,'?','d.');

eqtn.rhs = strrep(eqtn.rhs,'@','');
eqtn.rhs = strrep(eqtn.rhs,'*','.*');
eqtn.rhs = strrep(eqtn.rhs,'/','./');
eqtn.rhs = strrep(eqtn.rhs,'^','.^');

eqtn.nan = strtrim(strrep(eqtn.nan,'|',''));
for i = 1 : length(eqtn.nan)
  eqtn.nan{i} = str2num(eqtn.nan{i});
end
eqtn.nan(cellfun(@isempty,eqtn.nan) | ~cellfun(@isnumeric,eqtn.nan)) = {NaN};

% Remove blank spaces from RHSs.
for i = 1 : length(eqtn.rhs)
  eqtn.rhs{i}(isspace(eqtn.rhs{i})) = '';
end

end
% End of primary function.