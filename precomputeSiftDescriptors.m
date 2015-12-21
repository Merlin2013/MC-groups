function X_groups_sift = precomputeSiftDescriptors(X_traj, X_groups, cameras)
global text; text{400} = '';

% feature parameters
n_frames     = 5;

ng = size(X_groups, 1); % number of detected groups
X_groups_sift = cell(ng, 1);
if exist(sprintf('sift_features_%s.mat', mat2str(cameras)), 'file') > 0
    load(sprintf('sift_features_%s.mat', mat2str(cameras)), 'X_groups_sift');
    printMyText(400, 'SIFT DESCRIPTORS:                 loaded!\n');
else
    for i = 1 : ng
        data = X_traj(ismember(X_traj(:, 3), X_groups{i, 4}) & X_traj(:, 1) == X_groups{i, 3} & X_traj(:, 2) > X_groups{i, 5} & X_traj(:, 2) < X_groups{i, 6}, :);
        X_groups_sift{i} = extractSiftDescriptor(data, n_frames);
        printMyText(400, 'SIFT DESCRIPTORS:                 %04d/%04d\n', i, ng);
    end
    printMyText(400, 'SIFT DESCRIPTORS:                 computed!\n');

    save(sprintf('sift_features_%s.mat', mat2str(cameras)), 'X_groups_sift');
end


end