%% Import a cell from Igor and select the sweeps for calculating sag/rebound and input resistance


%                       ASSUMPTIONS
% Timing for sag/rebound and Rin pulses are consistent across selected
% sweeps.
% Igor-to-Matlab has to be exported to C:\Data\Export

%                      REQUIRED FUNCTIONS
% All the functions in this box folder.


% Forked from Import_and_Classify 20160623 by Perry Spratt for use in
% LineScan View

function [type Rin_Sweep_Average Vrest] = Import_and_Classify_LinescanViewer(Cell_to_load,pathName, plot_yes_or_no,CaBuffer)

raw = IBWread([pathName filesep Cell_to_load '_rawsweeps.ibw']);

f = 20000; %sampling rate
baselineStart = 0;
baselineEnd = 0.05;

Vrest = mean(raw.y(1:baselineEnd*f,1));



select_sagreb = 'no'; 
root = pwd;
cd(pathName);
Cell_to_load = [Cell_to_load '*'];







% All cells from Igor must be in the below folder; Cells with Rin & Reb/Sag
% sweeps will be output to "savepath"


    Cell = load_ibw_classify(Cell_to_load);
    Cell = ConvertDAQ(Cell);
    Cell.Fs = intersect(Cell.kHz, Cell.kHz)*1000;



% Determine what calcium buffer was used

% Setting default as 'Fluo5'
% Cell.CaBuffer = 'Fluo5';
Cell.CaBuffer = CaBuffer;



% Establish Cell.time
[~, num_sweeps] = size(Cell.data);
Cell.time = nan(max(intersect(Cell.DAQ, Cell.DAQ)), num_sweeps);

for ii = 1:num_sweeps
    points_per_sec = Cell.kHz(ii)*1000;
    num_points = Cell.DAQ(ii);
    sec_per_sweep = num_points/points_per_sec;
    sec_per_point = 1/points_per_sec;
    Cell.time(1:num_points, ii) = [0:sec_per_point:sec_per_sweep-sec_per_point]';
end


%%  Select input resistance and sag/rebound sweeps

