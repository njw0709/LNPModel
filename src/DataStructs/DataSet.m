classdef DataSet
    %DATASET class
    %   
    
    properties
        variable_mat
        label_vec
    end
    
    methods
        function obj = DataSet(variable_mat,label_vec)
            %DATASET Construct an instance of this class
            %   Detailed explanation goes here
            obj.variable_mat = variable_mat;
            obj.label_vec = label_vec;
        end
        
        function [train_var, train_lab, test_var, test_lab] = divide_train_test_data(obj, train_pct, random_mix)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            [data_len,~] = size(obj.variable_mat);
            if random_mix
                idx = randperm(data_len);
                train_var = obj.variable_mat(idx(1:round(train_pct*data_len)),:); 
                test_var = obj.variable_mat(idx(round(train_pct*data_len)+1:end),:);
                train_lab = obj.label_vec(idx(1:round(train_pct*data_len)));
                test_lab = obj.label_vec(idx(round(train_pct*data_len)+1:end));
            else
                train_var = obj.variable_mat(1:round(train_pct*data_len),:); 
                test_var = obj.variable_mat(round(train_pct*data_len)+1:end,:);
                train_lab = obj.label_vec(1:round(train_pct*data_len));
                test_lab = obj.label_vec(round(train_pct*data_len)+1:end);
            end
            
        end
        function obj = join(obj, dataset)
            obj.variable_mat = [obj.variable_mat;dataset.variable_mat];
            obj.label_vec = [obj.label_vec; dataset.label_vec];
        end
    end
end

