function Y = nsph2cart(X)
	% Convert n-dim spherical coordinates to Cartesian coordinates
	% compute the cartesian coordinates from the input
	% hypersphere angles

	% Number of column vectors
	n = size(X,2);

	% Cosine terms
	C = [cos(X); ones(1,n)];
	% Sine terms
	S = [ones(1,n); cumprod(sin(X),1)];
	% Calculate output
	Y = C .* S;
