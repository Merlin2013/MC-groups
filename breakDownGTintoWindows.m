groups_GT = load('D:\lab\MC-groups\GT\groups_GT_def.mat', 'groups');
groups_GT = groups_GT.groups;

ng = size(groups_GT, 1); tw = 150;
new_groups = cell(0, 6);
for i = 1 : ng
    frame_range = cell2mat(groups_GT(i, [5 6]));
    for j = 1 : ceil((frame_range(2)-frame_range(1))/tw)
        new_cell = groups_GT(i, :);
        new_cell{2} = size(new_groups, 1)+1;
        new_cell{5} = frame_range(1) + (j-1)*tw + 1;
        new_cell{6} = frame_range(1) + j*tw;
        new_groups = [new_groups; new_cell]; %#ok
    end
end