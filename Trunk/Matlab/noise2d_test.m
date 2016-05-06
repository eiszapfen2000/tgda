function n = noise2d_test(gll, gul, glr, gur, ll, ul, lr, ur, x)

delta_ll = x - ll;
delta_ul = x - ul;
delta_lr = x - lr;
delta_ur = x - ur;

n_ll = dot(gll, delta_ll);
n_ul = dot(gul, delta_ul);
n_lr = dot(glr, delta_lr);
n_ur = dot(gur, delta_ur);

i_x(1) = x(1) - ll(1);
i_x(2) = x(1) - ul(1);
i_x(3) = delta_ll(1);
i_x(4) = delta_ul(1);

i_y(1) = x(2) - ll(2);
i_y(2) = x(2) - lr(2);
i_y(3) = delta_ll(2);
i_y(4) = delta_lr(2);

a = n_ll * (1 - i_x(1)) + n_lr * i_x(1);
b = n_ul * (1 - i_x(1)) + n_ur * i_x(1);

n = a * (1 - i_y(1)) + b * i_y(1);

end