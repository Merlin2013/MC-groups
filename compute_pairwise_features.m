function [X_features, feasibility] = compute_pairwise_features(X_traj, X_groups, features, cameras)
m = 1; fi = -1; % feature index
nw            = numel(X_groups); % number of windows
X_features    = cell(nw, 1);    feasibility = cell(nw, 1);

% init structures
my_nchoosek = 0; if numel(cameras) > 1, my_nchoosek = nchoosek(numel(cameras), 2); end
for w = 1 : nw, ng = size(X_groups{w}, 1); X_features{w} = zeros(ng, ng, 2*sum(features)*(my_nchoosek + numel(cameras))); end

% retrieve unique information
X_groups_unique = cat(1, X_groups{:}); [~, idx] = unique(cell2mat(X_groups_unique(:, [2 3])), 'rows'); X_groups_unique = X_groups_unique(idx, :);
X_traj_unique = unique(cat(1,X_traj{:}), 'rows');

% decide feasibile association based on the number of people in groups and
% simultaneous appearance
for w = 1 : nw, feasibility{w} = detectUnfeasibleAssociations(X_groups{w}); end

% pre compute camera shift (to deal with different weights for different
% pairs of camera or between/across camera information variations)
cs = precomputeCameraShifts(X_groups, features, cameras);

