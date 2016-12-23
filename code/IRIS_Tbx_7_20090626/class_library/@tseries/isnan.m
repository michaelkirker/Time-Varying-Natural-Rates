function x = isnan(x)
x = unop_(@isnan,x,0);
end