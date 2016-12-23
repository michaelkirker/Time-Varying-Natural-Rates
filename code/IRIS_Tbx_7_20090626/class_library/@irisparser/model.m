function [m,assign] = model(p,m)
% Parse model code file.

% The IRIS Toolbox 2009/06/22.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% Check all words starting with an @.
chkkeywords_(p);

text = p.code;
assign = p.params;
m.fname = p.fname;

% Add new line character at the end of the file.
text = [text,char(10)];

% in-code linear model declaration
len = length(text);
text = strrep(text,'@linear','');
if len > length(text)
   m.linear = true;
end

% read blocks
blkname = {...
   '@variables:measurement\s',...     % 1
   '@variables:transition\s',...      % 2
   '@shocks\s',...                    % 3 Untyped shocks, for bkw compatibility only.
   '@parameters\s',...                % 4
   '@variables:log\s',...             % 5
   '@equations:measurement\s',...     % 6
   '@equations:transition\s',...      % 7
   '@substitutions\s',...             % 8
   '@dtrends:measurement\s',...       % 9
   '@equations:reporting\s',...       % 10
   '@shocks:measurement\s',...        % 11 Typed shocks.   
   '@shocks:transition\s',...         % 12 Typed shocks.
   '@links',...                       % 13 Dynamic links for parameters and/or steady-states.
};
eqtnBlocks = [6,7,9,13];

nblk = length(blkname);

% End of block is start of another block or end of file
eoblk = sprintf('|%s',blkname{:});
eoblk = sprintf('(?=$%s)',eoblk);

% read declaration blocks
block = cell([1,nblk]);
for i = 1 : length(blkname)
   patt = [blkname{i},'(.*?)',eoblk];
   tokens = regexpi(text,patt,'tokens');
   tokens = [tokens{:}];
   if ~isempty(tokens)
      % @allbut must be in all or none of log declaration blocks
      if i == 5
         chkallbut_(tokens);
      end
      % replace \n with blank spaces
      % block{i} = regexprep([tokens{:}],'\n',' ','ignorecase');
      block{i} = [tokens{:}];
   else
      block{i} = '';
   end
end

% No block of transition variables found.
if isempty(block{2}) || all(block{2} <= char(32))
   irisparser.error(0,m.fname,{},'variables');
end

% No block of transition equations found.
if isempty(block{7}) || all(block{7} <= char(32))
   irisparser.error(0,m.fname,{},'equations');
end

%********************************************************************
%! Splice typed and untyped shocks into block 3.

block{3} = [block{11},' ',block{12},' ',block{3}];
% Remember shocks declared as measurement shocks.
eylist = namelist_(block{11});
% Remember shocks declared as transition shocks.
exlist = namelist_(block{12});

%********************************************************************
%! Variables and parameters.

% Read individual names of variables and parameters.
% Evaluate parameters (nametype == 4) first so that they are available for steady-state expressions.
% Fields .name, .namelabel and .nametype are then constructed in reversed order so that nametype == 1 comes first.
for i = 4 : -1 : 1
   [name,label,value] = namelist_(block{i});
   m.name = [name,m.name];
   m.namelabel = [label,m.namelabel];
   m.nametype = [i*ones(size(name),'uint8'),m.nametype];
   if i == 3
      % Check for typed shocks.
      shocktype = nan(size(name));
      if ~isempty(eylist)
         % Measurement shocks.
         [ans,index] = intersect(name,eylist);
         shocktype(index) = 1;
      end      
      if ~isempty(exlist)
         % Transition shocks.
         [ans,index] = intersect(name,exlist);
         shocktype(index) = 2;
      end
      % Do not assign steady state values to shocks.
      continue
   end
   % Assign a value from declaration if not in the input database ('assign' option).
   for j = find(~cellfun(@isempty,value))
      if ~isfield(assign,name{j}) && ~isempty(value{j})
         aux = dbeval(assign,value{j}); % str2num(value{j});
         if isnumeric(aux) && length(aux) == 1
           assign.(name{j}) = aux;
         end
      end
   end
end

% Remove double and single quotes from within labels and comments.
m.namelabel = strrep(m.namelabel,'"','');

% take out std deviations if declared by user
index = strmatch('std_',m.name);
if ~isempty(index)
   m.name(index) = [];
   m.namelabel(index) = [];
   m.nametype(index) = [];
