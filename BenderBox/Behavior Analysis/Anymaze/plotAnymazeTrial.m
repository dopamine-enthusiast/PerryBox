function plotAnymazeTrial

directories = uipickfiles('Type',{'*Test*.csv','Anymaze Trial File'});

for i=1:length(directories)
    
    csvdata = csvread(directories{i},1,1);
    figure();
    plot(csvdata(2:end,1),csvdata(2:end,2),'k')
    [~, trialName] = fileparts(directories{i});
    title(trialName);
    xlim([min(csvdata(2:end,1)),max(csvdata(2:end,1))]);
    ylim([min(csvdata(2:end,2)),max(csvdata(2:end,2))]);
    box off;
    set(gca,'xcolor',get(gcf,'color'));
    set(gca,'xtick',[]);
    set(gca,'ycolor',get(gcf,'color'));
    set(gca,'ytick',[]);
    axis square;
    
end

end



