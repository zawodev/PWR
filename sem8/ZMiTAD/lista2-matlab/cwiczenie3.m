clear; clc;

% stawiamy h1 czy czas jest większy od 6min

mu0 = 6;
x_bar = 6 + 20/60;
sigma = 1.5;
n = 25;
alpha = 0.05;

z = (x_bar - mu0) / (sigma / sqrt(n));
z_crit = norminv(1 - alpha); % test prawostronny
p = 1 - normcdf(z); % p dla testu prawostronnego

fprintf('Cwiczenie 3\n');
fprintf('z = %.4f, z_kryt = %.4f, p = %.6f\n', z, z_crit, p);

if z > z_crit
    fprintf('Decyzja: odrzucamy H0 (czas jest istotnie dluzszy od 6 min)\n');
else
    fprintf('Decyzja: brak podstaw do odrzucenia H0\n');
end
