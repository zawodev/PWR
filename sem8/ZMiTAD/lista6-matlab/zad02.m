clc; clear; close all;
load('anova_data.mat');

% zalozenia (z tresci): normalnosc i rownosc wariancji przyjmujemy bez weryfikacji

%% Jednoczynnikowa ANOVA
% H0: srednie aktywnosci dobowej we wszystkich grupach wombatow sa rowne
% H1: co najmniej jedna srednia rozni sie istotnie
fprintf('Jednoczynnikowa ANOVA - aktywnosc dobowa wombatow:\n');
[p, ~, stats] = anova1(wombats, wombat_groups);
fprintf('p-value = %.4f\n', p);
if p < 0.05
    fprintf('Odrzucamy H0: co najmniej jedna srednia rozni sie istotnie.\n');
    figure('Name', 'Post-hoc: multcompare');
    multcompare(stats);
    title('Przedzialy ufnosci roznic srednich (multcompare)');
else
    fprintf('Brak podstaw do odrzucenia H0: srednie sa rowne.\n');
end
