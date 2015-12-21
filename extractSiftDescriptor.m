function out = extractSiftDescriptor(data, n_frames)
warning('off','MATLAB:colon:nonIntegerIndex');

global calibration;

all_d     = zeros(128, 0);
all_f     = zeros(4, 0);
cam       = data(1, 1);

% select frames to load
frames  = unique(data(:, 2));
frames  = frames(unique(round(linspace(1, numel(frames), n_frames))))';

for f = frames
    img  = rgb2gray(im2single(loadImage(f, cam, 'load')));
    mask = loadMask(f, cam, -1, 'load');
    
    % extract image place feet and head coordinates (assume uniform h = 1.8m)
    feet_pos = data(data(:, 2) == f, [4 5]); feet_pos = [feet_pos, zeros(size(feet_pos, 1), 1); feet_pos, -1.8*ones(size(feet_pos, 1), 1)]; %#ok
    cameraPosition = computeCameraPosition(calibration, cam);
    positions = cv.projectPoints(feet_pos, cameraPosition.rvec, cameraPosition.tvec, calibration(cam).cameraMatrix, calibration(cam).distCoeffs); positions = squeeze(positions);
    
    % extract bounding boxes to restrict frame foreground
    bb_mask = zeros(size(mask)); n_ped = size(feet_pos, 1)/2;
    for p = 1 : n_ped, bb_mask(max(1, positions(n_ped+p, 2)) : min(size(mask, 1), positions(p, 2)), max(1, positions(p, 1) - (positions(p, 2)-positions(n_ped+p, 2))*0.4/2) : min(size(mask, 2), positions(p, 1) + (positions(p, 2)-positions(n_ped+p, 2))*0.4/2)) = 1; end
    mask = mask .* bb_mask;
    
    % restrict image to compute sift onto
    [r,c] = find(mask > 0);
    [f1,d1] = vl_sift(img(min(r):max(r), min(c):max(c))); f1(1, :) = f1(1, :) + min(c); f1(2, :) = f1(2, :) + min(r);
    sift_in_mask = mask(sub2ind(size(img), min(size(img, 1), max(1, round(f1(2, :)))), min(size(img, 2), max(1, round(f1(1, :)))))) == 1; f1 = f1(:, sift_in_mask); d1 = d1(:, sift_in_mask);
    % figure(1); clf; imshow(img); hold on; h2 = vl_plotframe(f1); set(h2,'color','y','linewidth',2); h3 = vl_plotsiftdescriptor(d1,f1); set(h3, 'color', 'g') ;
    
    % append frame descriptor
    all_d = [all_d, d1]; all_f = [all_f, f1]; %#ok
end

out.d = all_d; out.f = all_f;