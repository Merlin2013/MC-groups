function [f1, p, r] = MITRE_score(final_prediction, Y_tracking_all)

% go from groups to individuals and create GT from prediction data
[pr, gt] = prepareForScoreTrackingOnly(final_prediction, Y_tracking_all);

% synthetize clusters
unique_ids_pr = unique([pr{:, 1}]); ybar = cell(1, numel(unique_ids_pr));
for i = 1 : numel(unique_ids_pr), ybar{i} = find([pr{:, 1}]==unique_ids_pr(i)); end

unique_ids_gt = unique([gt{:, 1}]); y = cell(1, numel(unique_ids_gt));
for i = 1 : numel(unique_ids_gt), y{i} = find([gt{:, 1}]==unique_ids_gt(i)); end

% compute loss
[delta, p, r] = lossM(y, ybar);
f1 = 1 - delta;