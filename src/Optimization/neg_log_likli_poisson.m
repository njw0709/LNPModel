function [neg_log_likelihood, dL] = neg_log_likli_poisson(stim, spike_train, glm_weights, td, temporal_len, grid_size)
%LOG_LIKLI_POISSON computes log likelihood function with exponential non
%linearity  
    %% compute log likelihood
    log_likelihood = 0;
    if size(glm_weights,1) == size(stim,2)
        how = 0; %time space nonseparable
        weight = glm_weights;
    elseif size(glm_weights,1) == temporal_len+grid_size^2
        % time-space separable rf
        how = 1; %time space separable
        temporal_rf = glm_weights(1:temporal_len);
        spatial_rf = glm_weights(temporal_len+1:end);
        weight = make_3d_rf(temporal_rf, spatial_rf);
    elseif size(glm_weights,1) == temporal_len+2*(grid_size^2)   
        how = 2; %time space separable on off separable
        temporal_rf = glm_weights(1:temporal_len);
        spatial_rf_on = glm_weights(temporal_len+1:temporal_len+grid_size^2);
        spatial_rf_off = glm_weights(temporal_len+grid_size^2+1:end);
        weight_on = make_3d_rf(temporal_rf, spatial_rf_on);
        weight_off = make_3d_rf(temporal_rf, spatial_rf_off);
    end
    
    if how == 0 || how ==1
       grad_stim = zeros(size(stim)); 
    elseif how == 2
       grad_stim_on = zeros(size(stim));
       grad_stim_off = zeros(size(stim));
       stim_on = stim;
       stim_on(stim_on<0) = 0;
       stim_off = stim;
       stim_off(stim_off>0) = 0;
    end
    for i=1:size(stim,1)
        if how == 0 || how == 1
            log_likelihood = log_likelihood + spike_train(i).*log(td*exp(stim(i,:)*weight)) ...
                - td*exp(stim(i,:)*weight) - log(factorial(spike_train(i)));
            grad_stim(i,:) = (spike_train(i) - td*exp(stim(i,:)*weight)).*stim(i,:);
        elseif how == 2
            log_likelihood = log_likelihood + spike_train(i).*log(td*exp(stim_on(i,:)*weight_on + stim_off(i,:)*weight_off)) ...
                - td*exp(stim_on(i,:)*weight_on + stim_off(i,:)*weight_off) - log(factorial(spike_train(i)));
            grad_scale = spike_train(i) - td*exp(stim_on(i,:)*weight_on + stim_off(i,:)*weight_off);
            grad_stim_on(i,:) = grad_scale.*stim_on(i,:);
            grad_stim_off(i,:) = grad_scale.*stim_off(i,:);
        end
    end
    neg_log_likelihood = -log_likelihood;
    negLL = sprintf('Neg Log Likelihood: %0.3f', neg_log_likelihood);
    disp(negLL);
    %% compute gradient w.r.t each weights (theta) for fmin solver
    if how == 0
        dwdth = eye(length(weights));
    elseif how == 1
        theta_len = temporal_len+grid_size^2;
        dwdth = compute_dwdth_separable(theta_len, temporal_rf, spatial_rf);
    elseif how == 2
        theta_len = temporal_len+grid_size^2;
        dwdth_on = compute_dwdth_separable(theta_len, temporal_rf, spatial_rf_on);
        dwdth_off = compute_dwdth_separable(theta_len, temporal_rf, spatial_rf_off); 
        %padding zeros for actual dwdth computation
        dwdth_on_pad = zeros(temporal_len*grid_size^2, theta_len+grid_size^2);
        dwdth_off_pad = zeros(temporal_len*grid_size^2, theta_len+grid_size^2);
        dwdth_on_pad(:,1:theta_len) = dwdth_on;
        dwdth_off_pad(:,1:temporal_len) = dwdth_off(:,1:temporal_len);
        dwdth_off_pad(:,temporal_len+grid_size^2+1:end) = dwdth_off(:,temporal_len+1:end);
    end
    
    if how == 0 || how == 1
        dL = grad_stim*dwdth;
        dL = -sum(dL,1)';
    elseif how == 2
        dL = grad_stim_on*dwdth_on_pad + grad_stim_off*dwdth_off_pad;
        dL = -sum(dL,1);
    end
    grad_norm = sprintf('gradient norm length: %0.3f', norm(dL));
    disp(grad_norm);
end


function weight = make_3d_rf(temporal_rf, spatial_rf)
    temporal_len = size(temporal_rf,1);
    spatial_len = size(spatial_rf,1);
    weight = repmat(spatial_rf, [temporal_len, 1]);
    weight = weight.*repelem(temporal_rf, spatial_len);
end

function dwdth = compute_dwdth_separable(theta_len, temporal_rf, spatial_rf)
    temporal_len = length(temporal_rf);
    spatial_len = length(spatial_rf);
    weight_len = temporal_len*spatial_len;
    dwdth = zeros(weight_len, theta_len);
    
    for i = 1:theta_len
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