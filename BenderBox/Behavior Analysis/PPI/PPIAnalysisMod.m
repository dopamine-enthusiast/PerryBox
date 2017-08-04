function PPIAnalysisMod

%Define stimuli names
backgroundStim = 'background';
startleStim = '40msStartle';
ppiStim{1} = '68dBppStartle 64back';
ppiStim{2} = '79dBppStartle 64back';
ppiStim{3} = '90dBppStartle 64back';

%load the files
files = dir('*.xls');

%extract data from the xls file
try
    [temp temp rawData] = xlsread(files(1).name);
catch
    error('The xls file either could not be found or parsed. Ensure that it is saved as an xls and not xlsx file');
end

%Format of data in rawData
% 1 - date
% 2 - time
% 3 - session
% 4 - subject
% 5 - group
% 6 - ID
% 7 - trial type
% 8 - chan
% 9 - trial number
% 10 - v start
% 11 - v max
% 12 - t max
% 13 - avg
% 14 - baseline
% onset
% t-peak 1
% amp P1

%Sort by subject
rawData = sortrows(rawData,4);

%Set initial variables
trial(1).mouseID = rawData{1,4};
trial(1).group = rawData{1,5};
trial(1).date = rawData{1,1};
trial(1).time = rawData{1,2};
trial(1).session = rawData{1,3};
trial(1).chamber = rawData{1,8};

trial(1).baseline.raw = [];
trial(1).startle.raw = [];
for i=1:length(ppiStim)
    trial(1).ppi(i).raw = [];
end

%Parse the xlsfile
counter = 1; %Counts number of trials
for i=1:length(rawData)
    if ~strcmp(trial(counter).mouseID,rawData{i,4})
        counter = counter + 1;
        trial(counter).baseline.raw = [];
        trial(counter).startle.raw = [];
        
        for j=1:length(ppiStim)
            trial(counter).ppi(j).raw = [];
        end
    end
    
    trial(counter).mouseID = rawData{i,4};
    trial(counter).group = rawData{i,5};
    trial(counter).date = rawData{i,1};
    trial(counter).time = rawData{i,2};
    trial(counter).session = rawData{i,3};
    trial(counter).chamber = rawData{i,8};
    
    stimulus = strtrim(rawData{i,7});
    
    if strcmp(backgroundStim,stimulus)
        trial(counter).baseline.raw = [trial(counter).baseline.raw rawData{i,13}];
    elseif strcmp(startleStim,stimulus)
        trial(counter).startle.raw = [trial(counter).startle.raw rawData{i,13}];
    end
    
    for j=1:length(ppiStim)
        if strcmp(ppiStim{j},stimulus)
            trial(counter).ppi(j).raw = [trial(counter).ppi(j).raw rawData{i,13}];
        end
    end
    
end


% Determine amount of Prepulse Inhibition

for i=1:length(trial)
    %Determine average values
    trial(i).baseline.avg = mean(trial(i).baseline.raw);
    trial(i).startle.avg = mean(trial(i).startle.raw);
    for j=1:length(trial(i).ppi)
        trial(i).ppi(j).avg = mean(trial(i).ppi(j).raw);
    end
    %Determine prepulse inhibition
    trial(i).baseline.percentInhibition = abs(((trial(i).baseline.avg-trial(i).startle.avg)/trial(i).startle.avg)*100);
    for j=1:length(trial(i).ppi)
        trial(i).ppi(j).percentInhibition = abs(((trial(i).ppi(j).avg-trial(i).startle.avg)/trial(i).startle.avg)*100);
    end
end

%Make output csvfile
for i=1:length(trial)
    header{1} = 'Mouse ID';
    csvOutput{i,1} = trial(i).mouseID;
    header{2} = 'Group';
    csvOutput{i,2} = trial(i).group;
    header{3} = 'Date';
    csvOutput{i,3} = trial(i).date;
    header{4} = 'Time';
    csvOutput{i,4} = trial(i).time;
    header{5} = 'Session';
    csvOutput{i,5} = trial(i).session;
    header{6} = 'Chamber';
    csvOutput{i,6} = trial(i).chamber;
    header{7} = 'Average Startle';
    csvOutput{i,7} = trial(i).startle.avg;
    header{8} = 'Baseline';
    csvOutput{i,8} = trial(i).baseline.percentInhibition;
    for j=1:length(trial(i).ppi)
        header{8+j} = ppiStim{j};
        csvOutput{i,8+j} = trial(i).ppi(j).percentInhibition;
    end
end


%Write the output csv file
[path fileName] = fileparts(files(1).name);

fid = fopen([fileName ' Processed.csv'],'wt');

for i=1:length(header(:,1))
    for j=1:length(header(i,1:end-1))
        fprintf(fid, '%s,', num2str(header{i,j}));
    end
    fprintf(fid, '%s\n', num2str(header{i,end})) ;
end

for i=1:length(csvOutput(:,1))
    for j=1:length(csvOutput(i,1:end-1))
        fprintf(fid, '%s,', num2str(csvOutput{i,j}));
    end
    fprintf(fid, '%s\n', num2str(csvOutput{i,end})) ;
end
fclose(fid) ;











