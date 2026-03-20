clear; clc;

mu = 6 + 20/60;
sigma = 1.5;
n = 25;
rng(42);
x = mu + sigma * randn(n,1);

% a) h0: sigma = 1.5 (test dwustronny)
v0_A = 1.5^2;
alpha_A = 0.05;
[hA, pA] = vartest(x, v0_A, 'Alpha', alpha_A, 'Tail', 'both');

% b) czy sigma < 1.6 ? (test lewostronny)
v0_B = 1.6^2;
alpha_B = 0.05;
[hB, pB] = vartest(x, v0_B, 'Alpha', alpha_B, 'Tail', 'left');

% c) to samo co B dla alpha = 0.1
alpha_C = 0.10;
[hC, pC] = vartest(x, v0_B, 'Alpha', alpha_C, 'Tail', 'left');

fprintf('Cwiczenie 4\n');
fprintf('srednia proby = %.4f, odch.std proby = %.4f\n', mean(x), std(x));

fprintf('\na) h0: sigma = 1.5 (dwustronny)\n');
fprintf('h = %d, p = %.6f\n', hA, pA);

fprintf('\nb) h0: sigma = 1.6, H1: sigma < 1.6 (alpha=0.05)\n');
fprintf('h = %d, p = %.6f\n', hB, pB);

fprintf('\nc) to samo dla alpha=0.10\n');
fprintf('h = %d, p = %.6f\n', hC, pC);
