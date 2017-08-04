function plotLineScanSweeps_dialoug(sweepTimes)

%Find the directories containing the linescans
root = pwd;
[~, cellName] = fileparts(root);

%directories = uipickfiles(); %Use this if you want to select files
linescanFile = subdir(fullfile(root,'LineScan-*.mat')); %Use if you want to plot all linescans in current directory 

counter = 1; %in case some loops fail
%load linescans
for i=1:length(linescanFile)
    
    %Some of these might not work so put in try catch
    try
        linescans(counter) = load(linescanFile(i).name);
        counter = counter+1;
    catch
        %Do nothing
    end
    cd(root);
    
end

%Sort by date
for i=1:length(linescans)
    dates(i) = datenum(linescans(i).date);
end

[temp order] = sort(dates);
linescans = linescans(order);
cd(root);

for i=1:length(linescans)
    prompt = {['Start sweep for: ' linescans(i).name]};
    dlg_title = 'Pick start sweeps';
    num_lines = 1;
    defaultans = {'1'};
    sweeps = inputdlg(prompt,dlg_title,num_lines,defaultans);
    sweepAverage{i} = getSweepAverage(str2num(sweeps{1}),linescans(i).numFrames);
    tempAverage{i} = getSweepTemperaturesAverage(str2num(sweeps{1}),linescans(i).numFrames);
end


%Set colormap
c = [0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];


fig = figure();
hold on;
for i=1:length(sweepAverage)
    h(i) = plot(sweepAverage{i},'color',c(i,:),'linewidth',1);
    legendTitles{i} = ['ls' num2str(i) ' ' num2str(tempAverage{i}) 'deg'];
end

ylim([-150 50]);


legend(h,legendTitles);
legend('boxoff');

[path name] = fileparts(pwd);
t = title([name,' linescan sweeps']);
set(t,'FontSize',15,'FontWeight','bold');


fileName = [name,' linescan sweeps.jpg'];
saveas(fig,fileName);
crop([pwd '/' fileName]);
