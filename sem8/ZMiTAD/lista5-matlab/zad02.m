% cw 2 & 4

% czy nowa praca wpływa na czas czytania prasy

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

% cw 2: wpływ (czy różnica różna od 0)
[p_w, h_w] = signrank(przed, po);

if h_w == 1
    disp('Wniosek: Zatrudnienie miało istotny wpływ na czas czytania.');
else
    disp('Wniosek: Brak podstaw do stwierdzenia wpływu zatrudnienia.');
end