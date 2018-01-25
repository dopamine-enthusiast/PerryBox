function outputTable = STDPBackpropAnalysis(showPlots)
%This function pulls out relevant data from selected linescans and saves
%data to the clipboard for adding to spreadsheet
%example spreadsheet: https://docs.google.com/spreadsheets/d/1elJ_9HW6ENi8D14uhngSU-gYchyhgQMe3btaM7QcHl8/edit?hl=en#gid=0



%Select Scans to include
scans = loadLineScans;
somaCoords = eval(['[' str2mat(inputdlg('Enter Soma Coordinates','Soma Coordinates',1,{'0,0,0'})) ']']);


%Go through each line scans pull out data for analysis
for i=1:length(scans)
    

    trace = scans(i).normGoR;
    channelName = 'Green/Red';

    burst_times = [.2, .3, .4, .5, .6];
    
    figure;
    hold on;
    plot(trace);

    
    for j=1:length(burst_times)
       smooth_trace = smooth(trace,5);
       burstStart = scans(i).time2index(burst_times(j));
       
       minRange = scans(i).time2index(burst_times(j) + 0.01);
       maxRange = scans(i).time2index(burst_times(j) + 0.05);
       
       [min_value, min_index] = min(smooth_trace(burstStart:minRange));
       [max_value, max_index] = max(smooth_trace(burstStart+min_index:maxRange));
       
       scatter(burstStart+min_index,min_value,'k');
       scatter(burstStart+min_index+max_index,max_value,'r');
       
       delta(j) = max_value-min_value;
        
    end
    
    max_value = max(smooth(trace,5));
    
    
    
    disp(delta)
    
    
    if strcmp(scans(i).imagingParams.rig,'bluefish')
        x(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,15}.Attributes.value)-somaCoords(1);
        y(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,16}.Attributes.value)-somaCoords(2);
        z(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,17}.Attributes.value)-somaCoords(3);
    elseif strcmp(scans(i).imagingParams.rig,'Thing1')
        x(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,15}.Attributes.value)-somaCoords(1);
        y(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,16}.Attributes.value)-somaCoords(2);
        z(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,17}.Attributes.value)-somaCoords(3);
    elseif strcmp(scans(i).imagingParams.rig,'Thing2')
        x(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,12}.Attributes.value)-somaCoords(1);
        y(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,13}.Attributes.value)-somaCoords(2);
        z(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,14}.Attributes.value)-somaCoords(3);
    end
    distance(i) = pdist([0,0,0;x(i),y(i),z(i)]);
    
    % Add date to a cell table
    outputTable{i,1} = scans(i).date;
    outputTable{i,2} = scans(i).name; %scan
    outputTable{i,3} = x(i);
    outputTable{i,4} = y(i);
    outputTable{i,5} = z(i);
    outputTable{i,6} = distance(i); %Eucl. Dist.
    outputTable{i,7} = max_value
    for j=1:length(delta)
        outputTable{i,7+j} = delta(j);
    end
    
end

%Save cell table to clipboard
mat2clip(outputTable);



