function nice_boxplot(x,y,c1,c2)

x = x(~isnan(x)); %remove NaNs

percentileNum = 25; % for the main quantiles
percentileNum2 = 9; % for the whisker ends
barWidth = .6;
wisOffset = barWidth./6;
linewidth=2;

medianX = median(x);
boxEdge = prctile(x,[percentileNum 100-percentileNum]);
IQR=max(diff(boxEdge),eps); % in case IQR is zero, make it eps

wisEdge = prctile(x,[percentileNum2  100-percentileNum2]);

boxColor = [0 0 0];
wisColor = [0 0 0];
meanColor = [0 0 0];
faceColor = c2;


boxEdge = prctile(x,[percentileNum 100-percentileNum]);

wisEdge = prctile(x,[percentileNum2  100-percentileNum2]);

hold on;

rectangle('Position',[y-barWidth/2,boxEdge(1),barWidth,IQR],'linewidth',linewidth,'EdgeColor',boxColor,'facecolor',faceColor); %plot rectangle
plot([y-barWidth/2 y+barWidth/2],[medianX medianX],'color',meanColor,'linewidth',linewidth); %plot median
% plot([y-barWidth/2 y-barWidth/2],[boxEdge(1) boxEdge(2)],'linewidth',linewidth,'color',boxColor);

%plot whiskers
plot([y-wisOffset y-wisOffset],[wisEdge(1) boxEdge(1)],'linewidth',linewidth,'color',wisColor); 
plot([y-wisOffset y-wisOffset],[boxEdge(2) wisEdge(2)],'linewidth',linewidth,'color',wisColor);

scatter(ones(length(x),1)*wisOffset+y,x,100,'MarkerEdgeColor',c1,'lineWidth',2);