end

% Add std deviations.
index = m.nametype == 3;
n = sum(index);
m.name(end+(1:n)) = strrep('std_$','$',m.name(index));
m.nametype(end+(1:n)) = 4;
tmp = m.namelabel(index);
try
   nonempty = ~cellfun(@isempty,tmp);
catch
   nonempty = ~cellfun('isempty',tmp);
end
for i = find(nonempty)
   tmp{i} = sprintf('SD of %s',tmp{i});
end
m.namelabel(end+(1:n)) = tmp;

% read substitutions
patt = '(\w+)\s*=\s*(.*?)\s*;';
tokens = regexp(block{8},patt,'tokens');
aux = [tokens{:}];
n = length(aux)/2;
subsname(1:n) = {''};
subsbody(1:n) = {''};
if ~isempty(aux)
   subsname = aux(1:2:end);
   subsbody = aux(2:2:end);
end

chklist = [m.name,subsname];

% Leading characters of names and substitutions must not be 0-9 or _.
patt = '^[0-9_]';
match = regexp(chklist,patt,'match');
try
   aux = ~cellfun(@isempty,match);
catch
   aux = ~cellfun('isempty',match);
end
if any(aux)
   % Invalid variable or parameter names.
   irisparser.error(2,m.fname,chklist(aux));
end

% Check for multiple declarations of names and substitutions.
chklist{end+1} = 'ttrend';
[check,index] = sort(chklist);
aux = all(diff(double(char(check)),1,1) == 0,2);
if any(aux)
   % Multiple declarations.
   irisparser.error(3,m.fname,chklist(sort(index(aux))));
end

% Read log declarations.
m.log = false(size(m.name));
m.log(m.nametype == 1 | m.nametype == 2) = iff(isempty(strfind(block{5},'@allbut')),false,true);
block{5} = strrep(block{5},'@allbut','');
logname = namelist_(block{5});
logname = unique(logname);
list = m.name(m.nametype == 1 | m.nametype == 2);
invalid = cell([1,0]);
for i = 1 : length(logname)
   aux = strmatch(logname{i},list,'exact');
   if ~isempty(aux) && (m.nametype(aux) == 1 || m.nametype(aux) == 2)
      m.log(aux) = ~m.log(aux);
   else
      invalid{end+1} = logname{i};
   end
end
if ~isempty(invalid)
   % Invalid names in log declaration.
   irisparser.error(4,m.fname,invalid);
end

% Add substitutions for parameters (hard number strings).
chk = [block{6:7}];
for i = find(m.nametype == 4)
   if isempty(strfind(chk,['$',m.name{i},'$']))
      continue
   end
   subsname{end+1} = m.name{i};
   try
      tmp = assign.(m.name{i})(1);
   catch
      tmp = NaN;
   end
   subsbody{end+1} = sprintf('%.16g',tmp);
end

maxCharCode = 1999;
namecode = char(maxCharCode+(1:length(m.name)));
subscode = char(maxCharCode+length(m.name)+(1:length(subsname)));

%********************************************************************
%! Reporting equations.

p1 = p;
p1.code = block{10};
m.outside = p1.reporting();

%********************************************************************
%! Equations & deterministic trends.

% Remove extra ;s from equation-like blocks.
patt = '(\s*;){2,}';
block(eqtnBlocks) = regexprep(block(eqtnBlocks),patt,';');

% Condense multiple time subscripts.
% Replace {t1}{t2}...{tn} with {t1+t2+...+tn}.
condense = @(x) ['{',strrep(strrep(strrep(x,'{','('),'}',')'),')(',')+('),'}'];
block(eqtnBlocks) = regexprep(block(eqtnBlocks),'(\{[^\}\{]*?\}){2,}','${condense($1)}');

%{
% Read individual equations.
patt = irisget('matchEquation'); % '\s*("[^"]*")?([^";]*?)(=[^";]*?)?;';
[eqtn,tokens] = regexp(block([6,7]),patt,'match','tokens');
m.eqtntype(1:length(eqtn{1})) = 1;
m.eqtntype(end+(1:length(eqtn{2}))) = 2;
m.eqtn = [eqtn{:}];
tokens = [tokens{:}];
for j = 1 : length(tokens)
   % Rewrite x = y as x - (y);
   m.eqtnF{end+1} = iff(isempty(tokens{j}{3}),sprintf('%s;',tokens{j}{2}),sprintf('(%s)-(%s);',tokens{j}{2},tokens{j}{3}(2:end)));
   m.eqtnlabel{end+1} = tokens{j}{1};
end
%}

