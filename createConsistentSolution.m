function final_prediction = createConsistentSolution(X_groups, y_bar)
all_dets_duplicate = cat(1,X_groups{:}); all_dets = unique(cell2mat(all_dets_duplicate(:, [2 3 5 6])), 'rows');
nd = size(all_dets, 1); labels = zeros(nd, 1);

for i = 1 : nd
    if labels(i) == 0, labels(i) = max(labels) + 1; end
    for j = 1 : numel(X_groups)
        % check if the detection is in this time window
        win_dets = cell2mat(X_groups{j}(:, [2 3]));
        [~, pos] = ismember(all_dets(i, [1 2]), win_dets, 'rows');
        if pos == 0, continue; end
        % all detections linked with this one get the same id
        linked = find(y_bar{j+1}(pos, :));
        for l = linked
            [~, pos] = ismember(win_dets(l, :), all_dets(:, [1 2]), 'rows');
            prev_pos = labels(pos);
            labels(pos) = labels(i);
            if prev_pos > 0, labels(labels==prev_pos) = labels(i); end
        end
    end
end

final_prediction = num2cell([labels all_dets]);
final_prediction(:, [5 6]) = final_prediction(:, [4 5]); final_prediction(:, 4) = cell(nd, 1);

% compact continuous windows and retrieve members ids
for i = 1 : nd
    [~, pos] = ismember(cat(2, final_prediction{i, [2 3]}), cell2mat(all_dets_duplicate(:, [2 3])), 'rows');
    final_prediction{i, 4} = all_dets_duplicate{pos(1), 4};
end
final_prediction = sortrows(final_prediction, [1 5 3]);