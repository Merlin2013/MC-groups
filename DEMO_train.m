%% READ ME
% In this demo the algorithm will learn 80 feature weights for the
% correlation score. Features have been precomputed but you can compute
% them from scratch by removing the respective *_features_*.mat files.

%% fill in params here
global dataset;
if ~exist('MC_groundtruth', 'var')
    clear; load('MC_groundtruth.txt'); addpath(genpath('.'));
    
    % set images and masks directories (only if want to recompute features)
    dataset.framesDirectory = 'F:/dataset/allframes/camera%d';     dataset.framesFormat = '%d.jpg';
    dataset.maskDirectory   = 'F:/dukeChapel/camera%d/background'; dataset.maskFormat   = '%d.png';
    
    % specify gurobi and vlfeat install directories
    cd('[...]\gurobi\win64\matlab'); gurobi_setup; cd('[...]\MC-groups\release');
    run('[...]\vlfeat-0.9.20-bin\vlfeat-0.9.20\toolbox\vl_setup.m'); clc;
else
    clearvars -except MC_groundtruth;
end

%% load data
cameras     = [1 2 4 5];        % cameras are numbered 1,2,4,5
frame_range = [10000 46000];    % from 5:30 mins to 25:30 mins
win_info    = [4500 1500];      % [length stride] in frames
features    = [1 1 1 1];        % HSV, SIFT, dist/speed, time/speed error
[X_traj, X_groups, Y_tracking, Y_groups] = load_data(MC_groundtruth, cameras, frame_range, win_info);
[~, ~, Y_tracking_all, Y_groups_all] = load_data_from_window(MC_groundtruth, cameras, frame_range);

%% compute features
global feasibility
[X_features, feasibility] = compute_pairwise_features(X_traj, X_groups, features, cameras);

%% split data set and train
n_training = 5;
X_features_train = X_features(1:n_training); X_features_test = X_features(n_training+1:end);
X_groups_train   = X_groups(1:n_training);   X_groups_test   = X_groups(n_training+1:end);
Y_groups_train   = Y_groups(1:n_training);   Y_groups_test   = Y_groups(n_training+1:end);
[model, w_final] = trainFW(X_features_train, Y_groups_train);

%% save training results
save DEMO_data.mat
