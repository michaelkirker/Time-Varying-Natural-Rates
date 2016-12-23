function [h,ha] = nextplot(varargin)

userdata = get(gcf,'userdata');
if length(userdata) == 2
  pos = 1;
else
  pos = userdata(3) + 1;
end

if pos > prod(userdata)
  copyobj(gcf,0);
  delete(get(gcf,'children'));
  pos = 1;
end

ha = subplot(userdata(1),userdata(2),pos);
h = plot(varargin{:});

userdata(3) = pos;
set(gcf,'userdata',userdata);

end