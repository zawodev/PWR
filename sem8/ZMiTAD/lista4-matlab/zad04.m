clear; clc;

data = readtable('data/absolwenci.csv');

salary_group0 = data.SALARY(data.GENDER == "Mezczyzna");
salary_group1 = data.SALARY(data.GENDER == "Kobieta");

[hN0, pN0] = lillietest(salary_group0(:));
[hN1, pN1] = lillietest(salary_group1(:));
fprintf('Normalnosc grupa 0 (Mezczyzna): h=%d, p=%.4f\n', hN0, pN0);
fprintf('Normalnosc grupa 1 (Kobieta): h=%d, p=%.4f\n\n', hN1, pN1);

figure('Name', 'QQ plot - SALARY Mezczyzna');
qqplot(salary_group0(:));
grid on;
title('QQ plot - SALARY Mezczyzna');

figure('Name', 'QQ plot - SALARY Kobieta');
qqplot(salary_group1(:));
grid on;
title('QQ plot - SALARY Kobieta');

fprintf('Liczba obserwacji - Grupa 0: %d\n', length(salary_group0));
fprintf('Liczba obserwacji - Grupa 1: %d\n', length(salary_group1));

try
    [h, p] = ttest(salary_group0, salary_group1);
catch ME
    fprintf('\nBlad: %s\n', ME.message);
    fprintf('Interpretacja: Test t dla prób zależnych wymaga wektorów o tej samej długości.\n');
end

[h_ind, p_ind] = ttest2(salary_group0, salary_group1);
fprintf('\nWynik testu dla prób niezależnych (ttest2): h=%d, p=%.4f\n', h_ind, p_ind);