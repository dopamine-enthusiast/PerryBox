function backpropComparisonV2(sheet)

%Eucl. dist. 13
%nexus 24
%Corrected dist 25








cells = cellSort(sheet,24);


binCenters =-200:100:200;
% binCenters = 100:100:500;

bwidth = 50;
axisLabels.ylims = [0 5];
axisLabels.ylabel = 'dG/G';
axisLabels.xlabel = 'Distance from Nexus';

compareTrainAmp(cells,3,binCenters,bwidth,axisLabels);


statistics = stats(cells,binCenters,bwidth);

result = averageValues(cells,100);
mat2clip(result);

binCenters =-200:100:350;
bwidth = 50;
axisLabels.ylims = [0 20];
axisLabels.ylabel = 'obs/exp';
axisLabels.xlabel = 'Distance from Nexus';

% compareTrainAmp(cells,4,binCenters,bwidth,axisLabels);



end

%-----Local Functions-----%

function figFormat
set(gca,'fontsize',16,...
    'TickDir','out',...
    'FontName','arial',...
    'box','off');


end


function cells = cellSort(sheet,distIdx)

%dist is 13;
%Distance from  soma 13
%distance from nexus 24
%Corrected distance 25



cells(1).name = sheet{1,1};
cells(1).genotype = sheet{1,2};
cells(1).data = [...
    sheet{1,9};...%Train ISI
    sheet{1,16};...%single amp
    sheet{1,17};...%train amp
    sheet{1,19};...%Obs/exp
    sheet{1,distIdx}];%Distance
%Organize data by cells
for i = 2:length([sheet{:,9}])
    newCell = 1;
    for j = 1:length(cells)
        if strcmp(sheet{i,1},cells(j).name)
            cells(j).data = [cells(j).data,[...
                sheet{i,9};...%Train ISI
                sheet{i,16};...%single amp
                sheet{i,17};...%train amp
                sheet{i,19};...%Obs/exp
                sheet{i,distIdx}]];%Distance
            newCell = 0;
        end
    end
    
    if newCell %if cell is new, initialize new cell in the array
        idx = length(cells)+1;
        cells(idx).name = sheet{i,1};
        cells(idx).genotype = sheet{i,2};
        cells(idx).data = [...
            sheet{i,9};...%Train ISI
            sheet{i,16};...%single amp
            sheet{i,17};...%train amp
            sheet{i,19};...%Obs/exp
            sheet{i,distIdx}];%Distance
    end
    
end
end

function compareTrainAmp(cells,dataType,binCenters,bwidth,axisLabels)

% Figure out the genotype groups
celltypes = unique({cells.genotype});
for i=1:length(celltypes)
    idx = cellfun(@(x) strcmp(celltypes{i},x),{cells.genotype});
    groups(i).cells = cells(idx);
    groups(i).name = celltypes{i};
end

%Figure out the ISIs used
data = cells.data;
ISIs = unique(data(1,:));


%Set colormap
c = [0 0 0;...
    0 0.6824 0.9373;...
     0.8863 0.7843 0.2824;...
    0.8863 0.2824 0.4824];
c2 = [0.5 0.5 0.5;...
    0.6392    0.8784    0.9686;...
    0.8863 0.7843 0.2824;...
    0.8863 0.2824 0.4824];

