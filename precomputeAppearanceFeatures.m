function X_groups_app = precomputeAppearanceFeatures(X_traj, X_groups, cameras)
global text; text{500} = '';

% feature parameters
n_bins       = [16 4 4]; % [h s v]
n_frames     = 5;

ng = size(X_groups, 1); % number of detected groups
X_groups_app = zeros(ng, sum(n_bins));
if exist(sprintf('appearance_features_%s.mat', mat2str(cameras)), 'file') > 0
    load(sprintf('appearance_features_%s.mat', mat2str(cameras)), 'X_groups_app');
    printMyText(500, 'HSV COLOR HISTOGRAMS:             loaded!\n');
else
    for i = 1 : ng
        data = X_traj(ismember(X_traj(:, 3), X_groups{i, 4}) & X_traj(:, 1) == X_groups{i, 3} & X_traj(:, 2) > X_groups{i, 5} & X_traj(:, 2) < X_groups{i, 6}, :);
        X_groups_app(i, :) = extractHSVcolorHistograms(data, n_bins, n_frames);
        printMyText(500, 'HSV COLOR HISTOGRAMS:             %04d/%04d\n', i, ng);
    end
    printMyText(500, 'HSV COLOR HISTOGRAMS:             computed!\n');
    save(sprintf('appearance_features_%s.mat', mat2str(cameras)), 'X_groups_app');
end


end