function loss = hammingLoss(Y_i, Y)
if size(Y_i, 1) < 2, loss = 0; return; end
loss = sum(sum(Y_i~=Y))/sum(sum(eye(size(Y_i))~=1)); %/sum(Y_i(:));