%plot amplitude vs distance at each ISI for each group
for i=1:length(groups)
    
    figure;    
    hold on;
    
    for j=1:length(ISIs) %For each ISI     
        for k=1:length(groups(i).cells) %
            data = groups(i).cells(k).data;
            idx = data(1,:) == ISIs(j);
            temp = data(:,idx);
            clear idx
            for l=1:length(binCenters)
                idx = temp(5,:) > binCenters(l)-bwidth & temp(5,:) < binCenters(l)+bwidth; %
                means(l) = mean(temp(dataType,idx));
                clear idx;
            end
            grandMeanTrain(k,:) = means;
            clear means;
        end
        errorbar(binCenters,nanmean(grandMeanTrain),nansem(grandMeanTrain),...
            '-o',...
            'linewidth',1,...
            'color',c(j+1,:),...
            'MarkerEdgeColor',[1 1 1],...
            'MarkerFaceColor',c(j+1,:),...
            'MarkerSize',8,...
            'CapSize',0);
        names{j} = [num2str(ISIs(j)) 'ms ISI'];
    end
    
    if dataType == 3
        %Create Single plot

        for j=1:length(groups(i).cells)
            singles = averageSingleAmp(groups(i).cells(j));
            for k=1:length(binCenters)
                idx = singles(2,:) > binCenters(k)-50 & singles(2,:) < binCenters(k)+50; %
                means(k) = mean(singles(1,idx));
            end
            grandMeanSingle(j,:) = means;
            clear means;
            
        end
        errorbar(binCenters,nanmean(grandMeanSingle),nansem(grandMeanSingle),...
                '-o',...
                'linewidth',1,...
                'color','k',...
                'MarkerEdgeColor',[1 1 1],...
                'MarkerFaceColor','k',...
                'MarkerSize',8,...
                'CapSize',0); 

        title([groups(i).name ' Amplitude by Distance']);
        figFormat;
        ylim(axisLabels.ylims);
        xlim([binCenters(1)-10 binCenters(end)+10]);
        ylabel(axisLabels.ylabel);
        xlabel(axisLabels.xlabel);
        names{length(names)+1} = 'Single';
        
    end
    legend(names,'box','off');
end
%For each ISI, compare amplitude vs distance

%If plot data type is amplitude, plot the single amplitude comparisons
if dataType == 3
    figure;
    hold on;
    for i=1:length(groups)
        for j=1:length(groups(i).cells)
            singles = averageSingleAmp(groups(i).cells(j));
            for k=1:length(binCenters)
                idx = singles(2,:) > binCenters(k)-bwidth & singles(2,:) < binCenters(k)+bwidth; %
                means(k) = mean(singles(1,idx));
            end
            grandMean(j,:) = means;


            meanTuft(j,i) = mean(singles(1,singles(2,:) > 100));

            clear means;
        end
        
        plot(binCenters,grandMean,'linewidth',0.5,'color',c2(i,:));
        
        errorbar(binCenters,nanmean(grandMean),nansem(grandMean),...
            '-o',...
            'color',c(i,:),...
            'linewidth',1,....
            'MarkerEdgeColor',[1 1 1],...
            'MarkerFaceColor',c(i,:),...
            'MarkerSize',8,...
            'CapSize',0);
        title('Single Amplitude')
        figFormat
        ylabel(axisLabels.ylabel)
        xlabel(axisLabels.xlabel);
        ylim(axisLabels.ylims);
        xlim([binCenters(1)-10 binCenters(end)+10]);
        title(['\color[rgb]{0 0 0}' groups(1).name ' vs '  '\color[rgb]{0    0.6824    0.9373}' groups(2).name  ' \color[rgb]{0 0 0}(Single)']);
        legend({groups.name},'box','off');
        clear grandMean;
    end
end

%compare data between groups for each ISI
for i= 1:length(ISIs)
    ISI = ISIs(i);
    
    figure
    hold on;
    % c = get(gca,'ColorOrder');
    for j=1:length(groups)
        for k=1:length(groups(j).cells)
            idx = groups(j).cells(k).data(1,:) == ISI;
            data = groups(j).cells(k).data(:,idx);
            
            for l=1:length(binCenters)
                idx = data(5,:) > binCenters(l)-bwidth & data(5,:) < binCenters(l)+bwidth; %
                means(l) = mean(data(dataType,idx));
            end
            grandMean(k,:) = means;
            meanTuft(k,i) = mean(data(dataType,data(5,:) > 100));
            
            tempBins = binCenters;
            l=2;
            while l < length(means) %remove NaN indicies
                
                if isnan(means(l))
                    means = means([1:l-1,l+1:end]);
                    tempBins = tempBins([1:l-1,l+1:end]);
                else
                    l = l+1;
                end
                
            end
            %         plot(tempBins,means,'color',c2(i,:),'linewidth',0.5);
            clear tempBins means;
            
        end
        
        plot(binCenters,grandMean,'linewidth',0.5,'color',c2(j,:));
        
        errorbar(binCenters,nanmean(grandMean),nansem(grandMean),...
            '-o',...
            'linewidth',1,...
            'color',c(j,:),...
            'MarkerEdgeColor',[1 1 1],...
            'MarkerFaceColor',c(j,:),...
            'MarkerSize',8,...
            'CapSize',0);
        ylabel(axisLabels.ylabel)
        xlabel(axisLabels.xlabel);
        ylim(axisLabels.ylims);
        xlim([binCenters(1)-10 binCenters(end)+10]);
        clear grandMean;
    end
    
    legend({groups.name},'box','off');
    title(['\color[rgb]{0 0 0}' groups(1).name ' vs '  '\color[rgb]{0    0.6824    0.9373}' groups(2).name  ' \color[rgb]{0 0 0}(' num2str(ISI) 'ms ISI)']);
    figFormat
