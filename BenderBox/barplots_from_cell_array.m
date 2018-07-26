function barplots_from_cell_array(cell_array,y_label, boxon)

if nargin < 3
    boxon = 1;
end


for i=1:length(cell_array(1,:))
    
    nice_barplot(cell2mat(cell_array(4:end,i)),i,cell2mat(cell_array(1,i)),cell2mat(cell_array(2,i)), boxon);
            
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
