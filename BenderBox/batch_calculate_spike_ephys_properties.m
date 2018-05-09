function output = batch_calculate_spike_ephys_properties

cells = dir('*.mat');



for i=1:length(cells)
   try 
   load(cells(i).name);
   [output{i+1,1},...
       output{i+1,2},...
       output{i+1,3},...
       output{i+1,4},...
       output{i+1,5},...
       output{i+1,6}] = calculate_spike_ephys_properties(Cell);
    disp([num2str(i) '/' num2str(length(cells)) ' ' cells(i).name ' processed']);
   catch
       output{i+1,1} = NaN;
       output{i+1,2}= NaN;
       output{i+1,3}= NaN;
       output{i+1,4}= NaN;
       output{i+1,5}= NaN;             
       output{i+1,6}= NaN;
       disp([num2str(i) '/' num2str(length(cells)) ' ' cells(i).name ' Failed']);
   end
   

end