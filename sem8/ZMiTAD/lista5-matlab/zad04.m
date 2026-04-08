% cw 2 & 4

% oceniamy czy zmienił się średni czas

clc; clear; close all;

data = readtable('data/czytelnictwo.csv');
przed = data.przed;
po = data.po;
roznica = po - przed;

figure;
subplot(2,2,1); boxplot([przed, po], 'Labels', {'Przed', 'Po'}); title('Czas czytania');
subplot(2,2,2); qqplot(roznica); title('QQ-Plot różnic');
subplot(2,2,3); histogram(roznica); title('Histogram różnic');
subplot(2,2,4); cdfplot(roznica); title('Empiryczna dystrybuanta różnic');

[h_norm, p_norm] = lillietest(roznica);

% cw 4: zmiana średniego czasu (wybór testu na podstawie normalności)
if h_norm == 0
    [h_t, p_t] = ttest(przed, po);
    fprintf('Rozkład normalny - wybrano Test t: p=%.4f, h=%d\n', p_t, h_t);
else
    [p_t, h_t] = signrank(przed, po);
    fprintf('Brak normalności - wybrano Wilcoxon (test median): p=%.4f, h=%d\n', p_t, h_t);
end

if h_t == 1
    disp('Wniosek: Średni czas czytania uległ istotnej zmianie.');
else
    disp('Wniosek: Nie stwierdzono istotnej zmiany średniego czasu.');
end