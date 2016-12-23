function x = iff(cond,iftrue,iffalse)

if length(cond) ~= 1
   error('Condition must be scalar.');
end

if cond
   x = iftrue;
else
   x = iffalse;
end

end