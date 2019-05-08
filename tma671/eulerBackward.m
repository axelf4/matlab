function [t, y] = eulerBackward(A, b, t0, y0, h, N)
    % h - step size
    % N - number of points
    t = linspace(t0, t0 + N * h, N);

    y = zeros(N, 4);
    y(1, :) = y0;
    for i = 2:N
        y(i, :) = (inv(eye(4) - h * A) * (y(i - 1, :)' + h * b))';
    end
