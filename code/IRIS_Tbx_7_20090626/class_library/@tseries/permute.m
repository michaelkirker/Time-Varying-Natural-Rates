function this = permute(this,order)

% ===========================================================================================================
%! Function body.

if order(1) ~= 1
   error('First dimension must remain fixed in tseries objects.');
end

this.data = permute(this.data,order);
this.comment = permute(this.comment,order);

end
% End of primary function.