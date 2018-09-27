fig = figure;
set(fig, 'menubar', 'none');

max_x = 20;
max_y = 20;
grid = zeros(max_x, max_y);

x = 1;

startTime = tic;
lastTime = toc(startTime);
while 1
    time = toc(startTime);
    dt = (time - lastTime) / 1000;
    x = x + 10 * dt;
    grid(floor(x), 5) = 1;
    set(fig, 'CurrentObject', imagesc(grid));
end
