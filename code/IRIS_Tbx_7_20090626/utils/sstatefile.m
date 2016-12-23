function sstatefile(infname,outfname,varargin)

default = {...
   'assign',struct(),@(x) isempty(x) || isstruct(x),...
   'simplify',Inf,@isnumeric,...
   'excludezero',false,@islogical,...
   'substitute',{},@(x) isempty(x) || iscellstr(x),...
};
options = passvalopt(default,varargin{:});

if nargin == 1
   [fpath,ftitle,fext] = fileparts(infname);
   outfname = fullfile(fpath,[ftitle,'.m']);
end

%********************************************************************
%! Function body.

%! Keywords:
% !parameters
% !equations
% !solvefor
% !variables:log or !variables:positive
% !allbut
% !symbolic
% !if !else !end !for !do
% !assignments

p = irisparser(infname,options.assign);
in = p.code;

% read list of input parameters
[tokens,stop] = regexp(in,'^\s*@parameters\s*(.*?)\s*(?=@equations|$)','tokens','end','once');
param = unique(charlist2cellstr(tokens{1}));
in = in(stop+1:end);

% read blocks
block = regexp(in,'\s*(@equations|@assignments)\s*(.*?)\s*(?=@equations|@assignments|$)','tokens');
nblock = length(block);

% Check !assignments for !solvefor.
straightTokens = [block{:}];
tmpType = straightTokens(1:2:end);
tmpBody = straightTokens(2:2:end);
invalidAssignment = [];
for i = 1 : length(tmpType)
   if strcmp(tmpType{i},'@assignments')
      if ~isempty(strfind(tmpBody{i},'@solvefor'))
         invalidAssignment(end+1) = i;
      end
   end
end

if ~isempty(invalidAssignment)
   error('iris:sstate','The <a href="">!assignments</a> block #%g includes a <a href="">!solvefor</a> section.\n',invalidAssignment);
end

% Read equations, variables, log variables, and methods.
eqtn = cell([1,nblock]);
solvefor = cell([1,nblock]);
loglin = cell([1,nblock]);
allbut = false([1,nblock]);
symbol = false([1,nblock]);
for i = 1 : nblock
   % Read !solvefor variables .
   [tokens,start,stop] = regexp(block{i}{2},'@solvefor\s*(.*?)\s*(?=@|$)','tokens','once','start','end');
   if isempty(tokens)
      % If no !solvefor found, block is assignment.
      solvefor{i} = {};
   else
      % Variables to solve for.
      solvefor{i} = regexp(tokens{1},'\w+','match');
      block{i}{2}(start:stop) = '';
   end
   % allbut
   allbut(i) = ~isempty(strfind(block{i}{2},'@allbut'));
   block{i}{2} = strrep(block{i}{2},'@allbut','');
   % read positive/loglin variables
   [aux,start,stop] = regexp(block{i}{2},'@variables:(log|positive)\s*(.*?)\s*(?=@|$)','tokens','once','start','end');
   if ~isempty(aux)
      loglin{i} = unique(charlist2cellstr(aux{1}));
      block{i}{2}(start:stop) = '';
   end
   % symbolic or numerical
   symbol(i) = ~isempty(strfind(block{i}{2},'@symbolic'));
   block{i}{2} = strrep(block{i}{2},'@symbolic','');
   block{i}{2} = strrep(block{i}{2},'@numerical','');
   % read equations
   block{i}{2} = regexprep(block{i}{2},'\s+','');
   block{i}{2} = regexprep(block{i}{2},';{2,}',';');
   eqtn{i} = regexp(block{i}{2},'[^;]*?(?=;)','match');
end

if any(symbol) && ~issymbolic()
   warning('iris:sstate','Symbolic Math Tbx not installed. All steady state blocks will be computed numerically.');
   symbol(:) = false;
end

