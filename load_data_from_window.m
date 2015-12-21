function [X_traj, X_groups, Y_tracking, Y_groups] = load_data_from_window(MC_groundtruth, cameras, frame_range)
global calibration; load('calibration.mat'); %#ok

% restrict ground truth to cameras and frame range
gt = MC_groundtruth(ismember(MC_groundtruth(:, 1), cameras), :);
gt = gt(gt(:, 2) >= frame_range(1) & gt(:, 2) <= frame_range(2), :);

% load detected groups from windows
groups = [];
for c = cameras
    temp = load(sprintf('detections/camera%d/groups_predicted.mat', c), 'groups');
    groups = [groups; temp.groups(cellfun(@(x,y) x>frame_range(1) && y<frame_range(2), temp.groups(:, 5), temp.groups(:, 6)), :)]; %#ok
end

% give unique single and multi camera id to groups
% for i = 1 : size(groups, 1), groups{i, 1} = i; groups{i, 2} = i; end %#ok

% load group tracking ground-truth
groups_GT = load('groups_GT_def.mat', 'groups');
groups_GT = groups_GT.groups;
groups_GT = groups_GT(cellfun(@(x,y,z) ismember(x, cameras) && y>frame_range(1) && z<frame_range(2), groups_GT(:, 3), groups_GT(:, 5), groups_GT(:, 6)), :);

% label detected groups
ng = size(groups, 1);
det_groups_GT = zeros(ng, ng);
for i = 1 : ng - 1
    for j = i + 1 : ng
        if numel(groups{i, 4}) == numel(groups{j, 4}) && numel(intersect(groups{i, 4}, groups{j, 4})) == numel(groups{j, 4})
            det_groups_GT(i, j) = 1;
        end
    end
end
det_groups_GT = det_groups_GT + det_groups_GT';

% prepare output
X_traj     = gt;
X_groups   = groups;
Y_tracking = groups_GT;
Y_groups   = det_groups_GT;