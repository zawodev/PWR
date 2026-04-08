clc; clear; close all;

% porównanie czasu ćwiczeń w dwóch grupach

data = readtable('data/dane z koronografii.csv');
g1 = data.time(data.group == 1);
g2 = data.time(data.group == 2);

figure;
subplot(1,3,1); boxplot(data.time, data.group); title('Czas vs Grupa');
subplot(1,3,2); qqplot(g1); title('QQ-Plot Grupa 1');
subplot(1,3,3); qqplot(g2); title('QQ-Plot Grupa 2');

% sprawdzenie normalności w grupach
p_n1 = lillietest(g1);
p_n2 = lillietest(g2);

% ranksum > signrank poniewaz grupy sa niezalezne (różna liczebność grup)
[p, h] = ranksum(g1, g2, 'alpha', 0.1);

fprintf('Normalność G1 (p): %.4f, G2 (p): %.4f\n', p_n1, p_n2);
fprintf('Test Ranksum (p): %.4f, h: %d\n', p, h);

if h == 1
    disp('Wniosek: Czas ćwiczenia zależy od stanu zdrowia.');
else
    disp('Wniosek: Brak istotnych różnic między grupami.');
end