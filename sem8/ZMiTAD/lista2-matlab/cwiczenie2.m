clear; clc;

x = [1 1 1 2 2 2 2 3 3 3 4 4 4 4 4 5 5 6 6 6 7 7]';
mu0 = 3;
alpha = 0.05;

n = length(x);
x_bar = mean(x);
s = std(x);
t_obs = (x_bar - mu0) / (s / sqrt(n)); % zaobserwowana statystyka z t studenta
p_manual = 2 * (1 - tcdf(abs(t_obs), n - 1));

[h, p] = ttest(x, mu0, 'Alpha', alpha);

fprintf('Cwiczenie 2\n');
fprintf('n = %d, srednia = %.4f, s = %.4f\n', n, x_bar, s);
fprintf('t = %.4f, p_reczne = %.6f\n', t_obs, p_manual);
fprintf('ttest: h = %d, p = %.6f\n', h, p);
