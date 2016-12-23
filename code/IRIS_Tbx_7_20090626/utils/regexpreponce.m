function this = regexpreponce(this,reg,replace)

if isempty(this)
   return
end

[match,tokens,start,finish] = regexp(this,reg,'match','tokens','start','end','once');
if ~isempty(match)
   this = [this(1:start-1),replace(match,tokens),regexpreponce(this(finish+1:end),reg,replace)];
end

end