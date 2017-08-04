function plotSweepAverage

prompt = {'Start Sweep:','Enter colormap name:'};
dlg_title = 'Pick Sweeps';
num_lines = 1;
defaultans = {'1','10'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

sweepAverage = getSweepAverage(str2num(answer{1}),str2num(answer{2}));

figure();

plot(sweepAverage);
