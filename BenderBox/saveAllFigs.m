function saveAllFigs

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');

for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  
  for j = 1:length(FigHandle.Children)
    if ~isempty(FigHandle.Children(j).Title.String)
        FigName = FigHandle.Children(j).Title.String; 
        break;
    else
        FigName = ['figure_' num2str(iFig)];
    end
  end
  savefig(FigHandle, [FigName, '.fig']);
end