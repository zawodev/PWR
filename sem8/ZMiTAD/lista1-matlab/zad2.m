x = 1:10;

[m,s] = stat(x)

x1 = 2*(randn(100,1)+1);
x2 = 3*(randn(100,1)-1);

z = [x1 x2];

subplot(211)
boxplot(z,1)

subplot(212)
hist(z)