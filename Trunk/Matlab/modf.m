function [x y] = modf(n)

x = fix(n);
y = n - x;

end