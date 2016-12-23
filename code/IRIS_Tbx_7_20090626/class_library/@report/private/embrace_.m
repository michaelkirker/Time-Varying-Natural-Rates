function code = embrace_(code,options,align)

font = font_([],options);
code = sprintf('{%s%s%s%s}%s\n',iff(options.centering & ~align,'\centering',''),font,code,iff(~align,'\medskip\par',''));

end