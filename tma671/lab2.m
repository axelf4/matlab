n = 6; % Number of points
m = 3; % Dimensionen av sfären

% x0 is matrix with starting points for optim
% kolonner är punkterna
x0 = 1;
objfun = @(rho) cost(rho);

x = fmincon(objfun, x0)

%%

function c = cost(rho)
	% Loss function that computes distance between points in spherical coords
    n = size(rho, 2); % Number of points
	x = nsph2cart(rho); % Convert to Cartesian coordinates

    sum = 0;
    cart = cartprod(1:n, 1:n)
	% We divide by two to skip to not both add |a-b| and |b-a|
    for i = 1:size(cart, 1) / 2
        a = cart(i, 1); b = cart(i, 2); % Indices of two points
		% If the points are distinct: add distance between them to sum
        if a ~= b
            sum = sum + norm(x(:, b) - x(:, a))
        end
    end

    c = sum;
end

function result = cartprod(x, y)
	% Computes the cartesian product of the two specified "sets"
	[X, Y] = meshgrid(x, y);
    result = [X(:) Y(:)];
end