% Read measurement equations.
[eqtn,eqtnF,eqtnlabel] = readeqtns_(block{6});
n = length(eqtn);
m.eqtn(end+(1:n)) = eqtn;
m.eqtnF(end+(1:n)) = eqtnF;
m.eqtnlabel(end+(1:n)) = eqtnlabel;
m.eqtntype(end+(1:n)) = 1;

% Read transition equations.
[eqtn,eqtnF,eqtnlabel] = readeqtns_(block{7});
n = length(eqtn);
m.eqtn(end+(1:n)) = eqtn;
m.eqtnF(end+(1:n)) = eqtnF;
m.eqtnlabel(end+(1:n)) = eqtnlabel;
m.eqtntype(end+(1:n)) = 2;

% Read individual deterministic regressors.
% Add them to m.eqtn and m.eqtnF.
m = readdtrends_(m,block{9});

% Remove comment marks #.. from equations.
m.eqtn = regexprep(m.eqtn,'^\s*#\d+\s*','');

% Read dynamic links.
% Add them to m.eqtn and m.eqtnF.
m = readlinks_(m,block{13});

% Remove @ from math functions.
% This is bkw compatibility.
m.eqtnF = strrep(m.eqtnF,'@','');

% Replace [] with ().
m.eqtnF = strrep(m.eqtnF,'[','(');
m.eqtnF = strrep(m.eqtnF,']',')');

% Remove blank spaces.
m.eqtn = regexprep(m.eqtn,{'\s+','".*?"'},{'',''});
m.eqtnF = regexprep(m.eqtnF,'\s+','');
m.eqtnlabel = strrep(m.eqtnlabel,'"','');

% replace names with code characters
[patt,repl] = deal(cell([1,0]));
for i = 1 : length(subsname)
   patt{end+1} = ['\$',subsname{i},'(\{.*?\})?\$'];
   repl{end+1} = [subscode(i),'$1'];
end
try
   len = cellfun(@length,m.name);
catch
   len = cellfun('length',m.name);
end
[aux,index] = sort(len,2,'descend');
for i = index
   patt{end+1} = ['\<',m.name{i},'\>'];
   repl{end+1} = namecode(i);
end
m.eqtnF = regexprep(m.eqtnF,patt,repl);
subsbodyF = subsbody;
subsbodyF = regexprep(subsbodyF,patt,repl);

% add implicit zero time subscripts in F equations and substitutions
if ~isempty(namecode) || ~isempty(subscode)
   startcode = char(min(double([namecode,subscode])));
   endcode = char(max(double([namecode,subscode])));
   patt = ['([',startcode,'-',endcode,'])(?!\{)'];
   repl = '$1{0}';
   m.eqtnF = regexprep(m.eqtnF,patt,repl);
   subsbodyF = regexprep(subsbodyF,patt,repl);
end

% add shifts to subscripts in F substitutions
% make substitutions in substitutions
% make substitutions in F equations
pattF = {};
pattF(1:length(subsname)) = {''};
replF = {};
replF(1:length(subsname)) = {''};
for i = 1 : length(subsname)
   patt0 = '\{(.*?)\}';
   repl0 = '\{$1+(\$1)\}';
   pattF{i} = [subscode(i),'\{(.*?)\}'];
   replF{i} = regexprep(subsbodyF{i},patt0,repl0);
   subsbodyF = regexprep(subsbodyF,pattF,replF);
end
m.eqtnF = regexprep(m.eqtnF,pattF,replF);

% evaluate time subscripts in F equations
% replace {} with ()
invalid = {};
patt0 = '\{(.*?)\}';
for i = 1 : length(m.eqtnF)
   tokens = regexp(m.eqtnF{i},patt0,'tokens');
   [patt,repl] = deal(cell(size(tokens)));
   if ~isempty(patt)
      [patt{:}] = deal(patt0);
      aux = vech(str2num(char([tokens{:}])));
      if length(aux) ~= length(tokens) || any(isnan(aux)) || any(isinf(aux))
         invalid{end+1} = m.eqtn{i};
         continue;
      end
      for j = 1 : length(tokens)
         repl{j} = sprintf(iff(aux(j) >= 0,'(t+%g)','(t-%g)'),abs(aux(j)));
      end
      m.eqtnF{i} = regexprep(m.eqtnF{i},patt,repl,'once');
   end
