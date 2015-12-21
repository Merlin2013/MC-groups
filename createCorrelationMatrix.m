function correlationMatrix = createCorrelationMatrix(varargin)
model = varargin{1};    X = varargin{2};
ng = size(X, 1); correlationMatrix = zeros(ng, ng);
for f = 1 : size(X, 3), correlationMatrix = correlationMatrix + model.w(f)*X(:,:,f); end
% load feasibility info
feasibility = zeros(ng,ng); if nargin > 2, feasibility = varargin{3}; end
% add previous overlapping information to feasibility
if nargin > 3, feasibility = modifyFeasibilityWithPreviousPrediction(feasibility, varargin{4}, varargin{5}, varargin{6}); end
correlationMatrix = correlationMatrix + feasibility*10^3;