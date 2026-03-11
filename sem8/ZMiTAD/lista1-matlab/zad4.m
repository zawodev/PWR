N = 1000;

g1 = gen1(1,N);
g2 = gen2(1,N);
g3 = gen3(1,N);
g4 = randn(N,1);

subplot(221)
hist(g1,20)
title('gen1')

subplot(222)
hist(g2,20)
title('gen2')

subplot(223)
hist(g3,20)
title('gen3')

subplot(224)
hist(g4,20)
title('randn')

mean(g1)
var(g1)

mean(g2)
var(g2)

mean(g3)
var(g3)

mean(g4)
var(g4)