end
if ~isempty(invalid)
   % Error evaluating time subscripts.
   irisparser.error(9,m.fname,invalid);
end

% replace matrix operators: moved to feval.m
%m.eqtnF = strrep(m.eqtnF,'*','.*');
%m.eqtnF = strrep(m.eqtnF,'/','./');
%m.eqtnF = strrep(m.eqtnF,'^','.^');

% create steady state equations
m.eqtnS = m.eqtnF;
m.eqtnS(m.eqtntype == 3) = {''};

% replace variables with x vector in full equations
patt = {};
patt(1:length(m.name)) = {''};
replF = {};
replF(1:length(m.name)) = {''};
replS = {};
replS(1:length(m.name)) = {''};
for i = 1 : length(m.name)
   patt{i} = [namecode(i),'\(t([\+\-]\d+)\)'];
   % remove time shifts from parameters
   if m.nametype(i) == 4
      replF{i} = sprintf('x(:,%d,t+0)',i);
   else
      replF{i} = sprintf('x(:,%d,t$1)',i);
   end
   if m.nametype(i) == 3
      replS{i} = '0';
   else
      replS{i} = sprintf('(x(%d)+($1)*dx(%d))',i,i);
      if m.nametype(i) <= 2 && m.log(i)
         replS{i} = sprintf('exp(%s)',replS{i});
      end
   end
end
m.eqtnF = regexprep(m.eqtnF,patt,replF);
m.eqtnS = regexprep(m.eqtnS,patt,replS);

% Remove zero shifts from S equations.
m.eqtnS = regexprep(m.eqtnS,'+\(\+0\)\*dx\(\d+\)','');
m.eqtnS = strrep(m.eqtnS,'exp(0)','1');

% Find occurences of each variable and parameter.
patt = 'x\(:,(\d+),t([\+\-](\d+))\)';
maxt = 0;
mint = 0;
id = cell(size(m.eqtn));
tokens = regexp(m.eqtnF,patt,'tokens');
for ieq = 1 : length(m.eqtnF)
   aux = vech(str2num(char([tokens{ieq}{:}])));
   id{ieq} = aux(1:2:end) + 1i*aux(2:2:end);
   maxt = max([maxt,aux(2:2:end)]);
   mint = min([mint,aux(2:2:end)]);
end
maxt = maxt + 1;
mint = mint - 1;
t = 1 - mint;
m.tzero = t;
nt = maxt - mint + 1;

occur = false([length(m.eqtnF),length(m.name),nt]);
for i = 1 : length(m.eqtnF)
   index = sub2ind(size(occur),i*ones([1,length(id{i})]),double(real(id{i})),t+double(imag(id{i})));
   occur(index) = true;
end

% fold full 3d [nrow,ncol,npage] into sparse 2d [nrow,ncol*npage]
m.occur = sparse(occur(:,:));

% Replace matrix operators with scalar operators.
m.eqtnF = strrep(m.eqtnF,'*','.*');
m.eqtnF = strrep(m.eqtnF,'/','./');
m.eqtnF = strrep(m.eqtnF,'^','.^');

% Replace #xx with labels.
m.namelabel = p.labelstore(m.namelabel);
m.eqtnlabel = p.labelstore(m.eqtnlabel);

chksyntax_(m,nt);
chkstructure_();

% End of function body.

%********************************************************************
%! Nested function chkstructure_().

