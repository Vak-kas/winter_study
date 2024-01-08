clear variables;
clc;

%%
A = [ -1 7 10 2 3; 4 8 9 1 0; 16 11 5 6 2; 1 12 15 24 20; 26 -7 -8 22 13];
B = A(2:4, 2:4);
C = inv(B);
D = B*C;

A
B
C
D