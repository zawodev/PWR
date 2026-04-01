clear; clc;
% Ćwiczenie 7. Ponownie gestykulacja, ale z użyciem testu U Manna-Whitneya.
nerwowi = [3, 3, 4, 5, 5];
spokojni = [4, 6, 7, 9, 9];

[hN1, pN1] = swtest(nerwowi(:), 0.05);
[hN2, pN2] = swtest(spokojni(:), 0.05);
fprintf('Normalnosc nerwowi: h=%d, p=%.4f\n', hN1, pN1);
fprintf('Normalnosc spokojni: h=%d, p=%.4f\n\n', hN2, pN2);

figure('Name', 'QQ plot - nerwowi');
qqplot(nerwowi(:));
grid on;
title('QQ plot - nerwowi');

figure('Name', 'QQ plot - spokojni');
qqplot(spokojni(:));
grid on;
title('QQ plot - spokojni');

fprintf('test u manna whitneya (ranksum)\n');
% H0: P(X>Y) == P(Y>X) - rozkłady gestykulacji w obu grupach są identyczne
% H1: P(X>Y) != P(Y>X) - istnieje istotna różnica w gestykulacji między grupami

[p, h, stats] = ranksum(nerwowi, spokojni, 'alpha', 0.05);

% ranksum to odpowiednik testu u manna whitleya, zamiast liczyć średnie ustawia 
% w kolejności i sprawdza czy jedna grupa na ogół ma wyższe pozycje niż druga

fprintf('wynik testu: h = %d\n', h);
fprintf('wartość p: %.4f\n', p);
fprintf('suma rang (ranksum): %.1f\n', stats.ranksum);

fprintf('średnia nerwowi: %.2f, średnia spokojni: %.2f\n', mean(nerwowi), mean(spokojni));