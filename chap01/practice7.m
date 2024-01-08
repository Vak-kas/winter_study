clear variables;
clc;

%%

x = [1 2 3 4 5];
y = func1(x);
y

function [y] = func1(x)
    l = length(x);
    y = zeros(l/l);
    idx = 1;

    for i  = 1:l
        z = mod(i, 2);
        if  z== 0
            continue;
        else
%             disp(i)
            y(idx) = x(i);
            idx = idx+1;
        end

    end


end