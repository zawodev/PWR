x = 3 + 2*randn(1000,1);

figure
hist(x,30)

[f,xi] = ecdf(x);

figure
plot(xi,f)
title('Dystrybuanta')