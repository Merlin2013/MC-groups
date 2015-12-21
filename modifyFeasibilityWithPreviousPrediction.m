function feasibility = modifyFeasibilityWithPreviousPrediction(feasibility, X_groups, k, y_bar)
if k == 1, return; end
ng = size(X_groups{k}, 1);

shared = zeros(ng, 1);
for i = 1 : ng, [~, shared(i)] = ismember(cell2mat(X_groups{k}(i, [2 3])), cell2mat(X_groups{k-1}(:, [2 3])), 'rows'); end

for i = 1 : ng - 1
    for j = i + 1 : ng
        if shared(i)*shared(j) > 0
            feasibility(i,j) = -1 + 2*y_bar(shared(i),shared(j));
            feasibility(j,i) = feasibility(i,j);
        end
    end
end
