function [X_traj, X_groups, Y_tracking, Y_groups] = load_data(MC_groundtruth, cameras, frame_range, win_info)
frame_start = frame_range(1) + 1; frame_end = min(frame_range(2), frame_start + win_info(1) - 1);
cc = 1;
while frame_end > frame_start
    win_frame_range = [frame_start, frame_end];
    [X_traj{cc}, X_groups{cc}, Y_tracking{cc}, Y_groups{cc}] = load_data_from_window(MC_groundtruth, cameras, win_frame_range); %#ok
    frame_start = frame_start + win_info(2); frame_end = min(frame_range(2), frame_start + win_info(1) - 1);
    cc = cc + 1;
end