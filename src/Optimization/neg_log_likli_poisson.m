function [neg_log_likelihood, dL] = neg_log_likli_poisson(stim, spike_train, glm_weights, td, temporal_len, grid_size)
%LOG_LIKLI_POISSON computes log likelihood function with exponential non
%linearity  
    %% compute log likelihood
    log_likelihood = 0;
    if size(glm_weights,1) == size(stim,2)
        how = 'nonseparable';
        weight = glm_weights;
    elseif size(glm_weights,1) == temporal_len+grid_size^2
        % time-space separable rf
        how = 'separable';
        temporal_rf = glm_weights(1:temporal_len);
        spatial_rf = glm_weights(temporal_len+1:end);
        weight = make_3d_rf(temporal_rf, spatial_rf);
    end
    grad_stim = zeros(size(stim));
    for i=1:size(stim,1)
        log_likelihood = log_likelihood + spike_train(i).*log(td*exp(stim(i,:)*weight)) ...
            - td*exp(stim(i,:)*weight) - log(factorial(spike_train(i)));
        grad_stim(i,:) = (spike_train(i) - td*exp(stim(i,:)*weight)).*stim(i,:);
    end
    neg_log_likelihood = -log_likelihood;
    negLL = sprintf('Neg Log Likelihood: %0.3f', neg_log_likelihood);
    disp(negLL);
    %% compute gradient w.r.t each weights (theta) for fmin solver
    if isequal(how, 'nonseparable')
        dwdth = eye(length(weights));
    elseif isequal(how , 'separable')
        dwdth = compute_dwdth_separable(glm_weights, temporal_rf, spatial_rf);
    end
    dL = grad_stim*dwdth;
    dL = -sum(dL,1)';
    grad_norm = sprintf('gradient norm length: %0.3f', norm(dL));
    disp(grad_norm);
end


function weight = make_3d_rf(temporal_rf, spatial_rf)
    temporal_len = size(temporal_rf,1);
    spatial_len = size(spatial_rf,1);
    weight = repmat(spatial_rf, [temporal_len, 1]);
    weight = weight.*repelem(temporal_rf, spatial_len);
end

function dwdth = compute_dwdth_separable(theta, temporal_rf, spatial_rf)
    temporal_len = length(temporal_rf);
    spatial_len = length(spatial_rf);
    weight_len = temporal_len*spatial_len;
    dwdth = zeros(weight_len, length(theta));
    
    for i = 1:length(theta)
        if i<=temporal_len
            dwdthi = zeros(weight_len,1);
            dwdthi((i-1)*spatial_len+1:i*spatial_len) = spatial_rf;
            dwdth(:,i) = dwdthi;
        else
            dwdthi = zeros(size(spatial_rf));
            dwdthi(i-temporal_len) = 1;
            dwdthi = repmat(dwdthi, [temporal_len, 1]);
            dwdthi = dwdthi.*repelem(temporal_rf, spatial_len);
            dwdth(:,i) = dwdthi;
        end
    end
end