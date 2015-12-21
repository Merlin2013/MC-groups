function [new_final_prediction, new_ground_truth] = prepareForScoreTrackingOnly(final_prediction, Y_tracking_all)

% i don't want to add false negatives (not detected ones) and I don't want
% to disassemble groups - I just want to evaluate associations: same group?
new_final_prediction = sortrows(final_prediction, [1 5 3]);

% take prediction and create ground truth replacing with correct links
ng = size(new_final_prediction, 1);
det_groups_GT = zeros(ng, ng);
for i = 1 : ng - 1
    for j = i + 1 : ng
        if numel(new_final_prediction{i, 4}) == numel(new_final_prediction{j, 4}) && numel(intersect(new_final_prediction{i, 4}, new_final_prediction{j, 4})) == numel(new_final_prediction{j, 4})
            det_groups_GT(i, j) = 1;
        end
    end
end
det_groups_GT = det_groups_GT + det_groups_GT';

labels = (1:ng);
for i = 1 : ng
    for j = i + 1 : ng
        if det_groups_GT(i,j) == 1, labels(j) = labels(i); end
    end
end

new_ground_truth = new_final_prediction;
new_ground_truth(:, 1) = num2cell(labels);