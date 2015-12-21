function X_groups_trj = precomputeAverageTrajectory(X_traj, X_groups, cameras)
global text; text{600} = '';

ng = size(X_groups, 1); % number of detected groups
X_groups_trj = cell(ng, 1);
if exist(sprintf('trajectory_features_%s.mat', mat2str(cameras)), 'file') > 0
    load(sprintf('trajectory_features_%s.mat', mat2str(cameras)), 'X_groups_trj');
    printMyText(600, 'AVERAGE TRAJECTORIES:             loaded!\n');
else
    for i = 1 : ng
        data = X_traj(ismember(X_traj(:, 3), X_groups{i, 4}) & X_traj(:, 1) == X_groups{i, 3} & X_traj(:, 2) > X_groups{i, 5} & X_traj(:, 2) < X_groups{i, 6}, [2 4 5]);
        frames = unique(data(:, 1));
        temp = arrayfun(@(x) mean(data(data(:, 1) == x, [2 3]), 1), frames, 'uniformoutput', false);
        X_groups_trj{i} = [frames, cat(1, temp{:})];
        printMyText(600, 'AVERAGE TRAJECTORIES:             %04d/%04d\n', i, ng);
    end
    printMyText(600, 'AVERAGE TRAJECTORIES:             computed!\n');
    save(sprintf('trajectory_features_%s.mat', mat2str(cameras)), 'X_groups_trj');
end

end