function [model, w_final] = trainFW(X, Y)
global text feasibility; text{5} = '';
n = numel(X); n_f = size(X{1}, 3);

% set hyper-parameters
parameters.lambda       = 1/10^6;        % regularization parameter (1/C)
parameters.maxIter      = 1000;          % maximum number of iterations
parameters.z            = 2000;          % update slowdown

% define functions callbacks
callbacks.lossFn        = @hammingLoss;
callbacks.constraintFn  = @oracleCall;
callbacks.featureFn     = @featureMap;

% initialize variables
w = 0*repmat([-1; 1], n_f/2, 1);              l = 0;
w_i = zeros(n_f, n);                        l_i = zeros(1, n);
w_final = zeros(n_f, parameters.maxIter);	l_final = zeros(1, parameters.maxIter);	ll_final = zeros(1, parameters.maxIter);
selected = zeros(1, n);

for k = 1 : parameters.maxIter
    % pick an example at random
    i = randi(n);   selected(i) = 1;
    
    % solve the oracle
    model.w = w;
    y_star = callbacks.constraintFn(model, X{i}, Y{i}, feasibility{i});
    
    % find the new best value of the variable
    w_s = 1/parameters.lambda*(callbacks.featureFn(X{i}, Y{i}) - callbacks.featureFn(X{i}, y_star));
    
    % also compute the loss at the new point
    l_s = callbacks.lossFn(Y{i}, y_star);
    
    % compute the step size
    step_size = min(max((parameters.lambda*(w_i(:, i)-w_s)'*w - l_i(i) + l_s) / parameters.lambda / ...
        ((w_i(:, i)-w_s)'*(w_i(:, i)-w_s)), 0), 1);
    
    % evaluate w_i and l_i
    w_i_new = (1 - step_size) * w_i(:, i) + step_size * w_s;
    l_i_new = (1 - step_size) * l_i(i) + step_size * l_s;
    
    % update w and l, w_i and l_i
    w = w + w_i_new - w_i(:, i);  l = l + l_i_new - l_i(i);
    w_i(:, i) = w_i_new;          l_i(i) = l_i_new;
    
    % slowing update should lead to faster convergence
    w = k/(k+parameters.z) * model.w + parameters.z/(k+parameters.z) * w;
    w_final(:, k) = w;  l_final(k) = mean([l_i(selected==1), ones(1, sum(selected==0))]);
    
    % recompute training error
    if mod(k, 5) == 1
        for j = 1 : n, ll_final(k) = ll_final(k) + callbacks.lossFn(Y{j}, makePrediction(createCorrelationMatrix(model, X{j}, feasibility{j})))/n; end
    else
        ll_final(k) = ll_final(k-1);
    end
    
    % plot variables
    figure(2); clf
    subplot(1,2,1), plot(w_final(:, 1:k)'); hold on; plot([k k], [min(w_final(:)) max(w_final(:))], 'k', 'linewidth', 3); axis([0 parameters.maxIter 0 1], 'auto y'); title(['Convergence at ' num2str(k) '-th iteration']);
    subplot(1,2,2), plot(l_final(1:k)); hold on; plot(ll_final(1:k), 'g'); plot([k k], [min(l_final) max(l_final)], 'k', 'linewidth', 3); axis([0 parameters.maxIter 0 1], 'auto y'); title(['Loss at ' num2str(k) '-th iteration']); legend(sprintf('oracle loss (%2.2f)', l_final(k)), sprintf('training loss (%2.2f)', ll_final(k)));
    
    drawnow; printMyText(5, '\nTraining...\n%d: %s\n', k, mat2str(w));
end

% prepare output
model.w = w; fprintf('\n');

end

