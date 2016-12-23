function [P,discrep] = solvefile_num(fname,P,varargin)

% ###########################################################################################################
%% function body

rehash();
in = readcode(fname,P);

% replace ends of lines with blank spaces
in = strrep(in,char(13),' ');
in = strrep(in,char(10),' ');

% read blocks
block = regexp(in,'.*?\}','match');
nblock = length(block);

% list of input parameters
params = regexp(block{1},'(?<=\{).*(?=\})','match','once');
params = regexp(params,'[A-Za-z]\w*','match');

discrep = cell([1,nblock-1]);

for iblock = 2 : nblock
   
   out = sprintf('function x = solvefile_(varargin)\n\n');
   for i = 1 : length(params)
      out = [out,sprintf('%s = varargin{2}.%s;\n',params{i},params{i})];
   end
   out = [out,sprintf('\n')];

   unkns = regexp(block{iblock},'(?<=\{).*(?=\})','match','once');
   eqtns = regexp(block{iblock},'.*?;','match');

   unkns = regexp(unkns,'[A-Za-z]\w*','match');
   x0 = ones(size(unkns));
   for i = 1 : length(unkns)
      out = [out,sprintf('%s = varargin{1}(%g);\n',unkns{i},i)];
      if isfield(P,unkns{i})
        x0(i) = P.(unkns{i});    
      end
   end
   x0 = x0(:);
   out = [out,sprintf('\n')];

   eqtns = regexprep(eqtns,'\s*','');
   eqtns = regexprep(eqtns,'^(.*?)=(.*?);$','$1-($2);');
   out = [out,sprintf('x = [\n')];
   out = [out,sprintf('%s\n',eqtns{:})];
   out = [out,sprintf('];\n')];
   out = [out,sprintf('\n')];

   out = [out,'end'];
   
   delete('solvefile_.*');
   rehash();
   char2file(out,'solvefile_.m');
   rehash();

   xopt = fsolve(@solvefile_,x0,optimset('display','iter',varargin{:}),P);
   discrep{iblock-1} = solvefile_(xopt,P);

   for i = 1 : length(unkns)
      P.(unkns{i}) = xopt(i);
   end
   params = [params,unkns];

end

end
% end of primary function
