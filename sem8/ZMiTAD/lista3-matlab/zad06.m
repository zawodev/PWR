clear; clc;

T = readtable('data/pacjenci.csv');
wzrost_m = T.wzrost(strcmp(T.plec, 'M'));
wzrost_w = T.wzrost(strcmp(T.plec, 'K'));

[h1, p1] = lillietest(wzrost_m); % test lilieforsa, ulepszenie k-s testu stosowane gdy parametry są estymowane bezpośrednio z próby
[h2, p2] = lillietest(wzrost_w);

fprintf('Lilliefors \n');
fprintf('Mężczyźni: h = %d, p-value = %.4f\n', h1, p1);
fprintf('Kobiety:   h = %d, p-value = %.4f\n\n', h2, p2);

wzrost_m_std = (wzrost_m - mean(wzrost_m)) / std(wzrost_m);
[h2_m, p2_m] = kstest(wzrost_m_std);

wzrost_w_std = (wzrost_w - mean(wzrost_w)) / std(wzrost_w);
[h2_w, p2_w] = kstest(wzrost_w_std);

fprintf('Test ks\n');
fprintf('Mężczyźni std: h = %d, p-value = %.4f\n\n', h2_m, p2_m);
fprintf('Kobiety std: h = %d, p-value = %.4f\n\n', h2_w, p2_w);

figure;
subplot(1,2,1); qqplot(wzrost_m); title('QQ Plot - Mężczyźni'); %kwantyl-kwantyl plot, porównuje kwantyle danych z teoretycznymi
subplot(1,2,2); qqplot(wzrost_w); title('QQ Plot - Kobiety'); %im bliżej linii tym bliżej normalnego