function chkstructure_() 

   ixname = cell([1,4]);
   for ii = 1 : 4
      ixname{ii} = find(m.nametype == ii);
   end
   ixeqtn = cell([1,3]);
   for ii = 1 : 3
      ixeqtn{ii} = find(m.eqtntype == ii);
   end
   ny = length(ixname{1});
   nx = length(ixname{2});
   ne = length(ixname{3});
   np = length(ixname{4});

   % one transition variable at least
   if ~any(m.nametype == 2)
      irisparser.error(6,m.fname,{},'No transition variable.');
   end

   % current dates of all transition variables
   aux = ~any(occur(ixeqtn{2},ixname{2},t),1);
   if any(aux)
      irisparser.error(6,m.fname,m.name(ixname{2}(aux)),'No current date of this transition variable: "%s".');
   end

   % current dates of all measurement variables
   aux = ~any(occur(ixeqtn{1},ixname{1},t),1);
   if any(aux)
      irisparser.error(6,m.fname,m.name(ixname{1}(aux)),'No current date of this measurement variable: "%s".');
   end

   % # measurement equations = # measurement variables
   if sum(m.nametype == 1) ~= sum(m.eqtntype == 1)
      irisparser.error(6,m.fname,{sum(m.eqtntype == 1),sum(m.nametype == 1)},'%g measurement equation(s) for %g measurement variable(s).');
   end

   % # transition equations = # transition variables
   if sum(m.nametype == 2) ~= sum(m.eqtntype == 2)
      irisparser.error(6,m.fname,{sum(m.eqtntype == 2),sum(m.nametype == 2)},'%g transition equation(s) for %g transition variable(s).');
   end

   % no lags/leads of measurement variables
   aux = any(any(occur(:,ixname{1},[1:t-1,t+1:end]),3),1);
   if any(aux)
      irisparser.error(6,m.fname,m.name(ixname{1}(aux)),'Lag(s) or lead(s) of this measurement variable: "%s".');
   end

   % no lags/leads of shocks
   aux = any(any(occur(:,ixname{3},[1:t-1,t+1:end]),3),1);
   if any(aux)
      irisparser.error(6,m.fname,m.name(ixname{3}(aux)),'This shock has lag(s) or lead(s): "%s".');
   end

   % no lags/leads of parameters
   aux = any(any(occur(:,ixname{4},[1:t-1,t+1:end]),3),1);
   if any(aux)
      irisparser.error(6,m.fname,m.name(ixname{4}(aux)),'This parameter has lag(s) or lead(s): "%s".');
   end

   % no measurement variables in transition equations
   aux = any(any(occur(ixeqtn{2},ixname{1},:),3),2);
   if any(aux)
      irisparser.error(6,m.fname,m.eqtn(ixeqtn{2}(aux)),'This transition equation has measurement variable(s): "%s".');
   end

   % no leads of transition variables in measurement equations
   aux = any(any(occur(ixeqtn{1},ixname{2},t+1:end),3),2);
   if any(aux)
      irisparser.error(6,m.fname,m.eqtn(ixeqtn{1}(aux)),'Lead(s) of transition variable(s) in this measurement equation: "%s".');
   end

   % current date of any transition variable in each transition equation
   aux = ~any(occur(ixeqtn{2},ixname{2},t),2);
   if any(aux)
      irisparser.error(6,m.fname,m.eqtn(ixeqtn{2}(aux)),'No current-dated transition variable in this transition equation: "%s".');
   end

   % Current date of any measurement variable in each measurement equation.
   aux = ~any(occur(ixeqtn{1},ixname{1},t),2);
   if any(aux)
      irisparser.error(6,m.fname,m.eqtn(ixeqtn{1}(aux)),'No current-dated measurement variables in this measurement equation: "%s".');
   end

   if ne > 0
      % Find index of shocks in measurement equations.
      % Find index of shocks in transition equations
      aux1 = any(occur(ixeqtn{1},ixname{3},t),1);
      aux2 = any(occur(ixeqtn{2},ixname{3},t),1);
   
      % No measurement shock in transition equations.
      aux = aux2 & shocktype == 1;
      if any(aux)
         irisparser.error(6,m.fname,m.name(ixname{3}(aux)),'This measurement shock occurs in transition equation(s): "%s".');
      end
      
      % No transition shock in measurement equations.
      aux = aux1 & shocktype == 2;
      if any(aux)
         irisparser.error(6,m.fname,m.name(ixname{3}(aux)),'This transition shock occurs in measurement equation(s): "%s".');
      end
      
      % No shock simultaneously in transition and measurement equations.
      aux = all([aux1;aux2],1);
      if any(aux)
         irisparser.error(6,m.fname,m.name(ixname{4}(aux)),'This shock occurs in both measurement and transition equation(s): "%s".');
      end
   end
   
   % Only parameters in deterministic trends.
   aux = vech(any(any(occur(:,m.nametype ~= 4,:),3),2));
   aux = aux & vech(m.eqtntype == 3);
   if any(aux)
      irisparser.error(6,m.fname,m.eqtn(aux),'This deterministic trend refers to name(s) other than parameters: "%s".');
   end

