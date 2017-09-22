function plotCaAmpByDistance(sheet, header)

% Code to parse header
% Need cell names, single amp, doublet amp, distance

requests = {'Cell','Condition','Distance','Amp. (single)','Amp. (train)','Obs/exp.'};
indices = parseHeader(header,requests);

cell_names = string({sheet{:,indices(1)}});
conditions = string({sheet{:,indices(2)}});
distance =  [sheet{:,indices(3)}];
single_amp = [sheet{:,indices(4)}];
train_amp = [sheet{:,indices(5)}];
obs_exp = [sheet{:,indices(6)}];
% Code to sort into cells

unique_cells = unique(cell_names);

% figure()
% hold on;

% title('Single Amplitude')
% xlabel('Distance(um)');
% ylabel('dG/G');



figure()
hold on
bins = -100:100:500;
plotByCellBinned(cell_names,train_amp,distance,conditions,bins)
plotResponse(cell_names,train_amp,distance,conditions,bins)
title('Train Amplitude')
xlabel('Distance (um)');
ylabel('dG/G');

figure()
hold on
bins = -100:100:500;
plotByCellBinned(cell_names,single_amp,distance,conditions,bins)
plotResponse(cell_names,single_amp,distance,conditions,bins)
title('Single Amplitude')
xlabel('Distance (um)');
ylabel('dG/G');


% figure()
% hold on
% plotByCellRaw(cell_names,single_amp,distance,conditions)
% title('Single Amplitude')
% xlabel('Distance (um)');
% ylabel('dG/G');
% 
% figure()
% hold on
% plotByCellRaw(cell_names,train_amp,distance,conditions)
% title('Train Amplitude')
% xlabel('Distance (um)');
% ylabel('dG/G');
% 
% figure()
% hold on
% bins = -100:100:500;
% plotByCellBinned(cell_names,single_amp,distance,conditions,bins)
% title('Single Amplitude')
% xlabel('Distance (um)');
% ylabel('dG/G');
% 
% figure()
% hold on
% bins = -100:100:500;
% plotByCellBinned(cell_names,train_amp,distance,conditions,bins)
% title('Train Amplitude')
% xlabel('Distance (um)');
% ylabel('dG/G');

end

function plotByCellRaw(cell_names,amplitude,distance,conditions)

unique_cells = unique(cell_names);
conditions_unique = unique(conditions);


c = [0 0 0;...
    0 0.6824 0.9373;...
     0.8863 0.7843 0.2824;...
    0.8863 0.2824 0.4824];

for i = 1:length(unique_cells)
    
    cell_idx = find(cell_names == unique_cells(i));
    
    dist = distance(cell_idx);
    amp = amplitude(cell_idx);
   
    [dist, sort_idx] = sort(dist);
    amp = amp(sort_idx);
    
    
    for j = 1:length(conditions_unique)
        if conditions(cell_idx(1)) == conditions_unique(j)
            color = c(j,:);
        end
    end
            
    plot(dist,amp,'color',color);
    ylim([0,inf])
        
end

end

function plotByCellBinned(cell_names,amplitude,distance,conditions,bins)

unique_cells = unique(cell_names);
conditions_unique = unique(conditions);


c = [0.5 0.5 0.5;...
    0.6392    0.8784    0.9686;...
    0.8863 0.7843 0.2824;...
    0.8863 0.2824 0.4824];

for i = 1:length(unique_cells)
    cell_idx = find(cell_names == unique_cells(i));
    dist = distance(cell_idx);
    amp = amplitude(cell_idx);
    for j = 1:length(bins)
        bin_idx = dist >= bins(j)-50 & bins(j)+50;        
        amp_binned(j) = mean(amp(bin_idx));
    end
     
    for j = 1:length(conditions_unique)
        if conditions(cell_idx(1)) == conditions_unique(j)
            color = c(j,:);
        end
    end
    
    plot(bins,amp_binned,'color',color);
    ylim([0,inf])
    
%     disp([unique_cells(i) ' ' conditions(cell_idx(1))]);
    
end




end

function plotResponse(cell_names,amplitude,distance,conditions,bins)

unique_cells = unique(cell_names);
conditions_unique = unique(conditions);


c = [0 0 0;...
    0 0.6824 0.9373;...
     0.8863 0.7843 0.2824;...
    0.8863 0.2824 0.4824];


for i = 1:length(conditions_unique)
    all_amp_binned(i).condition = [];
end

for i = 1:length(unique_cells)
    cell_idx = find(cell_names == unique_cells(i));
    dist = distance(cell_idx);
    amp = amplitude(cell_idx);
    
    for j = 1:length(bins)
        bin_idx = dist >= bins(j)-50 & bins(j)+50;        
        amp_binned(j) = mean(amp(bin_idx));
    end
     
    for j = 1:length(conditions_unique)
        if conditions(cell_idx(i)) == conditions_unique(j)
            all_amp_binned(j).condition = [all_amp_binned(j).condition; amp_binned];
        end
    end
    
end

for i = 1:length(conditions_unique)
    
    
    errorbar(bins,nanmean(all_amp_binned(i).condition),nansem(all_amp_binned(i).condition),...
            '-o',...
            'color',c(i,:),...
            'linewidth',1,....
            'MarkerEdgeColor',[1 1 1],...
            'MarkerFaceColor',c(i,:),...
            'MarkerSize',8,...
            'CapSize',0);
    lengend_titles(i) = conditions_unique(i);
end
legend(lengend_titles)

end



function indices = parseHeader(header,requests)
    
indices = [];

for i = 1:length(requests)
    for j = 1:length(header)
        if strcmp(requests{i},header{j})
            indices = [indices j];
        end
    end
end

end

