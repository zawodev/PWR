function y = gen3(x,N)

c = 65536;

y = zeros(N,1);

for i=1:N
    x = x*25;
    x = mod(x,c);
    x = x*125;
    x = mod(x,c);
    y(i) = x/c;
end

end