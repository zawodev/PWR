clear; clc;
% Ćwiczenie 5. Przeanalizujmy, czy średni wzrost studentów dla grupy z 13:00 jest 169.051
data13 = [175.26, 177.8, 167.64, 160.02, 172.72, 177.8, 175.26, 170.18, 157.48, 160.02, 193.04, 149.86, 157.48, 157.48, 190.5, 157.48, 182.88, 160.02];

[hN, pN] = lillietest(data13(:));
fprintf('Normalnosc data13: h=%d, p=%.4f\n\n', hN, pN);

figure('Name', 'QQ plot - data13');
qqplot(data13(:));
grid on;
title('QQ plot - data13');

fprintf('Test t dla jednej próby (wzrost 13:00 vs 169.051)\n');
[h, p, ci, stats] = ttest(data13, 169.051);

fprintf('h: %d, p: %.4f\n', h, p);
fprintf('Przedział ufności: [%.2f, %.2f]\n', ci(1), ci(2));