clc; clear; close all;

% sprawdzamy czy waga 20 kobiet po 7 tyg diety faktycznie spada, używamy
% wilcoxona bo dane są powiązane i mierzalne

w1 = [88, 69, 86, 59, 57, 82, 94, 93, 64, 91, 86, 59, 91, 60, 57, 92, 70, 88, 70, 85];
w2 = [73, 68, 75, 54, 53, 84, 84, 86, 66, 84, 78, 58, 91, 57, 59, 88, 71, 84, 64, 85];
diffs = w2 - w1; % po minus przed

figure;
subplot(2,2,1); boxplot([w1', w2'], 'Labels', {'Przed', 'Po'}); title('Masa ciała');
subplot(2,2,2); qqplot(diffs); title('QQ-Plot różnic');
subplot(2,2,3); histogram(diffs); title('Histogram różnic');
subplot(2,2,4); cdfplot(diffs); title('Empiryczna dystrybuanta różnic');

% sprawdzenie normalności różnic
[h_norm, p_norm] = lillietest(diffs); 

% test wilcoxona (jednostronny: czy masa zmalała, czyli różnica < 0)
[p, h] = signrank(w1, w2, 'tail', 'right');

fprintf('Normalność różnic (p): %.4f\n', p_norm);
fprintf('Test Wilcoxona jednostronny, p: %.4f, h: %d\n', p, h);

fprintf(' p = %.4f\n h = %d\n', p, h);
if h == 1
    disp('Wniosek: Dieta istotnie statystycznie zmniejsza ciężar ciała.');
else
    disp('Wniosek: Brak podstaw do odrzucenia H0 - dieta nie zmniejsza ciężaru.');
end