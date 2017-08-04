function backpropComparison(spreadsheet)

%Expects inputs from https://docs.google.com/spreadsheets/d/1elJ_9HW6ENi8D14uhngSU-gYchyhgQMe3btaM7QcHl8/edit#gid=0



%Get title and file description
description = inputdlg('Enter Title','Enter Title');

%%%%%Set what dimension to Compare%%%%%%%%%
filter = 2;
% cell 1
% Genotype 2
% celltype 3
% num spikes 8
% train freq. 9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Set what distance is aligned to%%%%%%%%
%dist = 13;
%Distance from  soma 13
%distance from nexus 24
%Corrected distance 25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Set bin width%%%%%%%%%%%%%%%%%%%%%%%%%%
binWidth = 50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Set Axis Limits%%%%%%%%%%%%%%%%%%%%%%%%%%
xlimits = [50 400];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







binCenters = ceil(min([spreadsheet{:,dist}])./binWidth)*binWidth:...
    binWidth:...
    floor(max([spreadsheet{:,dist}])./binWidth)*binWidth;





%%
plotType = 16; %single
f1 = figure;

%Set Color map
c = get(gca,'ColorOrder');

distances{1} = [];
data{1} = [];
comparisons= {};
comparisons{1} = num2str(spreadsheet{1,filter});

for i = 1:length([spreadsheet{:,dist}]) 
%Determine what category the next point belongs to 
    for j=1:length(comparisons)
        if strcmp(comparisons{j},num2str(spreadsheet{i,filter}))
            cchoice = j;
            break;
        elseif j ==length(comparisons)
            comparisons{j+1} = num2str(spreadsheet{i,filter});
            distances{j+1} = [];
            data{j+1} = [];
            cchoice = j+1;
        end
    end
    if [spreadsheet{i,14}] == 0%If a single transient were not detected, highlight it by leavin it open
        scatter([spreadsheet{i,dist}],[spreadsheet{i,plotType}],...
            'MarkerFaceColor','none',...
            'MarkerEdgeColor',c(cchoice,:));
        distances{cchoice} = [distances{cchoice} [spreadsheet{i,dist}]];
        data{cchoice} = [data{cchoice} [spreadsheet{i,plotType}]];
    else        
        h(cchoice) = scatter([spreadsheet{i,dist}],[spreadsheet{i,plotType}],...
            'MarkerFaceColor',c(cchoice,:),...
            'MarkerEdgeColor',[1 1 1]);        
        distances{cchoice} = [distances{cchoice} [spreadsheet{i,dist}]];
        data{cchoice} = [data{cchoice} [spreadsheet{i,plotType}]];  
    end
    hold on;
end
legend(h,comparisons);

%Add mean values
for i=1:length(distances)
    means = [];
    sem = [];
    for j=1:length(binCenters)
        
        index = find(distances{i} > binCenters(j)-binWidth & distances{i} < binCenters(j)+binWidth);
        means(j) = mean(data{i}(index));
        sem(j) = std(data{i}(index))/sqrt(length(data{i}(index)));
    end
    sem(isnan(sem)) = 0;
    means(isnan(means)) = 0;
    errorbar(binCenters(1:end),means',sem','color',c(i,:),'LineWidth',2);
end

title([description{1} ' Single']);
ylabel('dG/G');
xlabel('Distance');
xlim(xlimits);

sem = [];
means = [];
distances = {};
data={};
distances{1} = [];
data{1} = [];



%%
plotType = 17; %Train
f2 = figure
c = get(gca,'ColorOrder');

comparisons= {};
comparisons{1} = num2str(spreadsheet{1,filter});
distances{1} = [];
data{1} = [];

for i = 1:length([spreadsheet{:,dist}]) 
%Determine what category the next point belongs to 
    for j=1:length(comparisons)
        if strcmp(comparisons{j},num2str(spreadsheet{i,filter}))
            cchoice = j;
            break;
        elseif j ==length(comparisons)
            comparisons{j+1} = num2str(spreadsheet{i,filter});
            distances{j+1} = [];
            data{j+1} = [];
            cchoice = j+1;
        end
    end

    if [spreadsheet{i,15}] == 0 %If a train transient was not detected, highlight it by leavin it open
        scatter([spreadsheet{i,dist}],[spreadsheet{i,plotType}],...
            'MarkerFaceColor','none',...
            'MarkerEdgeColor',c(cchoice,:));
% Kevin's method        
%         scatter([spreadsheet{i,dist}],10,...
%             'MarkerFaceColor','none',...
%             'MarkerEdgeColor',c(cchoice,:));        
        distances{cchoice} = [distances{cchoice} [spreadsheet{i,dist}]];
        data{cchoice} = [data{cchoice} [spreadsheet{i,plotType}]];
    else        
        h(cchoice) = scatter([spreadsheet{i,dist}],[spreadsheet{i,plotType}],...
            'MarkerFaceColor',c(cchoice,:),...
            'MarkerEdgeColor',[1 1 1]);        
        distances{cchoice} = [distances{cchoice} [spreadsheet{i,dist}]];
        data{cchoice} = [data{cchoice} [spreadsheet{i,plotType}]];  
    end
    hold on;
end
legend(h,comparisons);
% Add binned y values for every bin distance
% figure
% hold on;
 
for i=1:length(distances)
    means = [];
    sem = [];
    for j=1:length(binCenters)
        
        index = find(distances{i} > binCenters(j)-binWidth & distances{i} < binCenters(j)+binWidth);
        means(j) = mean(data{i}(index));
        sem(j) = std(data{i}(index))/sqrt(length(data{i}(index)));
    end
    sem(isnan(sem)) = 0;
    means(isnan(means)) = 0;
    errorbar(binCenters(1:end),means',sem','color',c(i,:),'LineWidth',2);
