clear; clc;

T = readtable('data/pacjenci.csv');
m = T.wzrost(strcmp(T.plec, 'M'));
w = T.wzrost(strcmp(T.plec, 'K'));

figure; hold on;
cdfplot(m); cdfplot(w);

[h1, p1] = kstest2(m, w); % sprawdza czy dwie próbki pochodzą z tego samego rozkładu
[h2, p2] = kstest(m, [m, normcdf(m, mean(m), std(m,1))]); % k-s test (porównuje dystrybuane wynikającą z danych z tą teoretyczną np rozkładem normalnym)
[h3, p3] = kstest(w, [w, normcdf(w, mean(w), std(w,1))]);

fprintf('Test KS (czy rozkłady takie same): h=%d, p=%.4f\n', h1, p1);
fprintf('Normalność - Mężczyźni: h=%d, p=%.4f\n', h2, p2);
fprintf('Normalność - Kobiety:   h=%d, p=%.4f\n', h3, p3);



if h1 == 0
    disp('Obie próbki pochodzą z tego samego rozkładu.');
else
    disp('Obie próbki nie pochodzą z tego samego rozkładu.');
end

if h2 == 0
    disp('Mężczyźni: Rozkład zbliżony do normalnego.');
else
    disp('Mężczyźni: Odrzucamy hipoteze.');
end

if h3 == 0
    disp('Kobiety: Rozkład zbliżony do normalnego.');
else
    disp('Kobiety: Odrzucamy hipoteze.');
end