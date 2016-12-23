function savestruct(fname,this);
%
% The IRIS Toolbox 2008/03/18. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

if ischar(this)
   [this,fname] = deal(fname,this);   
end

this.name = repository_('NAME');
this.data = repository_('DATA');
this.lock = repository_('LOCK');
this = struct(this);
this.SAVESTRUCT_CLASS = 'container';

save(fname,'-struct','this','-mat');

end
% end of primary function