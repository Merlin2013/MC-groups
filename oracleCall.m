function y_star = oracleCall(model, X, Y, feasibility)
score_fun = createCorrelationMatrix(model, X, feasibility);
delta_fun = (1 - 2*Y)/sum(sum(eye(size(Y))~=1));%sum(Y(:));
correlationMatrix = score_fun + delta_fun;%sum(sum(eye(size(Y))~=1));%sum(Y.groups(:));
y_star = makePrediction(correlationMatrix);