clear; clc;
% Ćwiczenie 2. Zastanów się czy osoby nerwowe mają tendencję do silniejszej gestykulacji
% nerwowi = 3, 3, 4, 5, 5; spokojni = 4, 6, 7, 9, 9
nerwowi = [3, 3, 4, 5, 5];
spokojni = [4, 6, 7, 9, 9];

[hN1, pN1] = swtest(nerwowi(:), 0.05);
[hN2, pN2] = swtest(spokojni(:), 0.05);
fprintf('Normalnosc nerwowi: h=%d, p=%.4f\n', hN1, pN1);
fprintf('Normalnosc spokojni: h=%d, p=%.4f\n\n', hN2, pN2);

figure('Name', 'QQ plot - nerwowi');
qqplot(nerwowi(:));
grid on;
title('QQ plot - nerwowi');

figure('Name', 'QQ plot - spokojni');
qqplot(spokojni(:));
grid on;
title('QQ plot - spokojni');

% Hipotezy: H0: mu1 = mu2, H1: mu1 != mu2 (lub mu1 < mu2 dla jednostronnego)
fprintf('Test t dla prób niezależnych (gestykulacja)\n');
[h, p, ci, stats] = ttest2(nerwowi, spokojni, 0.05, 'both'); % both lub right

fprintf('Wynik h: %d\n', h);
fprintf('Wartość p: %.4f\n', p);
fprintf('Stopnie swobody (df): %d\n', stats.df);
fprintf('Statystyka t: %.4f\n', stats.tstat);