function [EGTA_table, D1_EGTA_table, D3_EGTA_table] = GenerateEGTATables(Table)
%

if isa(Table, 'char')
    Imported_table =  load(Table); 
    Cell_properties_table = Imported_table.(Table);
else
    Cell_properties_table = Table;
end


    EGTA = ismember(Cell_properties_table.Ca_buffer, {'EGTA'}); % Define what table want to work with

    D1 = ismember(Cell_properties_table.genetic_marker, {'D1'});
    D3 = ismember(Cell_properties_table.genetic_marker, {'D3'});

    EGTA_table =  Cell_properties_table(EGTA, :);
    D1_EGTA_table = Cell_properties_table(D1 & EGTA, :);
    D3_EGTA_table = Cell_properties_table(D3 & EGTA, :);

end

