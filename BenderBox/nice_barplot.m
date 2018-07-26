function nice_barplot(y,x,c1,c2, boxon)

if nargin < 5
    boxon = 1;
end
y = y(~isnan(y)); %remove NaNs

barWidth = .6;
wisOffset = barWidth./6;
linewidth=2;


boxColor = [0 0 0];
wisColor = [0 0 0];
meanColor = [0 0 0];
faceColor = c2;

hold on;
if boxon == 1
    if mean(y) > 0
        rectangle('Position',[x-barWidth/2,0,barWidth,mean(y)],'linewidth',linewidth,'EdgeColor',boxColor,'facecolor',faceColor); %plot rectangle
         plot([x-wisOffset x-wisOffset],[mean(y)+nansem(y) mean(y)-nansem(y)],'linewidth',linewidth,'color',wisColor); 
    else
        rectangle('Position',[x-barWidth/2,mean(y),barWidth,mean(y)*-1],'linewidth',linewidth,'EdgeColor',boxColor,'facecolor',faceColor); %plot rectangle
         plot([x-wisOffset x-wisOffset],[mean(y)+nansem(y) mean(y)-nansem(y)],'linewidth',linewidth,'color',wisColor); 
    end
else
    plot([x-wisOffset x-wisOffset],[mean(y)+nansem(y) mean(y)-nansem(y)],'linewidth',linewidth,'color',wisColor); 
    plot([x-wisOffset-.1 x-wisOffset+.1],[mean(y) mean(y)],'linewidth',linewidth,'color',c1);
end
%plot whiskers


scatter(ones(length(y),1)*wisOffset+x,y,100,'MarkerEdgeColor',c1,'lineWidth',2);