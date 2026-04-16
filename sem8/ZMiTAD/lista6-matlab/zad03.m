clc; clear; close all;

% dane: sprzedaz kwartalna batona w 14 marketach (wiersze=sklepy, kolumny=kwartaly)
X = [3415 4556 5772 5432;
     1593 1937 2242 2794;
     1976 2056 2240 2085;
     1526 1594 1644 1705;
     1538 1634 1866 1769;
      983 1086 1135 1177;
     1050 1209 1245  977;
     1861 2087 2054 2018;
     1714 2415 2361 2424;
     1320 1621 1624 1551;
     1276 1377 1522 1412;
     1263 1279 1350 1490;
     1271 1417 1583 1513;
     1436 1310 1357 1468];

%% Wizualizacja
figure('Name', 'Sprzedaz wg kwartalu');
sklep_labels = arrayfun(@(x) sprintf('Sk%d', x), 1:14, 'UniformOutput', false);
plot(1:4, X', '-o');
xticks(1:4); xticklabels({'Q1', 'Q2 (kampania)', 'Q3', 'Q4'});
xlabel('Kwartal'); ylabel('Sprzedaz [szt.]');
title('Sprzedaz batona w 14 marketach');
legend(sklep_labels, 'Location', 'eastoutside', 'FontSize', 7);
xline(2, '--r', 'Kampania billboardowa', 'LabelVerticalAlignment', 'bottom');

%% Test Friedmana
% te same sklepy mierzone w 4 kwartalach czyli dane są powiązane (powtarzające się pomiary)
% 
% test friedmana = nieparametryczny odpowiednik jednoczynnikowej ANOVA dla pomiarow powtarzanych
% 
% H0: kwartal nie ma wplywu na sprzedaz (mediany sa rowne)
% H1: co najmniej w jednym kwartale mediana jest istotnie rozna
fprintf('Test Friedmana (pomiary powiazane bo te same sklepy, 4 kwartaly):\n');
[p, tbl] = friedman(X, 1);
disp(tbl);
fprintf('p-value = %.4f\n', p);
if p < 0.05
    fprintf('Odrzucamy H0: kwartal ma istotny wplyw na sprzedaz.\n');
    fprintf('Kampania billboardowa (Q2) prawdopodobnie przyczynila sie do wzrostu sprzedazy.\n');
else
    fprintf('Brak podstaw do odrzucenia H0: kwartal nie ma istotnego wplywu na sprzedaz.\n');
end
