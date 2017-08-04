function plotPointScanNormalized(pointscan)
% This function plots the normalized-smoothed g over R value over time for each point
% in pointscan (made by importPointScan.m)

%% Plot
figure;
hold on;
CM = jet(length(pointscan.smoothedGoverR(:,1,1))+1);

for i =1:length(pointscan.smoothedGoverR(:,1,1))
    plot(pointscan.time(50:end-50,1),mean(pointscan.normSmoothedGoverR(i,50:end-50,:),3),'color',CM(i,:));
end

axis([0 pointscan.time(end) -0.03 0.2]);

% Action potential intiation mark
AP = area([0.025 0.0251],[0.2 0.2],-0.03);
set(AP, 'FaceColor', 'black');
% 
window = area([pointscan.hotspotWindowStart pointscan.hotspotWindowStart+pointscan.hotspotWindowLength],[0.2 0.2],-0.03);
set(window, 'FaceColor', 'black')
alpha(0.10);

t = title({['Baseline Subtracted Smoothed Green/Red for ' pointscan.name]},'Interpreter','none');
set(t,'FontSize',15,'FontWeight','bold');
ylabel('G/R - Baseline G/R');
xlabel('time (seconds)');
legend(pointscan.legend);
legend('boxoff')

end 