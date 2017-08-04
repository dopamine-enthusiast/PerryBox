function [ type ] = Classify_Cell(Cell, plot_yes_or_no)
%Classify_Cell

if Cell.Properties.SagReb.Rebound.ReboundLocation_ms_130ms < 90
    type = 'Type 2';
    return
end

Ca_buffer = Cell.CaBuffer;

type_overall = cell(1, 8);

if strcmp(plot_yes_or_no, 'yes')
    figure;
end

for i = 3:8
    
    % Load the LDA fit with the appropriate calcium buffer and spike number
    
    load(strcat('Standardized_Data_Values_', Ca_buffer, '_', mat2str(i)))
    load(strcat('LDA_fit_var_', Ca_buffer, '_', mat2str(i)))
    load(strcat('Distribution_Values_', Ca_buffer, '_', mat2str(i)))
    
    
    adaptation_ratio = reallog(Cell.Properties.(sprintf('APWaveformValues_%dspikes', i)).adaptation_ratio.Adaptation_Ratio_1(2));
    dVdt_rising = Cell.Properties.(sprintf('APWaveformValues_%dspikes', i)).dVdt_rising.percent20(i);
    threshold_vs_threshold = Cell.Properties.(sprintf('APWaveformValues_%dspikes', i)).mV_change.threshold_vs_threshold(i);
    sag = Cell.Properties.SagReb.Sag.sag_amplitude_fit;
    reb_delta_t = Cell.Properties.SagReb.Rebound.reb_delta_t;
    
    % Standardize the given cell
    Non_Fluor_array = [adaptation_ratio, dVdt_rising, threshold_vs_threshold, sag, reb_delta_t];
    Variable_means_matrix = repmat(fluor_means, size(Non_Fluor_array, 1), 1);
    Variable_stdev_matrix = repmat(fluor_stdev, size(Non_Fluor_array, 1), 1);
    NonFluor_points = (Non_Fluor_array-Variable_means_matrix)./Variable_stdev_matrix;
    
    
    
    % Get the discrimiant scores of the genetically labelled cells and the given
    % nonfluorescent cell
    D1_scores = discriminant_score(K, L, D1_points);
    D3_scores = discriminant_score(K, L, D3_points);
    NonFluor_scores = discriminant_score(K, L, NonFluor_points);
    
    % Pick which subplot this spike number will be plotted for
    
    if strcmp(plot_yes_or_no, 'yes')
        subplot(2, 3, i-2); hold on
    end
    
    
    cutoff_D1 = D1_mean-1.64*D1_std; cutoff_D3 = D3_mean+1.64*D3_std;
    
    if cutoff_D1 > 0
        cutoff_D1 = 0;
    end
    
    if cutoff_D3 < 0
        cutoff_D3 = 0;
    end
    
    if strcmp(plot_yes_or_no, 'yes')
        
        plot([cutoff_D1, cutoff_D1], [0, 1], 'Color', rgb('grey'),  'LineWidth', 1.5)
        plot([cutoff_D3, cutoff_D3], [0, 1], 'Color', rgb('grey'),  'LineWidth', 1.5)
        
        plot([0, 0], [0, 1], '--r', 'LineWidth', 1.5)
        plot(x_values,y_D1,'LineWidth',2, 'Color', 'k')
        plot(x_values,y_D3,'LineWidth',2, 'Color', rgb('dodgerblue'))
        
        plot(D1_scores, .1, 'ok')
        plot(NonFluor_scores,.2, 'o', 'MarkerSize', 7, 'MarkerEdgeColor', 'r', 'LineWidth', .5)
        plot(D3_scores, .3, 'o', 'Color', rgb('dodgerblue'))
        
        
        xlim([-10, 7]); ylim([0, .75])
        xlabel('Score'); ylabel('Probability')
    end
    
    if NonFluor_scores <=cutoff_D1
        type = 'Type 3';
        type_overall{i} = 3;
    elseif NonFluor_scores >= cutoff_D3
        type = 'Type 1';
        type_overall{i} = 1;
    elseif ~isnan(NonFluor_scores)
        type = 'Unidentified';
    else
        type = 'Unidentified: No Sweep';
    end
    
    spike_num = sprintf('%d spikes', i);
    type_identification = sprintf('ID: %s', type);
    
    if strcmp(plot_yes_or_no, 'yes')
        text(-8, .5, spike_num)
        text(-8, .45, type_identification)
    end
end


% Determine the overall cell type and use that to make the title
idx = find(~cellfun(@isempty, type_overall));
type_identifier_overall = type_overall(idx);
type_identifier_overall = cell2mat(type_identifier_overall);

if isempty(type_identifier_overall)
    type = 'Unidentified';
elseif all(type_identifier_overall == type_identifier_overall(1))
    type = sprintf('Type %d', type_identifier_overall(1));
else
    type = 'Unidentified';
end


if strcmp(plot_yes_or_no, 'yes')
    fig = gcf;
    set(fig, 'Position', [336, 180, 1234, 675])
    subplot(2, 3, 2)
    if strcmp(type, 'Unidentified')
        title('Unidentified Cell')
    else
        title(type);
    end
end




end