% Check multiple declarations of variables.
% Check number or equations and variables.
invalid = {};
multiple = {};
for i = 1 : nblock
   [aux,index] = unique(solvefor{i});
   if length(solvefor{i}) ~= length(index)
      solvefor{i}(index) = [];
      multiple = [multiple,solvefor{i}];
   end
   solvefor{i} = aux;
   if isempty(eqtn{i}) && isempty(solvefor{i})
      % Remove empty block.
      eqtn(i) = [];
      solvefor(i) = [];
      loglin(i) = [];
      symbol(i) = [];
   elseif ~isempty(solvefor{i}) > 0 && length(eqtn{i}) ~= length(solvefor{i})
      invalid{end+1} = [length(eqtn{i}),length(solvefor{i}),i];
   end
end

% Update number of blocks
% because the empty ones have been removed.
nblock = length(eqtn);

if ~isempty(multiple)
   multierror('This variable is declared mutliple times within one block: "%s".',multiple);
end
if ~isempty(invalid)
   multierror('Number of equations (%g) does not match number of variables (%g) in block #%g.',invalid);   
end

% Is this variable name valid?
%{
invalid = {};
for i = 1 : nblock
   index = ~cellfun(@isvarname,solvefor{i});
   if any(index)
      invalid = [invalid,solvefor{i}(index)];
   end
end
%if ~isempty(invalid)
%   multierror('This is an invalid variable name: "%s".',invalid);
%end
%}

% Write subfunctions for each block.
subfcn = cell([1,nblock]);
for i = 1 : nblock
   if isempty(solvefor{i})
      % Execute block.
      [subfcn{i},addparam] = execute_(i,param,eqtn{i});
   elseif symbol(i)
      % Solve block symbolically.
      subfcn{i} = symbolic_(i,param,eqtn{i},solvefor{i},loglin{i},options);
      addparam = solvefor{i};
   else
      % Solve block numerically.
      subfcn{i} = numerical_(i,param,eqtn{i},solvefor{i},allbut(i),loglin{i},options);
      addparam = solvefor{i};
   end
   param = [param,addparam];
end

% Write primary function.
txt = sprintf('function [P,discrep,exitflag] = %s(P,varargin)\n',regexprep(outfname,'\..*',''));
txt = [txt,sprintf('%% Steady-state file based on %s.\n',upper(infname))];
txt = [txt,sprintf('%% Created by The IRIS Toolbox''s SSTATEFILE function.\n')];
txt = [txt,sprintf('%% %s.\n\n',datestr(now()))];

% Create optimset.
txt = [txt,sprintf('discrep = cell([1,%g]);\n',nblock)];
txt = [txt,sprintf('exitflag= nan([1,%g]);\n',nblock)];
txt = [txt,sprintf('optim = optimset(varargin{:});\n')];

% Call individual blocks.
for i = 1 : nblock
   if symbol(i) || isempty(solvefor{i})
      % Symbolic or execute.
      txt = [txt,sprintf('P = block%g_(P);\n',i)];
   else
      % Numerical.
      txt = [txt,sprintf('[P,discrep{%g},exitflag(%g)] = block%g_(P,optim);\n',i,i,i)];
   end
end
% Write end of primary function.
txt = [txt,sprintf('\nend\n\n')]; 

% Write block-specific subfunctions.
for i = 1 : nblock
   txt = [txt,sprintf('%%********************************************************************\n')];
   txt = [txt,sprintf('%s\n',subfcn{i})];
end

% Save output function.
char2file(txt,outfname);
rehash();

end
% End of primary function.

%********************************************************************
%! Subfunction execute_().

function [txt,lhs] = execute_(block,param,eqtn)

% Write subfunction code.
txt = sprintf('function varargout = block%g_(varargin)\n',block);
for i = 1 : length(param)
   txt = [txt,sprintf('%s = varargin{1}.%s;\n',param{i},param{i})];
end
for i = 1 : length(eqtn)
   txt = [txt,sprintf('%s;\n',eqtn{i})];
end
% Create list of LHS variables, and assign them in varargout. 
% These will be then available for subsequent blocks.
lhs = regexp(eqtn,'^\s*(\w+)\s*(?==)','match','once');
lhs = lhs(~cellfun(@isempty,lhs));
lhs = strtrim(lhs);
txt = [txt,sprintf('varargout{1} = varargin{1};\n')];
for i = 1 : length(lhs)
   txt = [txt,sprintf('varargout{1}.%s = %s;\n',lhs{i},lhs{i})];
