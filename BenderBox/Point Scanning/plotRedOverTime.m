function plotRedOverTime(pointscan)
% This function plots the raw red channel value over time for each point

figure;
hold on;

for i=1:length(pointscan.redOverTime(1,:))

    subplot((ceil(length(pointscan.redOverTime(1,:))/2)),2,i);
    plot(smooth(pointscan.redOverTime(:,1),21),'color','r');
    t = title(pointscan.legend(i));    
    set(t,'FontSize',15,'FontWeight','bold');
    ylabel('Red Channel Value');
    xlabel('Time (seconds)');
      
end

    