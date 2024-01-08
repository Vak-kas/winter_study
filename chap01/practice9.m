clear variables;
clc;

%%
x = [1 2 3 4 5 6];
y = func3(x)

function [y] = func3(x)
    l = length(x);
    y = zeros(1, l/2);


    for i = 1:l/2
        y(i) = x(2*i-1) + x(2*i);
    end
end