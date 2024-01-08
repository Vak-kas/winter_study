clear variables;
clc;

%%
x = [1 2 3];
y = func2(x)


function [y] = func2(x)
    y = zeros(1, length(x)*2);

    for i = 1:length(x)
        y(2*i -1)  = x(i);
        y(2*i) = x(i)*2;
    end
end