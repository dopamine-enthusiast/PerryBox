function scans = updateInterleavedSpikeTimes(scans)

singleDelay = 0.2;
trainDelay = 0.8;

if nargin == 0
   scans = loadLineScans;   
end

for i=1:length(scans)
   isi = scans(i).expParams.trainISI; 
      
   scans(i).expParams.spikeTimes(1) = singleDelay;
   scans(i).expParams.spikeTimes(2) = trainDelay;
   scans(i).expParams.spikeTimes(3) = trainDelay + isi*.001;
   scans(i).expParams.spikeTimes(4) = trainDelay + isi*.001*2;
      
   scans(i).saveLS;
end