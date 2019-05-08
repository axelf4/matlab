function [t, y] = trapezoidal(A, b, t0, y0, h, N)
    % h - step size
    % N - number of points
    t = linspace(t0, t0 + N * h, N);

    y = zeros(N, 4);
    y(1, :) = y0;
    for i = 2:N
        y(i, :) = ((2 * eye(4) - h * A) \ ((2 * eye(4) + h * A) * y(i - 1, :)' + 2 * h * b))';
    end
