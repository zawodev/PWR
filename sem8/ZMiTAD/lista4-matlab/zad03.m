clear; clc;
% Ćwiczenie 3. Hipoteza: osoby poniżej 30 są bardziej dowcipni niż osoby po 30
mniej30 = [6, 7, 10, 9];
po30 = [5, 6, 2, 3];

fprintf('Test jednostronny (prawostronny): czy młodzi > starsi\n');
[h, p, ci, stats] = ttest2(mniej30, po30, 0.05, 'right');

fprintf('Wynik: h=%d, p=%.4f\n', h, p);
fprintf('Statystyka t: %.4f, df: %d\n', stats.tstat, stats.df);
fprintf('Przedzial ufnosci CI: [%.4f, %.4f]\n', ci(1), ci(2));