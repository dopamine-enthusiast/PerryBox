function [Standardized_array, Variable_means, Variable_stdev] = StandardizeVariables(Cell_properties_table, variables)
%StandardizeAllVariables 
%   
%% Extract only variables from the table
Extracted_table = Cell_properties_table(:, variables);
Extracted_array = table2array(Extracted_table);
%% Perform Z-score normalization on this array

Variable_means = nanmean(Extracted_array, 1);
Variable_stdev = nanstd(Extracted_array, 1);

Variable_means_matrix = repmat(Variable_means, size(Extracted_array, 1), 1);
Variable_stdev_matrix = repmat(Variable_stdev, size(Extracted_array, 1), 1);

Standardized_array = (Extracted_array-Variable_means_matrix)./Variable_stdev_matrix;

end

