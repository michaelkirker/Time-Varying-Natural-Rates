function texfile = reportcode_(fname,options,code)

texfile = file2char(fname);
texfile = strrep(texfile,'@PAPER',sprintf('%spaper',options.papersize));
texfile = strrep(texfile,'@FONTSIZE',sprintf('%g',options.fontsize));
texfile = strrep(texfile,'@FONTFAMILY',options.fontname);
texfile = strrep(texfile,'@ORIENTATION',iff(strcmp(options.orientation,'landscape'),'landscape',''));
texfile = strrep(texfile,'@SCALE',sprintf('%g,%g',options.textscale.*[1,1]));
texfile = strrep(texfile,'@HEADING',strrep(letterchk_(options.heading,options),'#','\'));
texfile = strrep(texfile,'@PAGENUMBER',iff(options.pagenumber,'\arabic{page}',''));
texfile = strrep(texfile,'@IRISSTAMP',iff(options.irisstamp,'\textit{IRIS Toolbox}',''));
texfile = strrep(texfile,'@TIMESTAMP',iff(options.timestamp,datestr(now,31),''));
texfile = strrep(texfile,'@REPORT',code);
texfile = strrep(texfile,'@COLSEP',sprintf('%gem',options.colsep));

end % of primary function