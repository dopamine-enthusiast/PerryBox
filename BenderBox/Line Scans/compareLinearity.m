function compareLinearity

files = uipickfiles;

for i=1:length(files)
    
   try
       
       load(files{i});       
       linearity(i) = obj;
       
   catch
      
       
   end
    
end

cm = hsv(length(linearity));
hold on;
for i=1:length(linearity)
    
   plot(linearity(i).isi,linearity(i).GoRLinearity,'color',cm(i,:));
   legendNames{i} = linearity(i).name;    
end
    
legend(legendNames);