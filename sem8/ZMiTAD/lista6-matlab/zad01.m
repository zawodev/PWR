clc; clear; close all;
load('anova_data.mat');

%% Normalnosc - QQplots + lillietest
figure('Name', 'Normalnosc - czas snu koali');
for i = 1:3
    subplot(1,3,i);
    qqplot(koala(:,i));
    [h, p] = lillietest(koala(:,i));
    title(sprintf('Grupa %d', i));
    xlabel(sprintf('lillietest: p=%.3f, h=%d  (h=0? -> normalny)', p, h));
end
sgtitle('QQ-plots: czas snu koali');

%% Rownosc wariancji - vartestn
% H0: wariancje sa rowne; H1: co najmniej jedna jest rozna
[p_var] = vartestn(koala, 'TestType', 'Bartlett', 'Display', 'off');
fprintf('vartestn (rownosc wariancji): p=%.4f', p_var);
if p_var > 0.05
    fprintf(' -> wariancje rowne (zalozenie spelnione)\n');
else
    fprintf(' -> wariancje NIEROWNE (zalozenie niespelnione!)\n');
end

%% Jednoczynnikowa ANOVA
% H0: srednie we wszystkich 3 grupach sa rowne
% H1: co najmniej jedna srednia rozni sie istotnie
fprintf('\nJednoczynnikowa ANOVA:\n');
[p, ~, stats] = anova1(koala, {'Gr.1', 'Gr.2', 'Gr.3'});
fprintf('p-value = %.4f\n', p);
if p < 0.05
    fprintf('Odrzucamy H0: co najmniej jedna srednia rozni sie istotnie.\n');
    figure('Name', 'Post-hoc: multcompare');
    multcompare(stats);
    title('Przedzialy ufnosci roznic srednich (multcompare)');
else
    fprintf('Brak podstaw do odrzucenia H0: srednie sa rowne.\n');
end
