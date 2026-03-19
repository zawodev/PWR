clear; clc;

n1 = 20; m1 = 27.7; s1 = 5.5;
n2 = 22; m2 = 32.1; s2 = 6.3;
alpha = 0.05;

rng(123); %1234
x1 = m1 + s1 * randn(n1,1); % nowy produkt
x2 = m2 + s2 * randn(n2,1); % znany produkt

% test rownosci dwóhc wariancji
[hF, pF] = vartest2(x1, x2, 'Alpha', alpha, 'Tail', 'both');

% czy nabywcy nowego produktu sa mlodsi
vartype = 'equal';
if hF == 1
    vartype = 'unequal';
end
[hT, pT] = ttest2(x1, x2, 'Alpha', alpha, 'Tail', 'left', 'Vartype', vartype);

fprintf('Cwiczenie 5\n');
fprintf('Nowy produkt:  srednia=%.4f, s=%.4f\n', mean(x1), std(x1));
fprintf('Znany produkt: srednia=%.4f, s=%.4f\n', mean(x2), std(x2));

fprintf('\nTest F (rownosc wariancji): h=%d, p=%.6f\n', hF, pF);
if hF == 0
    fprintf('Brak podstaw do odrzucenia H0: wariancje mozna uznac za rowne.\n');
else
    fprintf('Odrzucamy H0: wariancje sa istotnie rozne.\n');
end

fprintf('\nTest t (czy srednia wieku nowego produktu < znanego): h=%d, p=%.6f\n', hT, pT);
if hT == 1
    fprintf('Wniosek: nabywcy nowego produktu sa istotnie mlodsi.\n');
else
    fprintf('Brak podstaw do takiego wniosku.\n');
end
