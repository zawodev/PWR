clear; clc;

mu0 = 28;
mu_sample = 31.5;
s_sample = 5;
n = 100;
alpha = 0.05;

% rachunek reczny (z)
z = (mu_sample - mu0) / (s_sample / sqrt(n));
z_crit = norminv(1 - alpha/2); % norminv to odwrotność dystrybuanty

fprintf('Cwiczenie 1\n');
fprintf('z = %.4f, z_kryt = %.4f\n', z, z_crit);
if abs(z) > z_crit
    fprintf('Decyzja: odrzucamy H0\n');
else
    fprintf('Decyzja: brak podstaw do odrzucenia H0\n');
end

% sprawdzenie przez ttest na wygenerowanej probie
% jak p < alpha to ttest odrzuci H0, czyli h = 1
% jak p >= alpha to ttest nie odrzuci H0, czyli h = 0
% p oznacza dziwność danych, im mniejsze tym mocniejszy arg przeciw h0
rng(42);
x = mu_sample + s_sample * randn(n, 1);
[h, p] = ttest(x, mu0, 'Alpha', alpha);

fprintf('ttest: h = %d, p = %.6f\n', h, p);
