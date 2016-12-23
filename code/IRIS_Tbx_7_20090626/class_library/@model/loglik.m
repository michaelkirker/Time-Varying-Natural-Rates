function varargout = loglik(this,data,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.loglik">idoc model.loglik</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/14.
% Copyright 2007-2009 Jaromir Benes.

% <a href="model/loglik">LOGLIK</a>  Evaluate likelihood function in frequency domain.
%
% Syntax:
%   [mloglik,se2] = loglik(this,dpack,'domain','f',...)   
%   [mloglik,se2] = loglik(this,dbase,range,'domain','f'...)
% Output arguments:
%   mloglik [ numeric ] Minus log-likelihood.
%   se2 [ numeric ] Estimated common variance factor (if option 'relative' is true).
%   this [ model ] Model.
%   dpack [ cell | numeric ] Input datapack or data array.
%   dbase [ cell | numeric ] Input <a href="databases.html">database</a>.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   'band' [ numeric | <a href="default.html">[2,Inf]</a> ] Band of periodicities used to evaluate likelihood.
%   'domain' [ <a href="default.html">'time'</a> | 'freq' ] Evaluate likelihood function in time or frequency domain.
%   'exclude' [ cellstr | <a href="default.html">empty</a> ] List of measurement variables to be excluded from likelihood function.
%   'relative' [ <a href="default.html">true</a> | false ] Scale MSE matrices by estimated variance factor.
%   'zero' [ true | <a href="default.html">false</a> ] Include zero frequency (if zero lies in 'band').
%
% Nota bene:
%   <a href="matlab: help model/filte"r>MODEL/FILTER</a>, <a href="matlab: help model/loglik">MODEL/LOGLIK</a> (time domain) and <a href="matlab: help model/kalmanf">MODEL/KALMAN</a> differ only in their output arguments.
%
% The IRIS Toolbox 2007/10/11. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% Get array of measurement variables.
[data,range,varargin,outputformat] = loglikdata_(this,data,varargin{:});

default = {...
   'domain','time',@(x) any(strncmpi(x,{'t','f'},1)),...
   'output','auto',@(x) any(strcmpi(x,{'auto','dpack','dbase'})),...
   'pedind',[],@(x) isempty(x) || isstruct(x),...
};
[options,varargin] = extractopt(default(1:3:end),varargin{:});
options = passvalopt(default,options{:});

loglikoptions = loglikopt_(this,range,options.domain,varargin{:});

%********************************************************************
%! Function body.

if strncmpi(options.domain,'f',1)
   % Frequency domain.
   [I,freq,delta] = fourierdata_(this,data,loglikoptions);
   [mlogl,se2] = loglikf_(this,I,freq,delta,loglikoptions);
   varargout{1} = mlogl;
   varargout{2} = se2;
else
   % Time domain (Kalman filter).
   [varargout{1:nargout}] = loglikt2_(this,data,range,options.pedind,loglikoptions);
   % Dump inverses of FMSE matrices.
   if nargout > 2
      varargout{3} = varargout{3}{1}; 
   end
   if strcmpi(outputformat,'dbase')
      if nargout > 3
         % prediction errors varargout{4}
         % convert prediction error into database
         varargout{4} = pestruct_(this,varargout{4},range);
         if nargout > 7
            % pred datapack varargout{8}
            varargout{8}.mean = dp2db(this,varargout{8}.mean);
            varargout{8}.std = dp2db(this,varargout{8}.mse);
            varargout{8} = rmfield(varargout{8},'mse');
            if nargout > 8
               % smooth datapack varargout{9}
               varargout{9}.mean = dp2db(this,varargout{9}.mean);
               varargout{9}.std = dp2db(this,varargout{9}.mse);
               varargout{9} = rmfield(varargout{9},'mse');
            end
         end
      end
   end
end

end
% End of primary function.