function [mean_val,stdev] = stat(x)

n = length(x);
mean_val = sum(x) / n;
stdev = sqrt(sum((x - mean_val).^2)/n);

end