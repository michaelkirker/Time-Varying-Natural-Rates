classdef irisparser
   
   properties
      fname = '';
      params = struct();
      code = '';
      labels = {};
   end
   
   methods (Access = public)
      
      function p = irisparser(varargin)
         if nargin > 0
            p.fname = varargin{1};
            if nargin > 1
               p.params = varargin{2};
            end
            [p.code,p.labels] = irisparser.readcode(p.fname,p.params,p.labels);
         end
      end
      
      % Public function signatures.
      [m,params] = model(p,m);
      r = reporting(p);
      list = labelstore(p,list);

   end
   
   methods (Access = private, Static = true)
      % Private static function signatures.
      [code,labels] = readcode(fname,params,varargin);
      error(code,list,varargin);
      warning(code,list,varargin);
   end
   
end