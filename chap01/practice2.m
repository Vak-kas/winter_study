clear variables;
clc;

%%
x = 0.01:0.01:2;
y = exp(x);
plot(x, y, 'r');
grid on;

xlabel('x');
ylabel('y');
title("practice2");
z = log(x);

hold on;

plot(x, z, 'g');
axis([0.01 2 -10 10]);
legend('exp(x)', 'log(x)');