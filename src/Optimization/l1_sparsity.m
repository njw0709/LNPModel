function [loss, grad] = l1_sparsity(weights, temporal_len)
%L1_SPARSITY computes 
    % currently only support time-space separable rf
    temporal_rf = weights(1:temporal_len);
    spatial_rf = weights(temporal_len+1:end);
    temp_rf_2nd_der = diff(diff(temporal_rf));
    loss = sum(abs(temp_rf_2nd_der)) + sum(abs(spatial_rf));
    grad = zeros(size(weights));
    sgn_temporal_2nd_der = sign(temp_rf_2nd_der);
    sgn_spatial_rf = sign(spatial_rf);
    for i = 1:length(grad)
        if i <= temporal_len
            if i == 1
                grad(i) = (-1)*sgn_temporal_2nd_der(i);
            elseif i == 2
                grad(i) = (-2)*sgn_temporal_2nd_der(i-1) + (-1)*sgn_temporal_2nd_der(i);
            elseif i == temporal_len-1
                grad(i) = sgn_temporal_2nd_der(temporal_len-3)+sgn_temporal_2nd_der(temporal_len-2)*(-2);
            elseif i == temporal_len
                grad(i) = sgn_temporal_2nd_der(temporal_len-2);
            else
                grad(i) = sgn_temporal_2nd_der(i-2) + sgn_temporal_2nd_der(i-1)*(-2) + sgn_temporal_2nd_der(i)*(-1);
            end 
        else
            grad(i) = sgn_spatial_rf(i-temporal_len);
        end 
    end
end

