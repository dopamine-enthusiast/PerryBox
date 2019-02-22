export_path = '/Users/perryspratt/Data/Export';
cell_dir_path = '/Users/perryspratt/Google Drive/Lab/Projects/scn2a/double KO/Cells';

for i=1:length(cells)
    try
        disp(['Loading ' cells{i}]);
        sweeps = parse_ibw(cells{i},export_path, 50);
        save([cell_dir_path filesep cells{i} '.mat'], 'sweeps');        
    catch
        disp(['Problem loading ' cells{i}]);
    end
end