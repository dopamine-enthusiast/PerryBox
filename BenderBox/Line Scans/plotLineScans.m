function plotLineScans(baselineStartTime,baselineEndTime)

if nargin ~=2
    baselineStartTime = 0;
    baselineEndTime = 0;
end


%load scans
loadDirs = uipickfiles;


counter = 1;
for i=1:length(loadDirs)
    
    if isdir(loadDirs{i}) == 1
        try
            scans(counter) = lineScan(loadDirs{i});
            counter = counter+1;
        catch
            disp(['Failed to import ' loadDirs{i}]);
        end
    else
        try
            load(loadDirs{i});
            scans(counter) = obj;
            counter = counter+1;
        catch
            disp(['Failed to import ' loadDirs{i}]);
        end
    end
end

%Set Colormap
c = [0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];

rawTraces =[];
normTraces = [];
traces = [];

clear rawTraces normTraces traces
%% plot Green

if ~isempty(scans(i).green)
    counter = 1;
    figure();
    hold on;
    for i=1:length(scans)
        clear rawTraces normTraces traces j
        
        rawTraces = sum(scans(i).green,3);
        channel = 'Green';
        majorColor = c(i,:);
        minorColor = [.7,1,.7];
        obj = scans(i);
        
        %Everything that follows is standard to all line scan plots
        if nargin == 2 && baselineEndTime-baselineStartTime > 0
            for j=1:length(rawTraces(:,1))
                normTraces(j,:) = normalize(obj,rawTraces(j,:),baselineStartTime,baselineEndTime);
            end
            title(['Norm ' channel],'FontSize',14);
            ylabel('dF/F','FontSize',14);
            traces = normTraces;
           
        else
            title(['Raw ' channel],'FontSize',14);
            ylabel('Fluorescence','FontSize',14);
            traces = rawTraces;
        end
        
        if length(scans) == 1
            for j=1:length(traces(:,1))
                plot(obj.time,traces(j,:),'color',minorColor);
            end
        end
        
        m = smooth(mean(traces),3);
        plot(obj.time,m,'color',majorColor);
        legendnames{counter} = obj.name;
        counter = counter+1;
        
        clickableLegend(legendnames,'FontSize',10,'location','southoutside');
        
    end
    xlabel('Time (s)','FontSize',14);
    figurePresets;
end

%% plot red
if ~isempty(scans(i).red)
    counter = 1;
    figure();
    hold on;
    for i=1:length(scans)
        clear rawTraces normTraces traces j
        
        rawTraces = sum(scans(i).red,3);
        channel = 'Red';
        majorColor = c(i,:);
        minorColor = [1,.85,.85];
        obj = scans(i);
        
        %Everything that follows is standard to all line scan plots
        if nargin == 2 && baselineEndTime-baselineStartTime > 0
            for j=1:length(rawTraces(:,1))
                normTraces(j,:) = normalize(obj,rawTraces(j,:),baselineStartTime,baselineEndTime);
            end
            title(['Norm ' channel],'FontSize',14);
            ylabel('dF/F','FontSize',14);
            traces = normTraces;
            
            
        else
            title(['Raw ' channel],'FontSize',14);
            ylabel('Fluorescence','FontSize',14);
            traces = rawTraces;
        end
        
        if length(scans) == 1
            for j=1:length(traces(:,1))
                plot(obj.time,traces(j,:),'color',minorColor);
            end
        end
        
        m = smooth(mean(traces),3);
        plot(obj.time,m,'color',majorColor);
        legendnames{counter} = obj.name;
        counter = counter+1;
        
        clickableLegend(legendnames,'FontSize',10,'location','southoutside');
        
    end
    xlabel('Time (s)','FontSize',14);
    figurePresets;
end

%% plot green over red
if ~isempty(scans(i).red) && ~isempty(scans(i).green)
    counter = 1;
    figure();
    hold on;
    for i=1:length(scans)
        clear rawTraces normTraces traces j
        
        rawTraces = sum(scans(i).green,3)./ sum(scans(i).red,3);
        channel = 'G/R';
        majorColor = c(i,:);
        minorColor = [.85,.85,1];
        obj = scans(i);
        
        %Everything that follows is standard to all line scan plots
        if nargin == 2 && baselineEndTime-baselineStartTime > 0
            for j=1:length(rawTraces(:,1))
                normTraces(j,:) = rawTraces(j,:)-getBaseline(obj,rawTraces(j,:),baselineStartTime,baselineEndTime);                                
            end
            title(['Norm ' channel],'FontSize',14);
            ylabel('dF/F','FontSize',14);
            traces = normTraces;
        
            
        else
            title(['Raw ' channel],'FontSize',14);
            ylabel('Fluorescence','FontSize',14);
            traces = rawTraces;
        end
        
        if length(scans) == 1
            for j=1:length(traces(:,1))
                plot(obj.time,traces(j,:),'color',minorColor);
            end
        end
        
        m = smooth(mean(traces),3);
        plot(obj.time,m,'color',majorColor);
        legendnames{counter} = obj.name;
        counter = counter+1;
        
        clickableLegend(legendnames,'FontSize',10,'location','southoutside');
        
    end
    xlabel('Time (s)','FontSize',14);
    figurePresets;
end









