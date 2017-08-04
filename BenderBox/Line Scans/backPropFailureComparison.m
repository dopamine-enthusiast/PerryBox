function backPropFailureComparison(spreadsheet)


%Get title and file description
description = inputdlg('Enter Title','Enter Title');

%%%%%Set what dimension to Compare%%%%%%%%%
filter = 9;
% cell 1
% Genotype 2
% celltype 3
% num spikes 8
% train freq. 9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Set what distance is aligned to%%%%%%%%
dist = 13;
%Distance from  soma 13
%distance from nexus 24
%Corrected distance 25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Set bin width%%%%%%%%%%%%%%%%%%%%%%%%%%
binWidth = 50;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%Set Axis Limits%%%%%%%%%%%%%%%%%%%%%%%%%%
xlimits = [0 500];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

binCenters = ceil(min([spreadsheet{:,dist}])./binWidth)*binWidth:...
    binWidth:...
    floor(max([spreadsheet{:,dist}])./binWidth)*binWidth;


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



f1 = figure;
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
    errorbar(binCenters(1:end),pFailure',stderr','color',c(i,:),'LineWidth',2);
end
legend(comparisons);
title([description{1} ' pFailure']);
ylabel('p(failure)');
xlabel('Distance');
xlim(xlimits);
