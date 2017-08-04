function scans = interleavedLineScans(isi)

if nargin == 0
    isi = [10 20 30 40 50];
end


rig = 'bluefish';
singleDelay = 0.2;
trainDelay = 0.8;

root = pwd;

dirs = {};
dirs = uipickfiles('FilterSpec','LineScan*');

%Get and xmlfile 
xmlFile = subdir([dirs{1} filesep '*.xml']);

%create folders for interleaved Trials and add an xml file (needed for
%linescan importing
for i=1:length(isi)
    mkdir([root filesep 'Sorted Interleaved Trials' filesep 'LineScans ' num2str(isi(i)) 'ms ISI' filesep 'Alexa']);
    mkdir([root filesep 'Sorted Interleaved Trials' filesep 'LineScans ' num2str(isi(i)) 'ms ISI' filesep 'Fluo']);
    copyfile(xmlFile(1).name,[root filesep 'Sorted Interleaved Trials' filesep 'LineScans ' num2str(isi(i)) 'ms ISI']);
end

%Go through each of the folders sort and copy the line scan tiffs
for i=1:length(dirs)
    sortLineScan(rig,dirs{i})
    alexaFiles = subdir([dirs{i} filesep 'Alexa' filesep 'LineScan-*.tif']);
    fluoFiles = subdir([dirs{i} filesep 'Fluo' filesep 'LineScan-*.tif']);
    counter = 1;
    for j = 1:length(fluoFiles)                
        copyfile(alexaFiles(j).name,[root filesep 'Sorted Interleaved Trials' filesep 'LineScans ' num2str(isi(counter)) 'ms ISI' filesep 'Alexa']);
        copyfile(fluoFiles(j).name,[root filesep 'Sorted Interleaved Trials' filesep 'LineScans ' num2str(isi(counter)) 'ms ISI' filesep 'Fluo']);   
        if counter == length(isi)
            counter = 1;
        else
            counter = counter + 1;
        end        
    end    
end

for i=1:length(isi)
    
   scan = lineScan([root filesep 'Sorted Interleaved Trials' filesep 'LineScans ' num2str(isi(i)) 'ms ISI']);
   scan.expParams.spikeTimes(1) = singleDelay;
   scan.expParams.spikeTimes(2) = trainDelay;
   scan.expParams.spikeTimes(3) = trainDelay + isi(i)*.001;
   scan.expParams.spikeTimes(4) = trainDelay + isi(i)*.001*2;
   
   scan.expParams.trainISI = isi(i);
      
   scan.saveLS([root]);
   
end

