% y = [x y u v]', b vektor ober av y

% D_t x = u; D_t y = v -- Tidsderivatorna

%% a) Skriv upp systemet av differentialekvationer

% y' = Ay + b, där
A = [0 0 1 0
    0 0 0 1
    0 0 0 1
    0 0 -1 0];
b = [0 0 1 0]';

%% b) Lös problem 1 med ode45 och rita graf

[t, y] = ode45(@(t, y) odefun(t, y, A, b), [0 2], [1 0, -2 0]);

axis equal, hold on, grid on
rectangle('Position', [-1 -1, 2 2], 'Curvature', [1 1])

plot(y(:, 1), y(:, 2), '--') % Plot Y vs X

hold off

% Set axes
xlim(1.5 * [-1 1])
ylim(1.5 * [-1 1])

%% c) Solve approximately using the following three methods:
h = 0.4; N = ceil(2 / h);
hold on

[~, y] = eulerForward(A, b, 0, [1 0, -2, 0], h, N);
plot(y(:, 1), y(:, 2), 'c')
[~, y] = eulerBackward(A, b, 0, [1 0, -2, 0], h, N);
plot(y(:, 1), y(:, 2), 'y')
[~, y] = trapezoidal(A, b, 0, [1 0, -2, 0], h, N);
plot(y(:, 1), y(:, 2), 'g')

%% d) Discuss the accuracy of the above three methods

% Lösningskurvorna för Eulermetoderna ser ut som de gör pga
% - Framåtmetoden använder derivatorna i de första punkterna

% Trapetsmetoden blir typ medelvärdet av de båda Eulermetoderna
% -> Använder två funktionsvärden varje steg -> mest noggrann
% De Eulermetoderna ungefär lika bra.

%% e) 

%% f) Determine u so that electron reaches (0,1)
u = fsolve(@(u) fcost(u, A, b), -2);
[t, y] = ode45(@(t, y) odefun(t, y, A, b), [0 3], [1 0, u 0]);
plot(y(:, 1), y(:, 2), 'r')

function c = fcost(u, A, b)
    % Objective function for Problem 2
    [~, y, ~, ~, ~] = ode45(@(t, y) odefun(t, y, A, b), ...
        [0 10], [1 0, u 0], ...
        odeset('Events', @crossYAxisEventsFcn));
    % ye is y at the time of the event
    c = norm(y(end, 1:2) - [0 1]); % Set cost to dist to (0,1)
end

function yprim = odefun(~, y, A, b)
    % Field only exists within unit circle
    if norm(y(1:2, 1)) < 1
        yprim = A * y + b;
    else
        yprim = [0 0 1 0; 0 0 0 1; 0 0 0 0; 0 0 0 0] * y;
    end
end

function [value, isTerminal, direction] = crossYAxisEventsFcn(t, y)
    % ODE Event Function that stops if particle intersects y-axis
    value = y(1); % The x-coordinate
    isTerminal = 1; % Stop if value gets to zero
    direction = 1; % Only count when coming from the left (increasing x)
end