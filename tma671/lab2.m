n = 6; % Number of points
m = 3; % Dimensionen av sfären

% x0 is matrix with starting points for optim
% kolonner är punkterna
x0 = [
    1 0 0 -1 0 0
    0 1 0 0 -1 0
    0 0 1 0 0 -1
    ];

objfun = @negDist;
options = optimoptions(@fmincon, 'Algorithm', 'Interior-point', ...
    'MaxFunctionEvaluations', 100000, 'MaxIterations', 100000);
nonlcon = @circlecon;
x = fmincon(objfun, x0, [], [], [], [], -ones(size(x0)), ones(size(x0)), nonlcon, options)

%% d)
A = x * x'; % Mat.mul. is other way around since our points are the columns
alpha = diagonalDominance(A);

%% e)

% Want to reflect all points through the hyperplane that is orthogonal to v
v = 1/sqrt(2) * (x(:, 1) + [1 0 0]'); % v is vector between the two fuckers
P = eye(3) - 2 * (v * v') / (v' * v);

for i = 1:n
    x(:, i) = P * x(:, i); % Transform all fuckers
end

ang = acos(dot(x(:, 2), [0 1 0])) * 180/pi; % Angle between fuck and y-axis
R = rotx(-ang); % Rotation around x-axis

for i = 1:n
    x(:, i) = R * x(:, i); % Rotate all fuckers
end

A = x * x'
plotpoints(x)

% Får rätt egenskaper pga kan dela upp x:s kolonner i delmatriser y_i
% där dim(V(y)) = n = 3. Då är även dim(V(y^T)) = 3
% Från hur A är def följer alltså att den får rätt egenskaper

%%

function c = negDist(x)
	% Loss function that computes distance between points in spherical coords
    n = size(x, 2); % Number of points
	% x = nsph2cart(rho); % Convert to Cartesian coordinates

    sum = 0;
    cart = cartprod(1:n, 1:n);
	% We divide by two to skip to not both add |a-b| and |b-a|
    for i = 1:size(cart, 1)
        a = cart(i, 1); b = cart(i, 2); % Indices of two points
		% If the points are distinct: add distance between them to sum
        if a ~= b
            sum = sum + norm(x(:, b) - x(:, a));
        end
    end

    c = -sum;
end

function alpha = diagonalDominance(X)
    % Returns a measure of the relative diagonal dominance of the square matrix X
    n = size(X, 1); X = abs(X);
    d = diag(X); s = sum(X, 2) - d; % Sums of each row without the diagonal
    alpha = min(ones(n, 1) - s ./ d);
end

function [c, ceq] = circlecon(x)
    c = [];
    ceq = dot(x, x) - ones(1, size(x, 2));
end

function drawsphere
    [x, y, z] = sphere(32);
    h = surfl(x, y, z); 
    set(h, 'FaceAlpha', 0.1)
    shading interp
end

function plotpoints(x)
    n = size(x, 2); % Number of points
    axis equal
    drawsphere
    hold on, plot3(0, 0, 0, 'o')
    for i = 1:n
        p = num2cell(x(:, i)');
        plot3(p{:}, 'x')
    end
    grid on, hold off
end

function result = cartprod(x, y)
	% Computes the cartesian product of the two specified "sets"
	[X, Y] = meshgrid(x, y);
    result = [X(:) Y(:)];
end
