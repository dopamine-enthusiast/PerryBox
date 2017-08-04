function addGroupInformation




files = uipickfiles('FilterSpec','*EPM Trial.mat');


prompt = {'What group are these trials:'};
dlg_title = 'Ruler';
num_lines = 1;
group = char(inputdlg(prompt,dlg_title,num_lines));




for i=1:length(files)
    trial = load(files{i});
    trial.group = group;
    save([trial.name ' EPM Trial.mat'], '-struct', 'trial');
end


