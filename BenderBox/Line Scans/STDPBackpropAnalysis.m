function outputTable = STDPBackpropAnalysis(scans)
%This function pulls out relevant data from selected linescans and saves
%data to the clipboard for adding to spreadsheet
%example spreadsheet: https://docs.google.com/spreadsheets/d/1elJ_9HW6ENi8D14uhngSU-gYchyhgQMe3btaM7QcHl8/edit?hl=en#gid=0

show_plots = 1;

%Select Scans to include if they are not passed to the function
if nargin == 0
    scans = loadLineScans;
end

%sort scans
for i=1:length(scans)
    scans_datenum(i) = datenum(scans(i).date);
end
[temp idx] = sort(scans_datenum);
scans = scans(idx);

%Find the nexus scan
for i=1:length(scans)
    %First use regexp to identify it
    if ~isempty(regexp(scans(i).name,regexptranslate('wildcard','*nexus*')))
        nexus_scan = scans(i)
        break;
    end        
    
    %if no scan is named select it manually 
    if i == length(scans)
        [filename, pathname] = uigetfile({'*.mat'},'Select line scan of nexus');
        load([pathname filename]);
        nexus_scan = obj;        
    end
end
[nexus_x, nexus_y, nexus_z, nexus_distance] = getLineScanLocation(nexus_scan);

burst_times = [.2, .3, .4, .5, .6]; %trains of APs
stim_length = 0.022;







%Go through each line scans pull out data for analysis
for i=1:length(scans)
    
    trace = scans(i).normGoR;
    channelName = 'Green/Red';
    
    burst_start_idx = scans(i).time2index(burst_times);
    burst_end_idx = scans(i).time2index(burst_times+stim_length);
    isi_idx = burst_start_idx(2)-burst_start_idx(1);
    time_step = scans(i).time(2)-scans(i).time(1);
    
    
    baseline = 0;
    if show_plots
        figure;
        hold on;
        title(scans(i).name);
        xlabel('Scan Number');
        ylabel('dG/R');
        ylim([-.01 .25]);
        plot(scans(i).time, trace,'color',[0.8 0.8 0.8]);
    end
    
    for j=1:length(burst_times)-1
        decay_phase = trace(burst_end_idx(j):burst_start_idx(j+1)); %get the decay phase between bursts
        [peak,tau] = decayFit(scans(i),decay_phase); %fit to an exponetial decay
        
        x = 1:length(decay_phase);
        y = peak*exp(tau*x);
        
        if show_plots
            plot(scans(i).time(x+burst_end_idx(j)),y,'k');     
        end 
        
        delta(j) = peak-baseline;
        if delta(j) < 0
            delta(j) = 0;
        end
        baseline = y(end);
    end
    decay_phase = trace(burst_end_idx(end):burst_end_idx(end)+burst_end_idx(end)-burst_start_idx(end-1)); %get the decay phase between bursts
    [peak,tau] = decayFit(scans(i),decay_phase); %fit to an exponetial decay
    delta(j+1) = peak-baseline;
    x = 1:length(decay_phase);
    y = peak*exp(tau*x);
    baseline = y(end);
    
    if show_plots
        plot(scans(i).time(x+burst_end_idx(end)),y,'k');        
        if 7~=exist('Decay fits','dir')
           mkdir('Decay fits');
        end        
        saveas(gcf,['Decay fits' filesep scans(i).name '_decay fits.png']);
        close;
    end 
    
    auc = trapz(scans(i).time(burst_start_idx(1):burst_start_idx(end)+isi_idx),trace(burst_start_idx(1):burst_start_idx(end)+isi_idx));
    
    
    [scan_x, scan_y, scan_z, scan_distance] = getLineScanLocation(scans(i));
    
    % Add date to a cell table
    [~,cellname] = fileparts(pwd);
    
    
    outputTable{i,1} = cellname;
    outputTable{i,2} = []; %genotype
    outputTable{i,3} = scans(i).date;
    outputTable{i,4} = scans(i).name; %scan name
    outputTable{i,5} = scan_x;
    outputTable{i,6} = scan_y;
    outputTable{i,7} = scan_z;
    outputTable{i,8} = scan_distance;
    outputTable{i,9} = max(smooth(trace,5));
    for j=1:length(delta)
        outputTable{i,9+j} = delta(j);
    end
    outputTable{i,15} = scans(i).expParams.gsat;
    outputTable{i,16} = nexus_x;
    outputTable{i,17} = nexus_y;
    outputTable{i,18} = nexus_z;
    outputTable{i,19} = nexus_distance;
    if nexus_distance>=scan_distance
        outputTable{i,20} = -1*sqrt((nexus_x-scan_x)^2 + (nexus_y-scan_y)^2 + (nexus_z-scan_z)^2);
        outputTable{i,21} = scan_distance;
    else
        outputTable{i,20} = sqrt((nexus_x-scan_x)^2 + (nexus_y-scan_y)^2 + (nexus_z-scan_z)^2);
        outputTable{i,21} = outputTable{i,20}+nexus_distance;
    end
    outputTable{i,22} = auc;
    outputTable{i,23} = datestr(datetime);
   
    %old method of finding peaks
%     figure;
%     hold on;
%     plot(trace);
%     
%     for j=1:length(burst_times)
%        smooth_trace = smooth(trace,5);
%        burstStart = scans(i).time2index(burst_times(j));
%        
%        minRange = scans(i).time2index(burst_times(j) + 0.01);
%        maxRange = scans(i).time2index(burst_times(j) + 0.05);
%        
%        [min_value, min_index] = min(smooth_trace(burstStart:minRange));
%        [max_value, max_index] = max(smooth_trace(burstStart+min_index:maxRange));
%        
%        scatter(burstStart+min_index,min_value,'k');
%        scatter(burstStart+min_index+max_index,max_value,'r');
%        
%        delta2(j) = max_value-min_value;
%         
%     end
%     
%     max_value = max(smooth(trace,5));
 
end

%Save cell table to clipboard
mat2clip(outputTable);

end

function [x, y, z, distance] = getLineScanLocation(scan)
    somaCoords = [0 0 0]; %eval(['[' str2mat(inputdlg('Enter Soma Coordinates','Soma Coordinates',1,{'0,0,0'})) ']']);

    if strcmp(scan.imagingParams.rig,'bluefish')
        x = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,15}.Attributes.value)-somaCoords(1);
        y = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,16}.Attributes.value)-somaCoords(2);
        z = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,17}.Attributes.value)-somaCoords(3);
    elseif strcmp(scan.imagingParams.rig,'Thing1')
        x = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,15}.Attributes.value)-somaCoords(1);
        y = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,16}.Attributes.value)-somaCoords(2);
        z = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,17}.Attributes.value)-somaCoords(3);
    elseif strcmp(scan.imagingParams.rig,'Thing2')
        x = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,12}.Attributes.value)-somaCoords(1);
        y = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,13}.Attributes.value)-somaCoords(2);
        z = str2num(scan.xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,14}.Attributes.value)-somaCoords(3);
    end
    distance = pdist([0,0,0;x,y,z]);
end