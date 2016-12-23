function h = zeroline(varargin)

if nargin > 0 && isnumeric(varargin{1})
   h = varargin{1};
   varargin(1) = [];
elseif nargin > 0 && iscell(varargin{1})
   h = [varargin{1}{:}];
   varargin(1) = [];
else
   h = gca();
end

ln = [];
for ih = vech(h)
   yLim = get(ih,'yLim');
   if yLim(1) < 0 && yLim(2) > 0
      xlim = get(ih,'xlim');
      axes(ih);
      ln(end+1) = line(xlim,[0,0]);
      % Move zero line to background.
      ch = get(gca,'children');
      if length(ch) > 2
          set(gca,'children',ch([2:end,1]));
      end
   end
end

set(ln,'color','black');
if nargin > 1 && ~isempty(ln)
   set(ln,varargin{:});
end

end