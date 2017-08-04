function c=clip2cell
%CLIP2CELL paste Excel data from clipboard to cell array
%   
%   CELL_ARRAY = CLIP2CELL
%  
%   gives same result compared to a manual paste command 'Paste Excel Data'
%   (Ctrl+Shift+V in variable editor)
%   
%Author: Nikolay Bykovsky
%Last update: 09-Jan-2016

str=clipboard('paste');
str(end)=[]; % delete last carrige ('\n' character)
str=strrep(str,',','.'); % fix decimal

str=strsplit(str,'\n','collapsedelimiters',false)';
str=cellfun(@(x) strsplit(x,'\t','collapsedelimiters',false),str,'uniformoutput',false);
mx=cellfun(@length,str);

c=cell(length(str),max(mx));
for k=1:size(c,1)
    c(k,1:mx(k))=str{k};
end
num=str2double(c);
c(~isnan(num))=num2cell(num(~isnan(num)));
c(cellfun(@isempty,c))={[]};