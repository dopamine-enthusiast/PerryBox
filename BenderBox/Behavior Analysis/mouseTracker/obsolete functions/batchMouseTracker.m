function batchMouseTracker(timeFile)

directories = uipickfiles('Type',{'*.avi','Behavior Recording File'});

if nargin == 1
    load(timeFile);
else
       
    for i=1:length(directories)
        [path name ext] = fileparts(directories{i});
        prompt = ['What is the start time for ' name ': '] ;
        time(i) = input(prompt);
    end
    
end

prompt = ['How many seconds of recording: '] ;
recordTime = input(prompt);

for i=1:length(directories)
    try
        mouseTracker(directories{i},time(i),recordTime)
    end
end

save('starttimes.mat','time')