[Cell.Properties.Rin.Sweep, Cell.Properties.Rin.AveragedSweeps] = SelectInputResistance();
[Cell.Properties.SagReb.Sweep, Cell.Properties.SagReb.AveragedSweeps] = SelectSagReboundSweeps();

    function [Rin_Sweep_Average, Rin_Sweeps_Idx] = SelectInputResistance()
        Rin_Sweeps_Idx = intersect(find(Cell.swp_time<300), find(any(Cell.comm==-50)));
        Rin_Sweeps = Cell.data(:, Rin_Sweeps_Idx);
        
        % Remove nan from any row that contains it - this assumes that all
        % selected sweeps have the same sampling frequency
        Rin_Sweeps = Rin_Sweeps(~any(isnan(Rin_Sweeps),2), :);
        
        if strcmp(select_sagreb, 'yes')
            figure
            plot(Rin_Sweeps)
            clickableLegend(num2str(Rin_Sweeps_Idx)) % clickableLegend is a downloaded script
            
            str = input('Do you want to remove any sweeps? y/n   ', 's');
            if str ~= 'y' && str ~= 'n'
                str = input('Please enter "y" or "n"  ', 's');
            end
            
            Rin_Sweeps_Tmp = Rin_Sweeps;
            
            if str == 'y'
                sweeps_to_remove= input('What sweeps do you want to remove?   ');
                
                all_indices_to_remove = [];
                for i = 1:length(sweeps_to_remove)
                    current_sweep = sweeps_to_remove(i);
                    current_ind = find(Rin_Sweeps_Idx == current_sweep);
                    all_indices_to_remove = [all_indices_to_remove current_ind];
                end
                
                Rin_Sweeps_Tmp(:, all_indices_to_remove) = [];
                figure
                plot(Rin_Sweeps_Tmp)
                str = input('Do you want to keep these changes? y/n  ', 's');
                
                if str ~= 'y' && str ~= 'n'
                    str = input('Please enter "y" or "n"  ', 's');
                end
                
                if str == 'y'
                    Rin_Sweeps = Rin_Sweeps_Tmp;
                    Rin_Sweeps_Idx(all_indices_to_remove) = [];
                elseif str == 'n'
                    % if you don't want to save these changes, it will start over
                    % the sweep selection process
                    [Cell.Properties.Rin.Sweep, Cell.Properties.Rin.AveragedSweeps] = SelectInputResistance();
                end
            end
        end
        
        
        
        % Compute the average Rin sweep, the output of this function
        
        Rin_Sweep_Average = mean(Rin_Sweeps, 2);
        
        
    end

    function [SagRebSweep, SagReb_Sweeps_Idx] = SelectSagReboundSweeps()
        % Find all -400 pA hyperpolarizing pulses within the first 5 minutes
        % (or occassionally 10 minutes, if characterized a bit slower)
        SagReb_Sweeps_Idx = intersect(find(Cell.swp_time<300), find(any(Cell.comm==-400)));
        SagReb_Sweeps = Cell.data(:, SagReb_Sweeps_Idx);
        %%
        if strcmp(select_sagreb, 'yes')
                % Display these sweeps to see if you need to remove any
                plot(SagReb_Sweeps)
                clickableLegend(num2str(SagReb_Sweeps_Idx)) % clickableLegend is a downloaded script
        
                str = input('Do you want to remove any sweeps? y/n   ', 's');
                if str ~= 'y' && str ~= 'n'
                    str = input('Please enter "y" or "n"  ', 's');
                end
        
                % Create a temporary sagreb_sweeps so that you can check you removed
                % the right sweeps, if necessaryv
                SagReb_Sweeps_Tmp = SagReb_Sweeps;
        
                if str == 'y'
                    sweeps_to_remove= input('What sweeps do you want to remove?   ');
        
                    if ~isa(sweeps_to_remove, 'numeric')
                        input('Please enter a number  ', 's');
                    end
        
        
                    all_indices_to_remove = [];
                    SagReb_Sweeps_Idx_Tmp = SagReb_Sweeps_Idx;
        
                    % Remove sweeps if desired
                    for i = 1:length(sweeps_to_remove)
                        current_sweep = sweeps_to_remove(i);
                        current_ind = find(SagReb_Sweeps_Idx == current_sweep);
                        all_indices_to_remove = [all_indices_to_remove current_ind];
        
                    end
        
                    SagReb_Sweeps_Tmp(:, all_indices_to_remove) = [];
                    % Plot the remaining sweeps and see if you want to keep the changes
                    figure
                    plot(SagReb_Sweeps_Tmp)
        
                    str = input('Do you want to keep these changes? y/n  ', 's');
        
                    if str ~= 'y' && str ~= 'n'
                        str = input('Please enter "y" or "n"  ', 's')
                    end
        
                    if str == 'y'
                        SagReb_Sweeps = SagReb_Sweeps_Tmp;
                        SagReb_Sweeps_Idx(all_indices_to_remove) = [];
        
                    elseif str == 'n'
                        % if you don't want to save these changes, it will start over
                        % the sweep selection process
                        [Cell.Properties.SagReb.Sweep, Cell.Properties.SagReb.AveragedSweeps] = SelectSagReboundSweeps()
                    end
        
                end
        end
        
        
        % Calculate the average sag and rebound sweep
        SagRebSweep = mean(SagReb_Sweeps, 2);
        
        
        
    end


% Run all analyses on the particular cell
[Cell] = AnalyzeCell(Cell);
[type] = Classify_Cell(Cell, plot_yes_or_no);


cd(root);
end

%% Further possible inputs - Put back into the code if want to add this information

% % Determine the animal genotype and age
% Cell.mouse_genotype = input('What is the mouse genotype?  ', 's');
% Cell.animal_age = input('What is mouse age in days?   ', 's');
%
%
% % Determine whether it has a genetic marker
%
% str = input('Does this cell have a genetic marker? y/n   ', 's');
% if str ~= 'y' && str ~= 'n'
%     str = input('Please enter "y" or "n"  ', 's')
% end
% if str == 'y'
%     str = input('What is the genetic marker? ', 's');
%     Cell.genetic_marker = str;
% end

% Determine Vm and distance from the pia
% Cell.Vm = input('What was the resting membrane potential?    ');
% Cell.distance_from_pia = input('What was the distance from the pia?    ');
