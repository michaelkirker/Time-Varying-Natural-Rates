function irisassociate()
%
% The IRIS Toolbox 2008/04/01. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

try
   associate = charlist2cellstr(irisget('extensions'));
   % read prf file
   preffname = fullfile(prefdir,'matlab.prf');
   fid = fopen(preffname);
   x = transpose(fread(fid,'*char'));
   fclose(fid);
   % remove any mod, model, or iris extensions
   tokens = regexp(x,'(Editorm-Ext=S)(.*?)(\s*\n)','tokens','once');
   % list of extensions may not be included in matlab.prf
   if isempty(tokens)
      x = [x,sprintf('\nEditorm-Ext=Sm\n')];
      extensions = 'm';
   else
      extensions = tokens{2};
      extensions = regexprep(extensions,'(\<mod\>|\<model\>|\<iris\>)\s*(;|$)','');
   end
   if ~isempty(extensions) && extensions(end) == ';'
      extensions(end) = '';
   end
   % update associated extensions
   if ~isempty(associate)
      extensions = [extensions,sprintf(';%s',associate{:})];   
   end
   % update pfr file contentes
   x = regexprep(x,'(Editorm-Ext=S)(.*?)(\s*\n)',['$1',extensions,'$3'],'once');
   % update prf file
   fid = fopen(preffname,'w');
   fwrite(fid,x,'char');
   fclose(fid);
   rehash();
end

end
% end of primary function