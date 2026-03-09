iris = readtable('iris.txt');
glass = readtable('glass.txt');

figure
hist(iris.SL,20)
title('Iris SL')

figure
hist(iris.SW,20)
title('Iris SW')

figure
hist(glass.Na,20)
title('Glass Na')

figure
hist(glass.Ca,20)
title('Glass Ca')