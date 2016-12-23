function h = plotcircle(x,y,radius,varargin)

n = 128;
th = 2*pi*(0:n)/n;

fi = false;
index = find(strcmpi('fill',varargin));
if ~isempty(index)
  fi = varargin{index+1};
  varargin([index,index+1]) = [];
end

if fi
  h = fill(x+radius*cos(th),y+radius*sin(th),[0,0,1],varargin{:});
else
  h = plot(x+radius*cos(th),y+radius*sin(th),varargin{:});
end

end