classdef lineScan
    % last edit: Perry Spratt 01/17/2017
    %An object for saving and manipulating line scan data
    
    properties
        % Basics
        name = [];
        date = [];
        xmlData = [];
        imagingParams = [];
        
        % Parameters that vary between experiments
        expParams = [];
        
        % Imaging Data
        raw = []; %Raw data from each tiff file organized by channel
        red = [];
        green = [];
        time = [];
        
    end
    
    methods
        %Line scan
        function obj = lineScan(path)
            
            if nargin < 1
                path = pwd;
            end
            
            %Import Data that requires a line scan folder
            obj = importName(obj,path);
            obj = importXmlData(obj,path);            
            obj = importImagingData(obj,path);
            
            %Set standard values than can be edited if neccisary
            obj.expParams.baselineStart = 0.1;
            obj.expParams.baselineEnd = 0.2;
            obj.expParams.thresh = 0;
            obj.expParams.skip = [];
            
            obj = updateLineScan(obj);
            
        end
        
        function obj = changeThreshold(obj,thresh)
            
            if thresh > 1
                obj.thresh = 1;
            elseif thresh < 0
                obj.thresh = 0;
            else
                obj.expParams.thresh = thresh;
            end
            
            obj = updateLineScan(obj);
            
        end
        
        function obj = skipSweeps(obj,skip)
            obj.expParams.skip = skip;
            obj = updateLineScan(obj);
        end
        
        function obj = updateLineScan(obj)
            
            obj.red = [];
            obj.green = [];    
            
            if ~isfield(obj.expParams,'mask')
                imgDim = size(squeeze(mean(obj.raw.green)));
                obj.expParams.mask = ones(imgDim);
                obj.expParams.maskCoord = [0 1 imgDim(1)+1 imgDim(2)-1];
            end
            
            if ~isfield(obj.expParams,'gsat')
                obj.expParams.gsat = NaN;
            end
            
            
            if ~isfield(obj.expParams,'skip')
                obj.expParams.skip = [];
            end
            
            if ~isfield(obj.expParams,'thresh')
                obj.expParams.thresh = 0;
            end
            
            if ~isfield(obj.expParams,'baselineStart')
                obj.expParams.baselineStart = 0.1;
            end
            
            if ~isfield(obj.expParams,'baselineEnd')
                obj.expParams.baselineEnd = 0.2;
            end
            
            if ~isempty(obj.raw.red)
                for i=1:length(obj.raw.red(:,1,1))
                    if ~ismember(i,obj.expParams.skip)
                        obj.red(i,:) = sum(squeeze(obj.raw.red(i,:,:)).*obj.expParams.mask,2)./length(find(obj.expParams.mask(1,:)));
                    else
                        obj.red(i,:) = NaN(1,length(obj.raw.red));
                    end
                end
                
            end
            
            if ~isempty(obj.raw.green)
                for i=1:length(obj.raw.green(:,1,1))
                    if ~ismember(i,obj.expParams.skip)
                        obj.green(i,:) = sum(squeeze(obj.raw.green(i,:,:)).*obj.expParams.mask,2)./length(find(obj.expParams.mask(1,:)));
                    else
                        obj.green(i,:) = NaN(1,length(obj.raw.red));
                    end
                end
            end          
            
            if ~isfield(obj.expParams,'spikeTimes')
                
                obj.expParams.spikeTimes = [0.2 .22 .24];
            end
            
        end
        
        function obj = updateLineScanXML(obj)
            
            try
                if strcmp(obj.xmlData.PVScan.SystemConfiguration.Lasers.Laser.Attributes.name,'Imaging')...
                        && strcmp(obj.xmlData.PVScan.Sequence{1, 1}.Attributes.type,'Linescan')
                    obj.imagingParams.rig = 'bluefish';
                end
            catch
            end
            
            try
                if obj.xmlData.PVScan.Sequence{1, 1}.Frame.File{1, 2}.Attributes.channel == '3'
                    obj.imagingParams.rig = 'Thing1';
                end
            catch
            end
                
                
            try 
                if obj.xmlData.PVScan.Sequence{1, 1}.Frame.File{1, 2}.Attributes.channel == '2' &&...
                         strcmp(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 5}.Attributes.key,'linesPerFrame')  
                   obj.imagingParams.rig = 'Thing2'; 
                end
            catch
                
            end
            
            if strcmp(obj.imagingParams.rig,'bluefish')
                obj.imagingParams.greenPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 23}.Attributes.value);
                obj.imagingParams.redPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 25}.Attributes.value);
                obj.imagingParams.laserPower = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 28}.Attributes.value);
                obj.imagingParams.numFrames = length(obj.xmlData.PVScan.Sequence);
                obj.imagingParams.pixelsPerLine = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 6}.Attributes.value);
                obj.imagingParams.linesPerFrame = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 7}.Attributes.value);
                obj.imagingParams.scanlinePeriod = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 12}.Attributes.value);
                obj.imagingParams.micronPerPixelX = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 21}.Attributes.value);
            elseif strcmp(obj.imagingParams.rig,'Thing1')
                obj.imagingParams.greenPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 28}.Attributes.value);
                obj.imagingParams.redPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 23}.Attributes.value);
                
                %Because there are two lasers...
                laser0 = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 29}.Attributes.value);
                laser1 = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 30}.Attributes.value);
                if laser0 > laser1
                    obj.imagingParams.laserPower = laser0;
                else
                    obj.imagingParams.laserPower = laser1;
                end
                
                obj.imagingParams.numFrames = length(obj.xmlData.PVScan.Sequence);
                obj.imagingParams.pixelsPerLine = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 6}.Attributes.value);
                obj.imagingParams.linesPerFrame = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 7}.Attributes.value);
                obj.imagingParams.scanlinePeriod = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 12}.Attributes.value);
                obj.imagingParams.micronPerPixelX = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 21}.Attributes.value);
            
            elseif strcmp(obj.imagingParams.rig,'Thing2')
                obj.imagingParams.greenPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 20}.Attributes.value);
                obj.imagingParams.redPMTGain = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 22}.Attributes.value);
                obj.imagingParams.laserPower = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 24}.Attributes.value);
                obj.imagingParams.numFrames = length(obj.xmlData.PVScan.Sequence);
                obj.imagingParams.pixelsPerLine = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 4}.Attributes.value);
                obj.imagingParams.linesPerFrame = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 5}.Attributes.value);
                obj.imagingParams.scanlinePeriod = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 9}.Attributes.value);
                obj.imagingParams.micronPerPixelX = str2double(obj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 12}.Attributes.value);
            end
            
            obj.time = 0:obj.imagingParams.scanlinePeriod:obj.imagingParams.scanlinePeriod*(obj.imagingParams.linesPerFrame-1);
        end
        
        function saveLS(obj,path)
            if nargin ==2
                save([path filesep obj.name '.mat'],'obj');
            else
                save([obj.name '.mat'],'obj');
            end
        end
        
        % Basic line scan output data
        function trace = meanGreen(obj)
            trace = nanmean(obj.green);
        end
        
        function trace = meanRed(obj)
            trace = nanmean(obj.red);
        end
        
        function trace = GoR(obj)
            trace = obj.meanGreen./obj.meanRed;
            
            for i=1:length(obj.green(:,1))
                traces(i,:) = obj.green(i,:)./obj.red(i,:);
            end
            trace = nanmean(traces);
            
        end
        
        function trace = normGreen(obj)
            for i=1:length(obj.green(:,1))
                normTraces(i,:) = obj.normalize(obj.green(i,:),obj.expParams.baselineStart,obj.expParams.baselineEnd);
            end
            trace = nanmean(normTraces);
        end
        
        function trace = normRed(obj)
            for i=1:length(obj.red(:,1))
                normTraces(i,:) = obj.normalize(obj.red(i,:),obj.expParams.baselineStart,obj.expParams.baselineEnd);
            end
            trace = nanmean(normTraces);
        end
        
        function trace = normGoR(obj)
            for i=1:length(obj.green(:,1))
