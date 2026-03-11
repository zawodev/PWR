function y = gen1(x,N)

m = 8191;
a = 101;
c = 1731;

y = zeros(N,1);

for i=1:N
    x = mod(a.*x + c,m);
    y(i) = x/m;
end

end