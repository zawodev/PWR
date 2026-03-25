clear; clc;

T = readtable('data/pacjenci.csv');

alpha = 0.05;

[h, p, W] = swtest(T.cukier, alpha);

fprintf('Statystyka W: %.4f\n', W);
fprintf('Wartość p:    %.4f\n', p);

if h == 1
    fprintf('rozkład nie jest normalny.\n');
else
    fprintf('rozkład jest normalny.\n');
end

figure;
qqplot(T.cukier);
title('Q-Q cukru');
grid on;