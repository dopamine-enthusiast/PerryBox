

export_path = '/Users/perryspratt/Data/Export';
cell_dir_path = '/Users/perryspratt/Google Drive/Lab/Projects/scn2a/double KO/Cells';
num_sweeps = 50;

for i=1:length(cells)
    disp(cells{i});
    try
        sweeps = parse_ibw(cells{i},export_path,num_sweeps);
%         load([cell_dir_path filesep cells{i,1} '.mat']);
       
        output{i,1} = sweeps(1).Vm;
                        
        for j = 2:length(sweeps)            
            if sweeps(j).Vm > -74 && sweeps(j).Vm < -65 && ~isnan(sweeps(j).Rin)
                output{i,2} = j;
                output{i,3} = sweeps(j).Rin;
                break;
            end            
        end
        
        for j = 1:length(sweeps)
            if sweeps(j).Vm > -73 && sweeps(j).Vm < -65 && ~isnan(sweeps(j).sag) && ~isnan(sweeps(j).rebound)
                output{i,4} = j;
                output{i,5} = sweeps(j).sag;
                output{i,6} = sweeps(j).rebound;
                break;
            end
        end
        
        sweep_idx = [];
        num_spikes = [];
         for j = 1:length(sweeps)            
            if sweeps(j).Vm > -75 ...
                    && sweeps(j).Vm < -65 ...
                    && ~isempty(sweeps(j).spikes)...
                    && ~isempty(sweeps(j).commands)...
                    && sweeps(j).commands(1).length == .3
                
                num_spikes = [num_spikes length(sweeps(j).spikes)];
                sweep_idx = [sweep_idx j];                                                      
            end            
         end
         
         [~, min_idx] = min(num_spikes);
         
         output{i,7} = sweep_idx(min_idx);
%          figure;
         plot(sweeps(sweep_idx(min_idx)).data)
         title(cells{i});
         output{i,8} = sweeps(sweep_idx(min_idx)).spikes(1).threshold;
         output{i,9} = sweeps(sweep_idx(min_idx)).spikes(1).peak_dVdt;
         output{i,10} = sweeps(sweep_idx(min_idx)).commands(1).amp;
         output{i,11} = num_spikes(min_idx);
    catch
        output{i,1} = [];
        output{i,2} = [];
        output{i,3} = [];
        output{i,4} = [];
        output{i,5} = [];
        output{i,6} = [];
        output{i,7} = [];
        output{i,8} = [];
        output{i,9} = [];
    end   
end
mat2clip(output);
        



















