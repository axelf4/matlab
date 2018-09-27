function [a, b] = nearestNumbers(v)
%NEARESTNUMBERS Given a row vector of numbers, find the indices of the two nearest numbers
%   It does shit that would make Jesus proud
    l = length(v);    
    [X, Y] = meshgrid(v);
    cartprod = [X(:) Y(:)];
    delta = abs(cartprod(:, 1) - cartprod(:, 2));
    delta(1:l + 1:l^2) = Inf;
    [~, I] = min(delta);

    a = floor((I - 1) / l) + 1;
    b = mod(I - 1, l) + 1;
    
    fprintf('a: %i, b: %i\n', a, b);
end