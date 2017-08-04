function [DS] = load_ibw(fnstr)

%KJB 11/18/2014
%Creates data structure that stores all data for many cells
%
%                   INPUTS
%FNSTR = filename string used to find data. wildcards are helpful (e.g.
%       'burke*' to find all filenames starting with "burke"
%
%                   OUTPUTS
%DS = 1XN data structure containing fields for:
%        -name
%        -data
%        -comm (commands)
%        -temp (temperature)
%        -time
%   ... where N is the number of cells found according to fnstr

DS = struct();
if(nargin<1 || strcmp(fnstr,''))
    fnstr = '*.ibw';
end

% pull out names
FNS = dir(fnstr);
name_arr = {FNS.name};
for i=1:length(name_arr);
    name_arr{i} = name_arr{i}(1:regexp(FNS(i).name,'_')-1);
end
names = intersect(name_arr, name_arr);

% read/load data into MATLAB object using IBWread
filetypes = {'_rawsweeps.ibw' '_commands.ibw' '_temperature.ibw' '_sweeptimes.ibw'};
ds_datatypes = {'data' 'comm' 'temp' 'time'};

for i=1:length(names);                              % for each cell
    DS(i).name = names{i};                          % load name
    for j=1:length(filetypes);                      % load data
       temp = IBWread([names{i} filetypes{j}]);
       DS(i).(ds_datatypes{j}) = temp.y;
    end
end
end