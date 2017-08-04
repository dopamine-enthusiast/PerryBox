function importLinearity

lineScans = subdir(fullfile(pwd,'*ls_obj.mat'));
% Get ISI information
for i=1:length(lineScans)
    load(lineScans(i).name)
    lsObj{i,1} = obj;
    lsObj{i,2} = input(['What is the ISI for ' lsObj{i,1}.name '?']);
end

[~, deepestFolder] = fileparts(pwd);

save([deepestFolder ' linearity.mat'],'lsObj');

for i=1:length([lsObj{:,1}])
    ISIsec = lsObj{i,2}./1000;
    spikeTimes = [.8, .8+ISIsec, .8+ISIsec*2];
%         try %GoverR linearity
%         trace = lsObj{i,1}.normalize(lsObj{i,1}.meanGoverR,.1,.2);
%         lsObj{i,3} = lsObj{i,1}.linearity(trace,.2,spikeTimes);
%         catch
%         end
        
        try % G linearity
        trace = lsObj{i,1}.normalize(lsObj{i,1}.meanGreen,.1,.2);
        lsObj{i,4} = lsObj{i,1}.linearity(trace,.2,spikeTimes);
        catch
        end
    
end

%sort by ISI
[order idx] = sort([lsObj{:,2}]);
lsObj(:,1) = lsObj(idx,1);
lsObj(:,2) = lsObj(idx,2);
lsObj(:,3) = lsObj(idx,3);
lsObj(:,4) = lsObj(idx,4);

figure();
h = plot([lsObj{:,2}],[lsObj{:,4}]);

save([deepestFolder ' linearity.mat'],'lsObj')
saveas(h,[deepestFolder ' linearity.fig']);
close all;
% importAndPlotMultipleLineScans;
% plotMultipleLineScansGreenNorm;
end


