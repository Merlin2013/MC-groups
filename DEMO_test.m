%% READ ME
% In this demo, all features have been precomputed, all parameters learned
% and all the results evaluated. The DEMO loads a DEMO_data.mat file
% containing the required variables to run. These results are obtained by
% running the DEMO_train.m file as it is.

%% fill in [...] with correct paths and uncomment
%cd('[...]\gurobi\win64\matlab'); gurobi_setup; cd('[...]\MC-groups');

addpath(genpath('.'));
load DEMO_data.mat

%% predict results on test
error = 0; n = numel(X_features_test); y_bar = cell(1, numel(X_groups_test)+1); y_bar{1} = [];

for i = 1 : numel(X_groups_test)
    y_bar{i+1} = makePrediction(createCorrelationMatrix(model, X_features_test{i}, ...
        feasibility{i+n_training}, X_groups_test, i, y_bar{i}));
    figure(10)
    subplot(1,3,1), imagesc(createCorrelationMatrix(model, X_features_test{i})), colorbar, title('correlation matrix');
    subplot(1,3,2), imagesc(y_bar{i+1}), title('predicted solution');
    subplot(1,3,3), imagesc(Y_groups_test{i}), title('GT');
    pause(0.1);
end

final_prediction = createConsistentSolution(X_groups_test, y_bar);
[f1, pr, re] = MITRE_score(final_prediction, Y_tracking_all);
fprintf('Results on test set:\n--------------------\n%2.2f precision\n%2.2f recall\n%2.2f F-1 score\n', pr, re, f1);

%% show results (requires data set images - to be released shortly!)
show_frms = [10000 46000];  % limits to [10000 46000]
show_cams = [4 2 5 1];      % cameras are numbered 1,2,4,5

previewResults(MC_groundtruth, final_prediction, show_frms, show_cams);