end

% Write end of subfunction.
txt = [txt,sprintf('end\n')];

end
% End of subfunction execute_().

%********************************************************************
%! Subfunction symbolic_().

function txt = symbolic_(block,param,eqtn,solvefor,loglin,options)

% Add a sufix '00' to all variable names (not functions).
% This is to prevent conflicts with symbolic keywords or function names.
%{
eqtn = regexprep(eqtn,'(\<[a-zA-Z]\w*\>)(?!\()','$100');
for i = 1 : length(solvefor)
   solvefor{i} = [solvefor{i},'00'];
end
%}

% Make user substitutions.
if ~isempty(options.substitute)
   for i = 1 : 2 : length(options.substitute)
      eqtn = regexprep(eqtn,['\<',options.substitute{i},'\>'],options.substitute{i+1});
      for j = 1 : length(solvefor)
         if strcmp(options.substitute{i},solvefor{j})
            solvefor{j} = options.substitute{i+1};
            break
         end
      end
   end
end

lastwarn('','');
try
   aux = sprintf(',%s',solvefor{:});
   aux(1) = '';
   x = cell(size(solvefor));
   [x{:}] = solve(eqtn{:},solvefor{:});
catch
   error('Error when symbolically solving block #%g.\n\tMatlab sais: "%s"',block,strrep(lasterr(),char(10),' '));
end

%{
% Remove sufix '00' from variable names.
for i = 1 : length(solvefor)
   solvefor{i} = solvefor{i}(1:end-2);
end
%}

% Undo user substitutions.
if ~isempty(options.substitute)
   for i = 1 : 2 : length(options.substitute)
      eqtn = regexprep(eqtn,['\<',options.substitute{i+1},'\>'],options.substitute{i});
      for j = 1 : length(solvefor)
         if strcmp(options.substitute{i+1},solvefor{j})
            solvefor{j} = options.substitute{i};
            break
         end
      end
   end
end

if ~isempty(lastwarn())
   error('Explicit solution not found for block #%g.',block);
end

% Number of solutions returned.
nvar = length(x);
nsol = length(x{1});

% Convert sym solutions to char solutions.
s = cell([1,nsol]);
for i = 1 : nsol
   s{i} = cell([1,nvar]);
   for j = 1 : nvar
      s{i}{j} = char(x{j}(i));
      if length(aux) >= options.simplify
         x{j}(i) = simple(horner(simple(x{j}(i))));
         s{i}{j} = char(x{j}(i));
      end
   end
   % Remove sufix '00' from variable names.
   s{i} = regexprep(s{i},'\<([a-zA-Z]\w*)00\>(?!\()','$1');
end

% Exclude all-zero solutions
if nsol > 1 && options.excludezero
   remove = false([1,nsol]);
   for i = 1 : nsol
      remove(i) = all(cellfun(@(x) strcmp(x,'0'),s{i}));
   end
   if any(remove)
      s(remove) = [];
      nsol = length(s);
      warning('A total of %g all-zero solution(s) discarded in block #%g.',sum(remove),block);
   end
end
   
if nsol == 0
   error('Other than all-zero solutions not found for block #%g',block);
end

if nsol > 1
   choose = multisolutions_(s,solvefor,block);
else
   choose = 1;
end
s = s{choose};

% Write subfunction code.
txt = sprintf('function varargout = block%g_(varargin)\n',block);
for i = 1 : length(param)
   txt = [txt,sprintf('%s = varargin{1}.%s;\n',param{i},param{i})];
end
txt = [txt,sprintf('varargout{1} = varargin{1};\n')];
txt = [txt,writesolution_(s,solvefor,sprintf('\n'),'varargout{1}')];

% Write end of subfunction.
txt = [txt,sprintf('end\n')];

end
% End of subfunction symbolic_().

%********************************************************************
%! Subfunction numerical_().

function txt = numerical_(block,param,eqtn,solvefor,allbut,loglinlist,options)

neqtn = length(eqtn);
nsolvefor = length(solvefor);

