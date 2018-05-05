function nice_boxplot(y,x,c1,c2)

y = y(~isnan(y)); %remove NaNs

percentileNum = 25; % for the main quantiles
percentileNum2 = 9; % for the whisker ends
barWidth = .6;
wisOffset = barWidth./6;
linewidth=2;

medianX = median(y);
boxEdge = prctile(y,[percentileNum 100-percentileNum]);
IQR=max(diff(boxEdge),eps); % in case IQR is zero, make it eps

wisEdge = prctile(y,[percentileNum2  100-percentileNum2]);

boxColor = [0 0 0];
wisColor = [0 0 0];
meanColor = [0 0 0];
faceColor = c2;


boxEdge = prctile(y,[percentileNum 100-percentileNum]);

wisEdge = prctile(y,[percentileNum2  100-percentileNum2]);

hold on;

rectangle('Position',[x-barWidth/2,boxEdge(1),barWidth,IQR],'linewidth',linewidth,'EdgeColor',boxColor,'facecolor',faceColor); %plot rectangle
plot([x-barWidth/2 x+barWidth/2],[medianX medianX],'color',meanColor,'linewidth',linewidth); %plot median
% plot([y-barWidth/2 y-barWidth/2],[boxEdge(1) boxEdge(2)],'linewidth',linewidth,'color',boxColor);

%plot whiskers
plot([x-wisOffset x-wisOffset],[wisEdge(1) boxEdge(1)],'linewidth',linewidth,'color',wisColor); 
plot([x-wisOffset x-wisOffset],[boxEdge(2) wisEdge(2)],'linewidth',linewidth,'color',wisColor);

scatter(ones(length(y),1)*wisOffset+x,y,100,'MarkerEdgeColor',c1,'lineWidth',2);
