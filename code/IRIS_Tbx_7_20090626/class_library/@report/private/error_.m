function error_(code,list,varargin)

switch code
    
case 2
  msg = 'Misplaced command: ''%s''.';

case 3
  msg = 'Invalid value(s) of attribute(s) or unrecognised attribute(s): %s.';

case 4
  msg = 'Report unfinished. Unable to compile printable file.';
  
case 5
  msg = 'Unrecognised or missing output file extension (only PS or PDF accepted).';
  
case 6
  msg = 'LaTeX not linked. Unable to use report/compile function. ';  
  
case 7
  msg = 'DVIPS not linked. Unable to compile PS output file.';
  
case 8
  msg = 'DVIPDFM not linked. Unable to use compile PDF output file.';
  
case 9
  msg = 'Only matrices with 2 non-singleton dimensions can be used in MATRIX.';
  
end

if nargin == 1
  list = {};
end

printmsg('report','error',msg,list,code);

return