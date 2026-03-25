clear; clc;

data = [1345, 1127, 1925, 2028, 1276, 1053, 2034, 1857, 925, 1430];

alpha = 0.1;

[h, p, w] = swtest(data, alpha);

fprintf('Statystyka W: %.4f\n', w);
fprintf('Wartość p:    %.4f\n', p);

if h == 1
    fprintf('rozkład nie jest normalny.\n');
else
    fprintf('rozkład jest normalny.\n');
end

figure;
qqplot(data);
title('Q-Q Plot: Żarówki (Test S-W)');