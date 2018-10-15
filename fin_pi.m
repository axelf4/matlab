% MATLAB 3 Uppgift 3

term = @(i) ((-1)^i)/(2 * i + 1);

% a)

s = 0;
i = 0;
while 1
s = s + term(i);
i = i + 1;

if abs(pi - s * 4) < 1e-5, break, end

end

fprintf('Jag skule säga att pi är %d.\n', s * 4)

% b)

s = 0;
for i = 0:1000
s = s + term(i);
end
fprintf('Jag skule säga att pi med for-sats är %d.\n', s * 4)
