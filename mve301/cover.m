n = 10000; % The area of the square
l = sqrt(n); % The length of the sides

circles = KDTree; % Container with circles
circlesList = {}; % The items are { coord, Trail }

clf
axis equal, hold on
xlim([0 l])
ylim([0 l])

% maxDist = 2; isIntersection = @isCircleIntersection; % With circles
maxDist = triangleHeight; isIntersection = @isTriangleIntersection; % With triangles

while true
    c = rand(2, 1) * l; % Uniformly distributed coordinate vector over the square
    % [x, y] = ginput(1); c = [x; y];

    trail = Trail();
    trail.TouchLeft = c(1) <= 1;
    trail.TouchRight = c(1) >= l - 1;

    done = false;
    isFirst = ~(trail.TouchLeft || trail.TouchRight);

    % Find all intersecting circles
    intersecting = circles.find(c, maxDist, isIntersection);
    i = length(intersecting);
    while i > 0
        otherTrail = intersecting{i}.Data;

        if ~isFirst
            done = otherTrail.addNext(trail);
            if done, break, end
        end

        isFirst = false;
        trail = otherTrail;
        i = i - 1; % Decrement i
    end

    circle = {c, trail};
    circlesList{end + 1} = circle; % Append to list
    circles.insert(c, trail);

    if done
        disp Done
        break
    end
end

circles = circlesList;
fprintf("Required %i circles\n", length(circles))

clf
axis equal, hold on
xlim([0 l])
ylim([0 l])
for i = 1:length(circles)
    circle = circles{i};
    c = circle{1}; trail = circle{2};
    % h = rectangle('Position', [c(1) - 1, c(2) - 1, 2, 2], 'Curvature', [1 1]);
    h = triangle(c);
    %{
	if trail.touchesRight() && trail.touchesLeft()
	h.EdgeColor = [0 0 1];
elseif trail.touchesLeft()
	h.EdgeColor = [1 0 0];
elseif trail.touchesRight()
	h.EdgeColor = [0 1 0];
else
	h.EdgeColor = [0 0 0];
end
    %}
end
hold off

function y = isCircleIntersection(a, b)
    % Returns whether the two circles specified by their midpoints touch.
    y = sum((a - b).^2) <= 2^2;
end

function b = triangleBase
    % Returns the side length of an equilateral triangle with area pi.
    b = 2.693547374177197; % b = 2 * nthroot(pi^2 / 3, 4);
end

function h = triangleHeight
    % Returns the height of an equilateral triangle with area pi.
    h = 2 * pi / triangleBase;
end

function y = isTriangleIntersection(u, v)
    % Returns whether the two triangles specified by their midpoints touch.

    b = triangleBase; h = triangleHeight;
    d = abs(v(2) - u(2)); % Vertical distance between midpoints

    % If highest point is below entirety of second triangle: no intersection
    if d > h, y = false; return, end

    % For a given vertical distance d, the max of |u-v| while still intersecting
    % is achieved when maximizing horizontal distance
    maxHorDist = b/2 * ((1 - d / h) + 1);
    y = norm(u - v)^2 <= maxHorDist^2 + d^2;
end

function h = triangle(u)
    % Draws an equilateral triangle centered at u.

    b = triangleBase; th = triangleHeight;

    h = plot([u(1) - b/2, u(1), u(1) + b/2, u(1) - b/2], ...
        [u(2) - th/2, u(2) + th/2, u(2) - th/2, u(2) - th/2]);
end
