function h = ftext(position,text,varargin)

position = getsubposition(position);
text = strrep(text,'\\',char(10));
h = annotation('textbox',position,'string',text,varargin{:});

end