end

title([description{1} ' Train']);
ylabel('dG/G');
xlabel('Distance');
xlim(xlimits);

sem = [];
means = [];
distances = {};
data={};
distances{1} = [];
data{1} = [];

%%
plotType = 19; %obs/exp
f3 = figure;
c = get(gca,'ColorOrder');

comparisons= {};
comparisons{1} = num2str(spreadsheet{1,filter});
distances{1} = [];
data{1} = [];

for i = 1:length([spreadsheet{:,dist}]) 
%Determine what category the next point belongs to 
    for j=1:length(comparisons)
        if strcmp(comparisons{j},num2str(spreadsheet{i,filter}))
            cchoice = j;
            break;
        elseif j ==length(comparisons)
            comparisons{j+1} = num2str(spreadsheet{i,filter});
            distances{j+1} = [];
            data{j+1} = [];
            cchoice = j+1;
        end
    end
    
    if [spreadsheet{i,14}] == 0 && [spreadsheet{i,15}] == 0 %If both a single and train transient were not detected, set to zero and do not save the point for averaging
        scatter([spreadsheet{i,dist}],0,...
            'MarkerFaceColor',c(cchoice,:),...
            'MarkerEdgeColor',[0 0 0]);
    elseif [spreadsheet{i,14}] == 0 && [spreadsheet{i,15}] == 1 %If both a single transient were not detected, highlight it by leavin it open
        scatter([spreadsheet{i,dist}],[spreadsheet{i,plotType}],...
            'MarkerFaceColor','none',...
            'MarkerEdgeColor',c(cchoice,:));
% Kevin's method        
%         scatter([spreadsheet{i,dist}],10,...
%             'MarkerFaceColor','none',...
%             'MarkerEdgeColor',c(cchoice,:));        
        distances{cchoice} = [distances{cchoice} [spreadsheet{i,dist}]];
        data{cchoice} = [data{cchoice} [spreadsheet{i,plotType}]];
    else        
        h(cchoice) = scatter([spreadsheet{i,dist}],[spreadsheet{i,plotType}],...
            'MarkerFaceColor',c(cchoice,:),...
            'MarkerEdgeColor',[1 1 1]);        
        distances{cchoice} = [distances{cchoice} [spreadsheet{i,dist}]];
        data{cchoice} = [data{cchoice} [spreadsheet{i,plotType}]];  
    end
    hold on;
end
legend(h,comparisons);
% Add binned y values for every bin distance
% figure
% hold on;
for i=1:length(distances)
    means = [];
    sem = [];
    for j=1:length(binCenters)
        
        index = find(distances{i} > binCenters(j)-binWidth & distances{i} < binCenters(j)+binWidth);
        means(j) = mean(data{i}(index));
        sem(j) = std(data{i}(index))/sqrt(length(data{i}(index)));
    end
    sem(isnan(sem)) = 0;
    means(isnan(means)) = 0;
    errorbar(binCenters(1:end),means',sem','color',c(i,:),'LineWidth',2);
end
title([description{1} ' Observed/Expected']);
ylabel('Obs/Exp');
xlabel('Distance');
xlim(xlimits);



distances{1} = [];
train{1} = [];
comparisons= {};
comparisons{1} = num2str(spreadsheet{1,filter});

distances{1} = [];
distances{2} = [];
train{1} = [];
train{2} = [];
comparisons= {};
comparisons{1} = 'Single';
comparisons{2} = num2str(spreadsheet{1,filter});

for i = 1:length([spreadsheet{:,dist}]) 
%Determine what category the next point belongs to 
    for j=1:length(comparisons)
        if strcmp(comparisons{j},num2str(spreadsheet{i,filter}))
            cchoice = j;
            break;
        elseif j ==length(comparisons)
            comparisons{j+1} = num2str(spreadsheet{i,filter});
            distances{j+1} = [];
            train{j+1} = [];
            cchoice = j+1;
        end
    end
    
    train{1} = [train{1} spreadsheet{i,14}];
    distances{1} = [distances{1} spreadsheet{i,dist}];
    train{cchoice} = [train{cchoice} spreadsheet{i,15}];
    distances{cchoice} = [distances{cchoice} spreadsheet{i,dist}];    
    
end



f4 = figure;
%Set Color map
c = [0.5 0.5 0.5];
c = vertcat(c,get(gca,'ColorOrder'));
hold on;
for i=1:length(distances)
    pFailure = []; 
    for j=1:length(binCenters)        
        index = distances{i} > binCenters(j)-binWidth & distances{i} < binCenters(j)+binWidth;
        pFailure(j) = 1-mean(train{i}(index));   
        
        stderr(j) = sqrt(pFailure(j)*(1-pFailure(j))./length(train{i}(index)));
    end
    plot(binCenters(1:end),pFailure*100,'-o','color',c(i,:),'LineWidth',2);
%     errorbar(binCenters(1:end),pFailure',stderr','color',c(i,:),'LineWidth',2);
end
legend(comparisons{1:end});
title([description{1} ' Percentage Failures']);
ylabel('Percentage Failures (%)');
xlabel('Distance');
xlim(xlimits);
ylim([-5 100]);


choice = questdlg('Save figures?', ...
	'Save', ...
	'Yes','No','No');

if strcmp(choice,'Yes')
    savefig(f1,[description{1} ' Single.fig']);
    saveas(f1,[description{1} ' Single.png']);
    savefig(f2,[description{1} ' Train.fig']);
    saveas(f2,[description{1} ' Train.png']);
    savefig(f3,[description{1} ' Obs_exp.fig']);
    saveas(f3,[description{1} ' Obs_exp.png']);
    savefig(f4,[description{1} ' pFailure.fig']);
    saveas(f4,[description{1} ' pFailure.png']);
end

