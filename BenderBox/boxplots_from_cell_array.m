function boxplots_from_cell_array(cell_array,y_label)

% colors
% WT
% [0,0,0]
% [0.5,0.5,0.5]
% 
% Het
% [0,0.6824,0.9373]
% [0.6392,0.8784,0.9686]
% 
% dKO
% [0.8863    0.1647    0.4196]
% [0.9490    0.6392    0.7490]

for i=1:length(cell_array(1,:))
    
    nice_boxplot(cell2mat(cell_array(4:end,i)),i,cell2mat(cell_array(1,i)),cell2mat(cell_array(2,i)));
            
end

xticks(1:1:length(cell_array(1,:)));
xticklabels({cell_array{3,:}});
set(gca,'YMinorTick','off','TickLength',[0.02 0.035])
set(gca,'fontsize',16,...
    'TickDir','out',...
    'FontName','arial',...
    'box','off');
ylabel(y_label);


% for i=1:5
%         
%     plot([4 5],[cell2mat(cell_array(3+i,1)) cell2mat(cell_array(3+i,2))],'k');    
%             
% end
