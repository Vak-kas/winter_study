clear variables;
clc;
%%

a = rand(1);
if a>=0.5
    fprintf("high");
elseif a< 0.5
    fprintf("low");
end

a