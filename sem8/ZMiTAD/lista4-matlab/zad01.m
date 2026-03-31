clear; clc;

% test t studenta wymaga zbliżonego do normalnego rozkładu

% Ćwiczenie 1. Przeanalizuj dodatkowe parametry dla funkcji 'ttest2', tzn. alpha, tail oraz vartype.
data13 = [175.26, 177.8, 167.64, 160.02, 172.72, 177.8, 175.26, 170.18, 157.48, 160.02, 193.04, 149.86, 157.48, 157.48, 190.5, 157.48, 182.88, 160.02];
data17 = [172.72, 157.48, 170.18, 172.72, 175.26, 170.18, 154.94, 149.86, 157.48, 154.94, 175.26, 167.64, 157.48, 157.48, 154.94, 177.8];

fprintf('1. Parametr Alpha (poziom istotności)\n');
[h05, p05] = ttest2(data13, data17, 0.05);
[h01, p01] = ttest2(data13, data17, 0.01);
fprintf('Dla alpha=0.05: h=%d, p=%.4f\n', h05, p05);
fprintf('Dla alpha=0.01: h=%d, p=%.4f\n\n', h01, p01);

fprintf('2. Parametr Tail (typ testu)\n');
[h_both, p_both] = ttest2(data13, data17, 0.05, 'both');
[h_right, p_right] = ttest2(data13, data17, 0.05, 'right');
fprintf('Dwustronny (both): p=%.4f\n', p_both);
fprintf('Prawostronny (right - czy data13 > data17): p=%.4f\n\n', p_right);

fprintf('3. Parametr Vartype (wariancja)\n');
[h_eq, p_eq] = ttest2(data13, data17, 0.05, 'both', 'equal');
[h_uneq, p_uneq] = ttest2(data13, data17, 0.05, 'both', 'unequal');
fprintf('Równe wariancje (equal): p=%.4f\n', p_eq);
fprintf('Nierówne wariancje (unequal): p=%.4f\n', p_uneq);