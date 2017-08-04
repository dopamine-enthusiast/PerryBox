function plotPointScanRaw(pointscan) 
% This function plots the raw GoverR values over time for each point in
% pointscan

% Written by Perry Spratt 2015-07-07


% plot 
hold on;
CM = jet(length(pointscan.smoothedGoverR(:,1,1))+1);

for i =1:length(pointscan.smoothedGoverR(:,1,1))
    plot(pointscan.time(10:end) , mean(pointscan.rawGoverR(i,10:end,:),3),'color',CM(i,:));      
end

% Set the title and axis
t = title(['Raw G/R for ' pointscan.name],'Interpreter','none');
set(t,'FontSize',15,'FontWeight','bold');
ylabel('Green/Red');
xlabel('Time (seconds)');
legend(pointscan.legend);
legend('boxoff')

end





