function sweeps = importSweeps(cellName)

root = pwd;

try
    cd('c:\Data\Export\');
    copyfile([cellName '*.ibw'],pwd);
    cd('c:\Data\Default\');
    copyfile([cellName '.ibt'],pwd);
    cd(root);
catch
    cd(root);
end


% First search the current directory
sweeps.commands = IBWread([cellName '_commands.ibw']);
sweeps.DAQ = IBWread([cellName '_DAQ.ibw']);
sweeps.kHz = IBWread([cellName '_kHz.ibw']);
sweeps.rawsweeps = IBWread([cellName '_rawsweeps.ibw']);
sweeps.sweeptimes = IBWread([cellName '_sweeptimes.ibw']);
sweeps.temperature = IBWread([cellName '_temperature.ibw']);

save([cellName ' sweeps.mat'],'-struct', 'sweeps'); 