%     print([num2str(ISI) ' Train Plot.eps'],'-depsc')
    set(gca,'fontsize',16,...
    'TickDir','out');
end

end


function result = averageValues(cells,distanceThresh)

% % Figure out the genotype groups
% celltypes = unique({cells.genotype});
% for i=1:length(celltypes)
%     idx = cellfun(@(x) strcmp(celltypes{i},x),{cells.genotype});
%     groups(i).cells = cells(idx);
%     groups(i).name = celltypes{i};
% end

%Figure out the ISIs used
data = cells.data;
ISIs = unique(data(1,:));


result = {};

for i = 1:length(cells)
    result{i,1} = cells(i).name;
    result{i,2} = cells(i).genotype;
    
    
    singles = averageSingleAmp(cells(i));
    idx = singles(2,:) > distanceThresh;
    result{i,3} = nanmean(singles(1,idx));
    
   
    
    for j=1:length(ISIs)
        
        idx = cells(i).data(1,:) == ISIs(j);
        data = cells(i).data(:,idx);
        
        idx2 = data(5,:) > distanceThresh;
        result{i,j+3} = nanmean(data(3,idx2));
        result{i,j+3+length(ISIs)} = nanmean(data(4,idx2));
        
    end
    
end




end



function results = stats(cells,binCenters,bwidth)


dataType = 3;

% Figure out the genotype groups
celltypes = unique({cells.genotype});
for i=1:length(celltypes)
    idx = cellfun(@(x) strcmp(celltypes{i},x),{cells.genotype});
    groups(i).cells = cells(idx);
    groups(i).name = celltypes{i};
end

%Figure out the ISIs used
data = cells.data;
ISIs = unique(data(1,:));

for i=1:length(groups)
    
    for j=1:length(ISIs) %For each ISI
        for k=1:length(groups(i).cells) %
            data = groups(i).cells(k).data;
            idx = data(1,:) == ISIs(j);
            temp = data(:,idx);
            clear idx
            for l=1:length(binCenters)
                idx = temp(5,:) > binCenters(l)-bwidth & temp(5,:) < binCenters(l)+bwidth; %
                means(l) = mean(temp(dataType,idx));
                
                clear idx;
            end
            
            
            
            
            
            grandMeanTrain(k,:) = means;
            clear means;
        end
        groups(i).ISI(j).ISI = ISIs(j);
        groups(i).ISI(j).data = grandMeanTrain;
        
    end
    %Create Single plot
    
    for j=1:length(groups(i).cells)
        singles = averageSingleAmp(groups(i).cells(j));
        for k=1:length(binCenters)
            idx = singles(2,:) > binCenters(k)-50 & singles(2,:) < binCenters(k)+50; %
            means(k) = mean(singles(1,idx));
        end
        groups(i).single(j,:)= means;
        clear means;
    end
    
end

