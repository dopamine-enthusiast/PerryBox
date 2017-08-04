function outputTable = backpropAnalysis

scans = loadLineScans;
somaCoords = eval(['[' str2mat(inputdlg('Enter Soma Coordinates','Soma Coordinates',1,{'0,0,0'})) ']']);


for i=1:length(scans)

            trace = scans(i).normGreen;
            channelName = 'G/R';

    
    [traceLinearity(i), linearSumTrace, measuredPeakTrace, singlePeak(i)]= scans(i).linearity(trace, scans(i).expParams.spikeTimes);
    
    trainPeak(i) = max(measuredPeakTrace);
    expectedPeak(i) = max(linearSumTrace);
    
        figure;
        hold on;
        plot(scans(i).time,linearSumTrace,'r');
        plot(scans(i).time,smooth(trace,1),'k');
        plot(scans(i).time,measuredPeakTrace,'b');
        legend({'Expected','Trace','Measured Signal'});
        xlabel('Time (ms)');
        xticks(sort([0 0.5 1 1.5 scans(i).expParams.spikeTimes]));
        title([scans(i).name  ' ' channelName]);
        set(gca,'YGrid', 'on','GridLineStyle', '-');      
        xlim([0 floor(scans(1).time(end)*100)/100]);
        hold off;
    
    
    linearSum = [];
    measuredPeak = [];
    
    isi(i) = scans(i).expParams.spikeTimes(end)-scans(i).expParams.spikeTimes(end-1);
    
    x(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,15}.Attributes.value)-somaCoords(1);
    y(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,16}.Attributes.value)-somaCoords(2);
    z(i) = str2num(scans(i).xmlData.PVScan.Sequence{1,1}.Frame.PVStateShard.Key{1,17}.Attributes.value)-somaCoords(3);
    
    distance(i) = pdist([0,0,0;x(i),y(i),z(i)]);
   
    
    outputTable{i,1} = scans(i).name;
    outputTable{i,2} = scans(i).expParams.spikeTimes(end)-scans(i).expParams.spikeTimes(end-1);
    outputTable{i,3} = x(i);
    outputTable{i,4} = y(i);
    outputTable{i,5} = z(i);
    outputTable{i,6} = distance(i);
    outputTable{i,7} = singlePeak(i);
    outputTable{i,8} = trainPeak(i);
    outputTable{i,9} = expectedPeak(i);
    outputTable{i,10} = traceLinearity(i);
end


mat2clip(outputTable);



