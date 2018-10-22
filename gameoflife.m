function gameoflife
% GAMEOFLIFE Play as rattlesnake in this once in a lifetime puzzler
% Nice game game of life by Mr Axel Forsman

    n = 75;
	m = zeros(n, 'logical');
    m(3, end - 4) = 1;
    m(4, end - 4) = 1;
    m(5, end - 4) = 1;
    m(5, end - 3) = 1;
    m(4, end - 2) = 1;
	m(5, 5) = 1;
	m(6, 5) = 1;
	m(7, 5) = 1;

	% Create and then hide the UI as it is being constructed
	f = figure('Name', 'Game of Life', 'NumberTitle', 'off', ...
		'Visible', 'off', 'Position', [360, 200, 450, 285], ...
		'color', [0 1 0], ...
		'MenuBar', 'none', 'ToolBar', 'none', ...
		'CloseRequestFcn', @onClose, ...
        'ButtonDownFcn', @onButtonDown);

    img = imshow(m(2:end - 1, 2:end-1), ...
                'InitialMagnification', 'fit');
            img.PickableParts = 'none';
            img.XData = [n - 2 1];

    % Create the context menu
	c = uicontextmenu;
    f.UIContextMenu = c; % Assign the uicontextmenu
    % Create child menu items for the uicontextmenu
    uimenu(c, 'Label', 'Toggle animation', 'Callback', @toggleAnimation);
	f.Visible = 'on';

    p = [1 1:n-1]; q = [2:n n];

	FRAME_DURATION = 1 ./ 10;
	MAX_FRAME_SKIP = 2;

	playing = false;

	shouldExit = false;
	currentFrame = 0;
	startTime = tic;
    frameUpdated = false;
    while ~shouldExit
		time = toc(startTime);
		loops = 0;
		while time > (currentFrame * FRAME_DURATION) && loops < MAX_FRAME_SKIP
			if playing
				% Build neighbour matrix
                s = m(:, p) + m(:, q) + m(p, :) + m(q, :) ...
                    + m(p, p) + m(q, q) + m(p, q) + m(q, p);
				% Update field matrix
				m = s == 3 | s == 2 & m;
			end

			currentFrame = currentFrame + 1;
			loops = loops + 1;
			frameUpdated = true;
		end

		if frameUpdated
            frameUpdated = false;
            img.CData = m(2:end - 1, 2:end - 1);
			drawnow;
		end

        java.lang.Thread.yield();
    end
    delete(f);

	function onButtonDown(obj, ~)
        if strcmp(f.SelectionType, 'alt') return; end
        pos = get(f, 'Position');
        apos = get(gca, 'Position') .* [pos(3:4) pos(3:4)];
        imgSize = min(apos(3:4));
        coord = floor((...
            imgSize - ... Flip Y
            (obj.CurrentPoint - apos(1:2) ... TL-corner of axes
            - (apos(3:4) - imgSize) ./ 2)) ...
            .* (n - 2) ./ imgSize ) + 2; % Transform to field coords
        if all(1 < coord & coord < n)
            m(coord(2), coord(1)) = ~m(coord(2), coord(1));
            frameUpdated = true;
        end
    end

	function toggleAnimation(~, ~)
		playing = ~playing;
	end

	function onClose(~, ~)
		shouldExit = true;
	end
end
