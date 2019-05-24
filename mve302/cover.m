n = 1000; % The area of the square
l = sqrt(n); % The length of the sides

circles = KDTree; % Container with circles
circles2 = Grid(2 * 1, l);

points = {[0; 0], [l; 0], [0; l], [l; l]}; % Start with the corners
nextShapeId = 0;
hasTouched = false; % Cannot finish before this

%{
axis equal
xlim([0 l])
ylim([0 l])
%}

while true
    c = rand(2, 1) * l; % Uniformly distributed coordinate vector over the square
    % [x, y] = ginput(1); c = [x; y];
    shapeId = nextShapeId;
    nextShapeId = nextShapeId + 1;
    
    % Remove points that intersect the new circle
    points(cellfun(@(p) pointInsideCircle(c, p), points)) = [];
    
    % intersecting = circles.find(c, 2, @(~, ~) true);
    intersecting = circles2.find(c, @(~) true);
    for i = 1:length(intersecting)
        other = intersecting{i};
        oc = other.Coord;
        otherData = other.Data;
        
        [u, v] = getIntersections(c, oc);
        intersections = {u, v};
        for j = 1:length(intersections)
            p = intersections{j};
            if all(isreal(p)) ... % Actually touch
                    && all(p >= 0) && all(p <= l) % Inside square
                % Real intersection
                hasTouched = true;
                
                % touching = circles.exists(p, 1, @(node) node.Data{1} ~= other.Data{1} ...
                %    && pointInsideCircle(node.Coord, p));
                touching = circles2.exists(p, @(node) pointInsideCircle(node.Coord, p) ...
                    && node.Data ~= otherData);
                if ~touching
                    points{end + 1} = p;
                end
            end
        end
    end
    
    circles.insert(c, {shapeId});
    circles2.insert(GridNode(c, shapeId));
    
    if hasTouched && isempty(points)
        fprintf(1, 'Finished! Required %d circles\n', nextShapeId)
        break
    end
    
    plotAll(l, circles, points)
    pause(0.5)
end

plotAll(l, circles, points)

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

function plotAll(l, circles, points)
    clf
    axis equal, hold on
    xlim([0 l])
    ylim([0 l])
    circleList = circles.findAll();
    for i = 1:length(circleList)
        circle = circleList{i};
        c = circle.Coord;
        h = rectangle('Position', [c(1) - 1, c(2) - 1, 2, 2], 'Curvature', [1 1]);
    end
    
    for i = 1:length(points)
        p = points{i};
        plot(p(1), p(2), 'r*')
    end
    hold off
end
