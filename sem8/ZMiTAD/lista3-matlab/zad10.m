clear; clc;

dane = readtable('data/absolwenci.csv');

pedagogika = dane.SALARY(strcmp(dane.COLLEGE, 'Pedagogika'));
rolnictwo = dane.SALARY(strcmp(dane.COLLEGE, 'Rolnictwo'));

alpha = 0.05;

[h_p, p_p, w_p] = swtest(pedagogika, alpha);
[h_r, p_r, w_r] = swtest(rolnictwo, alpha);

fprintf('PEDAGOGIKA: p = %.4f, W = %.4f\n', p_p, w_p);
fprintf('ROLNICTWO:  p = %.4f, W = %.4f\n', p_r, w_r);



if h_p == 0
    disp('Pedagogika: Rozkład zbliżony do normalnego.');
else
    disp('Pedagogika: Odrzucamy hipoteze.');
end

if h_r == 0
    disp('Rolnictwo: Rozkład zbliżony do normalnego.');
else
    disp('Rolnictwo: Odrzucamy hipoteze.');
end

figure;
subplot(1,2,1); qqplot(pedagogika); title('Q-Q Plot: Pedagogika');
subplot(1,2,2); qqplot(rolnictwo); title('Q-Q Plot: Rolnictwo');