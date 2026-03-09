function y = gen2(x,N)

a = 517;
m = 32767;
c = 6923;

y = zeros(N,1);

for i=1:N
    x = mod(a*x + c,m);
    y(i) = x/m;
end

end