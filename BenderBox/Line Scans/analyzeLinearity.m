function scans = analyzeLinearity(scans)

if nargin == 0
   scans = loadLineScans;   
end

scans = updateInterleavedSpikeTimes(scans);

for i=1:length(scans)       
    GoRLinearity(i) = scans(i).linearity(scans(i).normGoR, scans(i).expParams.spikeTimes);
    scans(i).expParams.GoRLinearity = GoRLinearity(i);    
    isi(i) = scans(i).expParams.trainISI;  
end


GoRLinearity;

figure;
plot(isi,GoRLinearity,'-ok');
set(gca,'YGrid', 'on','GridLineStyle', '-');
set(gca,'XTick',isi)
ylabel('Observed/Expected')
xlabel('ISI (ms)');

