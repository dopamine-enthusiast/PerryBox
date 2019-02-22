
function sweeps = parse_ibw(cell_name, export_path, num_sweeps)
% cell_name = '/Users/perryspratt/Data/Export/ps20181023d';

if nargin > 1
    cell_name = fullfile(export_path,cell_name);
end


cell = load_ibw_data([cell_name]);

if nargin < 3 || num_sweeps > length(cell.time)
    num_sweeps = length(cell.time);
end

% figure;
% hold on;
% ylim([-150 50]);
for i=1:num_sweeps
   
   sweeps(i).data = cell.data(:,i);
   sweeps(i).comm = cell.comm(:,i);
   sweeps(i).Vm = cell.data(1,i);
   sweeps(i).temp = cell.temp(i);
   sweeps(i).time = cell.time(i);
   sweeps(i).DAQ = cell.DAQ(i);
   sweeps(i).fs = cell.fs(i)*1000;
   sweeps(i).spikes = parse_spikes(sweeps(i));
   sweeps(i).commands = parse_comms(sweeps(i));
   [sweeps(i).sag, sweeps(i).rebound] = calc_sag_rebound(sweeps(i));
   
   t = (1:1:length(cell.data(:,i)))./sweeps(i).fs;
   
%    
%    plot(t,cell.data(:,i))
%    title(['Sweep: ' num2str(i-1)]);
%    if ~isempty(sweeps(i).spikes)       
%        scatter([sweeps(i).spikes.start_time],cell.data([sweeps(i).spikes.start_idx],i));       
%    end
   sweeps(i).Rin = calc_Rin(sweeps(i));
end
end

function cell_data = load_ibw_data(cell_name)

filetypes = {'_rawsweeps.ibw' '_commands.ibw' '_temperature.ibw' '_sweeptimes.ibw' '_DAQ.ibw' '_kHz.ibw'};
ds_datatypes = {'data' 'comm' 'temp' 'time' 'DAQ' 'fs'};

for j=1:length(filetypes)
    try
        temp = IBWread([cell_name filetypes{j}]);
        cell_data.(ds_datatypes{j}) = temp.y;
    catch
        cell_data.(ds_datatypes{j}) = [];
    end
end

if length(cell_data.data(1,:)) < length(cell_data.time)
    i=1;
%     temp_data = cell_data.data((i-1).*cell_data.DAQ(i)+1:i*cell_data.DAQ(i));
%     temp_comm = cell_data.comm((i-1).*cell_data.DAQ(i)+1:i*cell_data.DAQ(i));

    temp_data = cell_data.data(1:cell_data.DAQ(i));
    temp_comm = cell_data.comm(1:cell_data.DAQ(i));

    cumul_samples = cell_data.DAQ(i);
    for i=2:length(cell_data.DAQ)
%         temp_data = catpad(2,temp_data,cell_data.data((i-1).*cell_data.DAQ(i)+1:i*cell_data.DAQ(i)));
%         temp_comm = catpad(2,temp_comm,cell_data.comm((i-1).*cell_data.DAQ(i)+1:i*cell_data.DAQ(i)));
        temp_data = catpad(2,temp_data,cell_data.data(cumul_samples+1:cumul_samples+cell_data.DAQ(i)));       
        temp_comm = catpad(2,temp_comm,cell_data.comm(cumul_samples+1:cumul_samples+cell_data.DAQ(i)));
        
        cumul_samples = cumul_samples + cell_data.DAQ(i);
    end
    cell_data.data = temp_data;
    cell_data.comm = temp_comm;
end


end

function spikes = parse_spikes(sweep)
    N = 10;
    t = (1:1:length(sweep.data))./sweep.fs;
    %Find spike indicies
    data = sweep.data;
    dVdt = gradient(data,1000/sweep.fs); 
    fast_dVdt = find(dVdt > 15);
    spikes = [];
    if ~isempty(fast_dVdt)
        bin = diff(fast_dVdt)==1; %create binary distrinction
        gaps = find(bin == 0); %find gaps between spikes
        valid_spikes = diff([1;gaps;length(bin)]) > N; %ensure spikes are of reasonable length (ie not artifacts)
        
        spike_idx = fast_dVdt([1;gaps+1]); %all possible spikes
        spike_idx = spike_idx(valid_spikes);
        spike_times = t(spike_idx);
    else
        spike_times = [];
        spike_idx = [];
    end
    
    %parse_spikes
    if ~isempty(spike_idx)
        spikes = [];
        for i=1:length(spike_idx)                                               
            spike.start_idx = spike_idx(i);
            spike.start_time = t(spike.start_idx);
            for j=spike.start_idx:length(data)-1 %There should be a way to linearize this
                if dVdt(j) < 0 && dVdt(j+1) <= 0 %find where dVdt goes from negative to postive after spike start
                    spike.end_idx = j;
                    spike.end_time = t(spike.end_idx);
                    break;
                end
            end
            spike.threshold = data(spike.start_idx);            
            spike.max = max(data(spike.start_idx:spike.end_idx));
            spike.peak_dVdt = max(dVdt(spike.start_idx:spike.end_idx));
            spikes = [spikes spike];                        
        end                                
    end

end


function commands = parse_comms(sweep)

    
    stim_times = find(sweep.comm ~= 0); %points with a stim
    if ~isempty(stim_times)              
        bin = diff([0;stim_times;0])  ~= 1; %find gaps
        gaps = find(bin);
        gap_lengths = diff(gaps); %find gap lengths
        
        for j=1:length(gap_lengths)            
            commands(j).start_idx = stim_times(gaps(j));
            commands(j).end_idx = stim_times(gaps(j+1)-1);
            commands(j).start_time = commands(j).start_idx/sweep.fs;
            commands(j).end_time = commands(j).end_idx/sweep.fs;
            commands(j).amp = sweep.comm(commands(j).start_idx);
            commands(j).length = gap_lengths(j)/sweep.fs;
            
        end
    else
        commands = [];
    end
end

    

function Rin = calc_Rin(sweep)    
    
    Rin = NaN;
    
    if ~isempty(sweep.commands)       
        for i=1:length(sweep.commands)
            if sweep.commands(i).amp == -50 && sweep.commands(i).length == .120
                Rin = abs((sweep.data(sweep.commands(i).start_idx -1) - sweep.data(sweep.commands(i).end_idx)) ./ -50)*1000;
            end
        end
    end
    
end

function [sag, rebound] = calc_sag_rebound(sweep)

    sag = NaN;
    rebound = NaN;
    
    
    if ~isempty(sweep.commands)
        for i=1:length(sweep.commands)
            if sweep.commands(i).amp == -400 && sweep.commands(i).length == .120
                steadystate_Vm = sweep.data(sweep.commands(i).end_idx);
                peak_sag = min(sweep.data(sweep.commands(i).start_idx:sweep.commands(i).end_idx));
                
                sag = abs((steadystate_Vm-peak_sag)/steadystate_Vm)*100;
                
                baseline_Vm = sweep.data(sweep.commands(i).start_idx -1);
                peak_rebound = max(sweep.data(sweep.commands(i).end_idx:end));
                
                rebound = abs((peak_rebound-baseline_Vm)./baseline_Vm)*100;
            end
        end
    end
    
end







        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        