n = 10000; % The area of the square
l = sqrt(n); % The length of the sides

circles = KDTree; % Container with circles
circlesList = {}; % The items are { coord, Trail }

clf
axis equal, hold on
xlim([0 l])
ylim([0 l])

while true
    c = rand(2, 1) * l; % Uniformly distributed coordinate vector over the square
    % [x, y] = ginput(1); c = [x; y];
    
    trail = Trail();
    trail.TouchLeft = c(1) <= 1;
    trail.TouchRight = c(1) >= l - 1;
    
    done = false;
    isFirst = ~(trail.TouchLeft || trail.TouchRight);
    
    % Find all intersecting circles
    intersecting = circles.find(c, 2, @isCircleIntersection);
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
    % c = circle.Coord;
    % trail = circle.Data;
    c = circle{1}; trail = circle{2};
    h = rectangle('Position', [c(1) - 1, c(2) - 1, 2, 2], 'Curvature', [1 1]);
    if trail.touchesLeft()
        h.EdgeColor = [1 0 0];
    elseif trail.touchesRight()
        h.EdgeColor = [0 1 0];
    else
        h.EdgeColor = [0 0 0];
    end
end
hold off

function y = isCircleIntersection(a, b)
    % Returns whether the two circles specified by their midpoints touch.
    y = sum((a - b).^2) <= 2^2;
end
