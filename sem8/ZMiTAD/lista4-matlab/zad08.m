clear; clc;
% Ćwiczenie 8. Wzrost studentów (13:00 vs 17:00) za pomocą testu U.
data13 = [175.26, 177.8, 167.64, 160.02, 172.72, 177.8, 175.26, 170.18, 157.48, 160.02, 193.04, 149.86, 157.48, 157.48, 190.5, 157.48, 182.88, 160.02];
data17 = [172.72, 157.48, 170.18, 172.72, 175.26, 170.18, 154.94, 149.86, 157.48, 154.94, 175.26, 167.64, 157.48, 157.48, 154.94, 177.8];

[hN13, pN13] = lillietest(data13(:));
[hN17, pN17] = lillietest(data17(:));
fprintf('Normalnosc data13: h=%d, p=%.4f\n', hN13, pN13);
fprintf('Normalnosc data17: h=%d, p=%.4f\n\n', hN17, pN17);

figure('Name', 'QQ plot - data13');
qqplot(data13(:));
grid on;
title('QQ plot - data13');

figure('Name', 'QQ plot - data17');
qqplot(data17(:));
grid on;
title('QQ plot - data17');

fprintf('test u dla wzrostu studentów\n');
% H0: średni wzrost w obu grupach jest taki sam (rozkłady są równe).
% H1: wzrost studentów w jednej grupie różni się od wzrostu w drugiej grupie.

[p, h, stats] = ranksum(data13, data17, 'alpha', 0.05);

fprintf('wynik testu: h = %d\n', h);
fprintf('wartość p: %.4f\n', p);
fprintf('suma rang: %.1f\n', stats.ranksum);