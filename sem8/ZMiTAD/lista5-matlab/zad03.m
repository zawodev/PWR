clc; clear; close all;

% masy nasion dwóch połówek tej samej rośliny (jedna zapylona druga nie)

data = readtable('data/chmiel.csv');
zapy = data.zapylona;
niez = data.niezapyl;
diffs = zapy - niez;

figure;
subplot(1,2,1); qqplot(diffs); title('QQ-Plot różnic (Chmiel)');
subplot(1,2,2); boxplot([zapy, niez], 'Labels', {'Zapylona', 'Niezapylona'}); title('Masa nasion');

[h_norm, p_norm] = lillietest(diffs);
[p, h] = signrank(zapy, niez);

fprintf('Normalność różnic (p): %.4f\n', p_norm);
fprintf('Test Wilcoxona (p): %.4f, h: %d\n', p, h);
if h == 1
    disp('Wniosek: Zapylenie ma istotny wpływ na masę nasion.');
else
    disp('Wniosek: Brak podstaw do odrzucenia H0.');
end