function outputTable = backpropAnalysis(channel, showPlots)
%This function pulls out relevant data from selected linescans and saves
%data to the clipboard for adding to spreadsheet
%example spreadsheet: https://docs.google.com/spreadsheets/d/1elJ_9HW6ENi8D14uhngSU-gYchyhgQMe3btaM7QcHl8/edit?hl=en#gid=0

if nargin == 0
    showPlots = 1;
    channel = 'gor';
elseif nargin == 1
    showPlots = 1;
end


%Select Scans to include
scans = loadLineScans;
somaCoords = eval(['[' str2mat(inputdlg('Enter Soma Coordinates','Soma Coordinates',1,{'0,0,0'})) ']']);


%Go through each line scans pull out data for analysis
for i=1:length(scans)
    
    if strcmp(channel,'g')
        trace = scans(i).normGreen;
        channelName = 'Green';
    elseif strcmp(channel,'gor')
        trace = scans(i).normGoR;
        channelName = 'Green/Red';
    else
        error('Invalid channel selection');
    end
    
    [traceLinearity(i), linearSumTrace, measuredPeakTrace, singlePeak(i), rms]= scans(i).linearity(trace, scans(i).expParams.spikeTimes);
    
    for j=1:length(scans(i).expParams.spikeTimes)
        spikeIndex(j) = scans(i).time2index(scans(i).expParams.spikeTimes(j));
    end
    
    
    
    train_baseline_start = spikeIndex(2)-scans(i).time2index(.05);
    train_baseline_end = spikeIndex(2);
    
    train_baseline = mean(trace(train_baseline_start:train_baseline_end));
    
    
    
    
    trainPeak(i) = max(measuredPeakTrace)-train_baseline;
    expectedPeak(i) = max(linearSumTrace)-train_baseline;
    
    if showPlots == 1
        figure('units','normalized','outerposition',[0.2 0.2 .8 .8]);
        hold on;
        plot(scans(i).time(1:spikeIndex(2)),linearSumTrace(1:spikeIndex(2)),'r');
        plot(scans(i).time(1:spikeIndex(2)),trace(1:spikeIndex(2)),'k');
        plot(scans(i).time(1:spikeIndex(2)),measuredPeakTrace(1:spikeIndex(2)),'b');
        legend({'Expected','Trace','Measured Signal'});
        xlabel('Time (ms)');
%         xticks(sort([0 0.5 1 1.5 scans(i).expParams.spikeTimes]));
        title([scans(i).name  ' ' channelName ' single spike']);
        set(gca,'YGrid', 'on','GridLineStyle', '-');
        set(gca,'fontsize',16,...
            'XMinorTick','on',...
            'YMinorTick','on',...
            'TickDir','out');
        hold off;
        
        figure('units','normalized','outerposition',[0.2 0.2 .8 .8]);
        hold on;
        plot(scans(i).time(spikeIndex(1):end),linearSumTrace(spikeIndex(1):end)-train_baseline,'r');
        plot(scans(i).time(spikeIndex(1):end),trace(spikeIndex(1):end)-train_baseline,'k');
        plot(scans(i).time(spikeIndex(1):end),measuredPeakTrace(spikeIndex(1):end)-train_baseline,'b');
        legend({'Expected','Trace','Measured Signal'});
        xlabel('Time (ms)');
%         xticks(sort([0 0.5 1 1.5 scans(i).expParams.spikeTimes]));
        title([scans(i).name  ' ' channelName ' burst']);
        set(gca,'YGrid', 'on','GridLineStyle', '-');
        set(gca,'fontsize',16,...
            'XMinorTick','on',...
            'YMinorTick','on',...
            'TickDir','out');
        hold off;
    end
    
    linearSum = [];
    measuredPeak = [];
    
    isi(i) = scans(i).expParams.spikeTimes(end)-scans(i).expParams.spikeTimes(end-1);
    
    
    
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
    outputTable{i,3} = []; %loc
    outputTable{i,4} = []; %branch num
    outputTable{i,5} = length(scans(i).expParams.spikeTimes); %num. spikes
    outputTable{i,6} = scans(i).expParams.spikeTimes(end)-scans(i).expParams.spikeTimes(end-1); %train freq.
    outputTable{i,7} = x(i);
    outputTable{i,8} = y(i);
    outputTable{i,9} = z(i);
    outputTable{i,10} = distance(i); %Eucl. Dist.
    outputTable{i,11} = rms(1); %Single dect.
    outputTable{i,12} = rms(2); %Train dect.
    outputTable{i,13} = singlePeak(i); %Amp. (single)
    outputTable{i,14} = trainPeak(i); %Amp. (train)
    outputTable{i,15} = expectedPeak(i); % Amp. (Exp.)
    outputTable{i,16} = traceLinearity(i); %Obs/exp.
end

%Save cell table to clipboard
mat2clip(outputTable);



