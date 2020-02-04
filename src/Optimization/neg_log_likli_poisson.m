function [neg_log_likelihood] = neg_log_likli_poisson(stim_test, spike_test, glm_weights, td)
%LOG_LIKLI_POISSON computes log likelihood function with exponential non
%linearity
    log_likelihood = 0;
    for i=1:size(stim_test,1)
        log_likelihood = log_likelihood + spike_test(i).*log(td*exp(stim_test(i,:)*glm_weights(2:end))) ...
            - td*exp(stim_test(i,:)*glm_weights(2:end)) - log(factorial(spike_test(i)));
    end
    neg_log_likelihood = -log_likelihood;
end

