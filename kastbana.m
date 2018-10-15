function [y] = kastbana(x, t)
%KASTBANA Summary of this function goes here
%   Detailed explanation goes here
t = t * pi / 180; % Convert to radians
v0 = 10;
y0 = 1.85;
g = 9.81;
y = y0 - g/(2 * v0^2 * cos(t).^2) .* (x - (v0^2 * sin(2 * t)) / (2 * g)).^2 + (v0^2 * sin(t).^2)/ (2 * g);
end

