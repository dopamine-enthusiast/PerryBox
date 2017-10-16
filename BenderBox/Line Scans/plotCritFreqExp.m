function plotCritFreqExp(frequencies)

if nargin == 0
    frequencies = [0.01 0.02 0.03 0.04 0.05];
end

%Import the linescan
scans = lineScan;
time = scans.time;
red = scans.red;
green = scans.green;
sumGoverR = sum(green,3)./ sum(red,3);

%Reshape into martix with frequencies by row
sumGoverR_byFreq = reshape(sumGoverR,length(frequencies),[],length(sumGoverR(1,:)));
%Take the mean of each scan per frequencies
meanGoverR = squeeze(mean(sumGoverR_byFreq,2));




%% Plot The Traces

%Set the color map
c = [0 0 0;...
    0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];

figure;
hold on
for i=1:length(frequencies)
    trace = meanGoverR(i,:);
    %Establish the baseline 
    baselineStartTime = 0.1;
    baselineEndTime = 0.2;
    baseline = mean(trace(1,...
                floor(baselineStartTime/scans.imagingParams.scanlinePeriod):...
                floor(baselineEndTime/scans.imagingParams.scanlinePeriod)));
    normMeanGoverR(i,:) = meanGoverR(i,:)-baseline;
    trace = smooth(normMeanGoverR(i,:),5);
    plot(time,trace,'color',c(i,:))

    legendTitles{i} = [num2str(frequencies(i)) ' ISI'];
end

plot(time,zeros(length(time),1),'k','LineWidth',2);

title([scans.name ' Traces']);
xlabel('Time (s)');
ylabel('G/R');
legend(legendTitles);

%% Plot the linearity

for i=1:length(frequencies)
    %Set spiketimes
    single = .2;
    multiple(1) = .8;
    multiple(2) = .8+frequencies(i);
    multiple(3) = .8+frequencies(i)*2;
    
    [L(i), measured(i), expected(i)] = linearity(scans,normMeanGoverR(i,:),single,multiple);
end
figure()
hold on;
plot(frequencies,L)
plot(frequencies,ones(length(frequencies),1),'k','LineWidth',2);
title([scans.name 'Observed/Expected'])
xlabel('Interspike Interval')
ylabel('Observed/Expected');

figure()
plot(frequencies,measured)
title([scans.name 'Observed/Expected'])
xlabel('Interspike Interval')
ylabel('Peak G/R');




