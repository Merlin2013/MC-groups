function out = loadImage(varargin)
global dataset trajImages

% index global images variable or load images from disk
frame = varargin{1};
c     = varargin{2};

if nargin < 3
    out = trajImages{[trajImages{:, 1}]==frame, 2};
else
    out = imread(fullfile(sprintf(dataset.framesDirectory, c), sprintf(dataset.framesFormat, frame + syncTimeAcrossCameras(c))), dataset.framesFormat(end-2:end));
end