for i=1:length(ISIs)
    stats.ISI(i).ISI = ISIs(i);
    for j = 1:length(binCenters)
        alpha = 1-(1-0.05)^(1/length(binCenters));
        stats.ISI(i).pValues(j) = ranksum(groups(1).ISI(i).data(:,j),groups(2).ISI(i).data(:,j));
        stats.ISI(i).sig(j) = stats.ISI(i).pValues(j) < alpha;
    end
    
    
    
    
end

for i = 1:length(binCenters)
    alpha = 1-(1-0.05)^(1/length(binCenters));
    
    stats.single.pValues(i) = ranksum(groups(1).single(:,i),groups(2).single(:,i));
    stats.single.sig(i) = stats.single.pValues(i) < alpha;
    
end
    

results.groups = groups;
results.stats = stats;
end














function [means, grandMean] = binData(data,distance,binCenters,bwidth)

for i=1:length(data(:,1))                 
    for j=1:length(binCenters)
        idx = distance > binCenters(j)-bwidth & distance < binCenters(j)+bwidth; %
        means(j) = mean(data(idx));
    end
    grandMean(i,:) = means;
end

end









function singles = averageSingleAmp(cell)

distances = unique(cell.data(5,:));
singles = zeros(2,length(distances));
for j=1:length(distances)
    singles(1,j) = mean(cell.data(2,distances(j) == cell.data(5,:)));
    singles(2,j) = distances(j);
end

end



function compareSingles(cells)
celltypes = unique({cells.genotype});

for i=1:length(celltypes)
    idx = cellfun(@(x) strcmp(celltypes{i},x),{cells.genotype});
    groups(i).cells = cells(idx);
    groups(i).name = celltypes{i};
end

figure
hold on;
% c = get(gca,'ColorOrder');
c = [0 0 0;0    0.6824    0.9373];
binCenters =-200:100:350;
bWidth = 50;

for i=1:length(groups)
    for j=1:length(groups(i).cells)
        singles = averageSingleAmp(groups(i).cells(j));
        for k=1:length(binCenters)
            idx = singles(2,:) > binCenters(k)-bWidth & singles(2,:) < binCenters(k)+bWidth; %
            means(k) = mean(singles(1,idx));
        end
        grandMean(j,:) = means;
        
        
        meanTuft(j,i) = mean(singles(1,singles(2,:) > 100));
        
        clear means;
    end
    errorbar(binCenters,nanmean(grandMean),nansem(grandMean),...
        '-o',...
        'color',c(i,:),...
        'linewidth',1,....
        'MarkerEdgeColor',[1 1 1],...
        'MarkerFaceColor',c(i,:),...
        'MarkerSize',8,...
        'CapSize',0);
    title('Single Amplitude')
    ylabel('dG/G')
    xlabel('Distance from Soma (um)');
    ylim([0 5]);
    xlim([binCenters(1)-10 binCenters(end)+10]);
    title(['\color[rgb]{0 0 0}' groups(1).name ' vs '  '\color[rgb]{0    0.6824    0.9373}' groups(2).name  ' \color[rgb]{0 0 0}(Single)']);
    clear grandMean;
end

% legend({groups.name});
set(gca,'fontsize',16);
print('Single Plot.eps','-depsc')
end

function compareObsOverExpected(cells,ISI)

celltypes = unique({cells.genotype});

for i=1:length(celltypes)
    idx = cellfun(@(x) strcmp(celltypes{i},x),{cells.genotype});
    groups(i).cells = cells(idx);
    groups(i).name = celltypes{i};
end

figure
hold on;
c = get(gca,'ColorOrder');
c2 =[0.7020    0.8510    1.0000;1.0000    0.7020    0.7020];
binCenters =50:50:500;

for i=1:length(groups)
    for j=1:length(groups(i).cells)
        idx = groups(i).cells(j).data(1,:) == ISI;
        data = groups(i).cells(j).data(:,idx);
        
        for k=1:length(binCenters)
            idx = data(5,:) > binCenters(k)-50 & data(5,:) < binCenters(k)+50; %
            means(k) = mean(data(4,idx));
        end
        grandMean(j,:) = means;
        
        
        tempBins = binCenters;
        k=2;
        while k < length(means) %remove NaN indicies
            
            if isnan(means(k))
                means = means([1:k-1,k+1:end]);
                tempBins = tempBins([1:k-1,k+1:end]);
            else
                k = k+1;
            end
            
        end
        plot(tempBins,means,'color',c2(i,:),'linewidth',0.5);
        clear tempBins means;
        
    end
    errorbar(binCenters,nanmean(grandMean),nansem(grandMean),'color',c(i,:),'linewidth',2)
    clear grandMean;
