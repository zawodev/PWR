clear; clc;
% Ćwiczenie 2. Zastanów się czy osoby nerwowe mają tendencję do silniejszej gestykulacji
% nerwowi = 3, 3, 4, 5, 5; spokojni = 4, 6, 7, 9, 9
nerwowi = [3, 3, 4, 5, 5];
spokojni = [4, 6, 7, 9, 9];

% Hipotezy: H0: mu1 = mu2, H1: mu1 != mu2 (lub mu1 < mu2 dla jednostronnego)
fprintf('Test t dla prób niezależnych (gestykulacja)\n');
[h, p, ci, stats] = ttest2(nerwowi, spokojni, 0.05, 'both'); % both lub right

fprintf('Wynik h: %d\n', h);
fprintf('Wartość p: %.4f\n', p);
fprintf('Stopnie swobody (df): %d\n', stats.df);
fprintf('Statystyka t: %.4f\n', stats.tstat);