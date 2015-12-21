function out = extractHSVcolorHistograms(data, n_bins, n_frames)
warning('off','MATLAB:colon:nonIntegerIndex');

global calibration;

out     = zeros(1, sum(n_bins));
cam     = data(1, 1);

% select frames to load
frames  = unique(data(:, 2));
frames  = frames(unique(round(linspace(1, numel(frames), n_frames))))';

for f = frames
    img  = loadImage(f, cam, 'load');
    mask = loadMask(f, cam, -1, 'load');
    
    % extract image place feet and head coordinates (assume uniform h = 1.8m)
    feet_pos = data(data(:, 2) == f, [4 5]); feet_pos = [feet_pos, zeros(size(feet_pos, 1), 1); feet_pos, -1.8*ones(size(feet_pos, 1), 1)]; %#ok
    cameraPosition = computeCameraPosition(calibration, cam);
    positions = cv.projectPoints(feet_pos, cameraPosition.rvec, cameraPosition.tvec, calibration(cam).cameraMatrix, calibration(cam).distCoeffs); positions = squeeze(positions);
    
    % extract bounding boxes to restrict frame foreground
    bb_mask = zeros(size(mask)); n_ped = size(feet_pos, 1)/2;
    for p = 1 : n_ped, bb_mask(max(1, positions(n_ped+p, 2)) : min(size(mask, 1), positions(p, 2)), max(1, positions(p, 1) - (positions(p, 2)-positions(n_ped+p, 2))*0.4/2) : min(size(mask, 2), positions(p, 1) + (positions(p, 2)-positions(n_ped+p, 2))*0.4/2)) = 1; end
    mask = mask .* bb_mask;
    
    % compute histogram
    img_hsv = rgb2hsv(img);
    h = img_hsv(:, :, 1); h = h(mask==1); h = histcounts(h, n_bins(1));
    s = img_hsv(:, :, 2); s = s(mask==1); s = histcounts(s, n_bins(2));
    v = img_hsv(:, :, 3); v = v(mask==1); v = histcounts(v, n_bins(3));
    
    out = out + [h, s, v];
end

out = out / sum(out);
end