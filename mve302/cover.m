%{
axis equal
xlim([0 l])
ylim([0 l])
%}

n = 10000; % The area of the square
l = sqrt(n); % The length of the sides
w = 1; % Half the width of the shapes
% Partition into vertical slices of same width as half width of shapes
numPartitions = ceil(l / w);
rng('shuffle'), seed = rng; % Get generator settings

% Binary search over number of shapes required to cover square
initialHi = 100000;
lo = 0; hi = initialHi; useLo = false;
while true
	if lo > hi
		disp('Too low upper guess')
		return
	end
	numShapes = idivide(lo + hi, int32(2), 'floor');

	midpoints = cell(1, numPartitions);
	rng(seed); % Restore previous generator settings
	for i = 1:numShapes
		c = rand(2, 1) * l; % Uniformly distributed coordinate vector over square
		partitionIndex = floor(c(1) / w) + 1;
		midpoints{partitionIndex}(:, end + 1) = c; % Add to respective partition
	end

	% Each vertical slice is covered => whole square is
	covered = true;
	for i = 1:numPartitions
		x1 = (i - 1) * w; x2 = x1 + w;
		currentPoints = midpoints{i};
		if i > 1, currentPoints = [currentPoints, midpoints{i - 1}]; end
		if i < numPartitions, currentPoints = [currentPoints, midpoints{i + 1}]; end
		if ~isCovered(x1, x2, l, currentPoints)
			covered = false;
			break
		end
	end
	fprintf(1, 'For %d shapes: %s\n', numShapes, mat2str(covered))

    if ~covered
        lo = numShapes + 1;
    elseif lo == numShapes
        fprintf(1, 'Finished! Required %d shapes\n', numShapes)
        
        currentPoints = {};
        for i = 1:numPartitions
            for j = 1:length(midpoints{i})
                currentPoints{end + 1} = midpoints{i}(:, j);
            end
        end
        plotAll(l, currentPoints, {})
        
        return
    else
        hi = numShapes;
    end
end

function covered = isCovered(x1, x2, l, midpoints)
	circles = KDTree; % Container with shapes
	circleList = {}; % Remember shapes to be able to draw them

	points = {[x1; 0], [x2; 0], [x1; l], [x2; l]}; % Start with the corners
	nextShapeId = 1;
	hasTouched = false; % Cannot finish before this
	covered = false;

	for c = midpoints
		% [x, y] = ginput(1); c = [x; y];
		shapeId = nextShapeId;

		% Remove points that intersect the new circle
		points(cellfun(@(p) pointInsideCircle(c, p), points)) = [];

		intersecting = circles.find(c, 2, @(~, ~) true);
		numIntersecting = length(intersecting);
		for i = 1:numIntersecting
			other = intersecting{i};
			oc = other.Coord;

			[u, v] = getIntersections(c, oc);
			intersections = {u, v};
			for j = 1:2
				p = intersections{j};

				if all(isreal(p)) ... % Actually touch
						&& all(p >= [x1; 0]) && all(p <= [x2; l]) % Inside square
					% Real intersection
					hasTouched = true;

					touching = circles.exists(p, 1, @(node) node.Data ~= other.Data ...
						&& pointInsideCircle(node.Coord, p));
					if ~touching
						points{end + 1} = p;
					end
				end
			end
		end

        circles.insert(c, shapeId);
        nextShapeId = nextShapeId + 1;
        
        % circleList{end + 1} = c;
        % plotAll(l, circleList, points)
		% pause(0.05)

		if hasTouched && isempty(points)
			% fprintf(1, 'Finished! Required %d shapes\n', numShapes)
			covered = true;
			return
        end
	end

	% plotAll(l, circleList, points)
end

function [u, v] = getIntersections(a, b)
	% Returns intersection points of the two circles specified by their midpoints.

	R = norm(a - b); % Distance between the centers of the circles
	u = 1/2 * (a + b) + 1/2 * sqrt(4 / R^2 - 1) * [b(2) - a(2); a(1) - b(1)];
	v = 1/2 * (a + b) - 1/2 * sqrt(4 / R^2 - 1) * [b(2) - a(2); a(1) - b(1)];
end

function y = pointInsideCircle(c, p)
	% Returns whether the circle centered at c contains the point p.

	% y = norm(c - p)^2 <= 1;
	d = c - p; y = d' * d <= 1;
end

function plotAll(l, circleList, points)
	clf
	axis equal, hold on
	xlim([0 l])
	ylim([0 l])
	for i = 1:length(circleList)
		c = circleList{i};
		h = rectangle('Position', [c(1) - 1, c(2) - 1, 2, 2], 'Curvature', [1 1]);
	end

	for i = 1:length(points)
		p = points{i};
		plot(p(1), p(2), 'r*')
	end
	hold off
end
