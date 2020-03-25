classdef DataSet
    % Dataset data structure. Makes joining of two datasets,
    % as well as dividing the dataset into train and test sets easy.
    
    properties
        variable_mat % Design matrix with flattened stimulus concatenated as rows (dim: [num_stim, stim_length]) 
        label_vec % binned spikes (dim: [num_stim, 1])
    end
    
    methods
        function obj = DataSet(variable_mat,label_vec)
            %DATASET Construct an instance of this class
            obj.variable_mat = variable_mat;
            obj.label_vec = label_vec;
        end
        
        function [train_var, train_lab, test_var, test_lab] = divide_train_test_data(obj, train_pct)
            % Divides the dataset into train and test sets
            [data_len,~] = size(obj.variable_mat);
            idx = randperm(data_len);
            train_var = obj.variable_mat(idx(1:round(train_pct*data_len)),:); 
            test_var = obj.variable_mat(idx(round(train_pct*data_len)+1:end),:);
            train_lab = obj.label_vec(idx(1:round(train_pct*data_len)));
            test_lab = obj.label_vec(idx(round(train_pct*data_len)+1:end));
        end
        function obj = join(obj, dataset)
            % joins two dataset objects
            obj.variable_mat = [obj.variable_mat;dataset.variable_mat];
            obj.label_vec = [obj.label_vec; dataset.label_vec];
        end
    end
end

