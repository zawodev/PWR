clc; clear; close all;

%% Dane FEV (toksyna x zaklad, n=12 na grupe)
T1_Z1 = [4.64,5.92,5.25,6.17,4.20,5.90,5.07,4.13,4.07,5.30,4.37,3.76]';
T2_Z1 = [3.21,3.17,3.88,3.50,2.47,4.12,3.51,3.85,4.22,3.07,3.62,2.95]';
T3_Z1 = [3.75,2.50,2.65,2.84,3.09,2.90,2.62,2.75,3.10,1.99,2.42,2.37]';
T1_Z2 = [5.12,6.10,4.85,4.72,5.36,5.41,5.31,4.78,5.08,4.97,5.85,5.26]';
T2_Z2 = [3.92,3.75,4.01,4.64,3.63,3.46,4.01,3.39,3.78,3.51,3.19,4.04]';
T3_Z2 = [2.95,3.21,3.15,3.25,2.30,2.76,3.01,2.31,2.50,2.02,2.64,2.27]';
T1_Z3 = [4.64,4.32,4.13,5.17,3.77,3.85,4.12,5.07,3.25,3.49,3.65,4.10]';
T2_Z3 = [4.95,5.22,5.16,5.35,4.35,4.89,5.61,4.98,5.77,5.23,4.76,5.15]';
T3_Z3 = [2.95,2.80,3.63,3.85,2.19,3.32,2.68,3.35,3.12,4.11,2.90,2.75]';

% macierz do anova2: 
% kolumny = toksyny (T1,T2,T3)
% wiersze pogrupowane po 12 = zaklady (Z1,Z2,Z3)
X = [T1_Z1, T2_Z1, T3_Z1;
     T1_Z2, T2_Z2, T3_Z2;
     T1_Z3, T2_Z3, T3_Z3];

%% Sprawdzenie normalnosci - QQ-plots + lilietest dla 9 grup
groups = {T1_Z1,T2_Z1,T3_Z1, T1_Z2,T2_Z2,T3_Z2, T1_Z3,T2_Z3,T3_Z3};
labels  = {'T1-Z1','T2-Z1','T3-Z1','T1-Z2','T2-Z2','T3-Z2','T1-Z3','T2-Z3','T3-Z3'};

figure('Name', 'Normalnosc FEV');
all_normal = true;
for i = 1:9
    subplot(3,3,i);
    qqplot(groups{i});
    [h, p] = lillietest(groups{i});
    title(labels{i});
    xlabel(sprintf('Lilliefors: p=%.3f, h=%d', p, h));
    if h, all_normal = false; end
end
sgtitle('QQ-plots FEV (h=0: normalny)');

if all_normal
    fprintf('Normalnosc: wszystkie grupy normalne (brak podstaw do odrzucenia normalnosci).\n');
else
    fprintf('Normalnosc: co najmniej jedna grupa odbiega od normalnosci!\n');
end

%% Sprawdzenie rownosci wariancji dla 9 grup
% X(:) laczy kolumny kolejno: T1(Z1,Z2,Z3), T2(Z1,Z2,Z3), T3(Z1,Z2,Z3)
group_ids = repelem(1:9, 12)';
[p_bart] = vartestn(X(:), group_ids, 'TestType', 'Bartlett', 'Display', 'off');
fprintf('Bartlett (rownosc wariancji, 9 grup): p=%.4f', p_bart);
if p_bart > 0.05
    fprintf('-> wariancje rowne (zalozenie spelnione)\n');
else
    fprintf('-> wariancje NIEROWNE (zalozenie niespelnione!)\n');
end

%% Dwuczynnikowa ANOVA (jesli zalozenia spelnione)
% H01: FEV nie zalezy od toksyny (kolumny)
% H02: FEV nie zalezy od zakladu (wiersze)
% H03: brak synergicznego wplywu toksyny i zakladu (interakcja)
fprintf('\nDwuczynnikowa ANOVA (toksyna x zaklad, n=12 na grupe):\n');

%[p, ~, stats] = anova2(X, 12);

% kolejnosc grup: T1Z1, T2Z1, T3Z1, T1Z2, T2Z2, T3Z2, T1Z3, T2Z3, T3Z3
values = cell2mat(groups(:)); % 108x1
toksyna = repelem([1;2;3;1;2;3;1;2;3], 12);
zaklad = repelem([1;1;1;2;2;2;3;3;3], 12);
[p, ~, stats] = anovan(values, {toksyna, zaklad}, 'model', 'interaction', 'varnames', {'Toksyna', 'Zaklad'}, 'display', 'off');

fprintf('Toksyna (kolumny): p=%.4f\n', p(1));
fprintf('Zaklad (wiersze): p=%.4f\n', p(2));
fprintf('Interakcja: p=%.4f\n', p(3));

%% Post-hoc
if p(1) < 0.05
    fprintf('\nIstotny efekt toksyny -> post-hoc:\n');
    figure('Name', 'Post-hoc: toksyna');
    multcompare(stats, 'Dimension', 1);
    title('Roznice miedzy toksynami');
end

if p(2) < 0.05
    fprintf('Istotny efekt zakladu -> post-hoc:\n');
    figure('Name', 'Post-hoc: zaklad');
    multcompare(stats, 'Dimension', 2);
    title('Roznice miedzy zakladami');
end

if p(3) < 0.05
    fprintf('Istotna interakcja toksyna x zaklad.\n');
else
    fprintf('Brak istotnej interakcji toksyna x zaklad (p=%.4f).\n', p(3));
end
