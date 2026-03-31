clear; clc;
% Ćwiczenie 6. Przeanalizujmy, czy średni wzrost studentów dla grupy z 17:00 jest 164.1475
data17 = [172.72, 157.48, 170.18, 172.72, 175.26, 170.18, 154.94, 149.86, 157.48, 154.94, 175.26, 167.64, 157.48, 157.48, 154.94, 177.8];

fprintf('Test t dla jednej próby (wzrost 17:00 vs 164.1475)\n');
[h, p, ci, stats] = ttest(data17, 164.1475);

fprintf('h: %d, p: %.4f\n', h, p);
fprintf('Przedział ufności: [%.2f, %.2f]\n', ci(1), ci(2));