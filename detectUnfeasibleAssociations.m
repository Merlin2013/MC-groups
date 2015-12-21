function feasibility = detectUnfeasibleAssociations(X_groups)
ng = size(X_groups, 1); feasibility = zeros(ng, ng);

for i = 1 : ng - 1
    for j = i + 1 : ng
        % 1) check for simultaneous associations
        if numel(intersect((X_groups{i, 5}:X_groups{i, 6}), (X_groups{j, 5}:X_groups{j, 6}))) > 0
            %feasibility(i, j) = -1;
        end
        
        % 2) check for unequal number of people in groups
        if numel(X_groups{i, 4}) ~= numel(X_groups{j, 4})
            %feasibility(i, j) = -1;
        end
    end
end
feasibility = feasibility + feasibility';

end