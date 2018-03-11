function riboGCaMP_analysis()

%This function pulls out relevant data from selected linescans and saves
%data to the clipboard for adding to spreadsheet
%example spreadsheet: https://docs.google.com/spreadsheets/d/1elJ_9HW6ENi8D14uhngSU-gYchyhgQMe3btaM7QcHl8/edit?hl=en#gid=0


scans = loadLineScans;

%Go through each line scans pull out data for analysis
for i=1:length(scans)
    
    trace = scans(i).normGreen;
    
    [scan_x, scan_y, scan_z, scan_distance] = getLineScanLocation(scans(i));
    
    % Add date to a cell table
    [~,cellname] = fileparts(pwd);
    
    
    figure;
    hold on;
    plot(trace,'color',[0.8 0.8 0.8]);
    plot(smooth(trace,5),'k');
    title(['Max dF/F: ' num2str(max(smooth(trace,5)))]);
    
    outputTable{i,1} = cellname;
    outputTable{i,2} = []; %genotype
    outputTable{i,3} = scans(i).date;
    outputTable{i,4} = scans(i).name; %scan name
    outputTable{i,5} = scan_x;
    outputTable{i,6} = scan_y;
    outputTable{i,7} = scan_z;
    outputTable{i,8} = scan_distance;
    outputTable{i,9} = 0; %apical vs Basal
    outputTable{i,10} = []; %nums spikes
    outputTable{i,11} = max(smooth(trace,5));
    

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



