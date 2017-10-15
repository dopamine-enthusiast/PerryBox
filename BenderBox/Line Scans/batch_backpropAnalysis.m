function batch_backpropAnalysis()

cell_dirs = uipickfiles;

counter = 1;
data = {};
for i=1:length(cell_dirs)
    ls_dir = dir([cell_dirs{i} '/*.mat']);
    
    for j=1:length(ls_dir)
        try
            load([cell_dirs{i} '/' ls_dir(j).name]);
            scans(counter) = obj.updateLineScanXML;
            scans(counter) = updateLineScan(obj);
            counter = counter+1;
        catch
        end
        clear obj;
    end
    
    outputTable = generate_data(scans);
    counter = 1;
    clear scans
    
    
    [J,~] = size(outputTable);
    [~,filename] = fileparts(cell_dirs{i});
    
    for j=1:J
        outputTable{j,1} = filename;
    end
    
    temp = cell(1,22);
    data = [data;outputTable;temp];
    disp([filename ' finished']);
   
end
mat2clip(data);
end


function outputTable = generate_data(scans)
for i=1:length(scans)

    trace = scans(i).normGoR;
    channelName = 'Green/Red';
    showPlots = 1;
    somaCoords = [0 0 0];
    
    [traceLinearity(i), linearSumTrace, measuredPeakTrace, singlePeak(i), rms]= scans(i).linearity(trace, scans(i).expParams.spikeTimes);

    trainPeak(i) = max(measuredPeakTrace);
    expectedPeak(i) = max(linearSumTrace);
    
    if showPlots == 1
        figure('units','normalized','outerposition',[0.2 0.2 .8 .8]);
        hold on;
        plot(scans(i).time,linearSumTrace,'r');
        plot(scans(i).time,smooth(trace,1),'k');
        plot(scans(i).time,measuredPeakTrace,'b');
        legend({'Expected','Trace','Measured Signal'});
        xlabel('Time (ms)');
        xticks(sort([0 0.5 1 1.5 scans(i).expParams.spikeTimes]));
        title([scans(i).name  ' ' channelName]);
        set(gca,'YGrid', 'on','GridLineStyle', '-');
        set(gca,'fontsize',16,...
            'XMinorTick','on',...
            'YMinorTick','on',...
            'TickDir','out');
        xlim([0 floor(scans(1).time(end)*100)/100]);
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
    outputTable{i,5} = scans(i).date;
    outputTable{i,6} = scans(i).name; %scan
    outputTable{i,7} = []; %loc
    outputTable{i,8} = []; %branch num
    outputTable{i,9} = length(scans(i).expParams.spikeTimes); %num. spikes
    outputTable{i,10} = scans(i).expParams.spikeTimes(end)-scans(i).expParams.spikeTimes(end-1); %train freq.
    outputTable{i,11} = x(i);
    outputTable{i,12} = y(i);
    outputTable{i,13} = z(i);
    outputTable{i,14} = distance(i); %Eucl. Dist.
    outputTable{i,17} = rms(1); %Single dect.
    outputTable{i,18} = rms(2); %Train dect.
    outputTable{i,19} = singlePeak(i); %Amp. (single)
    outputTable{i,20} = trainPeak(i); %Amp. (train)
    outputTable{i,21} = expectedPeak(i); % Amp. (Exp.)
    outputTable{i,22} = traceLinearity(i); %Obs/exp.
end
end 
%Save cell table to clipboard
