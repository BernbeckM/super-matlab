function load(obj, type)
    file = uigetfile('*.dat', 'MultiSelect', 'on');
    if ~iscell(file), file = {file}; end

    %runTypes = {'ac', 'waveform'};
    %classTypes = {@sp.AC, @sp.Waveform};
    %selector = contains(runTypes, type);

    for a = 1:length(file)
        if contains(file{a}, 'ACvsF')
            obj.datafiles = [obj.datafiles sp.AC(file{a})];
        elseif contains(file{a}, 'Waveform')
            obj.datafiles = [obj.datafiles sp.Waveform(file{a})];
        end
    end
end