%% FEATURE 1 - HSV COLOR HISTOGRAMS
if features(1)
    fi = fi + 2;
    
    % it is convenient to precompute all groups HSV color histogram and
    % then iterate over pairs to compute differences
    X_groups_app = precomputeAppearanceFeatures(X_traj_unique, X_groups_unique, cameras);

    fprintf('(1) HSV HISTOGRAMS INTERSECTION:\n');
    for w = 1 : nw
        ng = size(X_groups{w}, 1); % number of groups
        for i = 1 : ng - 1
            for j = i + 1 : ng
                i_unique = cellfun(@(x,y) x == X_groups{w}{i, 2} && y == X_groups{w}{i, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                j_unique = cellfun(@(x,y) x == X_groups{w}{j, 2} && y == X_groups{w}{j, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                X_features{w}(i, j, cs{w}(i,j) + fi) = 1 - sum(min([X_groups_app(i_unique, :); X_groups_app(j_unique, :)], [], 1)); X_features{w}(j, i, cs{w}(i,j) + fi) = X_features{w}(i, j, cs{w}(i,j) + fi);
                X_features{w}(i, j, cs{w}(i,j) + fi + 1) = (1 - X_features{w}(i, j, cs{w}(i,j) + fi)); X_features{w}(j, i, cs{w}(i,j) + fi + 1) = X_features{w}(i, j, cs{w}(i,j) + fi + 1);
            end
        end
    end
    fprintf('\b  done!\n');
end

%% FEATURE 2 - SIFT MATCHING
if features(2)
    fi = fi + 2;
    
    % it is convenient to precompute all groups HSV color histogram and
    % then iterate over pairs to compute differences
    X_groups_sift = precomputeSiftDescriptors(X_traj_unique, X_groups_unique, cameras);
    
    fprintf('(2) SIFT MATCHING:              \n');
    for w = 1 : nw
        ng = size(X_groups{w}, 1); % number of groups
        for i = 1 : ng - 1
            for j = i + 1 : ng
                i_unique = cellfun(@(x,y) x == X_groups{w}{i, 2} && y == X_groups{w}{i, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                j_unique = cellfun(@(x,y) x == X_groups{w}{j, 2} && y == X_groups{w}{j, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                X_features{w}(i, j, cs{w}(i,j) + fi) = computeSiftScores(X_groups_sift{i_unique}, X_groups_sift{j_unique}); X_features{w}(j, i, cs{w}(i,j) + fi) = X_features{w}(i, j, cs{w}(i,j) + fi);
                X_features{w}(i, j, cs{w}(i,j) + fi + 1) = (1 - X_features{w}(i, j, cs{w}(i,j) + fi)); X_features{w}(j, i, cs{w}(i,j) + fi + 1) = X_features{w}(i, j, cs{w}(i,j) + fi + 1);
            end
        end
    end
    fprintf('\b  done!\n');
end

%% FEATURE 3 - GROUP MOTION PREDICTION ERROR
if features(3)
    fi = fi + 2;
    
    % error threshold
    err_tresh = 10 * m;
    
    % as before, it is better to precompute all groups mean trajectory and
    % only after compare them in pairs
    X_groups_trj = precomputeAverageTrajectory(X_traj_unique, X_groups_unique, cameras);

    fprintf('(3) DIST/SPEED ERROR:             \n');
    for w = 1 : nw
        ng = size(X_groups{w}, 1); % number of groups
        X_informative = zeros(ng, ng, 1);
        for i = 1 : ng - 1
            for j = i + 1 : ng
                i_unique = cellfun(@(x,y) x == X_groups{w}{i, 2} && y == X_groups{w}{i, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                j_unique = cellfun(@(x,y) x == X_groups{w}{j, 2} && y == X_groups{w}{j, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                
                % data_a happens before data_b
                data_a = X_groups_trj{i_unique}; data_b = X_groups_trj{j_unique};
                if data_a(1, 1) > data_b(1,1), temp = data_b; data_b = data_a; data_a = temp; end
                
                % forward error
                vel_a = diff(data_a, 1, 1); vel_a = mean(vel_a(max(1, end-9):end, [2 3]), 1);
                err_f = data_b(1, [2 3]) - (data_a(end, [2 3]) + vel_a * (data_b(1,1)-data_a(end, 1))); err_f = sqrt(sum(err_f.^2));
                
                % backward error
                vel_b = diff(data_b, 1, 1); vel_b = mean(vel_b(1:min(end, 10), [2 3]), 1);
                err_b = data_a(end, [2 3]) - (data_b(1, [2 3]) - vel_b * (data_b(1,1)-data_a(end, 1))); err_b = sqrt(sum(err_b.^2));
                
                % check motion informativeness according to time difference
                X_informative(i,j) = exp(-(abs(data_b(1,1)-data_a(end, 1)))/200);
                
                X_features{w}(i, j, cs{w}(i,j) + fi) = min([err_f, err_b, err_tresh])/err_tresh;
                X_features{w}(i, j, cs{w}(i,j) + fi + 1) = (1-X_features{w}(i, j, cs{w}(i,j) + fi)).*X_informative(i,j); X_features{w}(j, i, cs{w}(i,j) + fi + 1) = X_features{w}(i, j, cs{w}(i,j) + fi + 1);
                X_features{w}(i, j, cs{w}(i,j) + fi) = X_features{w}(i, j, cs{w}(i,j) + fi).*X_informative(i,j); X_features{w}(j, i, cs{w}(i,j) + fi) = X_features{w}(i, j, cs{w}(i,j) + fi);
            end
        end
    end
    fprintf('\bdone!\n');
end

%% FEATURE 4 - GROUP MOTION TIME ERROR
if features(4)
    fi = fi + 2;
    
    % error threshold
    err_tresh = 1;
    
    % as before, it is better to precompute all groups mean trajectory and
    % only after compare them in pairs - do it only if not already done!
    if ~features(3), X_groups_trj = precomputeAverageTrajectory(X_traj_unique, X_groups_unique, cameras); end

    fprintf('(4) TIME/SPEED ERROR:             \n');
    for w = 1 : nw
        ng = size(X_groups{w}, 1); % number of groups
        X_informative = zeros(ng, ng, 1);
        for i = 1 : ng - 1
            for j = i + 1 : ng
                i_unique = cellfun(@(x,y) x == X_groups{w}{i, 2} && y == X_groups{w}{i, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                j_unique = cellfun(@(x,y) x == X_groups{w}{j, 2} && y == X_groups{w}{j, 3}, X_groups_unique(:, 2), X_groups_unique(:, 3));
                
                % data_a happens before data_b
                data_a = X_groups_trj{i_unique}; data_b = X_groups_trj{j_unique};
                if data_a(1, 1) > data_b(1,1), temp = data_b; data_b = data_a; data_a = temp; end
                
                % compute speeds
                vel_a = diff(data_a, 1, 1); vel_a = mean(vel_a(max(1, end-9):end, [2 3]), 1);   spd_a = norm(vel_a, 2);
                vel_b = diff(data_b, 1, 1); vel_b = mean(vel_b(1:min(end, 10), [2 3]), 1);      spd_b = norm(vel_b, 2);

                % compute time and distances
                dist_between    = norm(data_a(end, [2 3]) - data_b(1, [2 3]), 2);
                time_between    = abs(data_b(1,1)-data_a(end, 1));
                time_predicted  = 2*dist_between/(spd_a+spd_b);
                
                % errors
                err_t = abs(time_between-time_predicted)/time_between;
                                
                % check motion informativeness according to time difference
                X_informative(i,j) = exp(-time_between/2000);
                
                X_features{w}(i, j, cs{w}(i,j) + fi) = min([err_t, err_tresh])/err_tresh;
                X_features{w}(i, j, cs{w}(i,j) + fi + 1) = (1-X_features{w}(i, j, cs{w}(i,j) + fi)).*X_informative(i,j); X_features{w}(j, i, cs{w}(i,j) + fi + 1) = X_features{w}(i, j, cs{w}(i,j) + fi + 1);
                X_features{w}(i, j, cs{w}(i,j) + fi) = X_features{w}(i, j, cs{w}(i,j) + fi).*X_informative(i,j); X_features{w}(j, i, cs{w}(i,j) + fi) = X_features{w}(i, j, cs{w}(i,j) + fi);
            end
        end
    end
    fprintf('\bdone!\n');
end

end