function scans = loadLineScans
% Last edit: Perry Spratt 01/10/2017

% Launch a file picker UI, load or import line scans, return as array of
% line scans

dirs = {};
dirs = uipickfiles('FilterSpec','LineScan*');
counter = 1;
for i=1:length(dirs)
    
    if isdir(dirs{i}) == 1
        try
            scans(counter) = lineScan(dirs{i});
            counter = counter+1;
        catch
            disp(['Failed to import ' dirs{i}]);
        end
    else
        try
            load(dirs{i});
            %update lineScan objects
            scans(counter) = obj.updateLineScanXML;
            scans(counter) = updateLineScan(obj);
            
%             [~, filename] = fileparts(dirs{i});
%             scans(counter).name = filename(1:end-4);
            counter = counter+1;
        catch
            disp(['Failed to import ' dirs{i}]);
        end
    end
end