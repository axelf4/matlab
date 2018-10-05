a=2*sqrt(2)/3; b=-sqrt(2)/3; c=sqrt(2/3); d=-1/3;
H=[ a  b  b  0
0  c -c  0
d  d  d  1 ];

phi = (1 + sqrt(5)) / 2;
possible = [0 -1 1 -phi phi];
% H = cartesian(possible, possible, possible)'
H = [ 0 -1 -phi
0 -1 phi
0 1 -phi
0 1 phi

-1 -phi 0
-1 phi 0
1 -phi 0
1 phi 0

-phi 0 -1
-phi 0 1
phi 0 -1
phi 0 1
]';
n = size(H, 2);

figure(1), clf
axis equal, axis(3 * [-2 2 -2 2 -2 2]), axis off, axis vis3d
hold on
%{
for i=1:size(H,2)
text(H(1,i),H(2,i),H(3,i),num2str(i))
end
%}

% Generate faces
% Generate all permutations and filter where the dot product of the normal and the

% Generate permutations don't check if inner face
S = cartesian(1:n, 1:n, 1:n);
offset = 0;
for i = 1:size(S, 1)
	j = i - offset;
	if S(j, 1) == S(j, 2) || S(j, 1) == S(j, 3) || S(j, 2) == S(j, 3) || S(j, 2) < S(j, 1) || S(j, 3) < S(j, 2)
		S(j, :) = [];
		offset = offset + 1;
	end
end

offset = 0;
for i = 1:size(S, 1)
	j = i - offset;

	if norm((H(:, S(j, 2)) - H(:, S(j, 1)))') + norm((H(:, S(j, 3)) - H(:, S(j, 1)))') + norm((H(:, S(j, 2)) - H(:, S(j, 3)))') > 6
		S(j, :) = [];
		offset = offset + 1;
		continue
	end

	%{
	normal = cross((H(:, S(j, 2)) - H(:, S(j, 1)))', (H(:, S(j, 3)) - H(:, S(j, 1)))');

	% Check all vertices not part of the face if wrong side
	for k = 1:n
		% if any(ismember(k, S(j, :))), continue, end
		vertex = (H(:, k) - H(:, S(j, 1)))';

		fprintf('S is (%d, %d, %d) k is %d, dot is %d, normal is (%d, %d, %d), v is (%d, %d, %d)\n', S(j, :), k, dot(normal, vertex), normal, vertex);
		if dot(normal, vertex) < 0
			S(j, :) = [];
			offset = offset + 1;
			break;
		end
	end
	%}
end

%{
S=[ 1  2  3
1  2  4
1  3  4
2  3  4 ];
%}

%{
for i=1:size(S,1)
	Si=S(i,:);
	fill3(H(1,Si),H(2,Si),H(3,Si),[0.4 0.5 1], 'facealpha',0.8)
end
%}

%{
for i=1:size(S,1)
	Si=S(i,:);
	Mi=(H(:,Si(1))+H(:,Si(2))+H(:,Si(3)))/3; % Mittpunkten p ̊a sida nr i
	Mi=Mi*-2;
	fill3([H(1,Si(1:2)) Mi(1)],[H(2,Si(1:2)) Mi(2)],[H(3, Si(1:2)) Mi(3)],...
		[0.4 0.5 1],'facealpha',0.8)
	fill3([H(1,Si(2:3)) Mi(1)],[H(2,Si(2:3)) Mi(2)],[H(3, Si(2:3)) Mi(3)],...
		[0.4 0.5 1],'facealpha',0.8)
	fill3([H(1,Si([3,1])) Mi(1)],[H(2,Si([3,1])) Mi(2)],[H(3,Si([3,1])) Mi(3)],...
		[0.4 0.5 1],'facealpha',0.8)
end
%}

for i=1:n
	klot(H(:, i)', 0.3, 100, 'g', 0.5);
end

K = cartesian(1:n, 1:n);
offset = 0;
for i = 1:size(K, 1)
	j = i - offset;

	if K(j, 2) <= K(j, 1) || norm((H(:, K(j, 2)) - H(:, K(j, 1)))') > 2
		K(j, :) = [];
		offset = offset + 1;
		continue
	end
end

for i = 1: size(K, 1)
	stav(H(:, K(i, 1)), H(:, K(i, 2)), 0.1, 100, 'yellow', 1);
end

hold off
axis equal, axis tight, axis off, axis vis3d
view(-30,20)
material shiny
camlight left, camlight head

function C = cartesian(varargin)
	args = varargin;
	n = nargin;

	[F{1:n}] = ndgrid(args{:});

	for i=n:-1:1
		G(:,i) = F{i}(:);
	end

	C = unique(G , 'rows');
end

function []=klot(a,r,n,col,alpha)
	% klotyta - ritar ett klot runt en punkt i rummet.
	%   Syntax:
	%           []=klot(a,r,n,col,alpha)
	%   Argument:
	%           a - en vektor med medelpunkten för klotet.
	%           r - klotets radie.
	%           n - heltal som anger antal paneler på klotet.
	%           col - textsträng som anger färg på klotet.
	%           alpha - transparens, alpha=1 solid, alpha=0 transparent.
	%   Returnerar:
	%           -
	%   Beskrivning:
	%           -
	%   Exempel:
	%           r=0.3; n=30; col='g'; alpha=0.7;
	%           a=[0; 0; 0];
	%           klot(a,r,n,col,alpha)

	[S,T]=meshgrid(linspace(0,pi,n),linspace(0,2*pi,2*n));
	X=a(1)+r*sin(S).*cos(T);
	Y=a(2)+r*sin(S).*sin(T);
	Z=a(3)+r*cos(S);
	surf(X,Y,Z,'facecolor',col,'edgecolor','none','facealpha',alpha)
end

function []=stav(x1,x2,r,n,col,alpha)
	% stav - ritar en stav mellan två punkter i rummet.
	%   Syntax:
	%           []=stav(x1,x2,r,n,col,alpha)
	%   Argument:
	%           x1, x2 - två vektor med start och slutpunkt för staven.
	%           r - stavens radie.
	%           n - heltal som anger antal paneler på stavens yta.
	%           col - textsträng som anger färg på staven.
	%           alpha - transparens, alpha=1 solid, alpha=0 transparent.
	%   Returnerar:
	%           -
	%   Beskrivning:
	%           -
	%   Exempel:
	%           r=0.3; n=30; col='m'; alpha=0.7;
	%           x1=[0; 0; 0]; x2=[1; 2; 1];
	%           stav(x1,x2,r,n,col,alpha)

	u=x2-x1; u=u/norm(u); Z=null(u'); v=Z(:,1); w=Z(:,2);
	[S,T]=meshgrid(linspace(0,2*pi,n),linspace(0,1,2));
	X=x1(1)+T*(x2(1)-x1(1))+r*cos(S)*v(1)+r*sin(S)*w(1);
	Y=x1(2)+T*(x2(2)-x1(2))+r*cos(S)*v(2)+r*sin(S)*w(2);
	Z=x1(3)+T*(x2(3)-x1(3))+r*cos(S)*v(3)+r*sin(S)*w(3);
	surf(X,Y,Z,'facecolor',col,'edgecolor','none','facealpha',alpha)
end
