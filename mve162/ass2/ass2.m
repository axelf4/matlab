%% Find r, K, J for asymptotically stable/unstable equilibrium point
n = 4;
for r = linspace(0.1, 10, n)
    for K = linspace(0.1, 10, n)
        for J = linspace(0.1, 10, n)
            aStable = isAsymptoticallyStable(r, K, J);
            if r < K
            fprintf('r: %f, K: %f, J: %f, isAStable: %d\n', r, K, J, aStable)
        end
    end
end

%% Draw phase portrait for model I
nu = 1/4;
% nu = 1.25;
drawPhasePortrait1(nu)

%% Draw phase portrait for model II
r = 10; K = 6.7; J = 3.4;
% r = 10; K = 6.7; J = 0.1;
drawPhasePortrait2(r, K, J)

function x = xStar2(r, K, J)
    x1 = -(K * (1/(r*J)-1) + 1)/2 + sqrt(((K * (1/(r*J)-1) + 1)/2)^2 + K);
    x = [x1; 1/J * x1];
end

function b = isAsymptoticallyStable(r, K, J)
    x = xStar2(r, K, J);
    trA = r * (1 - 2/K * x(1)) - x(1) / (J * (1+x(1))^2) - J/x(1);
    detA = r*J * (2/K - 1/x(1)) + 1/(J * (1+x(1)))^2 + 1/(1+x(1));
    b = trA < 0 && detA > 0;
end

function drawPhasePortrait1(nu)
    t0 = 0; tEnd = 50;
    
    xlabel('x_1'), ylabel('x_2')
    xlim([0 1.5]), ylim([0 1.5])
    hold on
    
    x1s = linspace(0, 8);
    plot(x1s, 1 - x1s)
    plot(x1s, nu - 2 * nu^2 * x1s)
    
    button = 1;
    while button == 1
        [x1, x2, button] = ginput(1);
        [~, y] = ode45(@(t, y) [
            y(1) * (1 - y(1)) - y(1) * y(2)
            nu * y(2) * (1 - y(2) / nu) - 2 * nu^2 * y(1) * y(2)
            ], [t0 tEnd], [x1; x2]);
        plot(y(:, 1), y(:, 2), 'b');
    end
    
    hold off
end

function drawPhasePortrait2(r, K, J)
    t0 = 0; tEnd = 50;
    
    xlabel('x_1'), ylabel('x_2')
    xlim([0 8]), ylim([0 25])
    hold on
    
    x1s = linspace(0, 8);
    plot(x1s, r * (1 - x1s/K) .* (1 + x1s))
    plot(x1s, 1/J * x1s)
    
    % Plot equilibrium point
    xStar = xStar2(r, K, J);
    plot(xStar(1), xStar(2), 'ro')
    
    button = 1;
    while button == 1
        [x1, x2, button] = ginput(1);
        [~, y] = ode45(@(t, y) [
            r*y(1) * (1 - y(1)/K) - y(1)/(1+y(1)) * y(2)
            1 - J * y(2)/y(1)
            ], [t0 tEnd], [x1; x2]);
        plot(y(:, 1), y(:, 2), 'b');
    end
    
    hold off
end
