clear; clc;

T = readtable('data/kondensatory.csv');
alpha = 0.05;

[h, p, w] = swtest(T.pojemnosc, alpha);

fprintf('Statystyka W: %.4f\n', w);
fprintf('Wartość p:    %.4f\n', p);

if h == 1
    fprintf('brak rozkładu normalnego.\n');
else
    fprintf('rozkład normalny.\n');
end

figure;
qqplot(T.pojemnosc);
title('Q-Q Plot: Kondensatory');