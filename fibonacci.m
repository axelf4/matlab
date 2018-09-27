function [y] = fibonacci(n)
%FIBONACCI Returns the nth fibonacci number
%   Detailed explanation goes here
    m = [0, 1; 1, 1]^(n - 1);
    y = m(2, 2);
end