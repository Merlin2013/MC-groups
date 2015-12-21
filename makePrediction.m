function y_star = makePrediction(correlationMatrix)
y_star = zeros(size(correlationMatrix));

% solve BIP
correlationMatrix(eye(size(correlationMatrix))==1) = 0;
greedySolution = AL_ICM(sparse(correlationMatrix)); % init solution to BIP
labels         = solveBIP(correlationMatrix, greedySolution);

% from labels to matrix
for l = unique(labels)', y_star(labels==l, labels==l) = 1; end
y_star(eye(size(y_star))==1)=0;