function out = syncTimeAcrossCameras(cam)
% this function should return the proper frame shift with respect
% camera 9, which was taken as reference. Shifts returned are the
% following:
out = 0;

% public static int[] frameAdjustment = { 0, 20632, 21601, 9771, 7800, 23406, 12194, 13913, 0, 0 };

switch cam
    case 1, out = 20632;
    case 2, out = 21601;
    case 3, out = 9771;
    case 4, out = 7800;
    case 5, out = 23406;
    case 6, out = 12194;
    case 7, out = 13913;
    case 8, out = NaN;
    case 9, out = 0;
end

