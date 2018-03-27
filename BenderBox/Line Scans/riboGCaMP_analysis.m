function riboGCaMP_analysis()

%This function pulls out relevant data from selected linescans and saves
%data to the clipboard for adding to spreadsheet
%example spreadsheet: https://docs.google.com/spreadsheets/d/1elJ_9HW6ENi8D14uhngSU-gYchyhgQMe3btaM7QcHl8/edit?hl=en#gid=0


scans = loadLineScans;

num_spikes = [1 3 5 10 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5];
isi = .01;
stim_start = .2;

%Go through each line scans pull out data for analysis
for i=1:length(scans)
    
    trace = scans(i).normGreen;
    
    [scan_x, scan_y, scan_z, scan_distance] = getLineScanLocation(scans(i));
    
    % Add date to a cell table
    [~,cellname] = fileparts(pwd);
    
    
    figure;
    hold on;
    plot(scans(i).time,trace,'color',[0.8 0.8 0.8]);
    smoothed_trace = smooth(trace,9);
    plot(scans(i).time, smoothed_trace,'k');
    [peak_amp peak_idx] = max(smoothed_trace);
    scatter(scans(i).index2time(peak_idx), smoothed_trace(peak_idx));
    title(['Max dF/F: ' num2str(peak_amp)]);
    
    stim_end_idx = time2index(scans(i), stim_start + num_spikes(i)*isi);
    
    rise_idx = find(smoothed_trace - smoothed_trace(stim_end_idx) >= (peak_amp - smoothed_trace(stim_end_idx)) *.632,1);
    
    plot([stim_start + num_spikes(i)*isi stim_start + num_spikes(i)*isi],[0 peak_amp],'k');
    disp(smoothed_trace(rise_idx));
    rise_time = index2time(scans(i),rise_idx)- (stim_start + num_spikes(i)*isi);
    scatter(scans(i).index2time(rise_idx), smoothed_trace(rise_idx));
    
    fall_idx = find(smoothed_trace(peak_idx:end) <= peak_amp*0.368,1)+peak_idx-1;
    if isempty(fall_idx)
       fall_time = NaN;
    else
        fall_time = index2time(scans(i),fall_idx);
        disp(smoothed_trace(fall_idx));
        scatter(scans(i).index2time(fall_idx), smoothed_trace(fall_idx));
    end
            
    
    
    
    
    outputTable{i,1} = cellname;
    outputTable{i,2} = []; %genotype
    outputTable{i,3} = scans(i).date; %Experiment Date
    outputTable{i,4} = datestr(datetime); %Analysis Date
    outputTable{i,5} = scans(i).name; %scan name
    outputTable{i,6} = scan_x;
    outputTable{i,7} = scan_y;
    outputTable{i,8} = scan_z;
    outputTable{i,9} = scan_distance;
    outputTable{i,10} = 0; %apical vs Basal
    outputTable{i,11} = num_spikes(i); %nums spikes
    outputTable{i,12} = max(smoothed_trace);
    outputTable{i,13} = rise_time;
    outputTable{i,14} = fall_time;
    

%Save cell table to clipboard
mat2clip(outputTable);

end
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



