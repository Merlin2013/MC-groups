function out = featureMap(X, Y)
out = zeros(size(X, 3), 1);
[r, c] = find(Y);
for i = 1 : numel(r), out = out + squeeze(X(r(i), c(i), :)); end %/numel(r);