%                 normTraces(i,:) = obj.normalize(obj.green(i,:)./obj.red(i,:),obj.expParams.baselineStart,obj.expParams.baselineEnd);
                if isnan(obj.expParams.gsat)
                    normTraces(i,:) = obj.baseline_subtraction(obj.green(i,:),obj.expParams.baselineStart,obj.expParams.baselineEnd)./obj.red(i,:);
                else
                    normTraces(i,:) = (obj.baseline_subtraction(obj.green(i,:),obj.expParams.baselineStart,obj.expParams.baselineEnd)./obj.red(i,:))./obj.expParams.gsat;
                end

            end
            trace = nanmean(normTraces);
        end
        
        % Analysis
        function normalizedTrace = normalize(obj,trace,baselineStartTime,baselineEndTime)
            
            baseline  = getBaseline(obj,trace,baselineStartTime,baselineEndTime);
            normalizedTrace = (trace - baseline)/baseline;
            
        end
        
        function trace = baseline_subtraction(obj,trace,baselineStartTime,baselineEndTime)
            baseline  = getBaseline(obj,trace,baselineStartTime,baselineEndTime);
            trace = trace - baseline;
            
        end
        
        function baseline = getBaseline(obj,trace,baselineStartTime,baselineEndTime)
            baseline = nanmean(trace(1,...
                floor(baselineStartTime/obj.imagingParams.scanlinePeriod):...
                floor(baselineEndTime/obj.imagingParams.scanlinePeriod)));
        end
                                    
        function [peak,tau] = decayFit(obj,trace)
            
            decay = fit((1:length(trace))',...
                trace',...
                'exp1');
            
            confInts = confint(decay);
            
            if confInts(1,1) < 0 || confInts(2,1) < 0 || decay.b > 0
                peak = rms(trace);
                tau = 0;                        
            else              
                peak = decay.a;
                tau = decay.b; 
            end                                                
        end
        
        function [L, linearSum, measuredPeak, singlePeak, rms] = linearity(obj,trace,spikeTimes)
            
            %Convert spike times to indicies in the trace vector
            for i=1:length(spikeTimes)
                spikeIndicies(i) = time2index(obj,spikeTimes(i));
            end           
            
            
            %Find the peak and peak offset from the spike within 30ms of
            %spike onset
            [~, singleOffset] = findpeaks(smooth(trace(spikeIndicies(1):time2index(obj,spikeTimes(1)+.03)),3));                       
            if ~isempty(singleOffset)
                singleOffset = singleOffset(1);
            else
                singleOffset = length(trace(spikeIndicies(1):time2index(obj,spikeTimes(1)+.03)));
            end
            %Fit the decay of the first spike 
            [singlePeak, singleTau] =...
                obj.decayFit(trace(spikeIndicies(1)+singleOffset:spikeIndicies(2))); %,trace(time2index(obj,spikeTimes(1)-.03):spikeIndicies(1)));
            
            %Find the peak and peak offset from the spike within 30ms of
            %spike onset
            [~, trainOffset] = findpeaks(smooth(trace(spikeIndicies(end):time2index(obj,spikeTimes(end)+.03)),3));  
            trainOffset = trainOffset(1);

            %Fit the decay of the last spike
            [lastPeak, lastTau] =...
                obj.decayFit(trace(spikeIndicies(end)+trainOffset:length(trace)));%,trace(time2index(obj,spikeTimes(2)-.03):spikeIndicies(2)));
            
            
            
            %Determine expected sum of spikes 2:end based on spike 1
            linearSum = zeros(1,length(trace));
            
            if singleTau == 0 % this is a hacky way to ensure expected peak is 3x RMS not 4x
                linearSum(spikeIndicies(2)+singleOffset:end) = linearSum(spikeIndicies(2)+singleOffset:end)...
                    - singlePeak...
                    * exp(singleTau* (1:length(linearSum(spikeIndicies(2)+singleOffset:end))));
            end
            
            for i=1:length(spikeTimes)                   
                linearSum(spikeIndicies(i)+singleOffset:end) = linearSum(spikeIndicies(i)+singleOffset:end)...
                    + singlePeak...
                    * exp(singleTau* (1:length(linearSum(spikeIndicies(i)+singleOffset:end))));
            end   
            
            measuredPeak = zeros(1,length(trace));
            measuredPeak(spikeIndicies(end)+trainOffset:end) = measuredPeak(spikeIndicies(end)+trainOffset:end)...
                    + lastPeak...
                    * exp(lastTau* (1:length(measuredPeak(spikeIndicies(end)+trainOffset:end))));
                        
            measured = lastPeak;
            expected = max(linearSum);
            L = measured/expected;    
            rms(1) = singleTau ~= 0;
            rms(2) = lastTau ~= 0;
        end
        
        function index = time2index(obj,time)
            if time > obj.time(end)
                index = length(obj.time);
                warning('Time index requested is out of bounds');                
            elseif time < 0
                index = 1;
                warning('Time index requested is out of bounds')
            else
                index = ceil(time./obj.imagingParams.scanlinePeriod)+1;%+1 accounts for the time array starting with index 1 not 0
            end   
        end
        
        function time = index2time(obj,index)
            if index <= 0
                time = obj.time(1);
            elseif index > length(obj.time);
                time = obj.time(end);
            else
                time = obj.time(index);
            end   
        end
            
        
        % Ploting
        function h = showImage(obj)
            if ~isempty(obj.red)
                subplot(2,1,1)
                imshow(uint16(squeeze(nanmean(obj.red))'),[]);
                title({['Red Channel '];[obj.name]},'fontsize',16);
                subplot(2,1,2)
                imshow(uint16(squeeze(nanmean(obj.green))'),[]);
                title({['Green Channel '];[obj.name]},'fontsize',16);
            else
                imshow(uint16(squeeze(nanmean(obj.green))),[]);
                title(['Green Channel for ' obj.name]);
            end
            
            h = figure(length(findobj('type','figure')));
        end
        
        function ax = plotGreen(obj,norm,smoothing)
            if ~isempty(obj.green)
                %parse arguments
                if nargin == 1
                    norm = 0;
                    smoothing = 3;
                elseif nargin == 2
                    smoothing = 3;
                end
                              
                cla;
                hold on;
                
                if norm == 1
                    for j=1:length(obj.green(:,1))
                        trace = obj.normalize(obj.green(j,:),obj.expParams.baselineStart,obj.expParams.baselineEnd);
                        ax = plot(obj.time,trace,'color',[0.7,1,.7]);
                    end
                    plot(obj.time,smooth(obj.normGreen,smoothing),'k');
                    title([obj.name ' Norm Green'],'fontsize',14)
                else
                    for j=1:length(obj.green(:,1))
                        trace = obj.green(j,:);
                        ax = plot(obj.time,trace,'color',[0.7,1,.7]);
                    end
                    plot(obj.time,smooth(obj.meanGreen,smoothing),'k');
                    title([obj.name ' Green'],'fontsize',14)
                end
                
                xlabel('Time (s)','FontSize',14);
                xlim([0 floor(obj.time(end)*100)/100]);
                set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                    'XColor', 'k', 'YColor', 'k',  ...
                    'LineWidth', 1,'FontName','arial','FontSize',12);
                
            end
        end
        
        function ax = plotRed(obj,norm,smoothing)
            if ~isempty(obj.red)
                
                %parse arguments
                if nargin == 1
                    norm = 0;
                    smoothing = 3;
                elseif nargin == 2
                    smoothing = 3;
                end
                              
                cla;
                hold on;
                
                if norm == 1
                    for j=1:length(obj.red(:,1))
                        trace = obj.normalize(obj.red(j,:),obj.expParams.baselineStart,obj.expParams.baselineEnd);
                        ax = plot(obj.time,trace,'color',[1,.85,.85]);
                    end
                    plot(obj.time,smooth(obj.normRed,smoothing),'k');
                    title([obj.name ' Norm Red'],'fontsize',14)
                else
                    for j=1:length(obj.red(:,1))
                        trace = obj.red(j,:);
                        ax = plot(obj.time,trace,'color',[1,.85,.85]);
                    end
                    plot(obj.time,smooth(obj.meanRed,smoothing),'k');
                    title([obj.name ' Red'],'fontsize',14)
                end
                
                xlabel('Time (s)','FontSize',14);
                xlim([0 floor(obj.time(end)*100)/100]);
                set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                    'XColor', 'k', 'YColor', 'k',  ...
                    'LineWidth', 1,'FontName','arial','FontSize',12);
                                                                
            end
        end
        
        function plotGoverR(obj,norm,smoothing)
            if ~isempty(obj.red) && ~isempty(obj.green)
                
                %parse arguments
                if nargin == 1
                    norm = 0;
                    smoothing = 3;
                elseif nargin == 2
                    smoothing = 3;
                end
                              
                cla;
                hold on;
                
                if norm == 1
                    for j=1:length(obj.green(:,1))
%                         trace = obj.normalize(obj.green(j,:)./obj.red(j,:),obj.expParams.baselineStart,obj.expParams.baselineEnd
                        trace = obj.baseline_subtraction(obj.green(j,:),obj.expParams.baselineStart,obj.expParams.baselineEnd)./obj.red(j,:); 
                        if ~isnan(obj.expParams.gsat)
                            trace = trace./obj.expParams.gsat;
                        end
                        ax = plot(obj.time,trace,'color',[.85,.85,1]);
                    end
                                       
                    
                    plot(obj.time,smooth(obj.normGoR,smoothing),'k');
                    title([obj.name ' Norm G/R'],'fontsize',14)
                else
                    for j=1:length(obj.red(:,1))
                        trace = obj.green(j,:)./obj.red(j,:);
                        ax = plot(obj.time,trace,'color',[.85,.85,1]);
                    end
                    plot(obj.time,smooth(obj.GoR,smoothing),'k');
                    title([obj.name ' G/R'],'fontsize',14)
                end
                
                xlabel('Time (s)','FontSize',14);
                xlim([0 floor(obj.time(end)*100)/100]);
                set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
                    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
                    'XColor', 'k', 'YColor', 'k',  ...
                    'LineWidth', 1,'FontName','arial','FontSize',12);                               
            end
            
            
        end
        
    end
    
    methods(Access = private)
        %Functions called to initialized the line scan
        function obj = importName(obj,path)
            [~, obj.name] = fileparts(path);
        end
        
        function obj = importXmlData(obj,path2dir)
            %Imports the xml file into an xml object that is easy to parse
            %with matlab. Requires xml2struct
            try
                xmlFile = dir([path2dir filesep 'LineScan*.xml']);
                obj.xmlData = xml2struct([path2dir filesep xmlFile.name]);
                obj.date = obj.xmlData.PVScan.Attributes.date;
            catch
                error(['No xml file found for ' obj.name]);
            end
            
            obj = updateLineScanXML(obj);
        end
        
        function obj = importImagingData(obj,path)
            %collects data from line scan folder
            sortLineScan(obj.imagingParams.rig,path);
            
            %Import imaging data
            alexaFiles = dir([path '/Alexa/LineScan*.tif']);
            fluoFiles = dir([path '/Fluo/LineScan*.tif']);
            
            if ~isempty(alexaFiles)
                for i=1:length(alexaFiles)
                    obj.raw.red(i,:,:) = double(imread([path filesep 'Alexa' filesep alexaFiles(i).name]));
                end
            else
                obj.raw.red = [];
            end
            
            if ~isempty(fluoFiles)
                for i=1:length(fluoFiles)
                    obj.raw.green(i,:,:) = double(imread([path filesep 'Fluo' filesep fluoFiles(i).name]));
                end
            else
                obj.raw.green = [];
            end
            
            
            
            
        end
    end
    
    
end