% is this variable loglin?
loglin = allbut(ones([1,nsolvefor]));
if ~isempty(loglinlist)
   aux = ~isnan(findnames(loglinlist,solvefor));
   loglin(aux) = ~loglin(aux);
end

txt = sprintf('function varargout = block%g_(varargin)\n',block);
% input parameters
for i = 1 : length(param)
   txt = [txt,sprintf('%s = varargin{1}.%s;\n',param{i},param{i})];
end
% initial values
txt = [txt,sprintf('X__ = zeros([1,%g]);\n',nsolvefor)];
for i = 1 : nsolvefor
   if loglin(i)
      txt = [txt,sprintf('try, X__(%g) = log(varargin{1}.%s); end\n',i,solvefor{i})];
   else
      txt = [txt,sprintf('try, X__(%g) = varargin{1}.%s; end\n',i,solvefor{i})];      
   end
end
txt = [txt,sprintf('varargout{1} = varargin{1};\n')];
txt = [txt,sprintf('[X__,varargout{2},varargout{3}] = fsolve(@solve%g__,X__,varargin{2});\n',block)];
for i = 1 : nsolvefor
   if loglin(i)
      txt = [txt,sprintf('varargout{1}.%s = exp(X__(%g));\n',solvefor{i},i)];
   else
      txt = [txt,sprintf('varargout{1}.%s = X__(%g);\n',solvefor{i},i)];
   end
end
% nested function
txt = [txt,sprintf('\tfunction varargout = solve%g__(varargin)\n',block)];
for i = 1 : nsolvefor
   if loglin(i)
      txt = [txt,sprintf('\t%s = exp(varargin{1}(%g));\n',solvefor{i},i)];
   else
      txt = [txt,sprintf('\t%s = varargin{1}(%g);\n',solvefor{i},i)];
   end
end
% compute discrepancies in individual equations
txt = [txt,sprintf('\tvarargout{1} = [\n')];
for i = 1 : neqtn
   aux = regexprep(eqtn{i},'(.*?)=(.*)','$1-($2)');
   txt = [txt,sprintf('\t%s\n',aux)];
end
txt = [txt,sprintf('\t];\n')];
txt = [txt,sprintf('\tend\n')]; % end of nested function
txt = [txt,sprintf('end\n')]; % end of subfunction

end
% End of subfunction numerical_().

%********************************************************************
%! Subfunction multisolutions_().

function choose = multisolutions_(s,solvefor,block)

html = grabtext('=== START OF HTML ===','=== END OF HTML ===');
html = strrep(html,'### BLOCK NUMBER HERE ###',sprintf('%g',block));

nsol = length(s);
txt = '';
for i = 1 : nsol
   txt = [txt,sprintf('<div><div style="margin-top: 1em; font-size: large; font-weight: bold;">Solution #%g</div><pre style="font-family: Consolas,Monospace;">',i)];
   txt = [txt,writesolution_(s{i},solvefor,'<br/>')];
   txt = [txt,sprintf('</pre></div>')];
end

html = strrep(html,'### SOLUTIONS HERE ###',txt);
[ans,h] = web('-new');
set(h,'htmlText',html);

ask = true;
while ask
   choose = input(sprintf('Choose solution # (1 to %g) or press Ctrl+C to escape: ',nsol));
   ask = choose ~= round(choose) || choose < 1 || choose > nsol;
end
close(h);

end
% End of subfunction multisolutions_().

%********************************************************************
%! Subfunction writesolution_().

function txt = writesolution_(s,solveFor,newLine,prefix)

if nargin > 3 && ~isempty(prefix)
   prefix = [prefix,'.'];
else
   prefix = '';
end

txt = '';
for i = 1 : length(solveFor)
   txt = [txt,sprintf('%s%s = %s;%s',prefix,solveFor{i},s{i},newLine)];
end

end
% End of subfunction writesolution_().

%{
=== START OF HTML ===
<html>
<body>
<div style="font-size: large; font-weight: bold; color: #900;">
Multiple solutions found in block ### BLOCK NUMBER HERE ###.</br>
Choose one of them by typing its number in command prompt.
</div>
### SOLUTIONS HERE ###
</body>
</html>
=== END OF HTML ===
%}
   