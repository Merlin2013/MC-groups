function cam_shift = preComputeCameraShifts(X_groups, features, cameras)
nw            = numel(X_groups); % number of windows
cam_shift     = cell(nw, 1);

for w = 1 : nw
    ng = size(X_groups{w}, 1); % number of groups
    cam_shift{w} = zeros(ng, ng);
    for i = 1 : ng - 1
        for j = i + 1 : ng
            cam_i = X_groups{w}{i, 3};  cam_j = X_groups{w}{j, 3};
            if cam_i > cam_j, temp = cam_i; cam_i = cam_j; cam_j = temp; end
            
            if numel(cameras) == 1
                cam_shift{w}(i, j) = 0;
            elseif cam_i == cam_j
                cam_shift{w}(i, j) = (find(cameras==cam_i)-1)*sum(features)*2;
            else
                [~, loc] = ismember([cam_i cam_j], combnk(cameras, 2), 'rows');
                cam_shift{w}(i, j) = (numel(cameras) + loc - 1)*sum(features)*2;
            end
        end
    end
    
    cam_shift{w} = cam_shift{w} + cam_shift{w}';
end