clc; clear; close all;
load('anova_data.mat');

% popcorn: 6x3, 
% popcorn =
%    5.5000    4.5000    3.5000   -> powietrze
%    5.5000    4.5000    4.0000   -> powietrze
%    6.0000    4.0000    3.0000   -> powietrze
%    6.5000    5.0000    4.0000   -> olej
%    7.0000    5.5000    5.0000   -> olej
%    7.0000    5.0000    4.5000   -> olej
% kolumny=producenci (3), wiersze po 3=typ maszyny (powietrzna/olejowa)
% zalozenia (z przykladu 3): normalnosc, niezaleznosc, rowne wariancje, rowne grupy - spelnione

%% Dwuczynnikowa ANOVA
% H01: srednia liczba kubkow jest taka sama dla wszystkich producentow
% H02: srednia liczba kubkow jest niezalezna od typu maszyny
% H03: producent i typ maszyny nie maja synergicznego wplywu (brak interakcji)
fprintf('Dwuczynnikowa ANOVA (producent x maszyna):\n');

% nie chciało działać
%[p, ~, stats] = anova2(popcorn, 3);

values = popcorn(:);
producent = repelem([1;2;3], 6);
maszyna = repmat([ones(3,1); 2*ones(3,1)], 3, 1);
[p, ~, stats] = anovan(values, {producent, maszyna}, 'model', 'interaction', 'varnames', {'Producent', 'Maszyna'}, 'display', 'off');

fprintf('Producent (kolumny): p=%.4f\n', p(1));
fprintf('Maszyna (wiersze): p=%.4f\n', p(2));
fprintf('Interakcja: p=%.4f\n', p(3));

%% Post-hoc: producenci (kolumny)
if p(1) < 0.05
    fprintf('\nIstotny efekt producenta -> post-hoc multcompare:\n');
    figure('Name', 'Post-hoc: producenci');
    [c, ~] = multcompare(stats, 'Dimension', 1);
    title('Roznice miedzy producentami');
    % wyswietl pary z istotna roznica
    fprintf('  Para   | roznica srednich  |  p-value\n');
    for i = 1:size(c,1)
        fprintf('  %d vs %d |      %.4f       |  %.4f\n', c(i,1), c(i,2), c(i,4), c(i,6));
    end
end

%% Post-hoc: typ maszyny (wiersze)
if p(2) < 0.05
    fprintf('\nIstotny efekt maszyny -> post-hoc multcompare:\n');
    figure('Name', 'Post-hoc: maszyna');
    multcompare(stats, 'Dimension', 2);
    title('Roznice miedzy typami maszyny');
end

if p(3) >= 0.05
    fprintf('\nBrak istotnej interakcji producent x maszyna (p=%.4f).\n', p(3));
end
