function outtext = solvefile(infile,outfile,varargin)

default = {...
  'display',false,@islogical,...
  'simplify',Inf,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x,...
};
options = passvalopt(default,varargin{:});

% ###########################################################################################################
%% function body

rehash();
intext = file2char(infile);

% detect += or *=
if ~isempty(strfind(intext,'+='))
  options.function = false;
  options.sign = '+=';
  intext = strrep(intext,'+=','=');
else
  options.function = true;
  options.sign = '=';
end

% remove line comments %...
intext = regexprep(intext,'%.*?\n','\n');
intext = regexprep(intext,'%.*?$','');

% remove block comments /*...*/
intext = strrep(intext,'/*',char(1));
intext = strrep(intext,'*/',char(2));
intextlength = NaN;
while length(intext) ~= intextlength
  intextlength = length(intext);
  intext = regexprep(intext,'\x{1}[^\x{1}]*?\x{2}','');
end
intext = strrep(intext,char(1),'/*');
intext = strrep(intext,char(2),'*/');

%{
% find start verbatim block
startverbatim = regexp(intext,'^\s*"(.*?)"','tokens');
if ~isempty(startverbatim)
  startverbatim = startverbatim{1}{1};
end
intext = regexprep(intext,'^\s*".*?"','');

% find end verbatim block
endverbatim = regexp(intext,'"(.*?)"\s*$','tokens');
if ~isempty(endverbatim)
  endverbatim = endverbatim{1}{1};
end
intext = regexprep(intext,'".*?"\s*$','');
%}

% replace ends of lines with blank spaces
intext = strrep(intext,char(13),' ');
intext = strrep(intext,char(10),' ');

% replace @fcn with fcn, fcn = {log,exp,log10,sqrt}
fcnlist = 'log|exp|log10|sqrt';
intext = regexprep(intext,sprintf('@(%s)\\(',fcnlist),'$1(');

% read blocks
block = regexp(intext,'.*?\}','match');

outtext = '';
if options.function
  % function heading
  [ans,mfile,void] = fileparts(outfile);
  outtext = [outtext,sprintf('function varargout = %s(varargin)\n\n',mfile)];
end

% list of exogenous inputs (first block with no equations)
invrbl = regexp(block{1},'(?<=\{).*(?=\})','match','once');
invrbl = regexp(invrbl,'\w*','match');

if options.function
  % retrieve fields from input struct
  for name = vech(invrbl)
    outtext = [outtext,sprintf('%s = varargin{1}.%s;\n',name{1},name{1})];
  end
%  if ~isempty(startverbatim)
%    outtext = [outtext,sprintf('%s\n\n',startverbatim)];
%  end
end

% each block has its own list of equations and list of variables
outvrbl = {};
[lastmsg,lastid] = lastwarn();
warning('off','symbolic:solve:warnmsg3');
for i = 2 : length(block)
  [label,start,finish] = regexp(block{i},'".*?"','once','match');
  if options.display
    if isempty(label)
      disp(sprintf('Solving block #%g.',i-1));
    else
      disp(sprintf('Solving block #%g %s.',i-1,label));
    end
  end
  outtext = [outtext,sprintf('\n')];
  outtext = [outtext,sprintf('%% Block %g ',i-1)];
  if ~isempty(label)
    outtext = [outtext,label];
    label = [' ',label];
    block{i}(start:finish) = '';
  end
  outtext = [outtext,sprintf('\n')];
  eqtn = regexp(block{i},'\s*(.*?);','tokens');
  vrbl = regexp(block{i},'(?<=\{).*(?=\})','match','once');
  eqtn = [eqtn{:}];
  eqtn = strrep(eqtn,' ','');
  vrbl = regexp(vrbl,'\w*','match');
  if ~isempty(eqtn) && ~isempty(vrbl)
    lastwarn('','');
    try
      s = solve(eqtn{:},vrbl{:});
    catch
      error('Error when solving block #%g%s.\n\tMatlab sais: "%s"',i-1,label,strrep(lasterr,char(10),' '));
    end
    msg = lastwarn();
    if ~isempty(msg)
      error('Explicit solution could not be found for block %g%s.',i-1,label);
    end
    if length(vrbl) == 1
      s = struct(vrbl{1},s);
    end
    for name = vech(fieldnames(s))
      if length(s.(name{1})) > options.simplify
        s.(name{1}) = simple(horner(simple(s.(name{1}))));
      end
      s.(name{1}) = char(s.(name{1}));
      s.(name{1}) = regexprep(s.(name{1}),'\<ln\>\(','log(');
      s.(name{1}) = strrep(s.(name{1}),'*','.*');
      s.(name{1}) = strrep(s.(name{1}),'/','./');
      s.(name{1}) = strrep(s.(name{1}),'^','.^');
      outtext = [outtext,sprintf('%s %s %s;\n',name{1},options.sign,s.(name{1}))];
    end
    % disp(sprintf('block %g simplified',i-1));
    outvrbl = [outvrbl,vrbl];
  end
end
warning('on','symbolic:solve:warnmsg3');
lastwarn(lastmsg,lastid);

if options.function
  % create output struct
  outtext = [outtext,sprintf('\n')];
  outtext = [outtext,sprintf('varargout{1} = varargin{1};\n')];
  for name = outvrbl
    outtext = [outtext,sprintf('varargout{1}.%s = %s;\n',name{1},name{1})];
  end
%  if ~isempty(endverbatim)
%    outtext = [outtext,sprintf('\n')];
%    outtext = [outtext,sprintf('%s\n',endverbatim)];
%  end
  % end of function
  outtext = [outtext,sprintf('\n')];
  outtext = [outtext,sprintf('end')];
else
  % replace fnc with @fcn
  outtext = regexprep(outtext,sprintf('\\<(%s)\\>\\(',fcnlist),'@$1(');
end

char2file(outtext,outfile);

end

% end of primary function
% ###########################################################################################################