clear; clc;

data = readtable('data/absolwenci.csv');

salary_group0 = data.SALARY(data.GENDER == "Mezczyzna");
salary_group1 = data.SALARY(data.GENDER == "Kobieta");

fprintf('Liczba obserwacji - Grupa 0: %d\n', length(salary_group0));
fprintf('Liczba obserwacji - Grupa 1: %d\n', length(salary_group1));

try
    [h, p] = ttest(salary_group0, salary_group1);
catch ME
    fprintf('\Błąd: %s\n', ME.message);
    fprintf('Interpretacja: Test t dla prób zależnych wymaga wektorów o tej samej długości.\n');
end

[h_ind, p_ind] = ttest2(salary_group0, salary_group1);
fprintf('\nWynik testu dla prób niezależnych (ttest2): h=%d, p=%.4f\n', h_ind, p_ind);