function out = computeSiftScores(X_groups_sift_i, X_groups_sift_j)
out = 1;

f1 = X_groups_sift_i.f; d1 = X_groups_sift_i.d;
f2 = X_groups_sift_j.f; d2 = X_groups_sift_j.d;

[matches, scores] = vl_ubcmatch(d1,d2);
if isempty(matches), return; end
scores = sort(scores, 'descend'); %scores = scores(1:min(end, 3));
out = max(0, min(1, (sqrt(mean(scores))/sqrt(128*255^2)-0.05)*40/3));
return

numMatches = size(matches,2);
X1 = f1(1:2,matches(1,:)); X1(3,:) = 1;
X2 = f2(1:2,matches(2,:)); X2(3,:) = 1;

H = cell(100, 1); ok = cell(100, 1); score = zeros(100, 1);
for t = 1:100
    % estimate homograpyh
    subset = vl_colsubset(1:numMatches, 4); A = [];
    for i = subset, A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))); end
    [~, ~, V] = svd(A); H{t} = reshape(V(:,9),3,3);
    
    % score homography
    X2_ = H{t} * X1; du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:); dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:);
    ok{t} = (du.*du + dv.*dv) < 6*6; score(t) = sum(ok{t});
end

[~, best] = max(score);
out = min(1, sqrt(mean(scores(ok{best})))/sqrt(128*255^2)*5);