function sillouette
%SILLOUETTE Summary of this function goes here
%   Detailed explanation goes here
    clf
    axis([-1 1 0 1]), hold on
    coords = [];
    while true
        [x, y, button] = ginput(1);
        if button ~= 1, break; end
        disp('got coord');
        plot(x, y, 'o');
        plot(-x, y, 'o');
        coords = [coords; x y];
    end
    hold off

    % [S, T] = meshgrid(linspace(0, 1, length(coords)), linspace(0, 2 * pi));
    [S, T] = meshgrid(coords(:, 2), linspace(0, 2 * pi));
    x = coords(:, 1)' .* cos(T);
    y = coords(:, 1)' .* sin(T);
    z = S;
    surf(x, y, z);
end
