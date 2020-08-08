function parseWaveformData(obj, waveformData)
    
    toDelete = (waveformData.Raw.MomentErr ./ waveformData.Raw.Moment) > 0.3;
    waveformData.Raw(toDelete, :) = [];
    
    idxs = obj.findDataBlocks(waveformData, 30);
    disp(['found ' num2str(length(idxs) - 1) ' datablocks']);
    
    for a = 1:(length(idxs) - 1)
        start = idxs(a);
        stop = idxs(a + 1) - 1;
        waveform = waveformData.Raw(start:stop, :);

        numPoints = height(waveform);
        measureTime = waveform.Time(end) - waveform.Time(1);
        sampleRate = numPoints / measureTime;

        paren = @(x,varargin) x(varargin{:});
        dftm = paren(fft(waveform.Moment, numPoints), 1:numPoints / 2 + 1);
        dftf = paren(fft(waveform.Field, numPoints), 1:numPoints / 2 + 1);

        newSpectrum = array2table(...
            [...
            ones(length(dftm) - 1, 1)*round(waveform.Temperature(1)/0.1)*0.1,...
            ones(length(dftm) - 1, 1).*a, ...
            (sampleRate / numPoints : sampleRate / numPoints : sampleRate / 2)', ...
            dftm(2:end, :), ...
            dftf(2:end, :)], ...
            'VariableNames', obj.WaveformFieldsSpectra);
        %figure(a);
        %plot(newSpectrum.Frequency, abs(newSpectrum.hsDFTM));
        
        obj.Spectra = [obj.Spectra; newSpectrum];
        % todo : try using first harmonic and/or phase angle analysis of
        % multiple peaks
        % todo : mess around with lower amplitude pulse
        % todo : try this -4 +8 -8 thing with higher frequencies
        % todo : multifreq drive stuff - where that at?
        [m_dftm, i_dftm] = max(abs(newSpectrum.hsDFTM));
        [m_dftf, i_dftf] = max(abs(newSpectrum.hsDFTF));
        %figure
        %hold on
        %plot(newSpectrum.Frequency, abs(newSpectrum.hsDFTM)./max(abs(newSpectrum.hsDFTM)));
        %plot(newSpectrum.Frequency, abs(newSpectrum.hsDFTF)./max(abs(newSpectrum.hsDFTF)));
        phi = angle(newSpectrum.hsDFTF(i_dftf)/newSpectrum.hsDFTM(i_dftm));
        chi = m_dftm / m_dftf / waveformData.Header.Moles;
        %disp(newSpectrum.Frequency(i_dftf));
        %disp(phi);
        if ~(phi < 0)
            newParsed = array2table(...
                [newSpectrum.TemperatureRounded(1), ...
                newSpectrum.Frequency(i_dftf), ...
                abs(chi*cos(phi)), ...
                abs(chi*sin(phi)), ...
                phi], ...
                'VariableNames', obj.WaveformFieldsParsed);
            obj.Parsed = [obj.Parsed; newParsed];
        end
    end

    obj.Parsed = sortrows(obj.Parsed, {'TemperatureRounded', 'Frequency'});
end