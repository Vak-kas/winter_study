clear variables;
clc;
%%

x = [pi/4 -pi/2 pi -pi/3];
y = func4(x)


function [y] = func4(x)
    l = length(x);
    y = zeros(1, l);

    for i = 1:l
        s = sin(x(i));
        c = cos(x(i));

        y(i) = c + s*j;

    end
end