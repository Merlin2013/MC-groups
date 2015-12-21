function previewResults(MC_groundtruth, groups, show_frms, show_cams)

load('calibration.mat');
gt = MC_groundtruth(ismember(MC_groundtruth(:, 1), show_cams), :);
gt = gt(gt(:, 2) >= show_frms(1) & gt(:, 2) <= show_frms(2), :);

colors_groups = distinguishable_colors(max([groups{:, 1}]));

figure(3); maximize;

counter = 1;
for f = show_frms(1):5:show_frms(2)
    
    for c = show_cams
        % load frame
        img = loadImage(f, c, 'load');
        
        % compute image trajectories from GP data - gt is (cam, frame, id, wx, wy)
        wrl_positions = gt(gt(:, 2) == f & gt(:, 1) == c, [4 5]);
        figure(3), subplot(2,2,find(c==show_cams)); cla; title(sprintf('cam: %d, frame: %d', c, f));
        hold on;
        if ~isempty(wrl_positions)
            wrl_positions = [wrl_positions zeros(size(wrl_positions, 1), 1)]; %#ok
            cameraPosition = computeCameraPosition(calibration, c);
            positions = cv.projectPoints(wrl_positions, cameraPosition.rvec, cameraPosition.tvec, calibration(c).cameraMatrix, calibration(c).distCoeffs); positions = squeeze(positions);
            if size(positions, 2) == 1, positions = positions'; end
            positions = [positions(:, 1)-50 positions(:, 2)-200 100*ones(size(positions, 1), 1) 200*ones(size(positions, 1), 1)];
            
            identities = gt(gt(:, 2) == f & gt(:, 1) == c, 3);
            
            identities_groups = zeros(numel(identities), 1);
            Q = cellfun(@(x) ismember(identities, x), groups(:, 4), 'uniformoutput', 0);
            pickMe = repmat(f > [groups{:, 5}], numel(identities), 1) & repmat(f < [groups{:, 6}], numel(identities), 1) & cell2mat(Q');
            for i = 1 : numel(identities)
                if ~any(pickMe(i, :)), continue; end
                identities_groups(i) = groups{pickMe(i, :), 1};
            end
            
            positions   = positions(identities_groups~=0, :);
            identities  = identities(identities_groups~=0);
            identities_groups = identities_groups(identities_groups~=0);
            
            if ~isempty(identities)
                labels = cell(numel(identities), 1);
                for l = 1 : numel(identities)
                    labels{l} = sprintf('%d (%d)', identities(l), identities_groups(l));
                end
                img = insertObjectAnnotation(img, 'rectangle', ...
                    positions, labels, 'TextBoxOpacity', 1, 'FontSize', 35, 'Color', 255*colors_groups(identities_groups,:) );
                cla;
                imshow(img);
                hold on;
                for l = 1 : numel(identities)
                    wrl_positions_x = gt(gt(:, 2) <= f & gt(:, 2) > f-50 & gt(:, 1) == c & gt(:, 3) == identities(l), [4 5]);
                    wrl_positions_x = [wrl_positions_x zeros(size(wrl_positions_x, 1), 1)]; %#ok
                    cameraPosition = computeCameraPosition(calibration, c);
                    positions_x = cv.projectPoints(wrl_positions_x, cameraPosition.rvec, cameraPosition.tvec, calibration(c).cameraMatrix, calibration(c).distCoeffs); positions_x = squeeze(positions_x);
                    if size(positions_x, 2) == 1, positions_x = positions_x'; end
                    scatter(positions_x(:, 1), positions_x(:, 2), 10, colors_groups(identities_groups(l),:));
                end
                hold off;
            end
        end
        
        if isempty(wrl_positions) || (~isempty(wrl_positions) && isempty(identities))
            figure(3), subplot(2,2,find(c==show_cams)); cla; imshow(img); title(sprintf('cam: %d, frame: %d', c, f));
        end
        
    end
    pause(0.001);
    export_fig(sprintf('output/%06d.jpg', counter)); % save results
    counter = counter + 1;
end