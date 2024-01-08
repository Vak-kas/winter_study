clear variables;
clc;
%%

y = randint(3, 4);
y


function [output] = randint(N, M)
    output = rand(N, M) > 0.5;
end