end

legend({groups.name});
title(num2str(ISI));


end

function compareISIs(cells)

%Identify ISIs
catData = [];
for i=1:length(cells)
    catData = [catData cells(i).data] ;
end
ISIs = unique(catData(1,:));

%Sort into groups by genotype
celltypes = unique({cells.genotype});
for i=1:length(celltypes)
    idx = cellfun(@(x) strcmp(celltypes{i},x),{cells.genotype});
    groups(i).cells = cells(idx);
    groups(i).name = celltypes{i};
end


binCenters =50:50:550;


%This is a complete mess of loops, but it works

for i=1:length(groups)
    figure;
    hold on;
    for j=1:length(ISIs) %For each ISI
        for k=1:length(groups(i).cells) %
            data = groups(i).cells(k).data;
            idx = data(1,:) == ISIs(j);
            temp = data(:,idx);
            clear idx
            for l=1:length(binCenters)
                idx = temp(5,:) > binCenters(l)-50 & temp(5,:) < binCenters(l)+50; %
                means(l) = mean(temp(3,idx));
                clear idx;
            end
            grandMeanTrain(k,:) = means;
            clear means;
        end
        plot(binCenters,nanmean(grandMeanTrain));
    end
    
    %Create Single plot
    for j=1:length(groups(i).cells)
        singles = averageSingleAmp(groups(i).cells(j));
        for k=1:length(binCenters)
            idx = singles(2,:) > binCenters(k)-50 & singles(2,:) < binCenters(k)+50; %
            means(k) = mean(singles(1,idx));
        end
        grandMeanSingle(j,:) = means;
        clear means;
    end
    plot(binCenters,nanmean(grandMeanSingle),'k');
    
    title([groups(i).name ' Amplitude by Distance']);
    
end

for i=1:length(groups)
    figure;
    hold on;
    for j=1:length(ISIs) %For each ISI
        for k=1:length(groups(i).cells) %
            data = groups(i).cells(k).data;
            idx = data(1,:) == ISIs(j);
            temp = data(:,idx);
            clear idx
            for l=1:length(binCenters)
                idx = temp(5,:) > binCenters(l)-50 & temp(5,:) < binCenters(l)+50; %
                means(l) = mean(temp(4,idx));
                clear idx;
            end
            grandMeanTrain(k,:) = means;
            clear means;
        end
        errorbar(binCenters,nanmean(grandMeanTrain),nansem(grandMeanTrain));
    end
    
    
    title([groups(i).name ' Obs/Exp by Distance']);
    
end
end

function plotSingles(cells,name)

figure
hold on;

binCenters = 0:50:600;

for i=1:length(cells)
    singles = averageSingleAmp(cells(i));
    %     binCenters = ceil(min(singles(2,:))/50)*50 :50: ceil(max(singles(2,:))/50)*50; %Define bins every 50um
    
    for j=1:length(binCenters)
        idx = singles(2,:) > binCenters(j)-50 & singles(2,:) < binCenters(j)+50; %
        means(j) = mean(singles(1,idx));
    end
    grandMean(i,:) = means;
    
    
    
    tempBins = binCenters;
    j=2;
    while j < length(means) %remove NaN indicies
        
        if isnan(means(j))
            means = means([1:j-1,j+1:end]);
            tempBins = tempBins([1:j-1,j+1:end]);
        else
            j = j+1;
        end
        
    end
    plot(tempBins,means,'color',[.7,.7,.7]);
    clear tempBins means;
    
end


errorbar(binCenters,nanmean(grandMean),nansem(grandMean),'k','linewidth',1.5);
title(name)
end










