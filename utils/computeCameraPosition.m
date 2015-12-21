function cameraPosition = computeCameraPosition(calibration, c)

% compute calibration data
[~, imagePoints, worldPoints] = image_to_world([], c);
worldPoints = [worldPoints, zeros(4,1)];
[rvec, tvec] = cv.solvePnP(worldPoints, imagePoints, calibration(c).cameraMatrix, calibration(c).distCoeffs);

cameraPosition.rvec = rvec;
cameraPosition.tvec = tvec;
cameraPosition.pos  = cv.Rodrigues(rvec)' * tvec;

end