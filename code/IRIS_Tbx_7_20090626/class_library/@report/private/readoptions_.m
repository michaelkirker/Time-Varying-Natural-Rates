function A = readoptions_(parentoptions,varargin)

if ~isempty(parentoptions)
  A = parentoptions;
  A.footnote = '';
  A.saveas = '';
else
  A = default_();
end


for i = 1 : 2 : nargin-1

  lhs = strtrim(varargin{i});
     
  try
    rhs = varargin{i+1};
  catch
    lhs = '';
    rhs = '';
    flag = false;
  end
  
  switch lower(lhs)
  
  case 'angle'
    [A.angle,flag] = double_(rhs,1);
  
  case 'bold'
    [A.bold,flag] = logical_(rhs);
    
  case 'centering'
    [A.centering,flag] = logical_(rhs);        
    
  case 'close'
    [A.close,flag] = logical_(rhs);        
  
  case 'colnames'
    [A.colnames,flag] = cellstr_(rhs,'trim');
    
  case 'color'
    [A.color,flag] = logical_(rhs);        

  case 'colsep'
    [A.colsep,flag] = double_(rhs,1);

  case {'comment','footnote'}
    [A.footnote,flag] = char_(rhs,'trim');
  
  case 'dateformat'
    [A.dateformat,flag] = char_(rhs,'trim');
    
  case 'decimal'
    [A.decimal,flag] = double_(rhs,1);
    
  case 'divider'
    [A.divider,flag] = double_(rhs,inf);
    
  case 'equalwidth'
    [A.equalwidth,flag] = logical_(rhs);  

  case {'font','fontname'}
    [A.fontname,flag] = char_(rhs,'trim');  
        
  case 'fontsize'
    [A.fontsize,flag] = double_(rhs,1);
    if flag == false
      [A.fontsize,flag] = char_(rhs,'allblanks');
    end
  
  case {'graphvisible','visible'}
    [A.graphvisible,flag] = logical_(rhs);  
    
  case 'hdivider'
    [A.hdivider,flag] = double_(rhs,inf);      
    
  case {'header','head','heading'}
    [A.heading,flag] = char_(rhs,'trim');
    
  case {'hline','hframe'}
    [A.hframe,flag] = logical_(rhs);
    
  case 'horizontal'
    [A.horizontal,flag] = double_(rhs,1);  
    
  case 'inf'
    [A.inf,flag] = char_(rhs,'trim');
          
  case 'intercolumn'
    [A.intercolumn,flag] = double_(rhs,1);
  
  case 'irisstamp'
    [A.irisstamp,flag] = logical_(rhs);

  case 'italic'
    [A.italic,flag] = logical_(rhs);
   
  case 'language'
    [rhs,flag] = char_(rhs,'allblanks');
    if flag == true
      switch rhs
      case {'en','english'}
        A.language = 'en';
      case {'cz','czech'}
        A.language = 'cz';
      case {'es','sp','espanol','spanish'}
        A.language = 'es';
      otherwise
        flag = false;
      end
    end
    
  case 'legend'
    [A.legend,flag] = logical_(rhs);
    
  case 'linestretch'
    [A.linestretch,flag] = double_(rhs,1);
    
  case 'nan'
    [A.nan,flag] = char_(rhs,'trim');
    
  case 'orientation'
    [rhs,flag] = char_(rhs,'allblanks');
    if flag == true
      switch rhs
      case 'portrait'
        A.orientation = 'portrait';
      case 'landscape'
        A.orientation = 'landscape';
      end
    end
    
  case 'pagenumber'
    [A.pagenumber,flag] = logical_(rhs);
    
  case {'paper','papersize'}
    [rhs,flag] = char_(rhs,'allblanks');
    if flag == true
      switch rhs
      case {'a4','a4paper'}
        A.papersize = 'a4';
      case {'executive','executivepaper'}
        A.papersize = 'executive';
      case {'letter','letterpaper'}
        A.papersize = 'letter';
      end
    end
    
  case 'parskip'
    [A.parskip,flag] = double_(rhs,1); 
    
  case 'plotbox'
    [A.plotbox,flag] = double_(rhs,2);
    
  case 'range'
    [A.range,flag] = double_(rhs,Inf);
    
  case {'reportdate','timestamp'}
    [A.timestamp,flag] = logical_(rhs);
                              
  case 'rownames'
    [A.rownames,flag] = cellstr_(rhs,'trim');

  case 'saveas'
    [A.saveas,flag] = char_(rhs,'trim');
    A.saveas = strrep(A.saveas,'\','/');
    A.saveas = regexprep(A.saveas,'\.\w*$','');
    
  case 'scale'
    [A.scale,flag] = double_(rhs,1);
    
  case 'skip'
    [A.skip,flag] = double_(rhs,1);
    
  case 'smallcaps'
    [A.smallcaps,flag] = logical_(rhs);
  
  case 'sstate'
    [A.sstate,flag] = double_(rhs,1);
    if flag == false  
      [A.sstate,flag] = logical_(rhs);
    end
    
  case 'sstatemark'
    [A.sstatemark,flag] = char_(rhs,'trim');
    
  case 'text'
    [A.text,flag] = char_(rhs,'trim');
    
  case 'textscale'
    [A.textscale,flag] = double_(rhs,2);
    if flag == false
      [A.textscale,flag] = double_(rhs,1);
      A.textscale = A.textscale*[1,1];
    end
    
  case 'textwidth'
    [A.textwidth,flag] = double_(rhs,1);
    
  case {'unit','units'}
    [A.unit,flag] = char_(rhs,'trim');
 
  case 'vdivider'
    [A.vdivider,flag] = double_(rhs,inf);                 
    
  case {'vframe','vline'}
    [A.vframe,flag] = logical_(rhs);  
    if flag == false
      [A.vframe,flag] = double_(rhs,inf);  
    end        
    
  otherwise
    flag = false;
    
  end
  
  if flag == false
    error_(3,{lhs});
  end  
end
    
end  

  % -----subfunction----- %

  function [rhs,flag] = double_(rhs,len)
  
  if isnumeric(rhs)
    rhs = vech(rhs);
    flag = true;
    if ~isinf(len) && length(rhs) ~= len
      rhs = NaN;
      flag = false;
    end
  else
    rhs = NaN;
    flag = false;
  end
    
  end
  
  % -----subfunction----- %
  
  function [rhs,flag] = logical_(rhs)
  
  if islogical(rhs)
    flag = true;
  else
    rhs = NaN;
    flag = false;
  end
  
  end

  % -----subfunction----- %
  
  function [rhs,flag] = char_(rhs,option)
  
  flag = true;
  
  if ischar(rhs)
    switch option    
    case 'trim'
      rhs = strtrim(rhs);
    case 'allblanks'
      rhs(find(rhs <= char(32))) = '';
    end
  else
    flag = false;
  end
    
  end  
  
  % -----subfunction----- %
  
  function [rhs,flag] = cellstr_(rhs,option)
  
  flag = true;
  
  if iscellstr(rhs)
    if strcmp(option,'trim')
      rhs = strtrim(rhs);
    end
  else
    flag = false;
  end  
  
  end