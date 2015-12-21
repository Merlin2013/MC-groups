function mask = loadMask(varargin)
global dataset trackerdata trajMasks

frame = varargin{1};
c = varargin{2};

if nargin < 4
    mask = trajMasks{[trajMasks{:, 1}] == frame, 2};
    % cut out of the foreground people that stand between the camera and ID
    data = trackerdata(trackerdata(:, 2) == frame, [1 9 10 11 12]);
    mask = removePropleFromForeground2D(data, varargin{3}, mask);
else
    mask = imread(fullfile(sprintf(dataset.maskDirectory, c), sprintf(dataset.maskFormat, frame + syncTimeAcrossCameras(c))), dataset.maskFormat(end-2:end));
    mask = im2double(mask);
end