end 
% End of nested function chkstructure_().

end
% End of primary function.

%********************************************************************
%! Subfunction namelist_().

function [name,label,value] = namelist_(list)
   %  patt = '(?<label>".*?")?\s*(?<name>\w+)\s*(?<value>=[^;,"]+)?';
   %  patt = '(?<label>".*?")?\s*(?<name>\w+)\s*(?<value>=[\s-\d\.ei]+[;,])?';
   patt = '(?<label>#\d+)?\s*(?<name>\w+)\s*(?<value>=[^;,\n]+[;,\n])?';
   x = regexp(list,patt,'names');
   name = {x(:).name};
   label = {x(:).label};
   value = {};   
   if nargout > 2
      value = {x(:).value};
      value = strrep(value,'=','');
      value = strrep(value,'@','');
   end
end  
% End of subfunction namelist_().

%********************************************************************
%! Subfunction chkallbut_().
% @allbut must be in all or none of log declaration blocks.

function flag = chkallbut_(tokens) 
   index = cellfun(@isempty,regexp(tokens,'@allbut','match','once'));
   if any(index) && any(~index)
      irisparser.error(52,m.fname);
   end
end
% End of subfunction chkallbut_().

%********************************************************************
%! Subfunction chksyntax_().

function chksyntax_(m__,nt__) 
   t = m__.tzero;
   x = rand(1,length(m__.name),nt__);
   ttrend = 0;
   undeclared__ = {};
   syntax__ = {};
   eqtn__ = m__.eqtnF;
   for eq__ = 1 : length(eqtn__)
      try
         eval(eqtn__{eq__});
      catch E__
         [match__,tokens__] = regexp(E__.message,'Undefined function or variable ''(\w*)''','match','tokens','once');
         if ~isempty(match__)
            undeclared__{end+1} = tokens__{1};
            undeclared__{end+1} = m__.eqtn{eq__};
         else
            syntax__{end+1} = m__.eqtn{eq__};
            if E__.message ~= '.'
               E__.message(end+1) = '.';
            end
            syntax__{end+1} = sprintf('Matlab says: %s',E__.message);
         end
      end
   end
   if ~isempty(undeclared__)
      irisparser.error(38,m__.fname,undeclared__);
   end
   if ~isempty(syntax__)
      irisparser.error(8,m__.fname,syntax__);
   end
end
% End of subfunction chksyntax_().

%********************************************************************
%! Subfunction readeqtns_().
% Read measurement or transition equations.

function [eqtn,eqtnF,eqtnlabel] = readeqtns_(thisblock)
   % Regular expressions to match model code elements.
   pattern = '\s*(#\d+)?([^";]*?)(=[^";]*?)?;';
   [eqtn,tokens] = regexp(thisblock,pattern,'match','tokens');
   straightTokens = [tokens{:}];
   n = length(eqtn);
   eqtnF = cell([1,n]);
   for j = 1 : n
      if isempty(tokens{j}{3})
         eqtnF{j} = sprintf('%s;',tokens{j}{2})
      else
         % Rewrite x = y as x - (y);
         eqtnF{j} = sprintf('(%s)-(%s);',tokens{j}{2},tokens{j}{3}(2:end));
      end
   end
   eqtnlabel = straightTokens(1:3:end);
end
% End of subfunction readeqtns_().

%********************************************************************
%! Subfunction readdtrends_().

