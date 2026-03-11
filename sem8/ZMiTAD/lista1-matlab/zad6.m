x = 3 + 2*randn(1000,1);
% N(3, 4) to średnia = 3 i wariancja = 4
% sqrt(4) = 2

figure
hist(x,30)

[f,xi] = ecdf(x);

figure
plot(xi,f)
title('Dystrybuanta')