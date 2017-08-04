function [Fluo5_table, D1_Fluo5_table, D3_Fluo5_table] = GenerateFluo5Tables(Table)
%

if isa(Table, 'char')
    Imported_table =  load(Table); 
    Cell_properties_table = Imported_table.(Table);
else
    Cell_properties_table = Table;
end


Fluo5 = ismember(Cell_properties_table.Ca_buffer, {'Fluo5'}); % Define what table want to work with

D1 = ismember(Cell_properties_table.genetic_marker, {'D1'});
D3 = ismember(Cell_properties_table.genetic_marker, {'D3'});

Fluo5_table =  Cell_properties_table(Fluo5, :);
D1_Fluo5_table = Cell_properties_table(D1 & Fluo5, :);
D3_Fluo5_table = Cell_properties_table(D3 & Fluo5, :);

end