function m = readdtrends_(m,thisblock)

   n = sum(m.nametype == 1);
   eqtn = emptycellstr([1,n]);
   eqtnF = emptycellstr([1,n]);
   eqtnlabel = emptycellstr([1,n]);
   % Remove @ from dtrend equations.
   thisblock = strrep(thisblock,'@','');
   pattern = '\s*(#\d+)?\s*([\(\)\w]*)\s*([\+\*])=\s*([^";]*?;)';
   [match,tokens] = regexp(thisblock,pattern,'match','tokens');
   match = strtrim(match);
   match = regexprep(match,'#\d+','');
   
   % Replace x *= ...; with log(x) += log(...);
   for i = 1 : length(tokens)
      tokens{i}{2} = strtrim(tokens{i}{2});
      tokens{i}{4} = strtrim(tokens{i}{4});
      if strcmp(tokens{i}{3},'*')
          tokens{i}{2} = sprintf('log(%s)',tokens{i}{2});
          tokens{i}{4} = sprintf('log(%s);',tokens{i}{4}(1:end-1));
      end
    end

   % Create list of measurement variable names.
   % Add log(...) for log variables.
   list = m.name(m.nametype == 1);
   aux = m.log(m.nametype == 1);
   list(aux) = regexprep(list(aux),'(.*)','log($1)','once');
   invalid = {};
   multiple = {};
   nmatch = length(match);
   for i = 1 : nmatch
      index = find(strcmp(list,tokens{i}{2}),1);
      if isempty(index)
         invalid{end+1} = match{i};
         continue;
      end
      if ~isempty(eqtn{index})
         multiple{end+1} = m.name{index};
         continue;
      end
      eqtn{index} = match{i};
      eqtnF{index} = tokens{i}{4};
      eqtnlabel{index} = tokens{i}{1};
   end
   if ~isempty(invalid)
      invalid = regexprep(invalid,'\s+','');
      irisparser.error(55,m.fname,invalid);
   end
   if ~isempty(multiple)
      multiple = unique(multiple);
      irisparser.error(6,m.fname,multiple,'Multiple deterministic trend equations for "%s".');
   end
   m.eqtn(end+(1:n)) = eqtn;
   m.eqtnF(end+(1:n)) = eqtnF;
   m.eqtnlabel(end+(1:n)) = eqtnlabel;
   m.eqtntype(end+(1:n)) = 3;
end
% End of subfunction readdtrends_().





%********************************************************************
%! Subfunction readlinks_().

function m = readlinks_(m,thisblock)

   n = sum(m.nametype <= 4);
   eqtn = emptycellstr([1,n]);
   eqtnF = emptycellstr([1,n]);
   eqtnlabel = emptycellstr([1,n]);
   pattern = '\s*(#\d+)?([^";]*?)(=[^";]*?)?;';
   [match,tokens] = regexp(thisblock,pattern,'match','tokens');
   match = strtrim(match);
   match = regexprep(match,'#\d+','');
   
   nmatch = length(match);

   invalid = {};
   refresh = [];
   for j = 1 : nmatch
      tokens{j} = strtrim(tokens{j});
      if isempty(tokens{j}{3})
         invalid{end+1} = match{j};
         continue
      end
      lhs = strtrim(tokens{j}{2});
      index = strcmp(m.name(m.nametype <= 4),lhs);
      if ~any(index)
         invalid{end+1} = match{j};
         continue
      end
      eqtn{index} = match{j};
      eqtnF{index} = sprintf('%s;',strtrim(tokens{j}{3}(2:end)));
      eqtnlabel{index} = tokens{j}{1};
      refresh(end+1) = find(index);
   end
   
   if ~isempty(invalid)
      invalid = regexprep(invalid,'\s+','');
      irisparser.error(67,m.fname,invalid);
   end
   
   % Replace all time subscripts with 0.
   eqtnF = regexprep(eqtnF,'\{.*?\}','{0}');
   
   m.eqtn(end+(1:n)) = eqtn;
   m.eqtnF(end+(1:n)) = eqtnF;
   m.eqtnlabel(end+(1:n)) = eqtnlabel;
   m.eqtntype(end+(1:n)) = 4;
   m.refresh = refresh;

end
% End of subfunction readlinks_().





%********************************************************************
%! Subfunction chkkeywords_().

function chkkeywords_(p)
   keywords = regexp(p.code,'@[\w:]*','match');
   [blk,ctrl,math] = iriskeywords();
   list = [blk,ctrl,math];
   invalid = {};
   for i = 1 : length(keywords)
   	if ~any(strcmp(keywords{i},list))
         invalid{end+1} = keywords{i};
      end
   end
   if ~isempty(invalid)
      % Invalid keyword(s).
      irisparser.error(1,p.fname,invalid);
   end
end
% End of subfunction chkkeywords_().