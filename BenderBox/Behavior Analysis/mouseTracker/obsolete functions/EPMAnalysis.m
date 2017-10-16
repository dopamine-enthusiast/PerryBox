function EPMAnalysis(trial,open1,open2,closed1,closed2,center, bg);

time = trial.time;
posHead = trial.posHead;
posCenter = trial.posCenter;



open1Mask = createMask(open1);
open2Mask = createMask(open2);
closed1Mask = createMask(closed1);
closed2Mask = createMask(closed2);
openMask = open1Mask+open2Mask;
closedMask = closed1Mask+closed2Mask;
centerMask = center.createMask;

centerInOpen = zeros(length(time),1);
centerInClosed = zeros(length(time),1);
centerInCenter = zeros(length(time),1);
headInOpen = zeros(length(time),1);
headInClosed = zeros(length(time),1);
headInCenter = zeros(length(time),1);

timeCenterOpen = 0;
timeCenterClosed = 0;
timeCenterCenter = 0;
timeHeadOpen = 0;
timeHeadClosed = 0;
timeHeadCenter = 0;

entriesCenterOpen = 0;
entriesCenterClosed = 0;
entriesCenterCenter = 0;
entriesHeadOpen = 0;
entriesHeadClosed = 0;
entriesHeadCenter = 0;

cDist = zeros(length(time),1);

for i=1:length(time)
    
    
    %     Center Location
    try
        if openMask(posCenter(i,2) , posCenter(i,1)) ~= 0
            centerInOpen(i) = 1;
            if i ~= 1
                timeCenterOpen = timeCenterOpen + (time(i)-time(i-1));
                if openMask(posCenter(i-1,2) , posCenter(i-1,1)) == 0
                    entriesCenterOpen = entriesCenterOpen + 1;
                end
            end
        end
        
        if closedMask(posCenter(i,2) , posCenter(i,1)) ~= 0
            centerInClosed(i) = 1;
            if i ~= 1
                timeCenterClosed = timeCenterClosed + (time(i)-time(i-1));
                if closedMask(posCenter(i-1,2) , posCenter(i-1,1)) == 0
                    entriesCenterClosed = entriesCenterClosed + 1;
                end
                    
            end
        end
        
        if centerMask(posCenter(i,2) , posCenter(i,1)) ~= 0
            centerInCenter(i) = 1;
            if i ~= 1
                timeCenterCenter = timeCenterCenter + (time(i)-time(i-1));
                if centerMask(posCenter(i-1,2) , posCenter(i-1,1)) == 0
                    entriesCenterCenter= entriesCenterCenter + 1;
                end
            end
        end
        
        % Cumulative distance
        if i ~= 1
            p1 = [posCenter(i-1,1) , posCenter(i-1,2)];
            p2 = [posCenter(i,1) , posCenter(i,2)];
            
            dist = sqrt(sum((p1 - p2) .^ 2));
            
            cDist(i) =  cDist(i-1) + dist;
        end
    catch
        disp(['No center data for frame ' num2str(i)]);
    end
    
    
    
    %   Head Location
    try
        if openMask(posHead(i,2) , posHead(i,1)) ~= 0
            headInOpen(i) = 1;
            if i ~= 1
                timeHeadOpen = timeHeadOpen + (time(i)-time(i-1));
                if openMask(posHead(i-1,2) , posHead(i-1,1)) == 0
                    entriesHeadOpen = entriesHeadOpen + 1;
                end
            end
        end
        
        if closedMask(posHead(i,2) , posHead(i,1)) ~= 0
            headInClosed(i) = 1;
            if i ~= 1
                timeHeadClosed = timeHeadClosed + (time(i)-time(i-1));
                if closedMask(posHead(i-1,2) , posHead(i-1,1)) == 0
                    entriesHeadClosed = entriesHeadClosed + 1;
                end
            end
            
        end
        
        if centerMask(posHead(i,2) , posHead(i,1)) ~= 0
            headInCenter(i) = 1;
            if i ~= 1
                timeHeadCenter = timeHeadCenter + (time(i)-time(i-1));
                if closedMask(posHead(i-1,2) , posHead(i-1,1)) == 0
                    entriesHeadCenter = entriesHeadCenter + 1;
                end
            end
            
        end
    catch    
        disp(['No head data for frame ' num2str(i)])
    end
    
end






save([trial.name ' EPM Data.mat']...
    ,'time'...
    ,'posHead'...
    ,'posCenter'...
    ,'centerInOpen'...
    ,'centerInClosed'...
    ,'centerInCenter'...
    ,'headInOpen'...
    ,'headInClosed'...
    ,'headInCenter'...
    ,'timeCenterOpen'...
    ,'timeCenterClosed'...
    ,'timeCenterCenter'...
    ,'timeHeadOpen'...
    ,'timeHeadClosed'...
    ,'timeHeadCenter'...
    ,'cDist'...
    ,'entriesCenterOpen'...
    ,'entriesCenterClosed'...
    ,'entriesCenterCenter'...
    ,'entriesHeadOpen'...
    ,'entriesHeadClosed'...
    ,'entriesHeadCenter');














