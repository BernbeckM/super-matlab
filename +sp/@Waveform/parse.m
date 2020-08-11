function parse(obj)
    toDelete = (obj.raw.MomentErr ./ obj.raw.Moment) > 0.3;
    obj.raw(toDelete, :) = [];
    
    idxs = sp.DataFile.get_blocks(obj.raw.Time, 30);
    disp(['found ' num2str(length(idxs) - 1) ' datablocks']);
    
    for a = 1:(length(idxs) - 1)
        start = idxs(a);
        stop = idxs(a + 1) - 1;
        waveform = obj.raw(start:stop, :);

        numPoints = height(waveform);
        measureTime = waveform.Time(end) - waveform.Time(1);
        sampleRate = numPoints / measureTime;

        paren = @(x,varargin) x(varargin{:});
        dftm = paren(fft(waveform.Moment, numPoints), 1:numPoints / 2 + 1);
        dftf = paren(fft(waveform.Field, numPoints), 1:numPoints / 2 + 1);

        newSpectrum = array2table(...
            [ ...
            ones(length(dftm) - 1, 1)*round(waveform.Temperature(1)/0.1)*0.1, ...
            ones(length(dftm) - 1, 1).*a, ...
            (sampleRate / numPoints : sampleRate / numPoints : sampleRate / 2)', ...
            dftm(2:end, :), ...
            dftf(2:end, :)], ...
            'VariableNames', obj.WaveformFieldsSpectra);
        
        obj.spectra = [obj.spectra; newSpectrum];

        [m_dftm, i_dftm] = max(abs(newSpectrum.hsDFTM));
        [m_dftf, i_dftf] = max(abs(newSpectrum.hsDFTF));

        phi = angle(newSpectrum.hsDFTF(i_dftf)/newSpectrum.hsDFTM(i_dftm));
        chi = m_dftm / m_dftf / obj.header.Moles;

        if ~(phi < 0)
            newParsed = array2table( ...
                [newSpectrum.TemperatureRounded(1), ...
                newSpectrum.Frequency(i_dftf), ...
                abs(chi*cos(phi)), ...
                abs(chi*sin(phi)), ...
                phi], ...
                'VariableNames', obj.WaveformFieldsParsed);
            obj.data = [obj.data; newParsed];
        end
    end

    obj.data = sortrows(obj.data, {'TemperatureRounded', 'Frequency'});
end