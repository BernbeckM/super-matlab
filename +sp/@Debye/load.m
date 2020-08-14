function load(obj)
    file = uigetfile('*.dat', 'MultiSelect', 'on');
    if ~iscell(file), file = {file}; end

    obj.fits = [];
    obj.model_error = [];
    obj.model_data = [];
    
    for a = 1:length(file)
        if contains(file{a}, 'ACvsF')
            obj.datafiles = [obj.datafiles sp.AC(file{a})];
        elseif contains(file{a}, 'Waveform')
            obj.datafiles = [obj.datafiles sp.Waveform(file{a})];
        end
    end
end